%% 读取数据
data = util.load_data();

n_x = size(data, 1);
n_y = size(data, 2);
n_time = size(data, 3);
n_plate = size(data, 4);

% (#x, #y, #time, #plate)
% → (#time, #x, #y, #plate)
data = permute(data, [3 1 2 4]);
% → (#time, #slice)
data = reshape(data, n_time, []);

%% Attenuation estimation
t = plan_B.time_cut(data, "DurationEstimated", 0.31e-6);
peaks = attenuation_estimation.get_peaks(data, t);
ratios = peaks(2, :) ./ peaks(1, :);

% (#slice)
% → (#x, #y, #plate)
ratios = reshape(ratios, n_x, n_y, []);

%% Plot
figure;
util.plot_cut(data, randi(n_x * n_y * n_plate, 1, 8));
title(":-)");

figure;
util.plot_cut(data, [945 1275 1276 1278 1317 1403 1444 1526]);
title(":-(");
