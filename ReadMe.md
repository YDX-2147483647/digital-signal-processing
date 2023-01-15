# 实验：数字信号处理—— Non-Destructive Identification of Mechanically Stronger Composite Plates

2022年11月至2023年1月。

```matlab
>>> cd ./src/
>>> test_all  % 测试

% 针对一个典型信号
>>> main_typical  % 运行
>>> main_typical("Force", true)  % 运行，强制重新绘图

% 针对全部数据
>>> main  % 运行
```

## 文件结构

- `asset/`：截图等附件

- `data/`：数据

- `doc/`：文档，documentation

- `fig/`：图象，figures

  可由`src/`中程序生成。

- `src/`：源代码，sources
  - `main.m`、`main_typical.m`：程序入口
  - `test_all.m`：测试入口
  - `+util/`：utilities
    - `load_data.m`：读取数据
    - `plot_freq.m`：以频率为横轴`plot`
    - `plot_time.m`：以时间为横轴`plot`
    - `plot_cut.m`：展示切分情况
    - `plot_space.m`：以空间为横纵轴`pcolor`
  - `+signal_analysis/`：分析信号
    - `check_typicality.m`：检查典型性
    - `extract_the_typical.m`：提取一个典型信号
    - `extract_the_typical_test.m`（测试）
  - `+noise_reduction/`：抑制噪声
    - `prepare_filter.m`：制备数字滤波器（deprecated）
    - `prepare_reducer.m`：制备数字滤波器
  - `+plan_B/`
    - `private/connect_and_drop.m`：连接相邻点，丢弃孤立点
    - `freq_cut.m`：在频域切分为信号和噪声
    - `time_cut.m`：在时域切分为信号和噪声
    - `cut_test.m`（测试）
  - `+attenuation_estimation/`：估计衰减
    - `get_peaks.m`：提取峰值
    - `get_peaks_test.m`（测试）

## Background Data

- 3 mm thickness.
- Two ultrasonic data files (`Composite□□.mat`)
  - sampling at 100 MHz.
  - 40 mm × 20 mm with 1 mm resolution.
- A higher ultrasonic attenuation indicates a less dense composite part with higher porosity.

## Requirements

**Main goal**: Which composite plate is stronger? (metric: overall mechanical strength)

### Signal analysis

Ultrasonic signals are **noisy** in nature due to the back scattering phenomenon produced by the inherent microstructure of the material. The first step is to extract a typical ultrasonic signal from each composite part under test, and to carry out detailed signal analysis in the time and frequency domains to identify key signal features such as **locations, magnitudes and frequencies** for ultrasonic echoes and noise.

- Time domain analysis
  - [x] Program with comments to read, extract and plot ultrasonic signals
  - [x] Waveforms produced with correct scale
  - [x] Comments on the waveforms observed
- Frequency domain analysis
  - [x] Program with comments to plot magnitude frequency spectrum
  - [x] Spectrum produced with correct scale
  - [x] Comments on the spectrum observed for echo signal and noise

### Noise reduction

With the ultrasonic measurement operating at a particular frequency band, the second step is to implement a suitable **digital filtering system** to reduce the impact of out-of-band **noise** on ultrasonic echoes, and to demonstrate the effectiveness of the filter by comparing the output with respect to input in the time and frequency domains. A good filter should yield an output signal that is as similar to the original signal as possible in the **two ultrasonic echo intervals** (with minimum amplitude distortion) and as near to zero as possible outside the two ultrasonic echo intervals.

- [x] Program with comments to yield filter coefficients and filtered signal
- [x] Filter frequency response produced with correct scale
- [x] Filtered signal produced with correct scale
- [x] Magnitude frequency spectrum of filtered signal
- [x] Comments on output with respect to input in time and frequency domains
- [x] Effects of cut-off frequency and filter order on filtered signal

### Attenuation estimation

The ~~fourth~~ third step is to estimate the **attenuation of the back wall echo with respect to the front wall echo**. This involves application of the filter developed in the second step to the whole ultrasonic record of each composite plate, extraction of the **two peak values** from the front wall and back wall echoes in each ultrasonic signal, and calculation of the echo attenuation at each ultrasonic measurement point. The results should lead to two echo attenuation images for comparative visualisation of two composite plates. 

- [x] Program with comments to filter all signals and generate attenuation image
- [x] Illustration of echo peaks extracted and attenuation estimated
- [x] Attenuation images of two different composite plates
- [x] Comments on attenuation images observed

### Part sentencing

The final step is to show the two distributions of the echo attenuation values obtained from the third step, to compute basic statistics for the two distributions, and to use the results to determine which composite plate has the stronger mechanical strength overall.

- [x] Program with comments for statistical analysis of ultrasonic attenuation
- [x] Ultrasonic attenuation histograms
- [x] Statistics derived from ultrasonic attenuation histograms
- [x] Mechanically stronger composite plate identified with justification

