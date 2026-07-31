#!/bin/bash
# Ses kontrol betiği (pamixer kullanır)

STEP=5
ACTION="$1"

get_volume() {
    pamixer --get-volume
}

is_muted() {
    pamixer --get-mute
}

send_notification() {
    VOL=$(get_volume)
    MUTED=$(is_muted)
    
    if [ "$MUTED" == "true" ]; then
        ICON="󰝟"
        notify-send -h string:x-canonical-private-synchronous:audio "Ses Seviyesi" "$ICON  Sessiz"
    else
        if [ "$VOL" -ge 70 ]; then
            ICON="󰕾"
        elif [ "$VOL" -ge 30 ]; then
            ICON="󰖀"
        else
            ICON="󰕿"
        fi
        notify-send -h string:x-canonical-private-synchronous:audio -h int:value:"$VOL" "Ses Seviyesi" "$ICON  $VOL%"
    fi
}

case "$ACTION" in
    up)
        # Sesi aç, önce mute kaldır
        pamixer -u
        pamixer -i "$STEP"
        send_notification
        ;;
    down)
        # Sesi kıs, önce mute kaldır
        pamixer -u
        pamixer -d "$STEP"
        send_notification
        ;;
    mute)
        # Sesi tamamen kapat veya aç
        pamixer -t
        send_notification
        ;;
    *)
        echo "Kullanım: $0 {up|down|mute}"
        exit 1
        ;;
esac
