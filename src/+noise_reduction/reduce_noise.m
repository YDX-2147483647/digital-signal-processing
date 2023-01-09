function reduced = reduce_noise(raw)
%reduce_noise - 抑制噪声
%
% 输入：
% - raw(#time, #slice)：所有样本的数据
% 输出：
% - reduced(#time, #slice)：所有样本的数据

arguments
    raw(:, :)
end

% todo
reduced = raw;

end
