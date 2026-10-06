#!/bin/bash
# SkyMoon T480 Workstation - Otomatik Kurulum Betiği

echo "🚀 SkyMoon T480 Kurulumu Başlıyor..."

# 0. Dotfiles Klasör Kontrolü (Güvenlik Kilidi)
if [ ! -d "$HOME/dotfiles" ]; then
    echo "❌ HATA: ~/dotfiles klasörü bulunamadı!"
    echo "Lütfen kurulumdan önce repoyu ana dizine klonlayın: git clone <repo_url> ~/dotfiles"
    exit 1
fi

# 1. Çakışan Paketlerin Temizlenmesi
echo "🧹 Çakışan XFCE paketleri temizleniyor..."
sudo apt purge light-locker xfce4-screensaver xfce4-power-manager -y
sudo apt autoremove -y

# 2. Temel Paketlerin Kurulumu
echo "📦 Temel paketler ve araçlar kuruluyor..."
sudo apt update
sudo apt install git i3 i3status rofi polybar dunst thunar nitrogen lxappearance psmisc network-manager-gnome blueman xprintidle brightnessctl i3lock xss-lock flameshot kicad -y

# 3. VS Code Depo Entegrasyonu ve Kurulumu
echo "🧑‍💻 VS Code GPG anahtarları ve reposu ekleniyor..."
sudo apt install wget gpg apt-transport-https -y
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
sudo apt update
sudo apt install code -y
rm -f packages.microsoft.gpg

# 4. Donanım ve Çekirdek (Kernel) Yamaları
echo "⌨️ GRUB Klavye yaması uygulanıyor..."
sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet atkbd.reset=1 i8042.nomux=1 i8042.reset"/g' /etc/default/grub
sudo update-grub

echo "🖱️ Touchpad ayarları (Doğal Kaydırma ve Tıklama) yapılandırılıyor..."
sudo mkdir -p /etc/X11/xorg.conf.d
cat <<EOF | sudo tee /etc/X11/xorg.conf.d/90-touchpad.conf > /dev/null
Section "InputClass"
    Identifier "touchpad"
    MatchIsTouchpad "on"
    Driver "libinput"
    Option "Tapping" "on"
    Option "NaturalScrolling" "true"
EndSection
EOF

# 5. Güç ve Uyku (Systemd) Yamaları (Regex ile Güçlendirildi)
echo "🔋 Kapak (Lid) ve Uyku (Hibernate) ayarları yapılıyor..."
sudo sed -i 's/^#* *HandlePowerKey=.*/HandlePowerKey=ignore/g' /etc/systemd/logind.conf
sudo sed -i 's/^#* *HandleLidSwitch=.*/HandleLidSwitch=suspend/g' /etc/systemd/logind.conf
sudo sed -i 's/^#* *HibernateDelaySec=.*/HibernateDelaySec=30min/g' /etc/systemd/sleep.conf

# 6. Dotfiles Symlink (Köprü) Kurulumu
echo "🔗 Dotfiles sembolik linkleri kuruluyor..."
mkdir -p ~/.config/i3_backup ~/.config/polybar_backup ~/.config/rofi_backup ~/.config/dunst_backup

# Eğer eski klasörler varsa yedekle, sonra linkle
[ -d ~/.config/i3 ] && [ ! -L ~/.config/i3 ] && mv ~/.config/i3/* ~/.config/i3_backup/ 2>/dev/null; rm -rf ~/.config/i3; ln -s ~/dotfiles/i3 ~/.config/i3
[ -d ~/.config/polybar ] && [ ! -L ~/.config/polybar ] && mv ~/.config/polybar/* ~/.config/polybar_backup/ 2>/dev/null; rm -rf ~/.config/polybar; ln -s ~/dotfiles/polybar ~/.config/polybar
[ -d ~/.config/rofi ] && [ ! -L ~/.config/rofi ] && mv ~/.config/rofi/* ~/.config/rofi_backup/ 2>/dev/null; rm -rf ~/.config/rofi; ln -s ~/dotfiles/rofi ~/.config/rofi
[ -d ~/.config/dunst ] && [ ! -L ~/.config/dunst ] && mv ~/.config/dunst/* ~/.config/dunst_backup/ 2>/dev/null; rm -rf ~/.config/dunst; ln -s ~/dotfiles/dunst ~/.config/dunst

# 7. Gömülü Sistem Geliştirme İzinleri ve AppImages Klasörü
echo "🔌 Dialout grubuna yetki veriliyor ve Uygulama klasörleri açılıyor..."
sudo usermod -a -G dialout $USER
mkdir -p ~/Applications
mkdir -p ~/.local/share/applications

echo "✅ KURULUM TAMAMLANDI! Değişikliklerin aktif olması için lütfen sistemi yeniden başlatın (reboot)."
