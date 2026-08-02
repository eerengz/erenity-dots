#!/usr/bin/env bash
# ==============================================================================
# 🌸 ERENITY ARCH AUTOMATED INSTALLER (NVIDIA RTX 3050 Laptop)
# ==============================================================================
# ⚠️  DİKKAT: Bu script YALNIZCA yazarın kendi donanım/bölüm düzeni için
# tasarlanmıştır. Farklı bir makinede kullanmadan önce aşağıdaki değişkenleri
# MUTLAKA güncelleyin:
#   DISK, EFI_PART, SWAP_PART, ROOT_PART
# Yanlış disk seçimi VERİ KAYBINA yol açar. Önce bir VM'de test edin!
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
  _____                    _ _         
 |  ___| __ ___ _ __   ___| | |_ _   _ 
 | |_  | '__/ _ \ '_ \ / _ \ | __| | | |
 |  _| | | |  __/ | | |  __/ | |_| |_| |
 |_|   |_|  \___|_| |_|\___|_|\__|\__, |
                                   |___/ 
  Arch Linux + Hyprland + NVIDIA RTX 3050 Auto-Installer
EOF
echo -e "${NC}"

if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}HATA: Bu scripti root yetkisiyle (Arch Live ISO içinde) çalıştırmalısınız!${NC}"
  exit 1
fi

# ==============================================================================
# BÖLÜM DEĞİŞKENLERİ — Kendi diskinize göre düzenleyin
# ==============================================================================
DISK="/dev/nvme0n1"
EFI_PART="${DISK}p1"   # Windows EFI bölümü — p1 olduğu doğrulanacak
SWAP_PART="${DISK}p5"  # Oluşturulacak swap bölümü (8 GB)
ROOT_PART="${DISK}p6"  # Oluşturulacak root bölümü (kalan alan)
USERNAME="ero"
HOSTNAME="erenity"
# ==============================================================================

# --- Mevcut disk düzenini göster ---
echo -e "${YELLOW}⚠️  Mevcut disk düzeni (lsblk):${NC}"
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT "$DISK" || lsblk
echo ""

# --- Şifre sor ---
echo -e "${YELLOW}Kullanıcı ve root şifresi belirleyin (boş bırakırsanız '1234' kullanılır):${NC}"
read -s -p "Şifre: " USER_PASSWORD
echo ""
if [ -z "$USER_PASSWORD" ]; then
    USER_PASSWORD="1234"
    echo -e "${RED}⚠️  Uyarı: Varsayılan şifre '1234' kullanılacak. İlk girişten sonra 'passwd' ile değiştirin!${NC}"
fi

# --- EFI bölümünü doğrula ---
echo -e "\n${BLUE}EFI bölümü doğrulanıyor: ${EFI_PART}...${NC}"
EFI_TYPE=$(sgdisk -i 1 "$DISK" 2>/dev/null | grep "Partition GUID code" | grep -i "C12A7328" || true)
if [ -z "$EFI_TYPE" ]; then
    echo -e "${RED}HATA: ${EFI_PART} bir EFI System Partition (ef00) değil!${NC}"
    echo -e "${RED}Script durduruluyor. Lütfen EFI_PART değişkenini düzeltin.${NC}"
    echo -e "${YELLOW}Disk bölümlerini görmek için: sgdisk -p ${DISK}${NC}"
    exit 1
fi
echo -e "${GREEN}✓ EFI bölümü doğrulandı.${NC}"

# --- Silinecek bölümleri göster ve onay al ---
echo -e "\n${RED}⚠️  UYARI: Aşağıdaki bölümler SİLİNECEK ve YENİDEN OLUŞTURULACAK:${NC}"
echo -e "  • ${DISK}p5 → 8 GB Linux Swap (YENİ OLUŞTURULACAK)"
echo -e "  • ${DISK}p6 → Kalan alan (~41 GB) Linux Root (YENİ OLUŞTURULACAK)"
echo -e ""
echo -e "${YELLOW}Mevcut bölüm bilgileri:${NC}"
sgdisk -p "$DISK" 2>/dev/null || true
echo ""
echo -e "${RED}Bu işlem geri ALINAMAZ! Devam etmek istiyor musunuz?${NC}"
read -p "Kuruluma başlansın mı? (EVET yazın): " CONFIRM
if [ "$CONFIRM" != "EVET" ]; then
    echo -e "${RED}Kurulum iptal edildi.${NC}"
    exit 0
fi

echo -e "\n${BLUE}[1/8] İnternet Bağlantısı ve Saat Ayarlanıyor...${NC}"
loadkeys trq || true
timedatectl set-ntp true

echo -e "\n${BLUE}[1.5/8] Multilib Deposu (32-bit Desteği) Etkinleştiriliyor...${NC}"
# lib32-nvidia-utils için multilib zorunlu
sed -i '/\[multilib\]/,/Include/ s/^#//' /etc/pacman.conf
pacman -Sy --noconfirm

echo -e "\n${BLUE}[2/8] Disk Otomatik Bölümlendiriliyor (${DISK})...${NC}"
# Aktif swap ve mount'ları temizle
swapoff -a 2>/dev/null || true
umount -R /mnt 2>/dev/null || true

# Eski p5 ve p6 varsa kaldır
sgdisk -d 5 "$DISK" 2>/dev/null || true
sgdisk -d 6 "$DISK" 2>/dev/null || true
partprobe "$DISK" || true
udevadm settle || true

# 8GB Swap (p5) ve Kalan Alan Root (p6) oluştur
sgdisk -n 5:0:+8G  -t 5:8200 -c 5:"Linux swap" "$DISK"
sgdisk -n 6:0:0    -t 6:8300 -c 6:"Linux root"  "$DISK"
partprobe "$DISK" || true
udevadm settle || true
sleep 5

echo -e "\n${BLUE}[3/8] Bölümler Biçimlendiriliyor...${NC}"
mkswap -f "$SWAP_PART"
swapon "$SWAP_PART"
mkfs.ext4 -F "$ROOT_PART"

echo -e "\n${BLUE}[4/8] Diskler /mnt Dizinine Bağlanıyor...${NC}"
mount "$ROOT_PART" /mnt
mkdir -p /mnt/boot/efi
mount "$EFI_PART" /mnt/boot/efi

echo -e "\n${BLUE}[5/8] Arch Linux ve NVIDIA Paketleri Yükleniyor...${NC}"
pacstrap -K /mnt \
  base linux linux-firmware linux-headers base-devel \
  git nano networkmanager sudo pipewire pipewire-pulse wireplumber \
  bluez bluez-utils \
  nvidia-dkms nvidia-utils lib32-nvidia-utils egl-wayland \
  grub efibootmgr os-prober ntfs-3g tlp brightnessctl zsh

echo -e "\n${BLUE}[5.5/8] DNS Yapılandırması Chroot'a Kopyalanıyor...${NC}"
cp /etc/resolv.conf /mnt/etc/resolv.conf

echo -e "\n${BLUE}[6/8] Fstab Oluşturuluyor...${NC}"
genfstab -U /mnt >> /mnt/etc/fstab

echo -e "\n${BLUE}[7/8] Sistem Yapılandırılıyor (Chroot)...${NC}"

arch-chroot /mnt /bin/bash <<EOF
set -e

# Multilib deposunu kurulan sistemde de aktifleştir
sed -i '/\[multilib\]/,/Include/ s/^#//' /etc/pacman.conf

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
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 ${HOSTNAME}.localdomain ${HOSTNAME}" >> /etc/hosts

# Şifreler
echo "root:${USER_PASSWORD}" | chpasswd

# Kullanıcı Oluşturma — shell doğrudan zsh olarak ayarlanıyor
useradd -m -G wheel -s /usr/bin/zsh ${USERNAME}
echo "${USERNAME}:${USER_PASSWORD}" | chpasswd

# Sudo Yetkisi
mkdir -p /etc/sudoers.d
echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/wheel
chmod 440 /etc/sudoers.d/wheel

# NVIDIA Kernel Modülleri
sed -i 's/^MODULES=.*/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf

# kms hook kontrolü (NVIDIA ile çakışmaması için kaldır)
sed -i 's/ kms / /g' /etc/mkinitcpio.conf 2>/dev/null || true

mkinitcpio -P

# GRUB & Dual-Boot
if ! grep -q "GRUB_DISABLE_OS_PROBER" /etc/default/grub; then
    echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
else
    sed -i 's/GRUB_DISABLE_OS_PROBER=.*/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
fi

sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet nvidia-drm.modeset=1 nvidia-drm.fbdev=1"/' /etc/default/grub

grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Servisleri Aktifleştir
systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable tlp

# Erenity Dotfiles Reposunu Kopyala
cd /home/${USERNAME}
if git clone https://github.com/eerengz/erenity-dots.git erenity-dots; then
    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/erenity-dots
    echo "erenity-dots başarıyla klonlandı."
else
    echo "⚠️  UYARI: erenity-dots klonlanamadı. İnternet bağlantısını kontrol edin."
    echo "Sistem kurulumu tamamlandı, dotfiles'ı daha sonra şu komutla alabilirsiniz:"
    echo "  git clone https://github.com/eerengz/erenity-dots.git ~/erenity-dots"
fi

EOF

echo -e "\n${GREEN}================================================================${NC}"
echo -e "${GREEN} ARCH LINUX BAŞARIYLA KURULDU! ${NC}"
echo -e "${GREEN}================================================================${NC}"
echo -e "${YELLOW}Kullanıcı Adı : ${CYAN}${USERNAME}${NC}"
echo -e "${RED}⚠️  İLK GİRİŞTEN SONRA HEMEN ŞİFRENİZİ DEĞİŞTİRİN: passwd${NC}"
echo -e ""
echo -e "${CYAN}Şimdi yapılacaklar:${NC}"
echo -e " 1. ${YELLOW}reboot${NC} yazıp USB belleği çıkarın."
echo -e " 2. GRUB ekranından 'Arch Linux' seçin."
echo -e " 3. '${USERNAME}' kullanıcısı ve belirlediğiniz şifreyle giriş yapın."
echo -e " 4. Hyprland ve tüm dotfiles'ı kurmak için:"
echo -e "    ${GREEN}cd ~/erenity-dots && chmod +x install.sh && ./install.sh${NC}"
echo -e " 5. Hyprland'e ilk girişten SONRA bir terminalde hyprglass'ı kurun:"
echo -e "    ${GREEN}hyprpm update && hyprpm add https://github.com/hyprnux/hyprglass && hyprpm enable hyprglass${NC}"
echo -e "${GREEN}================================================================${NC}"
