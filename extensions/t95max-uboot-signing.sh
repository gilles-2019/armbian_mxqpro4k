#!/bin/bash

# Fonction qui contient votre logique de signature FIP
function t95max_sign_uboot_fip() {
    # Vérification du contexte pour ne pas polluer d'autres builds
    [[ $BOARD != "sei610" && $BOARD != "t95max" ]] && return

    display_alert "Extension" "Signature FIP pour S905X3..." "info"

    local fip_tools="$EXTER_USERPATCHES/amlogic-boot-fip"
    local raw_uboot="$OBJ/u-boot/u-boot.bin"
    local output_dir="$OBJ/u-boot"

    # Récupération des outils si nécessaire
    if [ ! -d "$fip_tools" ]; then
        git clone --depth=1 https://github.com "$fip_tools"
    fi

    # Exécution de la signature
    cd "$fip_tools"
    ./build-fip.sh sei610 "$raw_uboot" "$output_dir"

    # Création de l'artéfact attendu par Armbian (u-boot.bin.sd.bin)
    cp "$output_dir/u-boot.bin.sd.bin" "$output_dir/u-boot.bin.sd.bin"
    
    # Préparation du chainloader pour la partition /boot
    cp "$output_dir/u-boot.bin.sd.bin" "$SDCARD/u-boot.ext" 2>/dev/null || true

    display_alert "Extension" "Signature terminée : u-boot.bin.sd.bin généré" "success"
}

# ENREGISTREMENT DU HOOK
# Argument 1 : Le point d'ancrage (étape du build)
# Argument 2 : Le nom de votre fonction ci-dessus
add_hook "post_build_uboot" "t95max_sign_uboot_fip"

