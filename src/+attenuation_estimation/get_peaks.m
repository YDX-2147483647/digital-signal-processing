function peaks = get_peaks(data, t)
%get_peaks - 提取峰值
%
% 输入：
% - data(#time, #slice)：所有样本的数据
% - t(#time, #slice)：每一点的类型，1表示信号，0表示噪声
%
% 输出：
% - peaks(#peak, #slice)：每个样本的前两次峰值

arguments
    data(:, :)
    t(:, :) {mustBeMember(t, [0 1])}
end

assert(isequal(size(data), size(t)));

n_slice = size(data, 2);
t = diff(cat(1, zeros(1, n_slice), t, zeros(1, n_slice)));

peaks = zeros(2, n_slice);

for s = 1:n_slice
    starts = find(t(:, s) == 1, 2);
    ends = find(t(:, s) == -1, 2) - 1;

    for p = 1:2
        peaks(p, s) = max(abs(data(starts(p):ends(p), s)));
    end

end

end
