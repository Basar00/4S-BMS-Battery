% Senaryo 1: Normal çalışma (referans)
clear; clc; close all;
parametreler;

dt = 1;
t  = 0:dt:1800;
I_prof = zeros(size(t));
I_prof(t < 600) = 5.0;
I_prof(t >= 200 & t < 350) = 9.0;

Q_cell = [2.50 2.50 2.50 2.50];
z_init = [0.95 0.95 0.95 0.95];
k_R0   = [1.00 1.00 1.00 1.00];
hA     = [0.80 0.70 0.70 0.80];

opts = struct('bal_on', false, 'off_cell', 0, 'off_val', 0, 'off_t', 0);
[~, V_meas, z_arr, T_arr, ~] = hucre_modeli(Q_cell, z_init, k_R0, hA, I_prof, dt, opts);

fig = figure('Color', 'w', 'Position', [100 80 900 750]);
subplot(4,1,1); plot(t, T_arr', 'LineWidth', 1.5); ylabel('°C'); title('Senaryo 1: Normal Çalışma'); legend('T1','T2','T3','T4','Location','northeast'); grid on;
subplot(4,1,2); plot(t, V_meas', 'LineWidth', 1.5); ylabel('V'); legend('V1','V2','V3','V4','Location','southeast'); grid on;
subplot(4,1,3); plot(t, I_prof, 'k', 'LineWidth', 1.5); ylabel('A'); ylim([-1 11]); grid on;
subplot(4,1,4); plot(t, z_arr'*100, 'LineWidth', 1.5); ylabel('SOC %'); xlabel('t (s)'); grid on;

out_dir = fullfile(fileparts(mfilename('fullpath')), '..', 'Sonuclar');
if ~exist(out_dir, 'dir'), mkdir(out_dir); end
saveas(fig, fullfile(out_dir, 'senaryo_1_normal.png'));
