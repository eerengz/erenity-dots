#!/bin/bash
set -e

# Renkler
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logo
echo -e "${BLUE}"
cat << "EOF"
  ____ _            _              ____        _       
 / ___| | __ _  ___(_) ___ _ __   |  _ \ ___ | |_ ___  
| |  _| |/ _` |/ __| |/ _ \ '__|  | | | / _ \| __/ __| 
| |_| | | (_| | (__| |  __/ |     | |_| | (_) | |\__ \ 
 \____|_|\__,_|\___|_|\___|_|     |____/ \___/ \__|___/ 
                                                        
EOF
echo -e "Arch Linux + Hyprland + NVIDIA Kurulum Betiği\n${NC}"

# Root kontrolü — Bu script NORMAL KULLANICI olarak çalışmalıdır
if [ "$EUID" -eq 0 ]; then
  echo -e "${RED}[Hata] Lütfen betiği root (sudo) olarak çalıştırmayın. Normal kullanıcı olarak çalıştırın.${NC}"
  exit 1
fi

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}[1] Sistem Güncelleniyor (Multilib Etkinleştiriliyor)...${NC}"
# Multilib deposunu etkinleştir (lib32-nvidia-utils için gerekli)
sudo sed -i '/\[multilib\]/,/Include/ s/^#//' /etc/pacman.conf
sudo pacman -Syu --noconfirm

echo -e "\n${BLUE}[2] Resmi Paketler Kuruluyor...${NC}"
if [ -f "$DOTFILES_DIR/packages.txt" ]; then
    grep -v '^#' "$DOTFILES_DIR/packages.txt" | grep -v '^$' | xargs sudo pacman -S --needed --noconfirm
else
    echo -e "${RED}packages.txt bulunamadı!${NC}"
    exit 1
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
    # Yorum satırlarını ve boş satırları atla
    grep -v '^#' "$DOTFILES_DIR/aur-packages.txt" | grep -v '^$' | paru -S --needed --noconfirm
else
    echo -e "${RED}aur-packages.txt bulunamadı!${NC}"
    exit 1
fi

echo -e "\n${BLUE}[5] Varsayılan Kabuk (Shell) Zsh Olarak Ayarlanıyor...${NC}"
if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s "$(which zsh)"
    echo -e "${GREEN}Varsayılan kabuk zsh olarak değiştirildi. (Oturumu kapatıp açmanız gerekebilir)${NC}"
else
    echo -e "${GREEN}Zsh zaten varsayılan kabuk.${NC}"
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
    chmod +x ~/.local/bin/*.sh 2>/dev/null || true
    echo -e "${GREEN}Betikler ~/.local/bin/ dizinine kopyalandı ve çalıştırılabilir yapıldı.${NC}"
fi

# wallpapers
if [ -d "$DOTFILES_DIR/wallpapers" ]; then
    cp -r "$DOTFILES_DIR/wallpapers/"* ~/wallpapers/
    echo -e "${GREEN}Duvar kağıtları kopyalandı.${NC}"
fi

echo -e "\n${BLUE}[8] NVIDIA Kurulumu (mkinitcpio)...${NC}"
# NVIDIA env değişkenleri zaten ~/.config/hypr/env.conf'a kopyalandı.
# Kullanıcı istemedikçe initramfs modüllerini ekleriz.
read -p "NVIDIA modüllerini /etc/mkinitcpio.conf dosyasına eklemek istiyor musunuz? (e/h): " nv_ans
if [[ "$nv_ans" == "e" || "$nv_ans" == "E" ]]; then
    sudo sed -i 's/^MODULES=.*/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
    # kms hook kontrolü
    if ! grep -q '\bkms\b' /etc/mkinitcpio.conf; then
        sudo sed -i 's/\(^HOOKS=.*\)kms/\1/' /etc/mkinitcpio.conf || true
        echo -e "${YELLOW}Not: HOOKS satırında 'kms' bulunamadı. Mevcut varsayılan genellikle yeterlidir.${NC}"
    fi
    sudo mkinitcpio -P
    echo -e "${YELLOW}Kernel parametrelerinizde 'nvidia-drm.modeset=1' olduğunu doğrulayın (/etc/default/grub).${NC}"
else
    echo -e "${YELLOW}NVIDIA modülleri eklenmedi. env.conf'taki NVIDIA ortam değişkenleri Hyprland'ı başlatmayı deneyecek; sorun yaşarsanız bu adımı elle çalıştırın.${NC}"
    # NVIDIA env.conf'u yorum satırına al
    if [ -f ~/.config/hypr/env.conf ]; then
        sed -i 's/^env = LIBVA_DRIVER_NAME,nvidia/# env = LIBVA_DRIVER_NAME,nvidia/' ~/.config/hypr/env.conf
        sed -i 's/^env = GBM_BACKEND,nvidia-drm/# env = GBM_BACKEND,nvidia-drm/' ~/.config/hypr/env.conf
        sed -i 's/^env = __GLX_VENDOR_LIBRARY_NAME,nvidia/# env = __GLX_VENDOR_LIBRARY_NAME,nvidia/' ~/.config/hypr/env.conf
        sed -i 's/^env = NVD_BACKEND,direct/# env = NVD_BACKEND,direct/' ~/.config/hypr/env.conf
        echo -e "${YELLOW}NVIDIA'ya özgü env değişkenleri env.conf'ta devre dışı bırakıldı.${NC}"
    fi
fi

echo -e "\n${BLUE}[9] Servisler Etkinleştiriliyor...${NC}"
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth
sudo systemctl enable --now tlp

echo -e "\n${YELLOW}============================================================${NC}"
echo -e "${YELLOW}[10] Hyprglass Plugin Kurulumu — DİKKAT${NC}"
echo -e "${YELLOW}============================================================${NC}"
echo -e "${RED}hyprpm yalnızca çalışan bir Hyprland oturumu içinde çalışır!${NC}"
echo -e "${CYAN}İLK HYPRLAND GİRİŞİNİZDEN SONRA bir terminalde şunu çalıştırın:${NC}"
echo -e ""
echo -e "  ${GREEN}hyprpm update${NC}"
echo -e "  ${GREEN}hyprpm add https://github.com/hyprnux/hyprglass${NC}"
echo -e "  ${GREEN}hyprpm enable hyprglass${NC}"
echo -e ""
echo -e "${YELLOW}============================================================${NC}"

echo -e "\n${GREEN}=== KURULUM TAMAMLANDI ===${NC}"
echo -e "${RED}⚠️  GÜVENLİK UYARISI: Şifrenizi ilk girişten hemen sonra değiştirin: passwd${NC}"
echo -e "${YELLOW}Değişikliklerin tamamen uygulanması için sisteminizi yeniden başlatmanız önerilir.${NC}"
