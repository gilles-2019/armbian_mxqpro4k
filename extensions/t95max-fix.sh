function post_family_config() {
    display_alert "T95MAX" "GILLES-USERPATCH  POST-FAMILY-CONFIG" "info"
    if [[ $BOARD == "t95max" ]]; then
        display_alert "T95MAX" "GILLES-USERPATCH Forcing Odroid C4 FIP logic via extension" "info"
        BOOT_FIP_TYPE="odroidc4"
    fi
}
