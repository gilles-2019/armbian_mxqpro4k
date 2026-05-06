
post_uboot_custom_postprocess__hook_meson_sm1() {
	display_alert "GILLES" "trace dans ${FUNCNAME[0]} *** appel fn de meson_sm1.conf" "info"

	if [[ $BOARD == sei610 ]]; then
		display_alert "GILLES" "trace dans ${FUNCNAME[0]} file meson-sm1.conf" "info"
		uboot_g12_postprocess $SRC/cache/sources/amlogic-boot-fip/sei610 g12a
	fi
}

post_uboot_custom_postprocess_NOTDONE_hook_sign_amlogic_fip() {
    display_alert "GILLES" "trace dans ${FUNCNAME[0]} *** signature du uboot" "info"
    display_alert "sign_amlogic_fip() BOARD_NAME=$BOARD_NAME BOARD=$BOARD" "Amlogic-Secure" "info"
    display_alert "Dumping environment variables to output/env_dump.txt" "DEBUG" "GILLES"
    
    # On trie et on enregistre tout dans un fichier pour ne pas polluer le terminal
    printenv | sort > "${DEST}/env_dump.txt"
    
    # Optionnel : afficher une variable spécifique dans le terminal
    display_alert "Variable DEST actuelle : $DEST" "ENV" "GILLES"
    
    # On cible spécifiquement la SEI610 (S905X3)
    [[ $BOARD_NAME == "sei610" ]] || return 0

    display_alert "Signing FIP after compilation" "Amlogic-Secure" "info"

    # 2. Localiser le binaire compilé
    # À cette étape, Armbian a normalement placé le binaire dans $DEST/uboot ou $UBOOT_OUT_DIR
    local uboot_bin=""
    local search_paths=(
        "$PWD/u-boot.bin"
    )
    display_alert "Signing FIP after compilation" "PWD=$PWD DEST=$DEST" "info"
    for path in "${search_paths[@]}"; do
        if [[ -f "$path" ]]; then uboot_bin="$path"; break; fi
    done

    if [[ -z "$uboot_bin" ]]; then
        display_alert "ERREUR : u-boot.bin introuvable après compilation" "FIP" "err"
        return 0
    fi

    # 3. Préparer les outils de signature
    local fip_tool_dir="${SRC}/cache/sources/amlogic-boot-fip"
    if [[ ! -d "$fip_tool_dir" ]]; then
        display_alert "Téléchargement amlogic-boot-fip..." "FIP" "info"
        git clone --depth=1 https://github.com "$fip_tool_dir"
    fi

    # 4. Signature dans un répertoire temporaire
    local tmp_dir="/tmp/sign_sei610"
    mkdir -p "$tmp_dir"
    
    pushd "$fip_tool_dir" > /dev/null
    # build-fip.sh : board, u-boot-source, output-directory
    ./build-fip.sh sei610 "$uboot_bin" "$tmp_dir"
    popd > /dev/null

    # 5. Déploiement du résultat pour Armbian
    # On écrase le binaire par défaut ou on crée le fichier pour le chainloading
    if [[ -f "$tmp_dir/u-boot.bin.sd.bin" ]]; then
        # On le place dans le dossier final de destination d'Armbian
        mkdir -p "$DEST/uboot"
        cp "$tmp_dir/u-boot.bin.sd.bin" "$DEST/uboot/u-boot.ext"
        
        # Optionnel : Remplacer le binaire BSP par le binaire signé
        cp "$tmp_dir/u-boot.bin.sd.bin" "$DEST/uboot/u-boot.bin"
        
        display_alert "Signature réussie : u-boot.ext généré dans $DEST/uboot/" "FIP" "info"
    else
        display_alert "Échec de la génération du binaire signé" "FIP" "err"
    fi

    return 0
}


function post_family_config_NOTDONE_uboot_aml-s9xx-box() {
	# This board type relies on the vendor installed u-boot on emmc to boot
	display_alert "GILLES" "entre dans ${FUNCNAME[0]} board:${BOARD}" "info"
	display_alert "$BOARD" "Configuring ($BOARD) non-u-boot" "info"
	#unset BOOTSOURCE
	#declare -g BOOTCONFIG='none'
}

function post_family_tweaks_bsp_NOTDONE_config_aml-s9xx-box_bsp() {
	display_alert "GILLES" "entre dans ${FUNCNAME[0]} board:${BOARD}" "info"
	: "${destination:?destination is not set}"

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


