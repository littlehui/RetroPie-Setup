#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="splashscreen"
rp_module_desc="Configure Splashscreen"
rp_module_menus="3+"
rp_module_flags="nobin"

function depends_splashscreen() {
    getDepends fbi omxplayer
}

function install_splashscreen() {
    cp "$scriptdir/scriptmodules/$md_type/$md_id/asplashscreen" "/etc/init.d/"
    gitPullOrClone "$md_inst" https://github.com/RetroPie/retropie-splashscreens.git
}

function default_splashscreen() {
    find "$md_inst/retropie2015-blue" -type f >/etc/splashscreen.list
}

function enable_splashscreen() {
    # This command installs the init.d script so it automatically starts on boot
    update-rc.d asplashscreen start 00 S >/dev/null

    # not-so-elegant hack for later re-enabling the splashscreen
    update-rc.d asplashscreen enable >/dev/null
}

function disable_splashscreen() {
    update-rc.d asplashscreen disable >/dev/null
}

function choose_splashscreen() {
    local options=()
    local i=0
    local splashdir
    while read splashdir; do
        splashdir=${splashdir/$md_inst\//}
        options+=("$i" "$splashdir")
        ((i++))
    done < <(find "$md_inst" -mindepth 1 -maxdepth 1 -type d | sort)
    local cmd=(dialog --backtitle "$__backtitle" --menu "Choose splashscreen." 22 76 16)
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        choice=$((choice*2+1))
        splashdir=${options[choice]}
        find "$md_inst/$splashdir" -type f >/etc/splashscreen.list
        printMsgs "dialog" "Splashscreen set to '$splashdir'."
    fi
}


function configure_splashscreen() {
    if [[ ! -d "$md_inst" ]]; then
        rp_callModule splashscreen install
    fi
    local cmd=(dialog --backtitle "$__backtitle" --menu "Choose the desired boot behaviour." 22 86 16)
    local options=(
        1 "Enable custom splashscreen on boot"
        2 "Disable custom splashscreen on boot"
        3 "Choose splashscreen"
    )
    while true; do
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            case $choice in
                1)
                    [[ ! -f /etc/splashscreen.list ]] && rp_CallModule splashscreen default
                    enable_splashscreen
                    printMsgs "dialog" "Enabled custom splashscreen on boot."
                    ;;
                2)
                    disable_splashscreen
                    printMsgs "dialog" "Disabled custom splashscreen on boot."
                    ;;
                3)
                    choose_splashscreen
                    ;;
            esac
        else
            break
        fi
    done
}
