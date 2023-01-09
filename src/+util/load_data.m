function data = load_data()
%load_data - 读取数据
%
% data = load_data()
%
% 输出：
% - data(#x, #y, #time, #plate)：所有板的数据

data = cat( ...
4, ...
    load("../data/CompositeX.mat").CompositeX, ...
    load("../data/CompositeY.mat").CompositeY ...
);

end
