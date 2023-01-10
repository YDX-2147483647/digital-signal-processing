function main(options)
% 选项：
% - Force：是否强制重新绘图，默认不强制

arguments
    options.Force (1, 1) logical = false
end

import util.plot_time
import util.plot_freq

rng(42); % 为了容易复现，随便规定一下随机数种子

%% 读取数据
data = util.load_data();

%% Signal Analysis
fprintf("## Signal Analysis\n\n");

% 0. Check typicality

if options.Force || ~all(isfile("../fig/check_typicality-" + ["std" "all"] + ".jpg"))
    [f_std, f_all] = signal_analysis.check_typicality(data);
    exportgraphics(f_std, "../fig/check_typicality-std.jpg");
    exportgraphics(f_all, "../fig/check_typicality-all.jpg");
end

% 1. Extract and plot ultrasonic signals

typical_time = signal_analysis.extract_the_typical(data, "Method", "center");

if options.Force || ~all(isfile("../fig/time-center" + ["" "-detail"] + ".jpg"))
    figure;
    plot_time(typical_time);
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

% 2. Plot magnitude frequency spectrum

typical_freq = fft(typical_time); % 默认只变换首个维度（即 #time）

if options.Force || ~all(isfile("../fig/freq-center" + ["" "-detail"] + ".jpg"))
    figure;
    plot_freq(abs(typical_freq)); % 只画幅度，忽略相位
    title("典型信号（center）的幅度谱");
    exportgraphics(gcf, "../fig/freq-center.jpg");

    xlim([0 20]);
    exportgraphics(gcf, "../fig/freq-center-detail.jpg");
end

%% Plan B
fprintf("## Plan B\n\n");

fprintf("### Time cut\n\n");
t = plan_B.time_cut(typical_time);

if options.Force || ~all(isfile("../fig/Plan_B/" + ["cliff" "slope"].' + "-" + ["time" "freq" "cut"] + ".jpg"), "all")

    for label = ["cliff" "slope"]
        %% cut
        if label == "cliff"
            cut = t;
        else
            a = 0.03e-6 * 100e6;
            kernel = exp(- (-5 * a:5 * a) .^ 2 / a ^ 2).';
            cut = conv2(t, kernel, "same");
            cut = cut ./ max(cut);
        end

        s = typical_time .* cut;
        n = typical_time .* (1 - cut);

        fig = tiledlayout(2, 1);
        title(fig, "切分情况（" + label + "）");

        nexttile;
        plot_time(cut);
        ylim([-0.2 1.2]);
        title("时域");

        nexttile;
        plot_freq(abs(fft(cut)), "Shift", true);
        title("频域");
        exportgraphics(fig, "../fig/Plan_B/" + label + "-cut.jpg");

        %% time
        fig = tiledlayout(2, 1);
        title(fig, "时域裁切结果（" + label + "）");

        nexttile;
        plot_time(s);
        ylabel("信号");

        nexttile;
        plot_time(n);
        ylabel("噪声");

        exportgraphics(fig, "../fig/Plan_B/" + label + "-time.jpg");

        %% freq
        fig = tiledlayout(2, 1);
        title(fig, "时域裁切结果（" + label + "）的幅度谱");

        nexttile;
        plot_freq(abs(fft(s)));
        ylabel("信号");

        nexttile;
        plot_freq(abs(fft(n)));
        ylabel("噪声");

        exportgraphics(fig, "../fig/Plan_B/" + label + "-freq.jpg");
    end

end

% 对照组
fprintf("### Frequency cut (control group)\n\n");
t_control = plan_B.freq_cut(typical_freq);

if options.Force || ~all(isfile("../fig/Plan_B/control-" + ["cliff" "slope"].' + "-" + ["time" "freq" "cut" "compare"] + ".jpg"), "all")

    for label = ["cliff" "slope"]
        %% cut
        if label == "cliff"
            cut = t_control;
        else
            a = 0.6e6/100e6 * size(typical_freq, 1);
            kernel = exp(- (-5 * a:5 * a) .^ 2 / a ^ 2).';
            cut = conv2(t_control, kernel, "same");
            cut = cut ./ max(cut);
        end

        s_freq = typical_freq .* cut;
        n_freq = typical_freq .* (1 - cut);
        % imag ≈ 0 because of symmetry
        s_time = real(ifft(s_freq));
        n_time = real(ifft(n_freq));

        fig = tiledlayout(2, 1);
        title(fig, "对照组：切分情况（" + label + "）");

        nexttile;
        plot_time(real(ifft(cut)));
        title("时域");

        nexttile;
        plot_freq(abs(cut), "Shift", true);
        title("频域");
        ylim([-0.2 1.2]);
        exportgraphics(fig, "../fig/Plan_B/control-" + label + "-cut.jpg");

        %% time
        fig = tiledlayout(2, 1);
        title(fig, "对照组：频域裁切结果的时域序列（" + label + "）");

        nexttile;
        plot_time(s_time);
        ylabel("信号");

        nexttile;
        plot_time(n_time);
        ylabel("噪声");

        exportgraphics(fig, "../fig/Plan_B/control-" + label + "-time.jpg");

        %% freq
        fig = tiledlayout(2, 1);
        title(fig, "对照组：频域裁切结果（" + label + "）");

        nexttile;
        plot_freq(abs(s_freq));
        ylabel("信号");

        nexttile;
        plot_freq(abs(n_freq));
        ylabel("噪声");

        exportgraphics(fig, "../fig/Plan_B/control-" + label + "-freq.jpg");

        %% compare
        figure("WindowState", "maximized");
        fig = tiledlayout(2, 1);
        title(fig, "频域裁切（" + label + "）效果");

        names = ["X" "Y"];

        for p = 1:2
            nexttile;
            plot_time(typical_time(:, p), ".", "PlateNames", "原始");
            hold on;
            plot_time(s_time(:, p), "PlateNames", "处理后");
            hold off;
            legend(["原始" "处理后"]);
            ylabel(names(p));
        end

        exportgraphics(fig, "../fig/Plan_B/control-" + label + "-compare.jpg");
    end

end

end
