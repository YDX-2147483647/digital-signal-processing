function s = extract_the_typical(data, options)
%extract_the_typical - 提取一个典型信号
%
% s = extract_the_typical(data, "Method", "mean") 采用算术平均作为典型
% s = extract_the_typical(data, "Method", "center") 取中心作为典型
%
% 输入：
% - data(#x, #y, #time)：单个板的数据
%
% 输出：一个典型信号

arguments
    data(:, :, :)
    options.Method (1, 1) string {mustBeMember(options.Method, ["mean", "center"])}
end

if options.Method == "mean"
    s = mean(data, [1 2]);
else
    xy = round(size(data, [1 2]) / 2);
    s = data(xy(1), xy(2), :);
end

s = squeeze(s);

end
