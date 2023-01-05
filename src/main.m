function main(options)
% 选项：
% - Force：是否强制重新绘图，默认不强制

arguments
    options.Force (1, 1) logical = false
end

import util.plot_time

rng(42); % 为了容易复现，随便规定一下随机数种子

%% 读取数据

% data(#x, #y, #time, #plate)
data = cat( ...
4, ...
    load("../data/CompositeX.mat").CompositeX, ...
    load("../data/CompositeY.mat").CompositeY ...
);

%% Signal Analysis
fprintf("## Signal Analysis\n\n");

% 0. Check typicality

if options.Force || ~all(isfile("../fig/check_typicality-" + ["std" "all"] + ".jpg"))
    [f_std, f_all] = signal_analysis.check_typicality(data);
    exportgraphics(f_std, "../fig/check_typicality-std.jpg");
    exportgraphics(f_all, "../fig/check_typicality-all.jpg");
end

% 1. Extract and plot ultrasonic signals

the_typical = signal_analysis.extract_the_typical(data, "Method", "center");

if options.Force || ~all(isfile("../fig/time-center" + ["" "-detail"] + ".jpg"))
    figure;
    plot_time(the_typical);
    title("时域典型信号（center）");
    exportgraphics(gcf, "../fig/time-center.jpg");

    xlim([1.2 3.2]);
    ylim([-20 70]);
    exportgraphics(gcf, "../fig/time-center-detail.jpg");
end

if options.Force || ~all(isfile("../fig/time-" + ["random" "mean"] + ".jpg"))
    % 也看看其它取样方法
    for m = ["random" "mean"]
        figure;
        plot_time(signal_analysis.extract_the_typical(data, "Method", m));
        title("时域典型信号（" + m + "）");
        exportgraphics(gcf, "../fig/time-" + m + ".jpg");
    end

end

end
