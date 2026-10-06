#!/bin/bash

# Menü seçenekleri
options="Dock Modu: Aç\nDock Modu: Kapat\nSes: Hoparlör\nSes: Kulaklık\nSes: HDMI\nSes: Bluetooth\nBluetooth: Aç\nBluetooth: Kapat\nBluetooth: Cihaz Ara\nEkran: Çift Monitör\nEkran: Laptop Tek\nOverride: Aç (Kafein)\nOverride: Kapat\nGüç: Uykuya Al\nGüç: Kış Uykusu\nGüç: Kapat\nGüç: Yeniden Başlat"

# Rofi'yi çalıştır
chosen=$(echo -e "$options" | rofi -dmenu -p "Sistem Komutu")

# Seçimlere göre aksiyon al
case "$chosen" in
    "Ses: Hoparlör") pactl set-sink-port 0 analog-output-speaker && notify-send -u low "Donanım" "Ses çıkışı hoparlöre yönlendirildi." ;;
    "Ses: Kulaklık") pactl set-sink-port 0 analog-output-headphones && notify-send -u low "Donanım" "Ses çıkışı kulaklığa yönlendirildi." ;;
    "Ses: HDMI") pactl set-default-sink $(pactl list short sinks | grep -i hdmi | awk '{print $1}') && notify-send -u low "Donanım" "Ses HDMI'a yönlendirildi." ;;
    "Ses: Bluetooth") pactl set-default-sink $(pactl list short sinks | grep -i bluez | awk '{print $1}') && notify-send -u low "Donanım" "Ses Bluetooth cihaza yönlendirildi." ;;
    "Bluetooth: Aç") bluetoothctl power on && notify-send -u normal "Ağ" "Bluetooth anteni açıldı." ;;
    "Bluetooth: Kapat") bluetoothctl power off && notify-send -u normal "Ağ" "Bluetooth anteni kapatıldı." ;;
    "Bluetooth: Cihaz Ara") blueman-manager ;;
    "Ekran: Çift Monitör") xrandr --output eDP-1 --auto --output HDMI-2 --auto --above eDP-1 && notify-send -u normal "Görüntü" "Çift monitör düzeni aktif." ;;
    "Ekran: Laptop Tek") xrandr --output eDP-1 --auto --output HDMI-2 --off && notify-send -u normal "Görüntü" "Harici ekran kapatıldı." ;;
    "Güç: Kapat") systemctl poweroff ;;
    "Güç: Yeniden Başlat") systemctl reboot ;;
    "Güç: Uykuya Al") systemctl suspend ;;
    "Güç: Kış Uykusu") systemctl hibernate ;;
    "Dock Modu: Aç") 
        if ! pgrep -f "systemd-inhibit --what=handle-lid-switch"; then
            systemd-inhibit --what=handle-lid-switch --who="Dock Modu" --why="HDMI çıkışı aktif kalmalı" sleep infinity &
            notify-send -u normal "Sistem" "Dock Modu AKTİF: Kapak kapatıldığında uykuya geçilmeyecek."
        fi ;;
    "Dock Modu: Kapat") 
        pkill -f "systemd-inhibit --what=handle-lid-switch"
        notify-send -u normal "Sistem" "Dock Modu KAPALI: Standart uyku kuralları devrede." ;;
    "Override: Aç (Kafein)")
	touch /tmp/skymoon_override
	notify-send -u normal "Güç Yönetimi" "Override AKTİF: Ekran kapanmayacak ve sistem uyumayacak." ;;
    "Override: Kapat")
	rm -f /tmp/skymoon_override
	notify-send -u normal "Güç Yönetimi" "Override KAPALI: Standart güç planı devrede." ;;
esac
