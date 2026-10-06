# SkyMoon T480 Workstation - Kurulum ve Konfigürasyon Rehberi

Bu depo, Lenovo ThinkPad T480 (Çift Batarya) üzerinde koşan, "Brutalist" tasarıma ve yüksek donanım verimliliğine odaklanmış bir Debian + i3wm yapılandırmasıdır (dotfiles). Gömülü sistem geliştirme (ESP32/STM32/Arduino), 3D baskı dilimleme (Bambu Studio) ve PCB tasarımı (KiCad) gibi mühendislik iş akışları için özel güç algoritmaları ve X11 donanım yamaları içerir. 

## 🎯 Projenin Amacı ve Felsefesi
*   **Saf Performans:** XFCE gibi masaüstü ortamlarının hantal güç ve ekran yöneticileri tamamen sökülüp atılmış, yerine doğrudan `systemd` ve `bash` scriptleri ile konuşan hafif bir mimari kurulmuştur (Saydamlık ve gölge efektleri için kullanılan Picom bile saf performans adına sistemden çıkarılmıştır).
*   **Donanımsal Hata Giderimi:** ThinkPad T480'e özgü çift batarya yanlış okumaları, uykudan uyanamama (focus loss) ve X11 DPMS çakışmaları kökten çözülmüştür.
*   **Tek Merkez (Single Source of Truth):** Tüm yapılandırmalar `~/dotfiles` klasöründe tutulur ve sisteme sembolik linklerle (symlink) bağlanır.

---

## 🚀 Kurulum (Otomasyon)

Sistemi sıfır bir Debian üzerine kurmak için repoyu mutlaka **Ana Dizin'e (Home)** klonlamanız gerekmektedir. `install.sh` betiği bağımlılıkları yükler, kernel yamalarını uygular ve symlink köprülerini otomatik kurar.

```bash
# 0. Git'i kurun (Sıfır debian kurulumları için)
sudo apt update && sudo apt install git -y

# 1. Repoyu ana dizine klonlayın
git clone [https://github.com/SkyMoonIndustries/dotfiles.git](https://github.com/KULLANICI_ADIN/dotfiles.git) ~/dotfiles

# 2. Kurulum betiğine çalışma izni verin ve çalıştırın
chmod +x ~/dotfiles/install.sh
~/dotfiles/install.sh
```
*(Not: Script gerekli yerlerde sudo yetkisi isteyecektir. İşlem bitince sistemi yeniden başlatın).*

---

## 📦 Uygulama Kurulum ve Güncelleme Rehberi

Geliştirme ortamında geleneksel depoların (apt) dışındaki araçları kurmak ve güncellemek için aşağıdaki standartlar benimsenmiştir:

### 1. Yerel `.deb` Paketleri (Örn: Snapmaker Luban)
*   **Kurulum:** Bağımlılık hatalarını önlemek için `.deb` dosyalarını geleneksel `dpkg -i` ile DEĞİL, `apt` üzerinden yerel dosya yolu belirterek kurun:
    `sudo apt install ./uygulama_adi.deb`
*   **Güncelleme:** Uygulamanın yeni sürümüne ait `.deb` dosyasını indirin ve aynı kurulum komutunu (`sudo apt install ./yeni_surum.deb`) tekrar çalıştırın. `apt` eski sürümün üzerine yazarak güvenli bir şekilde güncelleyecektir.

### 2. AppImage Dosyaları (Örn: Arduino IDE, Bambu Studio)
*   **Kurulum:** İndirdiğiniz `.AppImage` dosyasını `~/Applications` klasörüne taşıyın ve terminalden çalışma izni verin: `chmod +x ~/Applications/uygulama_adi.AppImage`. Rofi'de görünmesi için `~/.local/share/applications/` dizininde bir `.desktop` dosyası oluşturun.
*   **Güncelleme:** Yeni `.AppImage` dosyasını indirin. Eski sürümü silin ve yeni dosyanın adını eskisiyle **birebir aynı olacak şekilde** yeniden adlandırarak `~/Applications` içine atın. (Örn: `BambuStudio_v3.AppImage` dosyasını indirip adını yine `BambuStudio_ubu22.AppImage` yapın). Çalışma iznini verin (`chmod +x`). Böylece `.desktop` kısayollarını değiştirmeden güncellemeyi tamamlamış olursunuz.

---

## 🔋 SkyMoon Güç ve Batarya Yönetimi

Sistemde güç ve batarya göstergeleri tamamen sıfırdan yazılmış Bash motorlarıyla yönetilir. Standart `acpi` veya XFCE güç modülleri **kullanılmaz**.

### Sensor Fusion Çift Batarya Okuyucu (`battery.sh`)
ThinkPad T480'in BAT0 (Dahili) ve BAT1 (Harici) pillerinin donanımsal `energy_now` (μWh) verilerini doğrudan Kernel üzerinden okuyup toplayan modüldür. `/tmp` durum dosyalarıyla bildirim spam'i engellenmiştir.

### Dinamik Güç Algoritması (`power_daemon.sh`)
Fiş/Batarya durumunu ve cihazda medya oynatılıp oynatılmadığını saniyeler içinde analiz eden motor:

| Durum | 5. Dakika | 10. Dakika | 15. Dakika | 20. Dakika | 30. Dakika |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Tactical (Pilde)** | Parlaklık %15 | i3lock Kilit | - | Suspend-then-Hibernate | - |
| **Workstation (Fişte)** | Parlaklık %40 | - | i3lock Kilit | - | Suspend-then-Hibernate |

**Suspend-then-Hibernate Nedir?**
Cihazı tamamen kapatmak veya sadece uyutmak yerine kullanılan karma bir sistemdir. Belirlenen tetikleyici anında cihaz önce RAM'de uykuya (Suspend) dalar. Eğer `/etc/systemd/sleep.conf` içinde belirlenen süre (HibernateDelaySec=30min) boyunca cihaz uyandırılmazsa, bataryayı korumak için sistem RAM'deki veriyi SSD'ye yazıp tamamen kapanır (Hibernate). Bu sayede kısa molalarda anında uyanma, uzun molalarda ise sıfır pil tüketimi sağlanır.
*(Not: PulseAudio dinlenir; eğer arkada bir video/ses oynuyorsa süreler dolsa dahi sistem uyutulmaz).*

---

## 🎛️ Sistem Modülleri ve Kısayollar (Macros)

### Rofi Komuta Merkezi (`Super + Z`)
Rofi, özel scriptlerimizle statik bir uygulama başlatıcıdan dinamik bir donanım kontrol paneline dönüştürüldü:
*   **Ses Yönlendirme:** Hoparlör, Kulaklık, HDMI ve Bluetooth kulaklık arası anında geçiş.
*   **Görüntü Modları:** Laptop tek ekran veya Çift Monitör.
*   **Dock Modu:** `systemd-inhibit` kullanılarak kapak kapatıldığında cihazın uyuması engellenir (Harici monitör ile kapak kapalı çalışmak için).
*   **Power Override (Kafein) Modu:** Uzun süren işlemlerde sistemin uykuya geçmesini veya ekranı karatmasını devreden çıkarır.

### Kısayol Tuşları (Cheat Sheet)

**1. SkyMoon Özel Atamaları**
| Kısayol | İşlev |
| :--- | :--- |
| `Super + Z` | Rofi Sistem ve Komuta Menüsü |
| `Super + X` | Firefox (Web Tarayıcı) |
| `PrtScn` | Flameshot (Ekran Alıntısı Aracı) |

**2. i3wm Varsayılanları (En Sık Kullanılanlar)**
| Kısayol | İşlev |
| :--- | :--- |
| `Super + Enter` | Terminali açar |
| `Super + Shift + Q` | Aktif pencereyi kapatır (Kill) |
| `Super + d` | Standart dmenu (Uygulama başlatıcı) |
| `Super + [1-9]` | Çalışma alanları (Workspaces) arası geçiş yapar |
| `Super + Shift + R` | i3wm'i yeniden başlatır (Değişiklikleri uygular) |

---

## 🛠 Sistem Yamaları (Under the Hood)

Sistemin stabilitesini korumak için `install.sh` betiğinin arka planda çözdüğü kronik sorunlar:

1.  **Klavye Uyanma (Focus Loss) Sorunu:** Cihaz uykudan uyanınca X11'in odağı kaybetmesini önlemek için GRUB üzerinden `atkbd.reset=1 i8042.nomux=1 i8042.reset` kernel yamaları uygulandı. Uyku yönetimi XFCE'den alınıp `xss-lock` ve `i3lock` (mat siyah arka plan: #111111) devredildi.
2.  **10. Dakika Video Kilidi Hatası:** X11'in kendi dahili sayacı (DPMS), video izlerken ekranı kapatmaması için i3 config üzerinden (`xset s off -dpms`) tamamen devre dışı bırakıldı. Tüm yetki SkyMoon Power Daemon'a verildi.
3.  **Fiziksel Tuş ve Kapak Davranışları:** Yanlışlıkla kapanmaları önlemek için güç tuşuna (`PowerButton`) basıldığında sistem hiçbir tepki vermez (`ignore`). Kapak kapatıldığında (`LidSwitch`) ise sistem doğrudan uykuya (`suspend`) geçer. (Kapağı kapatıp çalışmaya devam etmek için Rofi menüsünden "Dock Modu" açılmalıdır).
4.  **Touchpad Davranışları:** Doğal kaydırma (Natural Scrolling) ve dokunarak tıklama aktif edildi.
5.  **Gömülü Sistem İzinleri:** Kullanıcının ESP32/STM32 gibi donanımlarla iletişim kurabilmesi için `dialout` (seri port) yetkileri otomatik tanımlandı.

---

## 🔔 Dunst Bildirim Hiyerarşisi
Sonradan geliştirme yapacaklar veya bash scriptlerine bildirim ekleyecekler için sistemdeki Dunst öncelik seviyeleri şu şekilde kurgulanmıştır:

*   **`-u low` (Gri Bildirimler):** Ses çıkışının değişmesi veya HDMI bağlanması gibi arka plan bilgi mesajlarıdır. Birkaç saniye içinde kaybolur.
*   **`-u normal` (Standart Bildirimler):** Pilin %20'ye düşmesi veya Dock/Override modlarının açılıp kapanması gibi sistem olaylarını belirtir.
*   **`-u critical` (Kırmızı ve Kalıcı Bildirimler):** Pilin %10'a düşmesi gibi acil eylem gerektiren durumlardır. Kullanıcı üzerine tıklayıp kapatana kadar ekranda asılı (sticky) kalır.

---

## 🗺️ Yapılacaklar (Roadmap)
- [x] XFCE'den saf i3'e geçiş ve bloatware temizliği
- [x] Çift batarya için donanımsal sensor okuma algoritması
- [x] PulseAudio destekli akıllı güç yönetimi (power_daemon)
- [x] Rofi üzerinden donanım komuta merkezi ve Override modları
- [x] Dotfiles kurulum ve konfigürasyon otomasyonu (`install.sh` yazıldı)
- [ ] Kernel seviyesinde agresif güç tasarrufu (CPU Governor)
- [ ] KiCad, 3D baskı (Bambu Studio) ve FlatCAM workflow otomasyonları
- [ ] Başlangıç ekranı özelleştirmesi
-
