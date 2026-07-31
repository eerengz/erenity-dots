#!/bin/bash
set -e

# Renkler
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logo
echo -e "${BLUE}"
cat << "EOF"
  ____ _            _              ____        _       
 / ___| | __ _  ___(_) ___ _ __   |  _ \ ___ | |_ ___  
| |  _| |/ _` |/ __| |/ _ \ '__|  | | | / _ \| __/ __| 
| |_| | | (_| | (__| |  __/ |     | |_| | (_) | |_\__ \ 
 \____|_|\__,_|\___|_|\___|_|     |____/ \___/ \__|___/ 
                                                       
EOF
echo -e "Arch Linux + Hyprland + NVIDIA Kurulum Betiği\n${NC}"

# Root kontrolü
if [ "$EUID" -eq 0 ]; then
  echo -e "${RED}[Hata] Lütfen betiği root (sudo) olarak çalıştırmayın.${NC}"
  exit 1
fi

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}[1] Sistem Güncelleniyor (Multilib Etkinleştiriliyor)...${NC}"
sudo sed -i '/\[multilib\]/,/Include/ s/^#//' /etc/pacman.conf
sudo pacman -Syu --noconfirm

echo -e "\n${BLUE}[2] Resmi Paketler Kuruluyor...${NC}"
if [ -f "$DOTFILES_DIR/packages.txt" ]; then
    grep -v '^#' "$DOTFILES_DIR/packages.txt" | grep -v '^$' | xargs sudo pacman -S --needed --noconfirm
else
    echo -e "${RED}packages.txt bulunamadı!${NC}"
fi

echo -e "\n${BLUE}[3] Paru (AUR Yardımcısı) Kuruluyor...${NC}"
if ! command -v paru &> /dev/null; then
    echo -e "${YELLOW}Paru bulunamadı, kuruluyor...${NC}"
    git clone https://aur.archlinux.org/paru-bin.git /tmp/paru-bin
    cd /tmp/paru-bin
    makepkg -si --noconfirm
    cd -
    rm -rf /tmp/paru-bin
else
    echo -e "${GREEN}Paru zaten kurulu.${NC}"
fi

echo -e "\n${BLUE}[4] AUR Paketleri Kuruluyor...${NC}"
if [ -f "$DOTFILES_DIR/aur-packages.txt" ]; then
    grep -v '^#' "$DOTFILES_DIR/aur-packages.txt" | grep -v '^$' | paru -S --needed --noconfirm
else
    echo -e "${RED}aur-packages.txt bulunamadı!${NC}"
fi

echo -e "\n${BLUE}[5] Varsayılan Kabuk (Shell) Zsh Olarak Ayarlanıyor...${NC}"
if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s $(which zsh)
    echo -e "${GREEN}Varsayılan kabuk zsh olarak değiştirildi. (Oturumu kapatıp açmanız gerekebilir)${NC}"
fi

echo -e "\n${BLUE}[6] Klasörler Oluşturuluyor...${NC}"
mkdir -p ~/wallpapers
mkdir -p ~/Pictures/Screenshots
mkdir -p ~/.local/bin

echo -e "\n${BLUE}[7] Yapılandırma Dosyaları (Dotfiles) Kopyalanıyor...${NC}"
# .config kopyala
if [ -d "$DOTFILES_DIR/.config" ]; then
    cp -r "$DOTFILES_DIR/.config/"* ~/.config/
    echo -e "${GREEN}.config dosyaları kopyalandı.${NC}"
fi

# zshrc
if [ -f "$DOTFILES_DIR/.zshrc" ]; then
    cp "$DOTFILES_DIR/.zshrc" ~/.zshrc
    echo -e "${GREEN}.zshrc kopyalandı.${NC}"
fi

# scripts
if [ -d "$DOTFILES_DIR/scripts" ]; then
    cp -r "$DOTFILES_DIR/scripts/"* ~/.local/bin/
    chmod +x ~/.local/bin/*
    echo -e "${GREEN}Betikler ~/.local/bin/ dizinine kopyalandı ve çalıştırılabilir yapıldı.${NC}"
fi

# wallpapers
if [ -d "$DOTFILES_DIR/wallpapers" ]; then
    cp -r "$DOTFILES_DIR/wallpapers/"* ~/wallpapers/
    echo -e "${GREEN}Duvar kağıtları kopyalandı.${NC}"
fi

echo -e "\n${BLUE}[8] NVIDIA Kurulumu (mkinitcpio)...${NC}"
read -p "NVIDIA modüllerini /etc/mkinitcpio.conf dosyasına eklemek istiyor musunuz? (e/h): " nv_ans
if [ "$nv_ans" == "e" ]; then
    sudo sed -i 's/MODULES=(.*)/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/g' /etc/mkinitcpio.conf
    sudo mkinitcpio -P
    echo -e "${YELLOW}Kernel parametrelerinize 'nvidia_drm.modeset=1' eklemeyi unutmayın (örn: grub kullanıyorsanız /etc/default/grub).${NC}"
fi

echo -e "\n${BLUE}[9] Servisler Etkinleştiriliyor...${NC}"
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth
sudo systemctl enable --now tlp

echo -e "\n${BLUE}[10] Hyprglass Kurulumu (hyprpm)...${NC}"
echo -e "${YELLOW}Hyprland eklenti yöneticisi (hyprpm) ile hyprglass kuruluyor...${NC}"
hyprpm update
if hyprpm add https://github.com/hyprnux/hyprglass; then
    hyprpm enable hyprglass
    echo -e "${GREEN}Hyprglass başarıyla kuruldu ve etkinleştirildi.${NC}"
else
    echo -e "${RED}Hyprglass kurulamadı veya uyumsuz.${NC}"
fi

echo -e "\n${GREEN}=== KURULUM TAMAMLANDI ===${NC}"
echo -e "${YELLOW}Değişikliklerin tamamen uygulanması için sisteminizi yeniden başlatmanız önerilir.${NC}"
