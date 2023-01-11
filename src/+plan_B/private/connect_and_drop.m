function y = connect_and_drop(x, options)
%connect_and_drop - 连接相邻点，丢弃孤立点
%
% 输入：
% - x(#time或#freq, #slice)：0、1数据
%
% 选项：
% - WindowLength：窗长，最好是奇数
%
% 输出：
% - y(#time或#freq, #slice)：0、1数据，连接了相邻 1，丢弃了孤立 1
%
% 每个 slice 分别处理。

arguments
    x (:, :)
    options.WindowLength (1, 1) {mustBeGreaterThan(options.WindowLength, 2)}
end

% 扩散
y = conv2(x, ones([options.WindowLength 1]), 'same');
% logical or
y = double(y > 1);
% 反向扩散
y = conv2(1 - y, ones([options.WindowLength - 2 1]), 'same');
% logical and, then logical not
y = double(y < 1);

end
