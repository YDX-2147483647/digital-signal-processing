function t = time_cut(data, options)
%time_cut - 在时域切分为信号和噪声
%
% 输入：
% - data(#time, #slice)：所有样本的数据
%
% 选项：
% - MinMagnitude；可判为信号的最小振幅，相对最大振幅而言，默认 0.2
% - SamplingRate：采样率，Hz，默认 100 MHz
% - DurationEstimated：估计信号持续时间，默认为 0.3 μs
%
% 输出：
% - t(#time, #slice)：每一点的类型判断结果，1表示信号，0表示噪声
%
% 各样本会分别处理。
%
% 如果某些样本检出的回波次数不是2，会发出警告。

arguments
    data(:, :)
    options.MinMagnitude (1, 1) {mustBeGreaterThan(options.MinMagnitude, 0), mustBeLessThan(options.MinMagnitude, 1)} = 0.2
    options.SamplingRate (1, 1) {mustBePositive} = 100e6
    options.DurationEstimated (1, 1){mustBePositive} = 0.3e-6
end

% 1. 变动时间，将数据绝对值的最大值作为“最大振幅”
% max_overall(1, #slice)
max_overall = max(abs(data));

% 2. 大于“最大振幅” × MinMagnitude 的，初步判断为信号
t = double(abs(data) > max_overall * options.MinMagnitude);

% 3. 将孤立的信号修正为噪声，将连片信号夹杂的噪声修正为信号
% 这里会抑制开头结尾，不过没关系，反正那里没信号。
window_length = options.DurationEstimated * options.SamplingRate;
t = connect_and_drop( ...
    t, ...
    "MaxGap", round(window_length / 2) * 2 - 1, ...
    "MinDuration", max([3, round(window_length / 10) * 2 - 1]) ...
);

%% Check

n_echo = sum(diff(t) == 1);

if any(n_echo ~= 2)
    indices = find(n_echo ~= 2);
    values = n_echo(indices);
    warning("每份样本都应检出两次回波，但有 %d 份样本异常。各样本检出回波次数如下。\n%s.", ...
        length(indices), ...
        join(compose("%d (#%d)", [values; indices].'), ", "));
end

end
