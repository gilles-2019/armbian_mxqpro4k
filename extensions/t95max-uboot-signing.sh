#!/bin/bash

: << 'COMMENTAIRE'
# Fonction qui contient votre logique de signature FIP
function t95max_sign_uboot_fip() {
    display_alert "FnFipSign" "FN Signature FIP." "info"
    # Vérification du contexte pour ne pas polluer d'autres builds
    [[ $BOARD != "sei610" && $BOARD != "t95max" ]] && return

    display_alert "FnFipSign" "Signature FIP pour S905X3..." "info"
    export OBJ="$SRC/cache/sources/u-boot-worktree"
    local fip_tools="./userpatches/amlogic-boot-fip"
    local raw_uboot="$OBJ/u-boot/v2024.07/u-boot.bin"
    local output_dir="$OBJ/u-boot/v2024.07"
 
    display_alert "FnFipSign" "repertoire OBJ=<$OBJ> UBOOT_OUT=<$UBOOT_OUT> SRC=<$SRC> DEST=<$DEST>" "info"
     
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
    display_alert "FnFipSign" "chainloader...$output_dir/u-boot.bin.sd.bin VERS $SDCARD/u-boot.ext " "info"
    cp "$output_dir/u-boot.bin.sd.bin" "$SDCARD/u-boot.ext" 2>/dev/null || true

    display_alert "FnFipSign" "Signature terminée : u-boot.bin.sd.bin généré" "success"
}
COMMENTAIRE


function post_build_uboot() {
    # On ne cible que la board sei610 (chipset SM1 / S905X3)
    display_alert "FnFipSign" "FN Signature FIP." "info"
    [[ $BOARD != "sei610" ]] && return

    display_alert "S905X3" "Début de la signature FIP pour chainloader" "info"
    display_alert "FnFipSign" "repertoire  SRC=<$SRC> DEST=<$DEST> " "info"
    # 1. Définition des chemins
    local uboot_dir="$(pwd)"
# cache/sources/amlogic-boot-fip/sei610
    local fip_src="$SRC/userpatches/amlogic-boot-fip" # Dossier où vous avez cloné les blobs
    local board_fip="$fip_src/sei610"
    local output_bin="$DEST/u-boot.ext"
    
    display_alert "FnFipSign" "local var  uboot_dir=<$SRC> " "info"
    display_alert "FnFipSign" "local var  fip_src=<$SRC> " "info"
    display_alert "FnFipSign" "local var  board_fip=<$SRC> " "info"
    display_alert "FnFipSign" "local var  output_bin=<$SRC> " "info"

    # 2. Vérification de la présence des outils et blobs
    if [ ! -d "$board_fip" ]; then
        display_alert "S905X3" "Blobs introuvables dans $board_fip" "error"
        display_alert "Astuce" "git clone https://github.com $fip_src" "info"
        return 1
    fi

    # 3. Préparation de l'espace de travail temporaire
    local tmp_dir="/tmp/fip_sign"
    mkdir -p "$tmp_dir"
    cp "$board_fip"/* "$tmp_dir/"
    cp "$uboot_dir/u-boot.bin" "$tmp_dir/bl33.bin"

    display_alert "S905X3" "Assemblage des composants FIP..." "info"
    pushd "$tmp_dir" > /dev/null

    # 4. Logique de signature spécifique au S905X3 (SM1)
    # L'outil fip_create assemble les blobs sécurisés et le u-boot mainline (bl33)
    ./fip_create \
        --bl30  bl30.bin \
        --bl301 bl301.bin \
        --bl31  bl31.bin \
        --bl33  bl33.bin \
        u-boot.bin.fip

    # 5. Injection du header spécifique pour boot SD/eMMC
    # Cette étape rend le binaire exécutable par le premier bootloader
    cat bl2.bin u-boot.bin.fip > "$output_bin"

    popd > /dev/null

    # 6. Nettoyage et confirmation
    if [ -f "$output_bin" ]; then
        display_alert "S905X3" "Signature réussie : $output_bin" "success"
        # Nettoyage
        rm -rf "$tmp_dir"
    else
        display_alert "S905X3" "Échec de la signature" "error"
        return 1
    fi
}

: << 'COMMENTAIRE'
# ENREGISTREMENT DU HOOK
# Argument 1 : Le point d'ancrage (étape du build)
# Argument 2 : Le nom de votre fonction ci-dessus
display_alert "FnFipSign" "ENREGISTREMENT DU HOOK" "info"
# À la fin de votre script .sh
if  type add_hook >/dev/null 2>&1; then
    display_alert "FnFipSign" "ADD HOOK" "info"
    add_hook "post_build_uboot" "t95max_sign_uboot_fip"
else
    # Si add_hook n'est pas là, on définit la fonction standard en secours
    display_alert "FnFipSign" "ADD HOOK fonction standard en secours" "info"
    function uboot_custom_postprocess { t95max_sign_uboot_fip; }
fi
COMMENTAIRE

