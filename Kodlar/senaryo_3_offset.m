% Senaryo 3: Voltaj ölçüm offset'i (+50 mV, Hücre 3, t = 400 s)
clear; clc; close all;
parametreler;

dt = 1;
t  = 0:dt:1200;
I_prof = ones(size(t)) * 5.0;
I_prof(t >= 200 & t < 350) = 9.0;
I_prof(t >= 700 & t < 850) = 0.0;

Q_cell = [2.50 2.50 2.50 2.50];
z_init = [0.95 0.95 0.95 0.95];
k_R0   = [1.00 1.00 1.00 1.00];
hA     = [0.80 0.70 0.70 0.80];

opts = struct('bal_on', false, 'off_cell', 3, 'off_val', 0.050, 'off_t', 400);
[V_true, V_meas, ~, ~, ~] = hucre_modeli(Q_cell, z_init, k_R0, hA, I_prof, dt, opts);

% Komşu hücre medyanı ile fark kontrolü
res_mV  = abs(V_meas - median(V_meas, 1)) * 1000;
esik_mV = 30;
fault_flag = max(res_mV, [], 1) >= esik_mV;

ilk_tespit = find(fault_flag, 1);
if ~isempty(ilk_tespit)
    fprintf('Offset arızası tespit edildi: t = %d s (Fark = %.1f mV)\n', t(ilk_tespit), max(res_mV(:, ilk_tespit)));
end

fig = figure('Color', 'w', 'Position', [100 80 900 700]);
subplot(3,1,1);
plot(t, V_meas', 'LineWidth', 1.4); hold on;
plot(t, V_true(3,:), 'k--', 'LineWidth', 1.2);
ylabel('V'); title('Senaryo 3: Voltaj Ölçüm Offset''i (Hücre 3, +50 mV)');
legend('V1','V2','V3 (Ölçülen)','V4','V3 (Gerçek)','Location','southwest'); grid on;

subplot(3,1,2);
plot(t, res_mV', 'LineWidth', 1.4); hold on;
yline(esik_mV, 'r--', '30 mV Eşik');
ylabel('Fark (mV)'); legend('H1','H2','H3','H4','Location','northwest'); grid on;

subplot(3,1,3);
stairs(t, double(fault_flag), 'r', 'LineWidth', 1.8);
ylim([-0.2 1.2]); yticks([0 1]); yticklabels({'Normal','Arıza'});
xlabel('t (s)'); ylabel('Durum'); grid on;

out_dir = fullfile(fileparts(mfilename('fullpath')), '..', 'Sonuclar');
if ~exist(out_dir, 'dir'), mkdir(out_dir); end
saveas(fig, fullfile(out_dir, 'senaryo_3_voltaj_offset.png'));
