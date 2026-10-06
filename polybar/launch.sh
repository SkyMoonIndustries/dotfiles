#!/usr/bin/env bash

# Çalışan eski polybar'ları sonlandır
killall -q polybar

# Brutalist isimli barımızı başlat ve loglarını /tmp klasörüne yaz
polybar brutalist 2>&1 | tee -a /tmp/polybar.log & disown
