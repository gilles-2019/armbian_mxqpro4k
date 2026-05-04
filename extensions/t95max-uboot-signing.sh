#!/bin/bash

# Fonction qui contient votre logique de signature FIP
function t95max_sign_uboot_fip() {
    display_alert "Extension" "FN Signature FIP." "info"
    # Vérification du contexte pour ne pas polluer d'autres builds
    [[ $BOARD != "sei610" && $BOARD != "t95max" ]] && return

    display_alert "Extension" "Signature FIP pour S905X3..." "info"

    local fip_tools="./userpatches/amlogic-boot-fip"
    local raw_uboot="$OBJ/u-boot/u-boot.bin"
    local output_dir="$OBJ/u-boot"
 
     display_alert "Extension" "repertoire OBJ=<$OBJ> UBOOT_OUT=<$UBOOT_OUT> DEST=<$DEST>" "info"
     
    # Récupération des outils si nécessaire
    if [ ! -d "$fip_tools" ]; then
        git clone --depth=1 https://github.com/LibreELEC/amlogic-boot-fip "$fip_tools"
    fi

    # DEBUG : Vérifier si le fichier existe vraiment avant de lancer la signature
    if [ ! -f "$raw_uboot" ]; then
        echo "ERREUR : Le fichier source $raw_uboot est introuvable !" >&2
        # On tente de le localiser si $OBJ est mal défini
        raw_uboot=$(find "$DEST" -name "u-boot.bin" | head -n 1)
        echo "Tentative de secours, trouvé ici : $raw_uboot" >&2
    fi

    # 2. Exécution de la signature
    cd "$fip_tools" || exit
    
    # On passe le chemin sans guillemets problématiques
    ./build-fip.sh sei610 "$raw_uboot" "$output_dir"
    
    # Préparation du chainloader pour la partition /boot
    display_alert "Extension" "Préparation du chainloader...$output_dir/u-boot.bin.sd.bin VERS $SDCARD/u-boot.ext " "info"
    cp "$output_dir/u-boot.bin.sd.bin" "$SDCARD/u-boot.ext" 2>/dev/null || true

    display_alert "Extension" "Signature terminée : u-boot.bin.sd.bin généré" "success"
}

# ENREGISTREMENT DU HOOK
# Argument 1 : Le point d'ancrage (étape du build)
# Argument 2 : Le nom de votre fonction ci-dessus
display_alert "Extension" "ENREGISTREMENT DU HOOK" "info"
# À la fin de votre script .sh
if  type add_hook >/dev/null 2>&1; then
    display_alert "Extension" "ADD HOOK" "info"
    add_hook "post_build_uboot" "t95max_sign_uboot_fip"
else
    # Si add_hook n'est pas là, on définit la fonction standard en secours
     display_alert "Extension" "ADD HOOK fonction standard en secours" "info"
    function uboot_custom_postprocess { t95max_sign_uboot_fip; }
fi

