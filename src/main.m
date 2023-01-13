rng(37); % 为了容易复现，随便规定一下随机数种子

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

%% Noise reduction
reducer = designfilt( ...
'bandpassfir', ...
    'SampleRate', 100, ...
    'StopbandFrequency1', 2, 'StopbandAttenuation1', 13, ...
    'PassbandFrequency1', 3, 'PassbandFrequency2', 8, 'PassbandRipple', 1, ...
    'StopbandFrequency2', 15, 'StopbandAttenuation2', 13, ...
    'DesignMethod', 'equiripple' ...
);
raw_data = data;
data = filter(reducer, raw_data);

%% Attenuation estimation
t = plan_B.time_cut(data, "DurationEstimated", 0.31e-6);
peaks = attenuation_estimation.get_peaks(data, t);
ratios = peaks(2, :) ./ peaks(1, :);

% (#slice)
% → (#x, #y, #plate)
ratios = reshape(ratios, n_x, n_y, []);

%% Plot
if ~isfile("../fig/peak-ordinary.jpg")
    figure;

    util.plot_cut(data, randi(n_x * n_y * n_plate, 1, 5));
    title(subplot(2, 1, 1), "随机若干点的判决情况");

    exportgraphics(gcf, "../fig/peak-ordinary.jpg");
end

if ~isfile("../fig/peak-1403.jpg")
    figure;

    util.plot_cut(data, 1403);
    title(subplot(2, 1, 1), "#1403（Y，x = 15 mm，y = 3 mm）的判决情况");

    exportgraphics(gcf, "../fig/peak-1403.jpg");
end

if ~isfile("../fig/attenuation_image.jpg")
    figure('WindowState', 'maximized');
    util.plot_space(ratios);
    exportgraphics(gcf, "../fig/attenuation_image.jpg");
end

if ~isfile("../fig/attenuation_histogram.jpg")
    figure;

    for p = 1:n_plate
        histogram( ...
            ratios(:, :, p), ...
            "Normalization", "probability", ...
            "BinWidth", 0.02 ...
        );
        hold on;
    end

    hold off;
    grid on;
    legend(["X" "Y"]);
    title("衰减分布");
    xlabel("衰减程度");
    ylabel("频率/组距");

    exportgraphics(gcf, "../fig/attenuation_histogram.jpg");
end

if ~isfile("../fig/attenuation_box.jpg")
    figure;

    boxchart(reshape(ratios, [], 2));
    xticklabels(["X" "Y"]);
    ylabel("衰减程度");
    grid on;

    exportgraphics(gcf, "../fig/attenuation_box.jpg");
end
