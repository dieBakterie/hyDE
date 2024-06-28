#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC1091

#// set variables

scrDir=$(dirname "$(realpath "$0")")
source "$scrDir/globalcontrol.sh"


#//functions

# Locks the screen depending on player status
fn_hyprlock() {
    if [[ $(playerctl status) == Playing ]]; then
        hyprlock --config "${confDir}/hyprlock/presets/hyprlock_music.conf"
    elif [[ $(playerctl status) == Paused ]]; then
        hyprlock --config "${confDir}/hyprlock/presets/hyprlock_music_paused.conf"
    else
        hyprlock --config "${confDir}/hyprlock/presets/hyprlock_no_music.conf"
    fi
}

# Sets the background image
fn_background() {
    local wallpaper_path
    wallpaper_path=$(swww query | grep -oP '(?<=image: ).*' | head -n 1)

    # Replace lockFile in the configuration files
    background "${confDir}/hypr/hyprlock.conf" "$wallpaper_path"
    for file in "${confDir}/hyprlock/presets"/*; do
        background "$file" "$wallpaper_path"
    done
}

# Function to update the wallpaperpath in the configuration files
background() {
    local file=$1
    local wallpaper_path=$2

    # Use sed to directly edit the file
    sed -i -e "s|^\(\$wallpaper = \).*|\1${wallpaper_path}|" "$file"
    echo -e "\033[0;32m[BACKGROUND]\033[0m ${wallpaper_path} -> ${file}"
}

# Function for mpris
fn_mpris() {
    local thumb
    thumb="${cacheDir}/thumb"
    { playerctl metadata --format '{{title}}   {{artist}}' && mpris_thumb; } || { rm -f "${thumb}.*" && exit 1; }
}

# Generate thumbnail
mpris_thumb() {
    local artUrl
    artUrl=$(playerctl metadata --format '{{mpris:artUrl}}')
    [[ "${artUrl}" = "$(cat "${thumb}.inf")" ]] && return 0

    printf "%s\n" "$artUrl" >"${thumb}.inf"

    curl -so "${thumb}.png" "$artUrl"
    pkill -USR2 hyprlock # updates the mpris thumbnail
}

# Show help message
ask_help() {
    cat << HELP
Usage: $(basename "$0") [options]
Options:
  -h, --help        Show this help message
  -l, --lock        Lock the screen
  -b, --background  Set background
  -t, --thumbnail   Set MPRIS thumbnail
HELP
}

# Main function
main() {
    while getopts ":hlbt" opt; do
        case $opt in
        h) ask_help; exit 0 ;;
        l) fn_hyprlock ;;
        b) fn_background ;;
        t) fn_mpris ;;
        *) echo "Invalid option: -$OPTARG" ; ask_help ; exit 1 ;;
        esac
    done
}

main "$@"
