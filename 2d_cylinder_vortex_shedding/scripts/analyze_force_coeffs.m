% Run script with -h to show usage

USAGE={'Usage: octave analyze_force_coeffs.m <forceCoeffs>', ...
'Options:', ...
'  -t <t_min> <t_max>: Only considers time on the interval t_min <= t <= t_max', ...
'', ...
'Computes the minimum, maximum, and mean Cd and Cl values from the provided forceCoeffs file.'};
USAGE = sprintf('%s\n',USAGE{:});

if isempty(argv())
    disp(USAGE)
    return;
end

file_path = argv(){1};

% Extract optional Y axis limits from input arguments
t_min = -inf;
t_max = inf;

i = 2;
while i + 1 <= length(argv())
    if strcmp(argv(){i}, '-t')
        t_min = str2double(argv(){i + 1});
        t_max = str2double(argv(){i + 2});
        i = i + 3;
    end
end

file_id = fopen(file_path);

% In the forceCoeffs.dat file the time values can be printed as integers if they
% are a whole value, so parse them as strings then convert to floating point
data = textscan(file_id, '%s%f%f%f%f%f', 'Delimiter','\t', 'HeaderLines', 9, 'CollectOutput',1);
t = str2double(data{1}(:, 1));
Cd = data{2}(:, 2);
Cl = data{2}(:, 3);

% Trim for time range
indices = and(t >= t_min, t <= t_max);
t = t(indices);
Cd = Cd(indices);
Cl = Cl(indices);

Cd_min = min(Cd);
Cd_max = max(Cd);

Cl_min = min(Cl);
Cl_max = max(Cl);

fprintf('Force Coefficient Results:\n');
fprintf('\tCd=%.4f +/- %.4f (min=%.4f, max=%.4f)\n', 0.5 * (Cd_max + Cd_min), 0.5 * (Cd_max - Cd_min), Cd_min, Cd_max);
fprintf('\tCl=%.4f +/- %.4f (min=%.4f, max=%.4f)\n', 0.5 * (Cl_max + Cl_min), 0.5 * (Cl_max - Cl_min), Cl_min, Cl_max);
