installation script yazılacak
sudo apt install i3 i3status rofi polybar dunst thunar nitrogen lxappearance -y
sudo apt install psmisc -y (killall komutu için)
sudo apt install network-manager-gnome blueman -y (wifi ve bluetooth görsel arayüz polybarda)
sudo apt install xprintidle brightnessctl -y
sudo apt install kicad -y

-klavye fix (?)
sudo nano /etc/default/grub
GRUB_CMDLINE_LINUX_DEFAULT="quiet atkbd.reset=1 i8042.nomux=1 i8042.reset"
sudo update-grub

-touchpad config
sudo mkdir -p /etc/X11/xorg.conf.d
sudo nano /etc/X11/xorg.conf.d/90-touchpad.conf
Section "InputClass"
    Identifier "touchpad"
    MatchIsTouchpad "on"
    Driver "libinput"
    Option "Tapping" "on"
    Option "NaturalScrolling" "true"
EndSection

-klavye fix 2
sudo apt purge light-locker xfce4-screensaver -y
sudo apt install i3lock xss-lock -y
# Sistem uykuya daldığında ekranı mat siyah (#111111) renk ile kilitle
exec --no-startup-id xss-lock --transfer-sleep-lock -- i3lock -n -c 111111

-lid ve power button (?)
sudo nano /etc/systemd/logind.conf
HandlePowerKey=ignore
HandleLidSwitch=suspend

-lid ve power buttonun çalışması için 
killall xfce4-power-manager

-hibernate delay
sudo nano /etc/systemd/sleep.conf
[Sleep]
HibernateDelaySec=30min

-vs code auto update
# Gerekli indirme araçlarını kur
sudo apt install wget gpg apt-transport-https -y

# Microsoft GPG anahtarını indir ve sisteme kaydet
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg

# VS Code deposunu sistem kaynaklarına ekle
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

# Listeyi güncelle ve VS Code'u kur
sudo apt update
sudo apt install code -y

# İndirdiğimiz geçici anahtar dosyasını sil
rm -f packages.microsoft.gpg

-gömülü sistem yetki
sudo usermod -a -G dialout $USER
(sonrasında reboot gerekiyor)

-Kalan uygulamaların kurulumu (appimage)
appimage dosyalarını ~/Applications klasörüne atıyoruz
chmod +x ile executable hale getiriyoruz
sonra da rofi'ın uygulama olarak görebilmesi için .desktop kodlarını hazırlıyoruz

-arduino ide .desktop
nano ~/.local/share/applications/arduino-ide.desktop
[Desktop Entry]
Name=Arduino IDE
Comment=Gömülü Sistemler ve ESP32 Geliştirme
Exec=/home/skymoon/Applications/arduino-ide.AppImage
Icon=arduino
Terminal=false
Type=Application
Categories=Development;IDE;

-bambu studio .desktop
nano ~/.local/share/applications/bambu-studio.desktop
[Desktop Entry]
Name=Bambu Studio
Comment=Bambu Lab X1C 3D Dilimleyici
Exec=/home/skymoon/Applications/BambuStudio_ubu22.AppImage
Icon=3d-printer
Terminal=false
Type=Application
Categories=Utility;Graphics;3DGraphics;


-Kalan uygulamaların kurulumu (deb)
sudo apt install ./uygulama_adi.deb
(değpendencies ile birlikte kurulum için)

-fullscreen video oynatırken 10 dakika sonra i3lock aktifleşme hatası fix
i3 config dosyasında aşağıdaki execlerine altına koy:
# X11 yerleşik ekran koruyucusunu ve DPMS'i tamamen kapat
exec --no-startup-id xset s off -dpms

--Eklenecekler:
xfce rice da gelecek

picom kullanmıyoruz

güç gösterim scripti var

flameshot

rofi scriptlerimizi övelim

dunst bildirimlerimiz de var onları da övek

powerdaemon öv

Power Override modu eklendi

.config ile dotfiles klasörü arasında symlink kurduk 
makrolar:
super x firefox
super z rofi sistem menüsü





# SkyMoon T480 Workstation - Kurulum ve Konfigürasyon Rehberi

Bu depo, Lenovo ThinkPad T480 üzerinde koşan, "Brutalist" tasarıma ve yüksek verimliliğe odaklanmış Debian + i3wm sisteminin yapılandırma dosyalarını (dotfiles) ve sistem yamalarını içerir.

## 🛠 Temel Mimari
* **Donanım:** Lenovo ThinkPad T480 (Çift Batarya)
* **İşletim Sistemi:** Debian
* **Pencere Yöneticisi:** i3-wm (XFCE yedekli/fallback)
* **Durum Çubuğu:** Polybar
* **Uygulama ve Komuta Merkezi:** Rofi
* **Bildirim Yöneticisi:** Dunst

---

## ⚙️ Sistem Yamaları ve Çözülen Sorunlar

### 1. Klavye Uyanma (Focus Loss) Sorunu
* **Sorun:** Uykudan uyanınca X11 odağı kaybediyor, klavye basmıyordu.
* **Çözüm:** XFCE'nin sorunlu `light-locker` ve `xfce4-screensaver` paketleri sistemden purge edildi. Saf i3 mimarisine geçilerek `i3lock` ve `xss-lock` kuruldu.
* **Panik Kısayolu:** Odağın takılması ihtimaline karşı `Super + F12` ile anında `workspace next; workspace prev` yapan bir i3 kısayolu eklendi.

### 2. i3wm Brutalist Ricing
* **Görünüm:** Pencere kenarlıkları 2 piksel kırmızı/mat siyah olarak ayarlandı.
* **Boşluklar (Gaps):** `i3-gaps` ile pencereler arası 8 piksel, dış çerçevede 2 piksel boşluk bırakıldı.
* **Saydamlık ve Gölge:** `picom` kullanılarak inaktif pencerelere %90 matlık ve gölge efekti eklendi (Terminallerin okunabilirliği için aktif pencereler %100 opak bırakıldı).

---

## 🔋 Güç Yönetimi ve Otomasyon (SkyMoon Power Daemon)

Sistem, şarj durumuna göre iki farklı güç profilini dinamik olarak yöneten özel bir Bash scriptine (`power_daemon.sh`) sahiptir. Ayrıca PulseAudio dinlenerek medya (ses/video) oynatılırken sistemin uyuması engellenir.

* **Workstation Modu (Adaptör Takılı):**
  * 5. Dakika: Ekran parlaklığı %40'a düşer.
  * 15. Dakika: `i3lock` ile ekran kilitlenir.
  * 30. Dakika: `suspend-then-hibernate` tetiklenir.
* **Tactical Mod (Batarya):**
  * 5. Dakika: Ekran parlaklığı %15'e düşer.
  * 10. Dakika: `i3lock` ile ekran kilitlenir.
  * 20. Dakika: `suspend-then-hibernate` tetiklenir.
* **Kış Uykusu (Hibernate) Gecikmesi:** `/etc/systemd/sleep.conf` üzerinden `HibernateDelaySec=30min` olarak ayarlanmıştır.

---

## 🎛️ Özel Modüller ve Kontrol Merkezi

### 1. T480 Çift Batarya (Sensor Fusion)
Standart `acpi` modülü çift bataryayı yanlış hesapladığı için `battery.sh` yazıldı. BAT0 ve BAT1'in donanımsal `energy_now` (μWh) verileri toplanıp anlık güç tüketimine bölünerek kesin ve tek bir yüzde/kalan saat verisi Polybar'a yansıtıldı.

### 2. Rofi Komuta Merkezi (`Super + Z`)
Özel yazılan `rofi_menu.sh` ile Rofi bir sistem paneline dönüştürüldü.
* **Ses Yönlendirme:** Hoparlör, Kulaklık, HDMI ve Bluetooth kulaklık arası anında geçiş.
* **Ekran Yönetimi:** Laptop ekranı ve `HDMI-2` çift monitör geçişleri.
* **Dock Modu:** `systemd-inhibit` kullanılarak kapak kapatıldığında cihazın uyuması engellendi (HDMI açıkken kapak kapatıp çalışmaya devam etmek için).
* **Bluetooth ve Güç:** Arayüz (`blueman-manager`) çağırma ve sistem güç kontrolleri.
