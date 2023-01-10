function plot_time(data, LineSpec, options)
%plot_time - 以时间为横轴 plot
%
% plot_time(data)
%
% 输入：
% - data(#time, #plate)：所有板要画的一维数据
% - LineSpec：`plot`的`LineSpec`
%
% 选项：
% - SamplingRate：采样率，Hz，默认 100 MHz
% - PlateNames：板的名字，默认 X、Y。

arguments
    data(:, :)
    LineSpec = "-"
    options.SamplingRate (1, 1) {mustBePositive} = 100e6
    options.PlateNames (1, :) string = ["X" "Y"]
end

n_plate = size(data, 2);
assert(length(options.PlateNames) == n_plate);
n_time = size(data, 1);

t_us = (1:n_time) / options.SamplingRate * 1e6;

plot(t_us, data, LineSpec);
xlabel("$t$ / $\mu$s", "Interpreter", "latex");
legend(options.PlateNames);
grid('on');

end
