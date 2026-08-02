# 🌸 Erenity Dots

**Arch Linux + Hyprland + NVIDIA Dotfiles**

![Arch Linux](https://img.shields.io/badge/Arch-Linux-1793d1?style=for-the-badge&logo=arch-linux&logoColor=white)
![Hyprland](https://img.shields.io/badge/Hyprland-Window_Manager-00a896?style=for-the-badge&logo=linux)
![NVIDIA](https://img.shields.io/badge/NVIDIA-RTX_3050-76b900?style=for-the-badge&logo=nvidia&logoColor=white)

Catppuccin Mocha temalı, üretkenlik ve estetik odaklı Arch Linux Hyprland yapılandırması. (Özellikle NVIDIA RTX 3050 Laptop için uyarlanmıştır)

> [!WARNING]
> `auto-install.sh` betiği **yalnızca yazarın kendi donanım/bölüm düzeni** için tasarlanmıştır (`/dev/nvme0n1`, EFI: `p1`, Swap: `p5`, Root: `p6`). Farklı bir makinede kullanmadan önce `DISK`, `EFI_PART`, `SWAP_PART`, `ROOT_PART` değişkenlerini **mutlaka** düzenleyin. Yanlış disk seçimi **veri kaybına** yol açar.

## 📸 Önizleme
*(Buraya ekran görüntüleri eklenecek)*

## ✨ Özellikler
- 🎨 **Tema:** Catppuccin Mocha (Karanlık ve pastel, ikonlar için Papirus)
- 🚀 **Pencere Yöneticisi:** Hyprland (Wayland)
- 🖥️ **Terminal:** Kitty + Zsh + Starship
- 📝 **Editör:** Neovim
- 🔍 **Başlatıcı:** Rofi (Wayland)
- 📊 **Çubuk:** Waybar (batarya, parlaklık, güç modülleri dahil)
- 💚 **NVIDIA Uyumu:** RTX 3050 Laptop için özel yapılandırmalar (nvidia-dkms, modüller, kernel parametreleri)
- 🔗 **Görsellik:** Hyprglass (liquid glass), swww (wallpaper), JetBrains Mono Nerd Font
- 💡 **DynamicGlacier:** Opsiyonel — elle kurulum gerekir (aur-packages.txt açıklamalarına bakın)

## 🧩 Bileşenler

| Araç | Açıklama | Konfigürasyon Yolu |
|---|---|---|
| **Hyprland** | Pencere Yöneticisi | `~/.config/hypr/` |
| **Waybar** | Durum Çubuğu | `~/.config/waybar/` |
| **Kitty** | Terminal Emülatörü | `~/.config/kitty/` |
| **Rofi** | Uygulama Başlatıcı | `~/.config/rofi/` |
| **Zsh** | Kabuk (Shell) | `~/.zshrc` |
| **Starship** | Prompt Özelleştirici | `~/.config/starship.toml` |
| **swww** | Wallpaper Daemon (AUR: swww-git) | `scripts/wallpaper-switcher.sh` |
| **wlogout** | Güç/Çıkış Menüsü | Waybar power butonu |
| **Hyprglass** | Liquid Glass efekti (hyprpm ile) | `~/.config/hypr/plugins.conf` |

## 🚀 Sıfırdan Kurulum (Arch Live ISO → Dotfiles)

### 1. Otomatik Arch Kurulumu (Live ISO içinde)
```bash
curl -sL https://raw.githubusercontent.com/eerengz/erenity-dots/master/auto-install.sh | bash
```
> Reboot sonrası kullanıcıyla oturum açın.

### 2. Dotfiles Kurulumu (Yüklü sistemde)
```bash
cd ~/erenity-dots
chmod +x install.sh
./install.sh
```

### 3. Hyprglass Plugin (Hyprland oturumu açıkken)
```bash
hyprpm update
hyprpm add https://github.com/hyprnux/hyprglass
hyprpm enable hyprglass
```

## 🛠️ Manuel Kurulum

1. Paketleri kurun: `grep -v '^#' packages.txt | xargs sudo pacman -S --needed`
2. AUR yardımcısıyla AUR paketleri: `grep -v '^#' aur-packages.txt | paru -S --needed`
3. `.config` klasörünü `~/.config/` dizinine kopyalayın.
4. `.zshrc` dosyasını `~/.zshrc` olarak kopyalayın.
5. NVIDIA için `mkinitcpio.conf` düzenleyin ve `mkinitcpio -P` çalıştırın.
6. Servisleri aktif edin: `systemctl enable --now NetworkManager bluetooth tlp`

## ⌨️ Kısayollar

| Kısayol | Eylem |
|---|---|
| `SUPER + Enter` | Terminal (Kitty) |
| `SUPER + Q` | Aktif Pencereyi Kapat |
| `SUPER + M` | Güç/Çıkış Menüsü (wlogout) |
| `SUPER + SHIFT + M` | Hyprland'i Anında Kapat (onaysız!) |
| `SUPER + D` | Uygulama Başlatıcı (Rofi) |
| `SUPER + E` | Dosya Yöneticisi (Thunar) |
| `SUPER + V` | Pencereyi Float Yap |
| `SUPER + F` | Tam Ekran |
| `SUPER + L` | Ekranı Kilitle (hyprlock) |
| `SUPER + N` | Bildirim Merkezi (SwayNC) |
| `SUPER + P` | Pseudo Mod (Dwindle) |
| `SUPER + J` | Togglesplit |
| `SUPER + Yön Tuşları / HJKL` | Pencereler Arası Geçiş |
| `SUPER + 1-0` | Çalışma Alanı Değiştir |
| `SUPER + SHIFT + 1-0` | Pencereyi Çalışma Alanına Taşı |
| `Print` | Ekran Görüntüsü (Ekran) |
| `SUPER + Print` | Ekran Görüntüsü (Pencere) |
| `SHIFT + Print` | Ekran Görüntüsü (Bölge seç) |
| `Fn + Parlaklık Tuşları` | Ekran Parlaklığı |
| `Fn + Ses Tuşları` | Ses Kontrolü |

## 🖼️ Galeri
*(Buraya daha fazla ekran görüntüsü eklenecek)*

## 👏 Teşekkürler (Credits)
- [DynamicGlacier](https://github.com/mavxa/DynamicGlacier) — Opsiyonel widget, elle kurulum gerekir
- [Hyprglass](https://github.com/hyprnux/hyprglass) — Liquid glass Hyprland plugin
- [swww](https://github.com/LGFae/swww) — Wallpaper daemon (AUR: swww-git)
- [Catppuccin](https://github.com/catppuccin/catppuccin) — Renk paleti

## 📄 Lisans
Bu proje [MIT Lisansı](LICENSE) altında lisanslanmıştır.
