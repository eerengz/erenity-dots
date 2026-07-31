# 🏔️ Glacier Dots

**Arch Linux + Hyprland + NVIDIA Dotfiles**

![Arch Linux](https://img.shields.io/badge/Arch-Linux-1793d1?style=for-the-badge&logo=arch-linux&logoColor=white)
![Hyprland](https://img.shields.io/badge/Hyprland-Window_Manager-00a896?style=for-the-badge&logo=linux)
![NVIDIA](https://img.shields.io/badge/NVIDIA-RTX_3050-76b900?style=for-the-badge&logo=nvidia&logoColor=white)

Catppuccin Mocha temalı, üretkenlik ve estetik odaklı Arch Linux Hyprland yapılandırması. (Özellikle NVIDIA RTX 3050 Laptop için uyarlanmıştır)

## 📸 Önizleme
*(Buraya ekran görüntüleri eklenecek)*

## ✨ Özellikler
- 🎨 **Tema:** Catppuccin Mocha (Karanlık ve pastel, ikonlar için Papirus)
- 🚀 **Pencere Yöneticisi:** Hyprland (Wayland)
- 🖥️ **Terminal:** Kitty + Zsh + Starship
- 📝 **Editör:** Neovim
- 🔍 **Başlatıcı:** Rofi (Wayland fork)
- 📊 **Çubuk:** Waybar
- 💚 **NVIDIA Uyumu:** RTX 3050 Laptop için özel yapılandırmalar (Nvidia-DKMS, modüller, kernel parametreleri)
- 🔗 **Görsellik:** Hyprglass, awww, JetBrains Mono Nerd Font

## 🧩 Bileşenler

| Araç | Açıklama | Konfigürasyon Yolu |
|---|---|---|
| **Hyprland** | Pencere Yöneticisi | `~/.config/hypr/` |
| **Waybar** | Durum Çubuğu | `~/.config/waybar/` |
| **Kitty** | Terminal Emülatörü | `~/.config/kitty/` |
| **Rofi** | Uygulama Başlatıcı | `~/.config/rofi/` |
| **Zsh** | Kabuk (Shell) | `~/.zshrc` |
| **Starship** | Prompt Özelleştirici | `~/.config/starship.toml` |

## 🚀 Hızlı Kurulum

> **Uyarı:** Bu betik sistem yapılandırmalarınızı değiştirecektir. Kullanmadan önce mevcut dosyalarınızı yedekleyin.

```bash
git clone https://github.com/eerengz/glacier-dots.git ~/glacier-dots
cd ~/glacier-dots
chmod +x install.sh
./install.sh
```

## 🛠️ Manuel Kurulum

Eğer betiği kullanmak istemezseniz, adımları manuel olarak uygulayabilirsiniz:

1. Paketleri kurun: `pacman -S - < packages.txt` (Yorum satırlarını sildikten sonra)
2. AUR yardımcısı (paru/yay) ile AUR paketlerini kurun: `paru -S - < aur-packages.txt`
3. `.config` klasörünün içindekileri `~/.config/` dizinine kopyalayın.
4. `.zshrc` dosyasını `~/.zshrc` olarak kopyalayın.
5. NVIDIA sürücüleri için `mkinitcpio.conf` dosyasını düzenleyin ve `mkinitcpio -P` çalıştırın.
6. Servisleri (NetworkManager, bluetooth, tlp vb.) aktif edin.

## ⌨️ Kısayollar

| Kısayol | Eylem |
|---|---|
| `SUPER + Enter` | Terminali Aç (Kitty) |
| `SUPER + Q` | Aktif Pencereyi Kapat |
| `SUPER + M` | Çıkış Menüsü |
| `SUPER + E` | Dosya Yöneticisi (Thunar/Yazi) |
| `SUPER + V` | Pencereyi Float Yap (Dalgalı) |
| `SUPER + Space` | Uygulama Başlatıcı (Rofi) |
| `SUPER + P` | Sözde Düşük Mod (Pseudo) |
| `SUPER + J` | Togglesplit |
| `SUPER + Yön Tuşları` | Pencereler Arası Geçiş |

## 🖼️ Galeri
*(Buraya daha fazla ekran görüntüsü eklenecek)*

## 👏 Teşekkürler (Credits)
- [DynamicGlacier](https://github.com/mavxa/DynamicGlacier)
- [Hyprglass](https://github.com/hyprnux/hyprglass)
- [Catppuccin](https://github.com/catppuccin/catppuccin)

## 📄 Lisans
Bu proje [MIT Lisansı](LICENSE) altında lisanslanmıştır.
