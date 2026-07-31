#!/bin/bash
# Parlaklık kontrol betiği (brightnessctl kullanır)

STEP="5%"
ACTION="$1"

get_brightness_percent() {
    MAX=$(brightnessctl m)
    CUR=$(brightnessctl g)
    echo $((CUR * 100 / MAX))
}

send_notification() {
    PERC=$(get_brightness_percent)
    
    if [ "$PERC" -ge 80 ]; then
        ICON="󰃠"
    elif [ "$PERC" -ge 40 ]; then
        ICON="󰃝"
    else
        ICON="󰃞"
    fi
    
    notify-send -h string:x-canonical-private-synchronous:brightness -h int:value:"$PERC" "Parlaklık Seviyesi" "$ICON  $PERC%"
}

case "$ACTION" in
    up)
        brightnessctl set "+$STEP"
        send_notification
        ;;
    down)
        brightnessctl set "$STEP-"
        send_notification
        ;;
    *)
        echo "Kullanım: $0 {up|down}"
        exit 1
        ;;
esac
