% Senaryo 2: Hücre dengesizliği ve pasif dengeleme
clear; clc; close all;
parametreler;

dt = 1;
t  = 0:dt:1800;

% Özdeş olmayan 4 hücre (kapasite, iç direnç ve soğuma farklı)
Q_cell = [2.50 1.95 2.35 2.45];
k_R0   = [1.00 1.85 1.20 1.05];
hA     = [0.80 0.25 0.50 0.80];

% 2A: Yük altında dengesizlik (farklı SOC eğimleri ve sıcaklık)
I_load = zeros(size(t));
I_load(t < 600) = 5.0;
I_load(t >= 200 & t < 350) = 9.0;
z_load = [0.99 0.85 0.96 0.98];

opts_off = struct('bal_on', false, 'off_cell', 0, 'off_val', 0, 'off_t', 0);
[~, V_load, z_arr, T_arr, ~] = hucre_modeli(Q_cell, z_load, k_R0, hA, I_load, dt, opts_off);

% 2B: Şarj sonu / dinlenme bölgesinde pasif dengeleme karşılaştırması
I_rest = zeros(size(t));
z_rest = [0.995 0.88 0.96 0.985];
opts_on = struct('bal_on', true, 'off_cell', 0, 'off_val', 0, 'off_t', 0);

[~, V_nobal, ~, ~, ~] = hucre_modeli(Q_cell, z_rest, k_R0, hA, I_rest, dt, opts_off);
[~, V_bal,   ~, ~, ~] = hucre_modeli(Q_cell, z_rest, k_R0, hA, I_rest, dt, opts_on);

dV_nobal = (max(V_nobal, [], 1) - min(V_nobal, [], 1)) * 1000;
dV_bal   = (max(V_bal,   [], 1) - min(V_bal,   [], 1)) * 1000;

fprintf('Dengeleme öncesi DeltaV: %.1f mV -> Dengeleme sonrası: %.1f mV\n', dV_bal(1), dV_bal(end));

fig = figure('Color', 'w', 'Position', [100 60 950 820]);
subplot(4,1,1); plot(t, T_arr', 'LineWidth', 1.5); ylabel('°C'); title('Senaryo 2: Dengesizlik ve Pasif Dengeleme'); legend('H1','H2 (Zayıf)','H3','H4','Location','northeast'); grid on;
subplot(4,1,2); plot(t, z_arr'*100, 'LineWidth', 1.5); ylabel('SOC %'); legend('H1 (2.50Ah)','H2 (1.95Ah)','H3 (2.35Ah)','H4 (2.45Ah)','Location','southwest'); grid on;
subplot(4,1,3); plot(t, V_bal', 'LineWidth', 1.5); ylabel('V (Dengeli)'); legend('V1','V2','V3','V4','Location','northeast'); grid on;
subplot(4,1,4);
plot(t, dV_nobal, 'r--', 'LineWidth', 1.5); hold on;
plot(t, dV_bal,   'b-',  'LineWidth', 1.8);
yline(dV_bal_thr*1000, 'k:', '25 mV Eşik');
ylabel('\DeltaV (mV)'); xlabel('t (s)');
legend('Dengeleme Kapalı', 'Pasif Dengeleme Açık', 'Location', 'east'); grid on;

out_dir = fullfile(fileparts(mfilename('fullpath')), '..', 'Sonuclar');
if ~exist(out_dir, 'dir'), mkdir(out_dir); end
saveas(fig, fullfile(out_dir, 'senaryo_2_dengesizlik_ve_dengeleme.png'));
