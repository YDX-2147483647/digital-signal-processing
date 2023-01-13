function plot_space(ratios, options)
%plot_space - 以空间为横纵轴 pcolor
%
% 输入：
% - ratios(#x, #y, #plate)：所有板要画的二维数据
%
% 选项：
% - Resolution：分辨率，mm，默认 1 mm
% - PlateNames：板的名字，默认 X、Y。

arguments
    ratios(:, :, :)
    options.Resolution (1, 1) {mustBePositive} = 1
    options.PlateNames (1, :) string = ["X" "Y"]
end

n_x = size(ratios, 1);
n_y = size(ratios, 2);
n_plate = size(ratios, 3);

if length(options.PlateNames) ~= n_plate
    warning("有 %d 块板，却提供了 %d 个名字。", n_plate, length(options.PlateNames));
end

tiledlayout('flow');

x = (0:n_x - 1) * options.Resolution;
y = (0:n_y - 1) * options.Resolution;
[y, x] = meshgrid(y, x);

for p = 1:n_plate
    nexttile;

    pcolor(x, y, ratios(:, :, p));
    colorbar;
    caxis([0.3 1]);
    title(options.PlateNames(p));
    xlabel("$x$ / mm", "Interpreter", "latex");
    ylabel("$y$ / mm", "Interpreter", "latex");
end

end
