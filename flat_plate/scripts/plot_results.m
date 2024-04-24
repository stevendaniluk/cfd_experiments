% Run script with -h to show usage

USAGE={'Usage: octave plot_results.m', ...
'Options:', ...
'  -i <NAME> <SHEAR_STRESS_FILE> <U_SAMPLE_FILE> <IC_FILE>', ...
'  -Cf_lim <y_min> <y_max>: Sets the Y axis limits for the Cf plot', ...
'  -y_plus_lim <y_min> <y_max>: Sets the X axis limits for the u+ y+ plot', ...
'  -s <filename>: Saves a copy of the plots to <filename>.png then exits', ...
'', ...
'Plots skin friction coefficient and dimensionless velocity profile'};
USAGE = sprintf('%s\n',USAGE{:});

if strcmp(argv(){1}, '-h')
    disp(USAGE);
    return;
end

% Extract input data
data.names = {};
data.shear = {};
data.U = {};
data.IC = {};
n_sources = 0;

% Extract optional input arguments
Cf_y_lim = [];
y_plus_x_lim = [];
save_plot = false;
plot_image_name = '';

i = 1;
while i + 1 <= length(argv())
    if strcmp(argv(){i}, '-i')
        n_sources = n_sources + 1;
        data.names{n_sources} = argv(){i + 1};
        data.shear{n_sources} = argv(){i + 2};
        data.U{n_sources} = argv(){i + 3};
        data.IC{n_sources} = argv(){i + 4};

        i = i + 5;
    elseif strcmp(argv(){i}, '-Cf_lim')
        Cf_y_lim = [str2double(argv(){i + 1}), str2double(argv(){i + 2})];
        i = i + 3;
    elseif strcmp(argv(){i}, '-y_plus_lim')
        y_plus_x_lim = [str2double(argv(){i + 1}), str2double(argv(){i + 2})];
        i = i + 3;
    elseif strcmp(argv(){i}, '-s')
        save_plot = true;
        plot_image_name = argv(){i + 1};
        i = i + 2;
    else
        % fprintf('Unrecognized argument: %s\n', argv(){i})
        i = i + 1;
    end
end

% Create our figures
f_Cf = figure('NumberTitle', 'off', 'Name', 'Skin Friction Coefficient');
hold on;

f_y_plus = figure('NumberTitle', 'off', 'Name', 'Turbulent Wall Velocity');
hold on;

Re_x_max = 0;
for i=1:n_sources
    name = data.names{i};
    IC_data_path = data.IC{i};
    shear_data_path = data.shear{i};
    U_data_path = data.U{i};

    % Extract the initial conditions
    [~, U_inf] = system(strjoin({'foamDictionary -entry "U_inf" -value ', IC_data_path}));
    U_inf = str2double(U_inf);

    [~, Re] = system(strjoin({'foamDictionary -entry "Re" -value ', IC_data_path}));
    Re = str2double(Re);

    [~, plate_L] = system(strjoin({'foamDictionary -entry "plate_L" -value ', IC_data_path}));
    plate_L = str2double(plate_L);

    nu = U_inf * plate_L / Re;

    % Extract the shear stress data
    file_id = fopen(shear_data_path);
    shear_data = textscan(file_id, '%f%f%f%f%f%f', 'Delimiter','\t', 'HeaderLines', 1, 'CollectOutput', 1);

    x = shear_data{1}(:, 1);
    tau_w = shear_data{1}(:, 4);
    Cf = abs(tau_w) / (0.5 * U_inf^2);
    Re_x = U_inf * x / nu;
    Re_x_max = max(Re_x_max, max(Re_x));

    % Extract the velocity profile data
    file_id = fopen(U_data_path);
    U_data = textscan(file_id, '%f%f%f%f', 'Delimiter','\t', 'HeaderLines', 1, 'CollectOutput', 1);

    y = U_data{1}(:, 1);
    Ux = U_data{1}(:, 2);

    % Compute y+ and u+ values
    tau_w_at_plate_L = abs(interp1(x, tau_w, plate_L));

    y_plus = sqrt(tau_w_at_plate_L) * y / nu;
    u_plus = Ux / sqrt(tau_w_at_plate_L);

    % Plot results
    figure(f_Cf);
    plot(Re_x, Cf, 'DisplayName', name);

    figure(f_y_plus);
    semilogx(y_plus, u_plus, 'DisplayName', name);
end

% Compute some skin friction values from known approximations
Re_x_samples = linspace(0, Re_x_max);
Cf_1_7_law = 0.0592 * Re_x_samples .^ -0.2;

% Set constant plot properties
figure(f_Cf);
plot(Re_x_samples, Cf_1_7_law, 'DisplayName', '1/7 Power Law: 0.0592 Re_x^{-1.5}');
grid on;
title('Wall Skin Friction');
xlabel('Re_x');
ylabel('C_f');
if ~isempty(Cf_y_lim)
    ylim(Cf_y_lim);
end
leg = legend(gca, 'show');

figure(f_y_plus);
hold on;
grid on;
title('Dimensionless Velocity Profile');
xlabel('y+');
ylabel('u+');
if ~isempty(y_plus_x_lim)
    xlim(y_plus_x_lim);
end
leg = legend(gca, 'show', 'Location', 'northwest');

if save_plot
    saveas(f_Cf, strcat(plot_image_name, '_Cf.png'));
    saveas(f_y_plus, strcat(plot_image_name, '_y_plus.png'));
    return;
end

waitfor(f_Cf);
waitfor(f_y_plus);
