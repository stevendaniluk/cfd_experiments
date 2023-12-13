% Generates plots of Cd and Cl values from grid and time dependence studies

% All data from dependence studies
dx = [0.0625; 0.0625; 0.0625; 0.0625; 0.0625; 0.0625; 0.03125; 0.03125; 0.03125; 0.03125; 0.03125; 0.015625; 0.015625; 0.015625; 0.015625];
dt = 1000 * [0.04; 0.02; 0.01; 0.005; 0.0025; 0.00125; 0.02; 0.01; 0.005; 0.0025; 0.00125; 0.01; 0.005; 0.0025; 0.00125];
Cd_mean = [1.3533; 1.3372; 1.3274; 1.3218; 1.3193; 1.3179; 1.3599; 1.3520; 1.3469; 1.3442; 1.3429; 1.3528; 1.3492; 1.3469; 1.3456];
Cd_amp = [0.0514; 0.0455; 0.0415; 0.0393; 0.0385; 0.0382; 0.0518; 0.0485; 0.0464; 0.0453; 0.0450; 0.0487; 0.0469; 0.0460; 0.0454];
Cl_amp = [0.7291; 0.6826; 0.6530; 0.6375; 0.6300; 0.6257; 0.7344; 0.7093; 0.6947; 0.6868; 0.6829; 0.7112; 0.6990; 0.6917; 0.6877];

% Find which data points correspond to each mesh size
idx_coarse = dx == 0.0625;
idx_medium = dx == 0.03125;
idx_fine = dx == 0.015625;

% Iterate through each mesh size plotting Cd and Cl data
f = figure(1);
clf;

plot_data = {Cd_mean, Cd_amp, Cl_amp};
plot_y_names = {'C_D Mean', 'C_D Amplitude', 'C_L Amplitude'};
for i=1:3
    subplot(3, 1, i);
    semilogx(dt(idx_coarse), plot_data{i}(idx_coarse), 'k^:', ...
        dt(idx_medium), plot_data{i}(idx_medium), 'ro--', ...
        dt(idx_fine), plot_data{i}(idx_fine), 'bx-');

    grid on;
    xlabel('Time Step [ms]');
    ylabel(plot_y_names{i});
    legend({'Coarse', 'Medium', 'Fine'}, 'Location', 'southeast');
end

waitfor(f);
