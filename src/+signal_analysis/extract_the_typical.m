function s = extract_the_typical(data, options)
%extract_the_typical - 提取一个典型信号
%
% s = extract_the_typical(data, "Method", "mean") 采用算术平均作为典型
%
% 输入：
% - data(#x, #y, #time, #plate)：所有板的数据
% 
% 选项：
% - Method：取样方法。
%   - center：取中心
%   - mean：取空间的算术平均
%   - random：随机取一点，所有板都取同一位置
%
% 输出：
% - s(#time, #plate)：所有板的典型信号

arguments
    data(:, :, :, :)
    options.Method (1, 1) string {mustBeMember(options.Method, ["mean", "center", "random"])}
end

if options.Method == "mean"
    s = mean(data, [1 2]);
else

    if options.Method == "center"
        xy = round(size(data, [1 2]) / 2);
    else
        xy = [randi(size(data, 1)) randi(size(data, 2))];
    end

    s = data(xy(1), xy(2), :, :);
end

s = squeeze(s);

end
