# 4S BMS - CMU

4 seri LiFePO4 batarya paketi (~12.8 V) için **BQ76952 + STM32** tabanlı Hücre İzleme Ünitesi (CMU) tasarım ve simülasyon projesi.

- **Capstone 1:** MATLAB/Simulink üzerinde 4S LiFePO4 modelleme, sensör gürültüsü/offset modeli, pasif dengeleme ve senaryo testleri.
- **Capstone 2:** Özel PCB tasarımı (BQ76952 + STM32G4, I2C + USB/UART), gerçek ölçümler ve simülasyon-ölçüm karşılaştırması.

## Klasörler

- `Kodlar/` - 4S LiFePO4 MATLAB model ve senaryo scriptleri
- `Simulink/` - Simulink/Simscape `.slx` modelleri
- `Kaynak/` - Proje proposal dosyası, kılavuz ve referans makaleler
- `Sonuclar/` - Grafik çıktıları

## Test Senaryoları

| Senaryo | Amaç | Kapsam |
| :--- | :--- | :--- |
| **1. Normal Çalışma** | Nominal yük + sensör gürültüsü altında referans davranış | Ana kapsam |
| **2. Hücre Dengesizliği & Pasif Dengeleme** | Kapasite, iç direnç ve SOC farkıyla $\Delta V$ oluşturup pasif dengeleme ile düşürmek | Ana kapsam |
| **3. Voltaj Ölçüm Offset'i** | Tek kanala sabit offset (+50 mV) ekleyip komşu hücre farkıyla tespit etmek | Ana kapsam |
| Open Sense Line / NTC Arızası | Hat kopması ve sıcaklık sensörü arızası | Opsiyonel |

## Kullanılan Temel Denklemler (1-RC + Isıl Denge)

- **SOC:** $\frac{dz_i(t)}{dt} = -\frac{I_i(t)}{3600 \cdot Q_i}$
- **Kutuplanma (1-RC):** $\frac{dV_{p,i}(t)}{dt} = -\frac{V_{p,i}(t)}{R_{1,i} C_{1,i}} + \frac{I_i(t)}{C_{1,i}}$
- **Sıcaklık:** $C_{th} \frac{dT_i(t)}{dt} = I_i(t)^2 R_{0,i} + \frac{V_{p,i}(t)^2}{R_{1,i}} - hA_i (T_i(t) - T_a)$
- **Terminal Voltajı:** $V_{term,i}(t) = OCV(z_i(t)) - I_i(t) R_{0,i} - V_{p,i}(t)$

*Değişkenler:* $z_i(t), V_{p,i}(t), T_i(t), I_i(t)$  
*Sabitler:* $Q_i, C_{th}, hA_i, T_a$

## Çalıştırma

MATLAB'da `Kodlar` klasörüne girip istediğin senaryoyu veya hepsini çalıştırabilirsin:

```matlab
cd Kodlar
hepsini_calistir
```

Grafikler otomatik olarak `Sonuclar/` klasörüne kaydedilir.

## Ekip

- **Başar Yıldırım** & **Necati Ahmet Tanrıverdi**  
- **Danışman:** Doç. Dr. Selma Özaydın - İstinye Üniversitesi EEE401/402
