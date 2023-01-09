function h = prepare_filter(tau, options)
%prepare_filter - 制备数字滤波器
%
% 输入：
% - tau：滤波器的时延；阶数（`length(h)`）等于 2τ + 1
%
% 选项：
% - SamplingRate：采样率，Hz，默认 100 MHz
%
% 输出：
% - h(#time, 1)：滤波器的单位冲激响应
%
% todo 过渡带

arguments
    tau (1, 1) {mustBeInteger, mustBePositive}
    options.SamplingRate (1, 1) {mustBePositive} = 100e6
    options.CenterFreq (1, 1) {mustBePositive} = 7e6
    options.BandWidth (1, 1) {mustBePositive} = 6e6
end

order = 2 * tau + 1;

cutoff_freq = options.CenterFreq + options.BandWidth * [-1 1] / 2;
% analog → digital
cutoff_freq = cutoff_freq / options.SamplingRate;
cutoff_freq = round(cutoff_freq);
% todo N times

% 幅度函数
h_freq = zeros(order, 1);
h_freq(cutoff_freq(1):cutoff_freq(2)) = 1;

% todo 对称以让相位线性

h = fft(h_freq);
h = circshift(h, tau);

end
