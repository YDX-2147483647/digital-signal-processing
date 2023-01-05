function [f_std, f_all] = check_typicality(data, options)
%check_typicality - 检查典型性
%
% [f_std, f_all] = check_typicality(data) 检查 data 不同位置的典型性，返回 figure
% 
% 输入：
% - data(#x, #y, #time, #plate)：所有板的数据
%
% 选项：
% - SamplingRate：采样率，Hz，默认 100 MHz。
%
% 输出：
% - 打印：每块板的情况。
% - 图象：
%   - f_std：不同时刻的空间标准差
%   - f_all：所有数据

arguments
    data(:, :, :, :)
    options.SamplingRate (1, 1) {mustBeNumeric, mustBePositive} = 100e6
    options.PlateNames (1, :) string = ["X" "Y"]
end

n_plate = size(data, 4);
assert(length(options.PlateNames) == n_plate);
n_time = size(data, 3);

t = (1:n_time) / options.SamplingRate;
xy = 1:size(data, 1) * size(data, 2);
[t_mesh, xy_mesh] = meshgrid(t, xy);

f_std = figure("Position", [0 0 900 400]);
subplot(1, n_plate, 1);
f_all = figure("WindowState", "maximized");
subplot(n_plate, 1, 1);

for p = 1:n_plate
    fprintf("%d. plate #%d\n", p, p);

    spatial_std = squeeze(std(data(:, :, :, p), 0, [1 2]));
    all_std = std(data, 0, 'all');

    %% Print
    fprintf("  - 回波的整体的标准差是 %.2f。（所有帧、所有位置）\n", all_std);
    fprintf("  - 而同一帧中，（不同位置）回波的标准差平均只有 %.2f，占 %.1f%%。\n", ...
        mean(spatial_std), mean(spatial_std) / all_std);

    %% Plot
    figure(f_std);
    subplot(1, n_plate, p);
    plot(t, spatial_std);
    xlabel("$t$ / s", "Interpreter", "latex");
    title(options.PlateNames(p) + "的空间标准差");

    figure(f_all);
    subplot(n_plate, 1, p);
    mesh(xy_mesh, t_mesh, reshape(data(:, :, :, p), [], n_time));
    xlabel("空间取样点序号");
    ylabel("$t$ / s", "Interpreter", "latex");
    title(options.PlateNames(p));
end

end
