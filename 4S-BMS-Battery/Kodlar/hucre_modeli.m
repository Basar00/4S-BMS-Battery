function [V_true, V_meas, z_arr, T_arr, I_bal] = hucre_modeli(Q_cell, z_init, k_R0, hA, I_prof, dt, opts)
% 4S LiFePO4 1-RC Thevenin + termal model (Asama B)
parametreler;

N = length(I_prof);
V_true = zeros(4, N);
V_meas = zeros(4, N);
z_arr  = zeros(4, N);
T_arr  = zeros(4, N);
I_bal  = zeros(4, N);

z  = z_init(:);
T  = ones(4, 1) * T_a;
Vp = zeros(4, 1);

rng(1);

for k = 1:N
    I_p = I_prof(k);

    % Pasif dengeleme kontrolü
    if k > 1 && opts.bal_on
        v_min = min(V_meas(:, k-1));
        for c = 1:4
            if (V_meas(c, k-1) - v_min) >= dV_bal_thr
                I_bal(c, k) = V_meas(c, k-1) / R_bal;
            end
        end
    end

    for c = 1:4
        z_cl = min(max(z(c), 0), 1);
        ocv  = interp1(z_lut, OCV_lut, z_cl, 'linear', 'extrap');
        r0   = interp1(z_lut, R0_lut,  z_cl, 'linear', 'extrap') * k_R0(c);
        r1   = interp1(z_lut, R1_lut,  z_cl, 'linear', 'extrap') * k_R0(c);
        c1   = interp1(z_lut, C1_lut,  z_cl, 'linear', 'extrap');

        I_c = I_p + I_bal(c, k);
        V_true(c, k) = ocv - I_c * r0 - Vp(c);
        z_arr(c, k)  = z(c);
        T_arr(c, k)  = T(c);

        % Sensör gürültüsü + opsiyonel offset
        vm = V_true(c, k) + noise_std * randn;
        if opts.off_cell == c && (k-1)*dt >= opts.off_t
            vm = vm + opts.off_val;
        end
        V_meas(c, k) = vm;

        % Diferansiyel adımlar (Euler)
        dz  = -I_c / (3600 * Q_cell(c));
        dVp = -(Vp(c) / (r1 * c1)) + (I_c / c1);
        dT  = (I_c^2 * r0 + (Vp(c)^2)/r1 - hA(c) * (T(c) - T_a)) / C_th;

        z(c)  = z(c)  + dz  * dt;
        Vp(c) = Vp(c) + dVp * dt;
        T(c)  = T(c)  + dT  * dt;
    end
end
end
