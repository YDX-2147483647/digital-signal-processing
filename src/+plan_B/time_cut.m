function t = time_cut(data, options)
%time_cut - 在时域切分为数据和噪声
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
t = double(data > max_overall * options.MinMagnitude);

% 3. 将孤立的信号修正为噪声，将连片信号夹杂的噪声修正为信号
% 这里会抑制开头结尾，不过没关系，反正那里没信号。
% 窗长最好是奇数
window_length = round(options.DurationEstimated * options.SamplingRate / 2) * 2 - 1;
assert(window_length > 2);
% 扩散
t = conv2(t, ones([window_length 1]), 'same');
% logical or
t = double(t > 1);
% 反向扩散
t = conv2(1 - t, ones([window_length - 2 1]), 'same');
% logical or, then logical and
t = double(t < 1);

%% Check

n_echo = sum(diff(t) == 1);

if any(n_echo ~= 2)
    warning("每份样本都应检出两次回波，但有些样本异常。各样本检出回波次数为 [%s]。", ...
        join(string(n_echo)));
end

end
