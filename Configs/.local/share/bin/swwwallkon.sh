#!/usr/bin/env bash
# shellcheck disable=SC1091
# shellcheck disable=SC2154

#// Set variables
scrDir=$(dirname "$(realpath "$0")")
source "${scrDir}/globalcontrol.sh"
scrName="$(basename "$0")"
kmenuPath="$HOME/.local/share/kio/servicemenus"
kmenuDesk="${kmenuPath}/hydewallpaper.desktop"
tgtPath="$(dirname "${hydeThemeDir}")"
get_themes

#// Evaluate options
while getopts "t:w:" opt; do
    case $opt in
    t) theme="$OPTARG" ;;
    w) wallpaper="$OPTARG" ;;
    *) unset theme unset wallpaper ;;
    esac
done

if [[ -n $theme ]]; then
    setTheme=$(select_theme "$theme")
elif [[ -n $wallpaper ]]; then
    setWall=$(validate_wallpaper "$wallpaper")
fi

#// Regenerate desktop
if [ -n "${setTheme}" ] && [ -n "${setWall}" ]; then

    inwallHash="$(set_hash "${setWall}")"
    get_hashmap "${tgtPath}/${setTheme}"
    for hash in "${wallHash[@]}"; do
        if [[ "$hash" == *"${inwallHash}"* ]]; then
            notify-send -a "t2" -i "${thmbDir}/${inwallHash}.sqre" "Error" "Hash matched in ${setTheme}"
            exit 0
        fi
    done

    cp "${setWall}" "${tgtPath}/${setTheme}/wallpapers"
    ln -fs "${tgtPath}/${setTheme}/wallpapers/$(basename "${setWall}")" "${tgtPath}/${setTheme}/wall.set"

    "${scrDir}/themeswitch.sh" -s "${setTheme}"
    notify-send -a "t1" -i "${thmbDir}/${inwallHash}.sqre" "Wallpaper set in ${setTheme}"

else

    echo -e "[Desktop Entry]\nType=Service\nMimeType=image/png;image/jpeg;image/jpg;image/gif\nActions=Menu-Refresh$(printf ";%s" "${thmList[@]}")\nX-KDE-Submenu=Set As Wallpaper...\n\n[Desktop Action Menu-Refresh]\nName=.: Refresh List :.\nExec=${scrName}" >"${kmenuDesk}"
    for i in "${!thmList[@]}"; do
        echo -e "\n[Desktop Action ${thmList[i]}]\nName=${thmList[i]}\nExec=${scrName} -t \"${thmList[i]}\" -w %u" >>"${kmenuDesk}"
    done

fi
