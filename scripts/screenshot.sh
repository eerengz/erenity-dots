#!/bin/bash
# Ekran görüntüsü alma betiği (hyprshot kullanır)

MODE="${1:-region}"
SAVE_DIR="$HOME/Pictures/Screenshots"

# Klasör yoksa oluştur
mkdir -p "$SAVE_DIR"

case "$MODE" in
    full)
        hyprshot -m output -o "$SAVE_DIR" -f "screenshot_$(date +'%Y-%m-%d_%H-%M-%S').png"
        notify-send -u low "󰹑  Ekran Görüntüsü" "Tüm ekran panoya ve dosyaya kopyalandı."
        ;;
    window)
        hyprshot -m window -o "$SAVE_DIR" -f "screenshot_$(date +'%Y-%m-%d_%H-%M-%S').png"
        notify-send -u low "󰹑  Ekran Görüntüsü" "Pencere panoya ve dosyaya kopyalandı."
        ;;
    region)
        hyprshot -m region -o "$SAVE_DIR" -f "screenshot_$(date +'%Y-%m-%d_%H-%M-%S').png"
        notify-send -u low "󰹑  Ekran Görüntüsü" "Seçili alan panoya ve dosyaya kopyalandı."
        ;;
    *)
        echo "Geçersiz mod. (full, window, region)"
        exit 1
        ;;
esac
