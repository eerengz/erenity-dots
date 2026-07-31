#!/usr/bin/env bash
# ==============================================================================
# 🏔️ GLACIER ARCH AUTOMATED INSTALLER (NVIDIA RTX 3050 Laptop)
# ==============================================================================
set -e

# Renk tanımları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}"
cat << "EOF"
  ██████╗ ██╗      █████╗  ██████╗██╗███████╗██████╗ 
 ██╔════╝ ██║     ██╔══██╗██╔════╝██║██╔════╝██╔══██╗
 ██║  ███╗██║     ███████║██║     ██║█████╗  ██████╔╝
 ██║   ██║██║     ██╔══██║██║     ██║██╔══╝  ██╔══██╗
 ╚██████╔╝███████╗██║  ██║╚██████╗██║███████╗██║  ██║
  ╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝╚═╝╚══════╝╚═╝  ╚═╝
  Arch Linux + Hyprland + NVIDIA RTX 3050 Auto-Installer
EOF
echo -e "${NC}"

if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}HATA: Bu scripti root yetkisiyle (Arch Live ISO içinde) çalıştırmalısınız!${NC}"
  exit 1
fi

DISK="/dev/nvme0n1"
EFI_PART="${DISK}p1"
SWAP_PART="${DISK}p5"
ROOT_PART="${DISK}p6"
USERNAME="ero"
HOSTNAME="glacier"

echo -e "${YELLOW}Varsayılan Otomatik Kurulum Ayarları:${NC}"
echo -e "  • Hedef Disk       : ${CYAN}${DISK}${NC}"
echo -e "  • EFI Bölümü       : ${CYAN}${EFI_PART}${NC} (Mevcut Windows EFI)"
echo -e "  • Yeni Swap        : ${CYAN}${SWAP_PART}${NC} (8 GB)"
echo -e "  • Yeni Root        : ${CYAN}${ROOT_PART}${NC} (Kalan ~41 GB)"
echo -e "  • Kullanıcı Adı    : ${CYAN}${USERNAME}${NC}"
echo -e "  • Kullanıcı Şifresi: ${CYAN}1234${NC} (Sonradan 'passwd' ile değiştirebilirsiniz)"
echo -e "  • Root Şifresi     : ${CYAN}1234${NC}"
echo ""

read -p "Kuruluma başlansın mı? (e/h): " CONFIRM
if [[ "$CONFIRM" != "e" && "$CONFIRM" != "E" ]]; then
    echo -e "${RED}Kurulum iptal edildi.${NC}"
    exit 0
fi

echo -e "\n${BLUE}[1/8] İnternet Bağlantısı ve Saat Ayarlanıyor...${NC}"
loadkeys trq || true
timedatectl set-ntp true

echo -e "\n${BLUE}[2/8] Disk Otomatik Bölümlendiriliyor (${DISK})...${NC}"
# Eski p5 ve p6 varsa kaldır
sgdisk -d 5 "$DISK" 2>/dev/null || true
sgdisk -d 6 "$DISK" 2>/dev/null || true
partprobe "$DISK" || true

# 8GB Swap (p5) ve Kalan Alan Root (p6) oluştur
sgdisk -n 5:0:+8G -t 5:8200 -c 5:"Linux swap" "$DISK"
sgdisk -n 6:0:0   -t 6:8300 -c 6:"Linux root" "$DISK"
partprobe "$DISK"
sleep 2

echo -e "\n${BLUE}[3/8] Bölümler Biçimlendiriliyor...${NC}"
mkswap -F "$SWAP_PART"
swapon "$SWAP_PART"

mkfs.ext4 -F "$ROOT_PART"

echo -e "\n${BLUE}[4/8] Diskler /mnt Dizinine Bağlanıyor...${NC}"
mount "$ROOT_PART" /mnt
mount --mkdir "$EFI_PART" /mnt/boot

echo -e "\n${BLUE}[5/8] Arch Linux ve NVIDIA Paketleri Yükleniyor...${NC}"
pacstrap -K /mnt \
  base linux linux-firmware linux-headers base-devel \
  git nano networkmanager sudo pipewire pipewire-pulse wireplumber \
  nvidia-dkms nvidia-utils lib32-nvidia-utils egl-wayland \
  grub efibootmgr os-prober ntfs-3g tlp brightnessctl

echo -e "\n${BLUE}[6/8] Fstab Oluşturuluyor...${NC}"
genfstab -U /mnt >> /mnt/etc/fstab

echo -e "\n${BLUE}[7/8] Sistem Yapılandırılıyor (Chroot)...${NC}"

arch-chroot /mnt /bin/bash <<EOF
set -e

# Saat Dilimi & Saat
ln -sf /usr/share/zoneinfo/Europe/Istanbul /etc/localtime
hwclock --systohc

# Dil ve Klavye
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "tr_TR.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=trq" > /etc/vconsole.conf

# Hostname
echo "${HOSTNAME}" > /etc/hostname

# Root Şifresi
echo "root:1234" | chpasswd

# Kullanıcı Oluşturma ve Sudo Yetkisi
useradd -m -G wheel -s /bin/bash ${USERNAME}
echo "${USERNAME}:1234" | chpasswd
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers

# NVIDIA Kernel Modülleri (/etc/mkinitcpio.conf)
sed -i 's/MODULES=(.*)/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/g' /etc/mkinitcpio.conf
mkinitcpio -P

# GRUB & Dual-Boot (Windows 11/10 Otomatik Algılama)
echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet nvidia-drm.modeset=1 nvidia-drm.fbdev=1"/g' /etc/default/grub

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Servisleri Aktifleştir
systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable tlp

# Glacier Dots Reposunu Kopyala
cd /home/${USERNAME}
git clone https://github.com/eerengz/glacier-dots.git glacier-dots
chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/glacier-dots

EOF

echo -e "\n${BLUE}[8/8] Kurulum Tamamlandı!${NC}"
echo -e "${GREEN}================================================================${NC}"
echo -e "${GREEN} ARCH LINUX BAŞARIYLA KURULDU! ${NC}"
echo -e "${GREEN}================================================================${NC}"
echo -e "${YELLOW}Kullanıcı Adı : ${CYAN}${USERNAME}${NC}"
echo -e "${YELLOW}Şifre         : ${CYAN}1234${NC}"
echo -e ""
echo -e "${CYAN}Şimdi yapılacaklar:${NC}"
echo -e " 1. ${YELLOW}reboot${NC} yazıp USB belleği çıkarın."
echo -e " 2. Sistem açılınca '${USERNAME}' kullanıcısı ve '1234' şifresiyle giriş yapın."
echo -e " 3. Şu komutu çalıştırıp Hyprland ve tüm dotfiles'ı otomatik kurun:"
echo -e "    ${GREEN}cd ~/glacier-dots && ./install.sh${NC}"
echo -e "${GREEN}================================================================${NC}"
