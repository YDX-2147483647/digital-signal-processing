function main(options)
% 选项：
% - Force：是否强制重新绘图，默认不强制

arguments
    options.Force (1, 1) logical = false
end

% data(#x, #y, #time, #plate)
data = cat( ...
4, ...
    load("../data/CompositeX.mat").CompositeX, ...
    load("../data/CompositeY.mat").CompositeY ...
);

%% Signal Analysis
fprintf("## Signal Analysis\n\n");

if options.Force || ~all(isfile(["../fig/check_typicality-std.jpg", "../fig/check_typicality-all.jpg"]))
    [f_std, f_all] = signal_analysis.check_typicality(data);
    exportgraphics(f_std, "../fig/check_typicality-std.jpg");
    exportgraphics(f_all, "../fig/check_typicality-all.jpg");
end

end
