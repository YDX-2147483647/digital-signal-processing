function plot_cut(data, slices, options)
%plot_cut - 展示切分情况
%
% 输入：
% - data(#time, #slice)：所有样本的数据
% - slices(1, #slice)：要展示的样本的序号
% - options：`time_cut`的选项

arguments
    data(:, :)
    slices(1, :) {mustBeInteger, mustBePositive}
    % Disgusting!
    options.MinMagnitude (1, 1) {mustBeGreaterThan(options.MinMagnitude, 0), mustBeLessThan(options.MinMagnitude, 1)} = 0.2
    options.SamplingRate (1, 1) {mustBePositive} = 100e6
    options.DurationEstimated (1, 1){mustBePositive} = 0.3e-6
end

import util.plot_time

data = data(:, slices);

% Repulsive!
t = plan_B.time_cut(data, "MinMagnitude", options.MinMagnitude, "SamplingRate", options.SamplingRate, "DurationEstimated", options.DurationEstimated);
names = compose("#%d", slices);

%% data
subplot(2, 1, 1);
plot_time(abs(data), "PlateNames", names);
ylabel("时域波形");

thresholds = max(abs(data)) * options.MinMagnitude;

for i = 1:length(slices)
    l = yline(thresholds(i), '--', "#"+slices(i), ...
        "Color", "#77AC30", ...
        "LabelVerticalAlignment", "middle", ...
        "LabelHorizontalAlignment", "left" ...
    );
    l.HandleVisibility = 'off'; % Hide in legend
end

%% t
subplot(2, 1, 2);
plot_time(t, "PlateNames", names);
ylim([- .2 1.2]);
ylabel("切分情况");

end
