# Non-Destructive Identification of Mechanically Stronger Composite Plates

$$
\def\sinc{\operatorname{sinc}}
\newcommand\SI[2]{#1\ \mathrm{#2}}  % siunitx (package)
$$

## 简介

今有两薄板，欲探其强度。

以高强度超声波照之，板的两面都会反射回波。若板不够结实（致密），后面的回波会比前面的弱很多。检测两次回波间的衰减，就可了解板的强度。（衰减越轻越好）

- 板：碳纤维复合材料。长 40 mm、宽 20 mm、厚 3 mm。两块板，依次叫X、Y。
- 传感器数据：板上各个位置的波形。空间分辨率为 1 mm，时间采样率为 100 MHz。

本项目运用“数字信号处理”知识，分析这些数据，判断哪块板更好。

## 1 Signal Analysis

### 背景知识

- **数字信号**

  超声波信号 $\eval{x}_t$ 连续，计算机难以处理，抽样（并量化）为数字信号 $\eval{x}_n$ 才方便。实际处理时 $t,n$ 范围必须有限，只能截断。

  一般信号频谱范围有限，低采样率会导致高低频率歧义，采样定理限制了采样率的下限。

- **DFT**

  离散 Fourier 变换（discrete Fourier transform，DFT）及其逆如下。
  $$
  \begin{aligned}
  \eval{X}_k &= \sum_{n=0}^{N-1} \eval{x}_n W^{nk}. \\
  \eval{x}_n &= \frac{1}{N} \sum_{k=0}^{N-1} \eval{X}_k W^{-kn}. \\
  \end{aligned}
  $$
  其中 $N$ 是信号长度（或者说周期），$W = \exp(-2\pi j/N)$。

- **FFT**

  按定义计算 DFT 需 $\order{N^2}$ 次复数乘法，较复杂。存在快速 Fourier 变换（fast FT，FFT），只需 $\order{N \log N}$，提高了计算机处理数字信号的能力。

  FFT 利用 ${W_N}^{nk}$ 的对称性合并首尾项，利用其周期性、对称性、可约性将长序列 DFT 分解为多个短序列 DFT。

  就映射关系而言，FFT 与 DFT 完全等价——它们只是计算过程不同。本项目不关心 FFT 的具体实现，故不再介绍。

- **DFT 逼近连续信号**

  用 DFT 计算出的 $\eval{X}_k$ 可以逼近连续信号的频谱密度 $\eval{X}_{\Omega}$。
  $$
  \Omega
  = \frac{\omega}{T_\text{sample}}
  = \frac{k \frac{2\pi}{N}}{T_\text{sample}}.
  $$
  其中 $\Omega$ 是模拟频率，$\omega$ 是数字频率，$T_\text{sample}$ 是采样周期。

  然而数字信号、DFT毕竟不是原本连续信号、FT（Fourier transform），存在以下问题。

  |     问题     | 原因                                               | 改善方法                              |
  | :----------: | :------------------------------------------------- | :------------------------------------ |
  | **频域混叠** | 时域（周期）取样<br>频域周期化                     | 加紧采样，提高折叠频率                |
  | **栅栏效应** | 频域（周期）取样（只取基频整倍）<br>时域周期化     | 在时域补零凑数                        |
  | **频谱泄露** | 时域截断<br>频域每个横向滤波器的响应太宽，副瓣太强 | 乘缓变（taper）窗，减弱截断处的不连续 |

  在时域补零时窗函数宽度仍应按数据实际长度选取，并且只能提高频谱分辨率，增加总采样时长才能提高频率分辨能力。

  本项目和上面不太一样。

  |     问题     | 本项目情况                                   | 结果                           |
  | :----------: | :------------------------------------------- | ------------------------------ |
  | **频域混叠** | 采样率很高，回波频率远低于折叠频率           | 问题可忽略                     |
  | **栅栏效应** | 回波呈脉冲状，数据中有大段空白，天生就补零了 | 问题可忽略                     |
  | **频谱泄露** | 回波并不持续，不等人为截断自己就结束了       | 信号自身频谱就宽，二次截断无效 |

  这些特点后面也能实际观察到。

### a 读取数据

#### 原理和结果

为了方便之后向量化，我们把两块板的数据统一存到一个变量`data`里。这个张量有如下四个维度。

|   维度   |   意义   | 点数 |       采样间隔        |  记录长度  |
| :------: | :------: | :--: | :-------------------: | :--------: |
|   `#x`   | 空间之一 |  40  |         1 mm          |   40 mm    |
|   `#y`   | 空间之二 |  20  |         1 mm          |   20 mm    |
| `#time`  |   时间   | 905  | 1 / 100 MHz = 0.01 μs |  9.05 μs   |
| `#plate` |  哪块板  |  2   |      （不适用）       | （不适用） |

> 信号是 $\R^2 \cross \R \cross \R \to \R$，上表只介绍了自变量——因变量因信息不足，我并不确定是什么（大约是空气密度），因此下面所有文字、图中，因变量都不标单位。

#### 实现`+util/load_data.m`

实际代码如下。注释已涵盖在正文，以后不再重复，读者您可阅读附件中源代码或用`help <我的函数名>`查看。（例如在`src/`中`help util.load_data`）

```matlab
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
```

这个函数无需输入；后面还有需要输入的，例如`util.plot_time`，如下。函数体开头的 arguments 块验证数据类型，不影响程序逻辑，所以我们下面也都省略。

```matlab
function plot_time(data, LineSpec, options)
%plot_time - 以时间为横轴 plot
%
% plot_time(data)
%
% 输入：
% - data(#time, #plate)：所有板要画的一维数据
% - LineSpec：`plot`的`LineSpec`
%
% 选项：
% - SamplingRate：采样率，Hz，默认 100 MHz
% - PlateNames：板的名字，默认 X、Y。

arguments
    data(:, :)
    LineSpec = "-"
    options.SamplingRate (1, 1) {mustBePositive} = 100e6
    options.PlateNames (1, :) string = ["X" "Y"]
end

n_plate = size(data, 2);
n_time = size(data, 1);

if length(options.PlateNames) ~= n_plate
    warning("有 %d 块板，却提供了 %d 个名字。", n_plate, length(options.PlateNames));
end

t_us = (1:n_time) / options.SamplingRate * 1e6;

plot(t_us, data, LineSpec);
xlabel("$t$ / $\mu$s", "Interpreter", "latex");
legend(options.PlateNames);
grid('on');

end
```

### b 提取典型信号

每块板的数据有两维空间、一维时间，我们重点研究随时间的变化关系，基本独立分析各个空间位置点。

为此需提取典型信号，作为模型来初步分析。

#### 检查典型性：原理和实现`+signal_analysis/check_typicality.m`

选哪里作典型？这是个问题。需简单统计一下。

遍历所有板（`for p = 1:n_plate`）。

```matlab
n_plate = size(data, 4);
assert(length(options.PlateNames) == n_plate);
n_time = size(data, 3);

% ……

for p = 1:n_plate
    % ……
end
```

- **数据整体样貌**
  
  每块板数据的自变量、因变量共 4 维，难以画图直观理解。若将两维空间合并成一维，可画三维图。

  > 合并空间维度：`(#x, #y)` ↦ `#x + #y * 40`，其中 40 是`#x`这一维的点数。
  >
  > ```matlab
  > reshape(data(:, :, :, p), [], n_time)
  > ```
  
  画图代码比较繁琐，意义不大，后面不再罗列，请直接参考附件源代码。
  
  使用`mesh`绘图。为正确标注 $t$，需制备网格。
  
  ```matlab
  t = (1:n_time) / options.SamplingRate;
  xy = 1:size(data, 1) * size(data, 2);
  [t_mesh, xy_mesh] = meshgrid(t, xy);
  ```
  
  然后就能画图了。
  
  ```matlab
  % 准备 figure
  f_all = figure("WindowState", "maximized");
  subplot(n_plate, 1, 1);
  
  for p = 1:n_plate
      % ……（画其它的图）……
  
      % 切换 figure
      figure(f_all);
  
      subplot(n_plate, 1, p);
      mesh(xy_mesh, t_mesh, reshape(data(:, :, :, p), [], n_time));
      xlabel("空间取样点序号");
      ylabel("$t$ / s", "Interpreter", "latex");
      title(options.PlateNames(p));
  end
  ```
  
- **定量计算**

  之所以“定量计算”，是因为分析了“数据整体样貌”，详见后文。
  
  ```matlab
  fprintf("%d. plate #%d\n", p, p);
  
  spatial_std = squeeze(std(data(:, :, :, p), 0, [1 2]));
  all_std = std(data, 0, 'all');
  
  %% Print
  fprintf("  - 数据的整体的标准差是 %.2f。（所有帧、所有位置）\n", all_std);
  fprintf("  - 而同一帧中，（不同位置）数据的标准差平均只有 %.2f，占 %.1f%%。\n", ...
      mean(spatial_std), mean(spatial_std) / all_std * 100);
  ```

#### 检查典型性：结果及分析

将两维空间合并成一维，得到下图。

<figure>
    <img src='../fig/check_typicality-all.jpg'>
    <figcaption>数据整体样貌</figcaption>
</figure>

- 在绝大部分空间位置点，数据都明显包含两次回波，并且这些回波的时间范围几乎一致。
- 不同地方回波的幅度参差不齐，相位看不太清，可能也不完全相同。

于是**<u>猜想：不同地方的数据基本同步变化</u>**，大家都挺典型。

定量计算检验如下。

```matlab
>>> main_typical
1. plate #1
  - 数据的整体的标准差是 10.21。（所有帧、所有位置）
  - 而同一帧中，（不同位置）数据的标准差平均只有 5.47，占 53.6%。
2. plate #2
  - 数据的整体的标准差是 10.21。（所有帧、所有位置）
  - 而同一帧中，（不同位置）数据的标准差平均只有 5.78，占 56.6%。
```

<figure>
    <img src='../fig/check_typicality-std.jpg' style='max-width: 80%;'>
    <figcaption>空间标准差随时间的变化</figcaption>
</figure>

- 空间标准差占比大约一半。

  如果数据完全没有同步变化趋势，占比应接近 100%。

- 空间标准差随时间显著变化。数据本身幅度越大的时刻，空间标准差大致也越大。

  如果数据完全同步变化，不同位置的差异全由板子引起，那么空间标准差应几乎恒定。

所以，不同地方回波**<u>确实有同步变化趋势</u>**，但**<u>只是趋势</u>**，相位等有不小差异。仍可认为**<u>大部分空间位置点都挺典型</u>**。

#### 提取典型信号`+signal_analysis/extract_the_typical.m`

##### 实现

- **输入**`data(#x, #y, #time, #plate)`：所有板的数据。
- **选项**
  - Method：取样方法。
    - center：取中心（默认）
    - mean：取空间的算术平均
    - random：随机取一点，所有板都取同一位置
- **输出**`s(#time, #plate)`：所有板的典型信号。

```matlab
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
```

##### 单元测试

我采用基于脚本的测试框架。例如`extract_the_typical_test.m`测试`extract_the_typical`，如下。

```matlab
import signal_analysis.extract_the_typical

data = rand(4, 3, 5, 2);

%% Shapes
for m = ["mean" "center", "random"]
    assert(isequal( ...
        size(extract_the_typical(data, "Method", m)), ...
        [5 2] ...
    ));
end
```

它帮助事前设计结构、事后验证功能。例如我最初没写`s = squeeze(s)`，若没有上面这测试，我很难一开始就发现，让`(1, 1, #time, #plate)`型张量影响后面分析、画图。

由于测试不影响程序逻辑，后面也不再一一列出。

### c 时域分析

<figure>
    <div style='display: grid; grid-template-columns: 3fr 2fr; gap: 1em;'>
        <img src="../fig/time-center.jpg">
        <img src="../fig/time-center-detail.jpg">
    </div>
    <figcaption>时域典型信号（center）<br>右图是左图的局部放大。</figcaption>
</figure>

- 无论是哪块板，都存在**两次明显回波**，**峰值**为 50–100。

  两次回波分别来自板的前面、后面，符合预期。

- 两块板**回波的位置**不同，X 大约在 3 μs、5 μs，Y 大约在 2 μs、4 μs。两次回波的间隔相近，约 2 μs。

  回波时间差 = 2 × 板厚 / 波速，板厚都是 3 mm，波速也与板无关，故两块板的回波时间差应当一样，符合预期。

  这样反推出的波速是 3 km/s 上下。不过老师的文档只说是碳纤维复合板，不知具体为何材料，但一般金属中声速是 6 km/s，水中是 1.5 km/s，数量级大差不差。

- 无论是哪块板、哪次回波，**回波**基本都只**持续**一两个周期（约 0.3 μs），就淹没在噪声中了。

- 由局部放大图，**回波的周期**约为 0.15 μs，对应频率 7 MHz，确实是超声波，而且 100 MHz 足够采样。

- **噪声**幅度基本不随时间变化，峰值大约为 10。

<figure>
    <div style='display: grid; grid-template-columns: repeat(2, auto); gap: 1em;'>
        <img src="../fig/time-random.jpg">
        <img src="../fig/time-mean.jpg">
    </div>
    <figcaption>时域典型信号（其它取样方法）<br>左：random；右：mean。</figcaption>
</figure>

以上是取板的中心作为典型信号，我还看了下其它取样方法，如上图。

- 左边 random 是随机取别的点，特征和前面 center 相同。

- 右边 mean 是取每帧的空间算术平均，回波、噪声的幅度都变小了，噪声变小得更多，而且不同时刻的相对幅度几乎不变。噪声被抑制后，能看到更长时间的回波。

  回波来自板的整体振动，由前面“检查典型性”分析，不同位置相位不完全一致，空间平均会削弱振幅。噪声来自空气、仪器，不同位置没太大关联，空间平均削弱得更多。无论是哪种情况，这种削弱都是整体缩小，与时间无关。——这些现象都可以解释。

  另外，X 在 7 μs 附近还有个小峰，不过峰值没超过抑制前的噪声峰值（10），很可能是噪声累积而成的巧合。

center 有整体变形，random 结果难以复现，故后面还是采用 center。

### d 频域分析

<figure>
    <div style='display: grid; grid-template-columns: 3fr 2fr; gap: 1em;'>
        <img src="../fig/freq-center.jpg">
        <img src="../fig/freq-center-detail.jpg">
    </div>
    <figcaption>典型信号（center）的幅度谱<br>右图是左图的局部放大。</figcaption>
</figure>

- 时域按 100 MHz 抽样，频域则以 100 MHz 周期化；时域截断在第 905 点，DFT周期化导致频域离散为 905 个点，频谱分辨率为 100 MHz / 905 ≈ 0.1 MHz。上图横轴是模拟频率，由数字频率转换而来。

  根据下面对信号频谱的分析，频域 0.1 MHz 分辨率已足够，不必再在时域补零。

- 幅度谱严格偶对称[^even]，连毛刺都一模一样。（关于 0 MHz 或 50 MHz）

  因为是实信号，频谱共轭对称，故幅度谱偶对称，符合预期。

- **信号**集中在 3–8 MHz（及其对称位置），与时域分析出的 7 MHz 一致。

- X、Y 性态相似，包括信号和噪声。

- **信号**不是冲激，而是有约 5 MHz 的**宽度**，并且峰内部还有宽约 0.5 MHz 的小峰。

  先看包络宽度。时域分析出信号只持续 0.3 μs 左右，时域乘门函数相当于频域卷积 $\sinc$，按谱零点计，带宽 ≈ 2 / 0.3 μs ≈ 6 MHz，与幅度谱包络宽 5 MHz 一致。这时再仔细看频谱，原来主峰之外还能看到一两个副瓣。

  再看小峰宽度。由于频谱分辨率高达 0.1 MHz，0.5 MHz 的小峰并非幻觉，实际标出数据点观察也如此。回顾时域，信号有前后两次回波，相距 $\Delta t \approx \SI{2}{\mu s}$，频谱相位差导致干涉因子 $1 + e^{-j \omega \Delta t}$，体现在幅度谱就是 $\abs{1 + e^{-j\omega \Delta t}} = \abs{\cos(\frac{\omega \Delta t}{2})}$，零点间隔 $\Delta \omega = 2\pi / \Delta t$，即 $\Delta f = 1/\Delta t \approx \SI{0.5}{MHz}$，与小峰宽度一致。

- 噪声是**白噪声**，在所有频率的功率相近，大约为 100。

[^even]: 此处“对称”均指圆周对称。

### 小结

| 信号特征 |              数值              |
| -------: | :----------------------------: |
|     位置 | X: 3 μs, 5 μs<br>Y: 2 μs, 4 μs |
| 时间间隔 |              2 μs              |
| 持续时间 |             0.3 μs             |
|     幅度 |             50–100             |
|     频率 |             7 MHz              |

噪声所有时间、所有频率均匀分布，时域峰值大约为 10。

## 2 Noise Reduction

## 3 Attenuation Estimation

## 4 Part Sentencing

## 总结

- 测试不仅帮助事前设计结构、事后验证功能，还有心理上的积极作用。不过 MATLAB 自己的包命名空间与测试框架不太兼容，我反复倒腾了很多次……感觉历史遗留问题浑身。