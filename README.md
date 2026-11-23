# 4S $\text{LiFePO}_4$ Hücre İzleme Birimi (CMU / BMS) — MATLAB/Simulink & Donanım Projesi

Bu repo, 4 seri bağlı (4S) $\text{LiFePO}_4$ batarya paketi için geliştirilen **Hücre İzleme ve Yönetim Birimi (CMU/BMS)** bitirme projesinin (Capstone) MATLAB/Simulink (Simscape) modelini, test senaryolarını ve donanım yol haritasını içerir.

## Proje Kapsamı ve Neden 4S $\text{LiFePO}_4$?

* **Donanım Uyumu:** İkinci aşamada kullanılacak **TI BQ76952** batarya izleme entegresi (AFE) minimum 3S konfigürasyonunu desteklemektedir.
* **Standart Test Barası:** 4S $\text{LiFePO}_4$ paketi ($4 \times 3.2\text{ V} = 12.8\text{ V}$ nominal), otomotiv ve standart $12\text{ V}$ DC test altyapılarıyla doğrudan uyumludur.
* **Arıza ve Ofset Tespiti:** En az 4 seri hücre kullanımı, tek bir ölçüm kanalında oluşan sensör ofseti veya temas direnci arızasını komşu hücrelerle (medyan/fark tabanlı) kıyaslayarak tespit etmeye olanak tanır.

---

## Referans Hücre Parametreleri (EVE C40)

Simülasyon modeli, fiziksel testlerde kullanılması planlanan **EVE C40** $\text{LiFePO}_4$ hücresine göre yapılandırılmıştır:

| Parametre | Değer | Not |
| :--- | :--- | :--- |
| **Konfigürasyon** | 4S1P | 4 seri bağlı hücre |
| **Nominal Kapasite ($Q$)** | $20\text{ Ah}$ | Hücre başına |
| **Nominal Gerilim** | $3.2\text{ V}$ | Paket nominal: $12.8\text{ V}$ |
| **Çalışma Gerilim Aralığı** | $2.50\text{ V} - 3.65\text{ V}$ | $\text{LiFePO}_4$ OCV-SOC tablosu |
| **Başlangıç İç Direnci ($R_{ic}$)** | $8\text{ m}\Omega$ | Katalog DCIR üst sınırı varsayımı |
| **Termal Kapasite ($C_{termal}$)** | $410\text{ J/K}$ | Silindirik $20\text{ Ah}$ LFP hücre yaklaşımı |
| **Ortam Sıcaklığı ($T_{ortam}$)** | $25\ ^\circ\text{C}$ | Referans laboratuvar koşulu |

---

## Simulink / Simscape Model Mimarisi (`CMU2.slx`)

Model, elektriksel ve termal davranışı tek bir kapalı çevrimde birleştirir:

* **Elektriksel Devre:** 4 adet seri bağlı `Controlled Voltage Source` bloğu ve her hücrenin çıkışına seri bağlanmış iç dirençler (`R_ic1` – `R_ic4`).
* **Yük Akımı:** 4S pakete paralel bağlanan tek bir `Controlled Current Source` ile kapalı akım döngüsü sağlanır; `Voltage Sensor` blokları her hücrenin yük altındaki terminal gerilimini ($V_{ocv} - I \cdot R_{ic}$) ölçer.
* **SOC Hesabı:** Her hücre için coulomb sayımı (`Integrator`, $[0, 1]$ sınır korumalı) ve $\text{LiFePO}_4$ `1-D Lookup Table` (OCV-SOC) yapısı.
* **Termal Model:** Her hücre için $I^2 R_{ic}$ kaynaklı ısınma ve ortam sıcaklığına göre soğuma dinamiği.
* **İzlenen Çıktılar:** Hücre gerilimleri ($V_1 - V_4$), $\Delta V = V_{\max} - V_{\min}$, paket akımı ($I_{desarj}$), hücre SOC değerleri ($SOC_1 - SOC_4$), sıcaklıklar ($T_1 - T_4$) ve arıza/dengeleme durumları.

---

## Test Senaryoları (8 Senaryo)

Tüm testler aynı Simulink modeli üzerinde, yalnızca ilgili senaryonun parametresi değiştirilerek referans koşulla (Test 1) karşılaştırılır:

| Test | Senaryo | Değiştirilen Girdi / Koşul | Temel Değerlendirme Çıktısı |
| :---: | :--- | :--- | :--- |
| **1** | **Normal Deşarj (Referans)** | 4 hücre $\%80$ SOC, $R_{ic} = 8\text{ m}\Omega$, $5\text{ A}$ | Simetrik gerilim, SOC ve sıcaklık referansı |
| **2** | **SOC Dengesizliği** | Başlangıç SOC: $\%85, \%72, \%80, \%82$, $5\text{ A}$ | Düz plato ve diz bölgesinde $\Delta V$ ayrışması |
| **3** | **İç Direnç Farklılığı** | 1 hücrede artırılmış $R_{ic}$ (ör. $28\text{ m}\Omega$) | Yük altında ani gerilim düşümü ve $I^2 R$ ısınması |
| **4** | **Kapasite Farklılığı** | 1 hücrede azaltılmış kapasite (ör. $16\text{ Ah}$) | Seri akımda farklılaşan SOC düşüş eğimleri |
| **5** | **Değişken Yük Akımı** | Basamaklı akım profili ($2\text{ A} - 5\text{ A} - 8\text{ A} - 15\text{ A} - 2\text{ A}$) | Dinamik akım değişiminde gerilim toparlanması |
| **6** | **Pasif Dengeleme** | $5\ \Omega$ dengeleme direnci, $\Delta V \ge 25\text{ mV}$ eşiği | Dengeleme öncesi/sonrası $\Delta V$ azalması |
| **7** | **Gerilim Sensör Hatası** | 1 kanala ofset enjeksiyonu (ör. $+35\text{ mV}$) | Yanlış balanslama riski ve ofset arıza tespiti |
| **8** | **Sıcaklık (NTC) Hatası** | 1 NTC kanalına aşırı sıcaklık ($>45\ ^\circ\text{C}$) / aralık dışı hata | Aşırı sıcaklık koruması (OTP) ve sensör bayrağı |

---

## Kurulum ve Çalıştırma

### Gereksinimler
* MATLAB / Simulink (R2023a veya üzeri önerilir)
* Simscape & Simscape Electrical

### Çalıştırma Adımları
1. Repoyu klonlayın veya indirin.
2. MATLAB çalışma dizinini proje klasörüne ayarlayın.
3. `CMU2.slx` dosyasını açın. Model başlangıç parametreleri `Model Properties -> Callbacks -> InitFcn` içinden otomatik olarak yüklenir (veya senaryo geçişleri için başlatıcı `.m` scripti çalıştırılabilir).
4. **Stop Time** değerini test senaryosuna göre ayarlayıp (ör. $3600\text{ s} - 10000\text{ s}$) **Run** butonuna basın.
5. `Output` Scope bloğundan sıcaklık, gerilim, deşarj akımı ve SOC grafiklerini inceleyin.

---

## Proje Yol Haritası

- [x] 4S $\text{LiFePO}_4$ temel elektriksel ve termal Simulink modelinin kurulması
- [x] EVE C40 ($20\text{ Ah}$, $3.2\text{ V}$) parametrelerine geçiş ve kapalı çevrim yük bağlantısı
- [x] Seri iç dirençlerin (`R_ic1` – `R_ic4`) devre yoluna eklenmesi
- [ ] Pasif dengeleme devresi ve arıza enjeksiyon bloklarının (Test 6–8) tamamlanması
- [ ] 8 senaryonun tamamının koşulması ve sonuç grafiklerinin raporlanması
- [ ] **Capstone 2 (Donanım):** TI BQ76952 + STM32G4 tabanlı özel PCB tasarımı ve gerçek hücrelerle simülasyon doğrulaması

---

## Klasör Yapısı

```text
.
├── CMU2.slx                     # Ana 4S LiFePO4 Simulink/Simscape modeli
├── Kodlar/                      # Test başlatıcı ve analiz MATLAB scriptleri
├── Sonuclar/                    # Senaryolara ait Scope ve grafik çıktıları
└── Dokumanlar/                  # Revizyon rehberi, test planı ve teknik notlar
```
