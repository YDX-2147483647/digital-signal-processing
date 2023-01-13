function t = freq_cut(data, options)
%freq_cut - 在频域切分为信号和噪声
%
% 输入：
% - data(#freq, #slice)：所有样本的数据
%
% 选项：
% - MinMagnitude；可判为信号的最小振幅，相对最大振幅而言，默认 0.2
% - SamplingRate：采样率，Hz，默认 100 MHz
% - BandWidthEstimated：估计信号带宽，默认为 6 MHz
%
% 输出：
% - t(#freq, #slice)：每一点的类型判断结果，1表示信号，0表示噪声
%
% 各样本会分别处理。

arguments
    data(:, :)
    options.MinMagnitude (1, 1) {mustBeGreaterThan(options.MinMagnitude, 0), mustBeLessThan(options.MinMagnitude, 1)} = 0.2
    options.SamplingRate (1, 1) {mustBePositive} = 100e6
    options.BandWidthEstimated (1, 1){mustBePositive} = 6e6
end

% 1. 变动时间，将数据绝对值的最大值作为“最大振幅”
% max_overall(1, #slice)
max_overall = max(abs(data));

% 2. 大于“最大振幅” × MinMagnitude 的，初步判断为信号
t = double(abs(data) > max_overall * options.MinMagnitude);

% 3. 将孤立的信号修正为噪声，将连片信号夹杂的噪声修正为信号
% 这里会抑制开头结尾，不过没关系，反正那里没信号。
n_freq = size(data, 1);
window_length = options.BandWidthEstimated / options.SamplingRate * n_freq;
t = connect_and_drop( ...
    t, ...
    "MaxGap", round(window_length / 2) * 2 - 1, ...
    "MinDuration", round(window_length / 4) * 2 - 1 ...
);

end
