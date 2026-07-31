#!/bin/bash
# Duvar kağıdı değiştirme betiği (swww kullanır)

# Duvar kağıtlarının bulunduğu klasör
WALLPAPER_DIR="$HOME/wallpapers"
TRANSITION_TYPE="grow"
TRANSITION_DURATION="1.5"

# Argümana göre işlem yap
if [ "$1" == "random" ]; then
    if [ -d "$WALLPAPER_DIR" ]; then
        # Rastgele bir resim seç
        IMAGE=$(find "$WALLPAPER_DIR" -type f \( -name '*.jpg' -o -name '*.png' -o -name '*.jpeg' \) | shuf -n 1)
    else
        notify-send -u critical "Hata" "Duvar kağıdı klasörü bulunamadı: $WALLPAPER_DIR"
        exit 1
    fi
elif [ -n "$1" ]; then
    IMAGE="$1"
else
    echo "Kullanım: $0 [resim_yolu | random]"
    exit 1
fi

if [ -z "$IMAGE" ] || [ ! -f "$IMAGE" ]; then
    notify-send -u critical "Hata" "Geçerli bir resim bulunamadı."
    exit 1
fi

# swww-daemon çalışıyor mu kontrol et, çalışmıyorsa başlat
if ! pgrep -x swww-daemon > /dev/null; then
    swww-daemon &
    sleep 1
fi

# Duvar kağıdını ayarla
swww img "$IMAGE" --transition-type "$TRANSITION_TYPE" --transition-duration "$TRANSITION_DURATION"

# Bildirim gönder
notify-send -i "$IMAGE" "  Duvar Kağıdı Değiştirildi" "Yeni duvar kağıdı uygulandı."
