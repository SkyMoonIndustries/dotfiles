#!/bin/bash

# --- BAŞLANGIÇ DEĞERLERİ ---
total_now=0
total_full=0
total_power=0
status="Unknown"


# --- T480 ÇİFT BATARYA DÖNGÜSÜ (BAT0 / BAT1) ---
# ThinkPad T480'deki dahili ve harici piller üzerinde sırayla döner
for bat in /sys/class/power_supply/BAT*; do
    [ -d "$bat" ] || continue
    
    # Kernel sürücüsüne göre enerji (μWh) veya yük (μAh) metriklerini oku
    if [ -f "$bat/energy_now" ]; then
        now=$(cat "$bat/energy_now")
        full=$(cat "$bat/energy_full")
        power=$(cat "$bat/power_now")
    elif [ -f "$bat/charge_now" ]; then
        now=$(cat "$bat/charge_now")
        full=$(cat "$bat/charge_full")
        power=$(cat "$bat/current_now")
    else
        continue
    fi

    # İki bataryanın anlık, tam kapasite ve anlık güç tüketimini topla
    total_now=$((total_now + now))
    total_full=$((total_full + full))
    total_power=$((total_power + power))

    # Şarj/deşarj durumunu belirle (Biri dahi şarj oluyorsa öncelik Charging olur)
    bat_status=$(cat "$bat/status")
    if [ "$bat_status" = "Charging" ]; then
        status="Charging"
    elif [ "$bat_status" = "Discharging" ] && [ "$status" != "Charging" ]; then
        status="Discharging"
    fi
done

# --- BİRLEŞİK YÜZDE HESAPLAMA ---
# Toplam kapasite üzerinden ağırlıklı ve net batarya yüzdesini bul
if [ "$total_full" -gt 0 ]; then
    percent=$(( 100 * total_now / total_full ))
else
    percent=0
fi

# --- KALAN SÜRE HESABI (AWK) ---
# Tüketim/dolum hızına göre kalan süreyi SS:DD formatında hesapla
time_str=$(awk -v en="$total_now" -v ef="$total_full" -v pn="$total_power" -v st="$status" '
BEGIN {
    if (pn > 0) {
        if (st == "Discharging") {
            h = en / pn;
        } else if (st == "Charging") {
            h = (ef - en) / pn;
        } else {
            h = 0;
        }
        hours = int(h);
        mins = int((h - hours) * 60);
        printf "%02d:%02d", hours, mins;
    } else {
        printf "00:00";
    }
}')

# --- SKYMOON BİLDİRİM VE DURUM YÖNETİMİ ---
# /tmp üzerinde durum saklayarak bildirimlerin sürekli spam yapmasını engeller
state_file="/tmp/battery_notification_state"
current_state=$(cat "$state_file" 2>/dev/null || echo "FULL")

if [ "$status" = "Discharging" ]; then
    # %10 ve altı: Kritik uyarı
    if [ "$percent" -le 10 ] && [ "$current_state" != "CRITICAL" ]; then
        notify-send -u critical "Batarya Kritik" "Güç %${percent} seviyesinde! Tactical Mod devrede, cihaz kapanabilir."
        echo "CRITICAL" > "$state_file"
    # %11 - %20 arası: Düşük pil uyarısı
    elif [ "$percent" -le 20 ] && [ "$percent" -gt 10 ] && [ "$current_state" != "LOW" ] && [ "$current_state" != "CRITICAL" ]; then
        notify-send -u normal "Batarya Düşük" "Güç %${percent} seviyesine indi. Fişe takmanız önerilir."
        echo "LOW" > "$state_file"
    fi
else
    # Fişe takıldığında uyarı durum hafızasını sıfırla
    if [ "$current_state" != "FULL" ]; then
        echo "FULL" > "$state_file"
    fi
fi

# --- STATUS BAR FORMATINDA EKRANA BASMA ---
# i3blocks / i3status uyumlu brutalist gösterge formatı
if [ "$status" = "Charging" ]; then
    echo "BAT %${percent}+ (${time_str})"
elif [ "$status" = "Discharging" ]; then
    echo "BAT %${percent}- (${time_str})"
else
    echo "BAT %${percent} (AC)"
fi