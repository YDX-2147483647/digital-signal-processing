function y = connect_and_drop(x, options)
%connect_and_drop - 连接相邻点，丢弃孤立点
%
% 输入：
% - x(#time或#freq, #slice)：0、1数据
%
% 选项：
% - MaxGap：可以忽略的连续0最大长度，最好是奇数
% - MinDuration：可以忽略的连续1最大长度，最好是奇数
%
% 输出：
% - y(#time或#freq, #slice)：0、1数据，连接了相邻 1，丢弃了孤立 1
%
% 每个 slice 分别处理。

arguments
    x (:, :)
    options.MaxGap (1, 1) {mustBeGreaterThan(options.MaxGap, 2)}
    options.MinDuration (1, 1) {mustBeGreaterThan(options.MinDuration, 2)}
end

%% 连接相邻点
% 扩散
y = conv2(x, ones(options.MaxGap, 1), 'same');
% ≈ logical or
y = double(y > 1);

% 反向扩散
y = conv2(1 - y, ones(options.MaxGap - 2, 1), 'same');
% ≈ logical and, then logical not
y = double(y < 1);

%% 丢弃孤立点
% 反向扩散
y = conv2(1 - y, ones(options.MinDuration, 1), 'same');
% ≈ logical and, then logical not
y = double(y <= 1);

% 扩散
y = conv2(y, ones(options.MinDuration - 2, 1), 'same');
% ≈ logical or
y = double(y >= 1);

end
