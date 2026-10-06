#!/bin/bash

# X11 Ekran tanımlaması (Arka planda çalışırken xprintidle'ın ekranı bulabilmesi için)
export DISPLAY=:0

# Durum bayrakları (State flags)
is_dimmed=0

while true; do
    # 1. Medya Kontrolü: PulseAudio/PipeWire üzerinde aktif ses akışı var mı?
    if pactl list sinks 2>/dev/null | grep -q "State: RUNNING"; then
        # Müzik/Video oynuyor -> Parlaklık kısıldıysa geri al, döngüyü pas geç
        if [ "$is_dimmed" -eq 1 ]; then
            brightnessctl --restore >/dev/null 2>&1
            is_dimmed=0
        fi
        sleep 10
        continue
    fi
    # 1.5 Override (Kafein) Modu Kontrolü
    if [ -f "/tmp/skymoon_override" ]; then
        # Override aktifse ve önceden ekran kısıldıysa eski haline getir
        if [ "$is_dimmed" -eq 1 ]; then
            brightnessctl --restore >/dev/null 2>&1
            is_dimmed=0
        fi
        sleep 10
        continue
    fi
    # 2. Kullanıcının boşta kalma süresi (Saniye)
    idle_ms=$(xprintidle 2>/dev/null || echo 0)
    idle_sec=$((idle_ms / 1000))

    # 3. Güç Kaynağı Kontrolü: Adaptör (1) mü, Batarya (0) mı?
    ac_online=$(cat /sys/class/power_supply/A*/online 2>/dev/null | grep -m 1 "1" || echo 0)

    # Kullanıcı tekrar hareket ettiyse parlaklığı eski seviyesine geri getir
    if [ "$idle_sec" -lt 300 ] && [ "$is_dimmed" -eq 1 ]; then
        brightnessctl --restore >/dev/null 2>&1
        is_dimmed=0
    fi

    # -------------------------------------------------------------
    # WORKSTATION MODU (Adaptör Takılı)
    # -------------------------------------------------------------
    if [ "$ac_online" -eq 1 ]; then
        # 30. Dakika (1800s): Suspend-then-hibernate tetikle
        if [ "$idle_sec" -ge 1800 ]; then
            systemctl suspend-then-hibernate
            sleep 10

        # 15. Dakika (900s): i3lock devreye girsin
        elif [ "$idle_sec" -ge 900 ]; then
            if ! pgrep -x "i3lock" > /dev/null; then
                i3lock -n -c 111111 &
            fi

        # 5. Dakika (300s): Ekranı hafif kıs (%40)
        elif [ "$idle_sec" -ge 300 ]; then
            if [ "$is_dimmed" -eq 0 ]; then
                brightnessctl --save >/dev/null 2>&1
                brightnessctl set 40% >/dev/null 2>&1
                is_dimmed=1
            fi
        fi

    # -------------------------------------------------------------
    # TACTICAL MOD (Bataryada Çalışma)
    # -------------------------------------------------------------
    else
        # 20. Dakika (1200s): Suspend-then-hibernate tetikle
        if [ "$idle_sec" -ge 1200 ]; then
            systemctl suspend-then-hibernate
            sleep 10

        # 10. Dakika (600s): i3lock devreye girsin
        elif [ "$idle_sec" -ge 600 ]; then
            if ! pgrep -x "i3lock" > /dev/null; then
                i3lock -n -c 111111 &
            fi

        # 5. Dakika (300s): Ekranı agresif kıs (%15)
        elif [ "$idle_sec" -ge 300 ]; then
            if [ "$is_dimmed" -eq 0 ]; then
                brightnessctl --save >/dev/null 2>&1
                brightnessctl set 15% >/dev/null 2>&1
                is_dimmed=1
            fi
        fi
    fi

    sleep 5
done
