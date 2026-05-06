
post_config_uboot_target__sign_amlogic_fip() {
    display_alert "sign_amlogic_fip() BOARD_NAME=$BOARD_NAME BOARD=$BOARD" "Amlogic-Secure" "info"
    # On cible spécifiquement la SEI610 (S905X3)
    [[ $BOARD_NAME == "sei610" ]] || return 0

    display_alert "Signing FIP for SEI610 (U-Boot v2026.04)" "Amlogic-Secure" "info"

    # 1. Localisation dynamique du binaire (v2026.04 utilise souvent un build-dir séparé)
    local uboot_bin=""
    for path in "${UBOOT_OUT_DIR}/u-boot.bin" "./u-boot.bin" "../u-boot.bin"; do
        if [[ -f "$path" ]]; then uboot_bin="$(realpath "$path")"; break; fi
    done

    if [[ -z "$uboot_bin" ]]; then
        display_alert "ERREUR : u-boot.bin non trouvé pour v2026.04" "FIP" "err"
        return 0
    fi

    # 2. Gestion de l'outil de signature (Repository LibreELEC amlogic-boot-fip)
    # Cet outil est indispensable car Amlogic ne fournit pas les sources des BL2/BL30
    local fip_tool_dir="${SRC}/cache/sources/amlogic-boot-fip"
    if [ ! -d "$fip_tool_dir" ]; then
        display_alert "Clonage des sources FIP (v2026.04 compatible)..." "FIP" "info"
        git clone --depth=1 https://github.com "$fip_tool_dir"
    fi

    # 3. Signature spécifique pour SEI610
    local output_tmp="/tmp/sei610_fip_out"
    mkdir -p "$output_tmp"
    
    pushd "$fip_tool_dir" > /dev/null
    # La commande standard pour SEI610 assemble BL2 + BL30 + BL31 + votre U-Boot (BL33)
    ./build-fip.sh sei610 "$uboot_bin" "$output_tmp"
    popd > /dev/null

    # 4. Déploiement pour Armbian (Chainloading)
    # On place le résultat dans le dossier destination de l'image
    mkdir -p "$DEST/uboot"
    if [ -f "$output_tmp/u-boot.bin.sd.bin" ]; then
        # On le nomme u-boot.ext car c'est le fichier cherché par le bootloader eMMC
        cp "$output_tmp/u-boot.bin.sd.bin" "$DEST/uboot/u-boot.ext"
        display_alert "Succès : Binaire signé pour v2026.04 disponible dans output/debug/uboot/u-boot.ext" "FIP" "info"
    fi

    return 0
}
