% Generates plots of Cd and Cl values from grid and time dependence studies
n_cells = [13250, 33032, 110318, 414412];
mesh_Cd_mean = [0.9336, 1.4656, 1.6464, 1.5939];
mesh_Cd_amp = [0.0348, 0.2012, 0.2430, 0.2496];
mesh_Cl_amp = [0.6730, 1.4031, 1.5818, 1.5675];

dt = [0.02, 0.01, 0.005, 0.0025, 0.00125];
dt_Cd_mean = [1.5865, 1.6562, 1.6464, 1.6439, 1.6415];
dt_Cd_amp = [0.3346, 0.2423, 0.2430, 0.2382, 0.2376];
dt_Cl_amp = [1.5989, 1.5913, 1.5818, 1.5742, 1.5709];

% Iterate through each mesh size plotting Cd and Cl data
plot_y_names = {'C_D Mean', 'C_D Amplitude', 'C_L Amplitude'};

f1 = figure(1);
clf;

plot_data = {mesh_Cd_mean, mesh_Cd_amp, mesh_Cl_amp};
for i=1:3
    subplot(3, 1, i);
    semilogx(n_cells, plot_data{i}, '-o');

    grid on;
    xlabel('Mesh Size [cells]');
    ylabel(plot_y_names{i});
end

f2 = figure(2);
clf;

plot_data = {dt_Cd_mean, dt_Cd_amp, dt_Cl_amp};
for i=1:3
    subplot(3, 1, i);
    semilogx(dt, plot_data{i}, '-o');

    grid on;
    xlabel('Time Step [s]');
    ylabel(plot_y_names{i});
end

waitfor(f1);
