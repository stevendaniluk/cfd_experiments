% Run script with -h to show usage

USAGE={'Usage: octave plot_force_coeffs.m <FORCE_COEFF_FILE>', ...
'Options:', ...
'  -Cd <y_min> <y_max>: Sets the Y axis limits for the Cd plot', ...
'  -Cl <y_min> <y_max>: Sets the Y axis limits for the Cl plot', ...
'  -t  <t_min> <t_max>: Sets the X axis limits for all plots', ...
'  -s <filename>: Saves a copy of the plot to <filename>.png then exits', ...
'', ...
'Plots the drag and lift coefficients from the postProcessing forceCoeffs.dat file.'};
USAGE = sprintf('%s\n',USAGE{:});

if strcmp(argv(){1}, '-h')
    disp(USAGE);
    return;
end

data_path = argv(){1};
file_path = fullfile(data_path, 'postProcessing/forces/0/forceCoeffs.dat');

% Extract optional Y axis limits from input arguments
Cd_y_lim = [];
Cl_y_lim = [];
x_lim = [];
save_plot = false;
plot_image_name = '';

i = 2;
while i + 1 <= length(argv())
    if strcmp(argv(){i}, '-Cd')
        Cd_y_lim = [str2double(argv(){i + 1}), str2double(argv(){i + 2})];
        i = i + 3;
    elseif strcmp(argv(){i}, '-Cl')
        Cl_y_lim = [str2double(argv(){i + 1}), str2double(argv(){i + 2})];
        i = i + 3;
    elseif strcmp(argv(){i}, '-t')
        x_lim = [str2double(argv(){i + 1}), str2double(argv(){i + 2})];
        i = i + 3;
    elseif strcmp(argv(){i}, '-s')
        save_plot = true;
        plot_image_name = argv(){i + 1};
        i = i + 2;
    else
        fprintf('Unrecognized argument: %s\n', argv(){i})
        i = i + 1;
    end
end

f = figure('NumberTitle', 'off', 'Name', 'Force Coefficients');

while true
    file_id = fopen(data_path);

    % In the forceCoeffs.dat file the time values can be printed as integers if they
    % are a whole value, so parse them as strings then convert to floating point
    data = textscan(file_id, '%s%f%f%f%f%f', 'Delimiter','\t', 'HeaderLines', 9, 'CollectOutput', 1);
    t = str2double(data{1}(:, 1));
    Cd = data{2}(:, 2);
    Cl = data{2}(:, 3);

    if isempty(x_lim)
        x_lim = [0, max(t)];
    end

    clf;

    subplot(2, 1, 1);
    plot(t, Cd);
    grid on;
    xlabel('Time [s]');
    ylabel('Drag Coefficient');
    xlim(x_lim);
    if ~isempty(Cd_y_lim)
        ylim(Cd_y_lim);
    end

    subplot(2, 1, 2);
    plot(t, Cl);
    grid on;
    xlabel('Time [s]');
    ylabel('Lift Coefficient');
    xlim(x_lim);
    if ~isempty(Cl_y_lim)
        ylim(Cl_y_lim);
    end

    if save_plot
        saveas(gcf, strcat(plot_image_name, '.png'))
        return;
    end

    pause(1.0);
end

waitfor(f)
