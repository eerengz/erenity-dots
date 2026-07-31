#!/bin/bash
# Güç profili değiştirme betiği (powerprofilesctl kullanır)

PROFILES=("performance" "balanced" "power-saver")
CURRENT_PROFILE=$(powerprofilesctl get)

set_profile() {
    local prof="$1"
    powerprofilesctl set "$prof"
    
    case "$prof" in
        "performance")
            ICON="󰓅"
            ;;
        "balanced")
            ICON="󰾆"
            ;;
        "power-saver")
            ICON="󰌪"
            ;;
    esac
    
    notify-send -h string:x-canonical-private-synchronous:power "Güç Profili" "$ICON  $prof"
}

if [ -n "$1" ]; then
    # Argüman verildiyse ona geç
    if [[ " ${PROFILES[@]} " =~ " ${1} " ]]; then
        set_profile "$1"
    else
        echo "Geçersiz profil: $1. Seçenekler: performance, balanced, power-saver"
        exit 1
    fi
else
    # Argüman yoksa profiller arasında geçiş yap (cycle)
    case "$CURRENT_PROFILE" in
        "performance")
            set_profile "balanced"
            ;;
        "balanced")
            set_profile "power-saver"
            ;;
        "power-saver")
            set_profile "performance"
            ;;
        *)
            set_profile "balanced"
            ;;
    esac
fi
