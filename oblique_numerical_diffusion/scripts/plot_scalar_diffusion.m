% Run script with -h to show usage

USAGE={'Usage: octave plot_scalar_diffusion.m [OPTIONS]', ...
'Options:', ...
'  -i  <filename> <name>: Loads filename and plots with legen entry name, can be specific multiple times', ...
'  -y  <y_min> <y_max>: Sets the Y axis limits for the plot', ...
'  -s <filename>: Saves a copy of the plot to <filename>.png then exits', ...
'', ...
'Plots the diffusion of a passive scalar across a domain.'};
USAGE = sprintf('%s\n',USAGE{:});

if strcmp(argv(){1}, '-h')
    disp(USAGE);
    return;
end

file_paths = {};
source_names = {};
n_sources = 0;

% Extract optional Y axis limits from input arguments
y_lim = [];
save_plot = false;
plot_image_name = '';

i = 1;
while i + 1 <= length(argv())
    if strcmp(argv(){i}, '-i')
        n_sources = n_sources + 1;
        file_paths{n_sources} = argv(){i + 1};
        source_names{n_sources} = argv(){i + 2};
        i = i + 3;
    elseif strcmp(argv(){i}, '-y')
        y_lim = [str2double(argv(){i + 1}), str2double(argv(){i + 2})];
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

f = figure('NumberTitle', 'off', 'Name', 'Scalar Diffusion');
hold on;

plot([0, 0.5, 0.5, 1], [1, 1, 0, 0], '--r', 'DisplayName', 'Exact');

for i=1:n_sources
    % Extract data from the file and normalize the distance
    file_id = fopen(file_paths{i});
    data = textscan(file_id, '%f%f', 'Delimiter',',', 'HeaderLines', 1, 'CollectOutput', 1);

    x = data{1}(:, 1);
    x = x / max(x);

    s = data{1}(:, 2);

    plot(x, s, 'DisplayName', source_names{i});
end

grid on;
xlabel('x');
ylabel('s');

leg = legend(gca, 'show');
% leg.Location = 'northwest';

xlim([0, 1])
if ~isempty(y_lim)
    ylim(y_lim);
end

if save_plot
    saveas(gcf, strcat(plot_image_name, '.png'))
    return;
else
    waitfor(f)
end
