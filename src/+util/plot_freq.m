function plot_freq(data, options)
%plot_freq - 以时间为横轴 plot
%
% plot_freq(data)
%
% 输入：
% - data(#freq, #plate)：所有板要画的一维数据
%
% 选项：
% - SamplingRate：采样率，Hz，默认 100 MHz
% - PlateNames：板的名字，默认 X、Y。
% - Shift：是否移位为正负频率，默认不移位

arguments
    data(:, :)
    options.SamplingRate (1, 1) {mustBePositive} = 100e6
    options.PlateNames (1, :) string = ["X" "Y"]
    options.Shift (1, 1) logical = false
end

n_plate = size(data, 2);
assert(length(options.PlateNames) == n_plate);
n_freq = size(data, 1);

f_MHz = (0:n_freq - 1) / n_freq * options.SamplingRate / 1e6;

if options.Shift
    half_freq = round(n_freq / 2);
    f_MHz(half_freq:end) = f_MHz(half_freq:end) - options.SamplingRate / 1e6;
end

plot(f_MHz, data);
xlabel("$f$ / MHz", "Interpreter", "latex");
legend(options.PlateNames);
grid('on');

end
