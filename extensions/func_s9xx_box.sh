
post_uboot_custom_postprocess_NOTDONE_hook_meson_sm1() {
	display_alert "GILLES" "trace dans ${FUNCNAME[0]} *** appel fn SIGNATURE BOARD=$BOARD" "info"

	if [[ $BOARD == "sei610" || true ]]; then
		display_alert "GILLES" "trace dans ${FUNCNAME[0]} file meson-sm1.conf" "info"
		uboot_g12_postprocess $SRC/cache/sources/amlogic-boot-fip/sei610 g12a
	fi
}



function post_family_config_NOTDONE_uboot_aml-s9xx-box() {
	# This board type relies on the vendor installed u-boot on emmc to boot
	display_alert "GILLES" "entre dans ${FUNCNAME[0]} board:${BOARD}" "info"
	display_alert "$BOARD" "${FUNCNAME[0]} UNSET UBOOT BOOTSOURCE" "info"
	unset BOOTSOURCE
	declare -g BOOTCONFIG='none'
}

function  post_family_tweaks_bsp_NOTDONE_config_aml-s9xx-box_bsp() {
	display_alert "GILLES" "entre dans ${FUNCNAME[0]} board:${BOARD}" "info"
	: "${destination:?destination is not set}"
	display_alert "GILLES" "dans ${FUNCNAME[0]} destination=${destination}" "info"
	
	# Important: this board has board-specific bsp-cli files in config/optional/boards/aml-s9xx-box/_packages/bsp-cli
	#            that path is hashed by the bsp-cli hashing function automatically
	display_alert "${BOARD}" "Adjusting perms of bsp-cli files for ${BOARD} in /root" "info"
	run_host_command_logged chmod -v 744 "${destination}"/root/install-aml.sh
	run_host_command_logged chmod -v 644 "${destination}"/root/fstab.template

	display_alert "${BOARD}" "Removing armbian-install" "info"
	run_host_command_logged rm -v "${destination}"/usr/bin/armbian-install

	display_alert "${BOARD}" "Adding bsp-cli preinst logic" "info"
	# Inline function! So this function is automatically hashed when this hook is hashed.
	function aml-s9xx-box-bsp-cli-preinst() {
		display_alert "GILLES" "entre dans ${FUNCNAME[0]} board:${BOARD}" "info"
		#update of the board bsp-cli package fails because the filesystem type is
		#fat and dpkg tries to create a hard link for the existing files as backup
		#so rm the files instead in a preinst step
		[ -f /boot/aml_autoscript ] && rm /boot/aml_autoscript
		[ -f /boot/emmc_autoscript ] && rm /boot/emmc_autoscript
		[ -f /boot/s905_autoscript ] && rm /boot/s905_autoscript
		[ -f /boot/u-boot-s905 ] && rm /boot/u-boot-s905
		[ -f /boot/u-boot-s905x-s912 ] && rm /boot/u-boot-s905x-s912
		[ -f /boot/u-boot-s905x2-s922 ] && rm /boot/u-boot-s905x2-s922
		[ -f /boot/u-boot-s905x3 ] && rm /boot/u-boot-s905x3
		[ -f /boot/u-boot-s905x3-ugoosx3 ] && rm /boot/u-boot-s905x3-ugoosx3
		[ -f /boot/extlinux/extlinux.conf.template ] && rm /boot/extlinux/extlinux.conf.template
		[ -f /boot/build-u-boot/readme.txt ] && rm /boot/build-u-boot/readme.txt
		[ -f /boot/build-u-boot/u-boot-s905x-s912.patch ] && rm /boot/build-u-boot/u-boot-s905x-s912.patch
		[ -f /boot/build-u-boot/u-boot-s905x2-s922.patch ] && rm /boot/build-u-boot/u-boot-s905x2-s922.patch
		[ -f /boot/build-u-boot/u-boot-s905x3.patch ] && rm /boot/build-u-boot/u-boot-s905x3.patch
		[ -f /boot/build-u-boot/u-boot-s905x3-ugoos-x3.patch ] && rm /boot/build-u-boot/u-boot-s905x3-ugoos-x3.patch
		return 0 # short-circuits above, avoid errors
	}
	preinst_functions+=('aml-s9xx-box-bsp-cli-preinst')
	if false; then aml-s9xx-box-bsp-cli-preinst; fi # so shellcheck stops complaining the function is unused. sorry
}


user_config__hook_trace_debug()
{
	display_alert "GILLES" "trace dans ${FUNCNAME[0]}" "info"
}
post_family_config__hook_trace_debug()
{
	display_alert "GILLES" "trace dans ${FUNCNAME[0]}" "info"
}
extension_prepare_config__hook_trace_debug()
{
	display_alert "GILLES" "trace dans ${FUNCNAME[0]}" "info"
}
post_family_tweaks_bsp__hook_trace_debug()
{
	display_alert "GILLES" "trace dans ${FUNCNAME[0]}" "info"
}
pre_install_kernel_debs__hook_trace_debug()
{
	display_alert "GILLES" "trace dans ${FUNCNAME[0]}" "info"
}
post_install_kernel_debs__hook_trace_debug()
{
	display_alert "GILLES" "trace dans ${FUNCNAME[0]}" "info"
}
post_aggregate_packages__hook_trace_debug()
{
	display_alert "GILLES" "trace dans ${FUNCNAME[0]}" "info"
}
pre_customize_image__hook_trace_debug()
{
	display_alert "GILLES" "trace dans ${FUNCNAME[0]}" "info"
}
post_customize_image__hook_trace_debug()
{
	display_alert "GILLES" "trace dans ${FUNCNAME[0]}" "info"
}
post_post_debootstrap_tweaks__hook_trace_debug()
{
	display_alert "GILLES" "trace dans ${FUNCNAME[0]}" "info"
}
run_after_build__hook_trace_debug()
{
	display_alert "GILLES" "trace dans ${FUNCNAME[0]}" "info"
}
build_custom_uboot__hook_trace_debug()
{
	display_alert "GILLES" "trace dans ${FUNCNAME[0]}" "info"
} 
fetch_custom_uboot__hook_trace_debug()
{
	display_alert "GILLES" "trace dans ${FUNCNAME[0]}" "info"
}
post_config_uboot_target__hook_trace_debug()
{
	display_alert "GILLES" "trace dans ${FUNCNAME[0]}" "info"
}
post_uboot_custom_postprocess__hook_trace_debug()
{
	display_alert "GILLES" "trace dans ${FUNCNAME[0]}" "info"
}
pre_config_uboot_target__hook_trace_debug()
{
	display_alert "GILLES" "trace dans ${FUNCNAME[0]}" "info"
}
pre_package_uboot_image__hook_trace_debug()
{
	display_alert "GILLES" "trace dans ${FUNCNAME[0]}" "info"
}
uboot_make_config__hook_trace_debug()
{
	display_alert "GILLES" "trace dans ${FUNCNAME[0]}" "info"
}

user_config__list_all_armbian_hooks_avail() {
    display_alert "GILLES" "trace dans ${FUNCNAME[0]}" "info"
    display_alert "Scanning Armbian Core for available hook methods..." "Hook-Trace" "info"

    # 1. Rechercher tous les appels à call_extension_method dans le code source
    # On extrait le premier argument de la fonction qui correspond au nom du hook
    local core_dir="${SRC}/lib"
    local hooks=$(grep -r "call_extension_method" "$core_dir" | \
                  sed -n "s/.*call_extension_method ['\"]\([^'\"]*\)['\"].*/\1/p" | \
                  sort | uniq)

    echo -e "\e[32m------------------------------------------------------------\e[0m"
    echo -e "\e[1mListe des hooks détectés dans cette version d'Armbian :\e[0m"
    echo -e "\e[32m------------------------------------------------------------\e[0m"

    for hook in $hooks; do
        # On cherche dans quel fichier ce hook est défini pour donner du contexte
        local file_origin=$(grep -l "call_extension_method [\"']$hook[\"']" -r "$core_dir" | head -n 1 | xargs basename)
        printf "  \e[33m%-35s\e[0m (Appelé dans : %s)\n" "$hook" "$file_origin"
    done

    echo -e "\e[32m------------------------------------------------------------\e[0m"
    echo -e "Usage : Créez une fonction 'nom_du_hook__votre_nom' pour l'utiliser."
    
    # On s'arrête ici si vous voulez juste voir la liste (optionnel)
    # exit 0 
}


