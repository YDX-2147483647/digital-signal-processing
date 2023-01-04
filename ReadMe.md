# 实验：数字信号处理—— Non-Destructive Identification of Mechanically Stronger Composite Plates

2022年11月至2023年1月。

```matlab
>>> main  % 运行
>>> main("Force", true)  % 运行，强制重新绘图
```

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
  - [ ] Program with comments to read, extract and plot ultrasonic signals
  - [ ] Waveforms produced with correct scale
  - [ ] Comments on the waveforms observed
- Frequency domain analysis
  - [ ] Program with comments to plot magnitude frequency spectrum
  - [ ] Spectrum produced with correct scale
  - [ ] Comments on the spectrum observed for echo signal and noise

### Noise reduction

With the ultrasonic measurement operating at a particular frequency band, the second step is to implement a suitable **digital filtering system** to reduce the impact of out-of-band **noise** on ultrasonic echoes, and to demonstrate the effectiveness of the filter by comparing the output with respect to input in the time and frequency domains. A good filter should yield an output signal that is as similar to the original signal as possible in the **two ultrasonic echo intervals** (with minimum amplitude distortion) and as near to zero as possible outside the two ultrasonic echo intervals.

- [ ] Program with comments to yield filter coefficients and filtered signal
- [ ] Filter frequency response produced with correct scale
- [ ] Filtered signal produced with correct scale
- [ ] Magnitude frequency spectrum of filtered signal
- [ ] Comments on output with respect to input in time and frequency domains
- [ ] Effects of cut-off frequency and filter order on filtered signal

### Attenuation estimation

The ~~fourth~~ third step is to estimate the **attenuation of the back wall echo with respect to the front wall echo**. This involves application of the filter developed in the second step to the whole ultrasonic record of each composite plate, extraction of the **two peak values** from the front wall and back wall echoes in each ultrasonic signal, and calculation of the echo attenuation at each ultrasonic measurement point. The results should lead to two echo attenuation images for comparative visualisation of two composite plates. 

- [ ] Program with comments to filter all signals and generate attenuation image
- [ ] Illustration of echo peaks extracted and attenuation estimated
- [ ] Attenuation images of two different composite plates
- [ ] Comments on attenuation images observed

### Part sentencing

The final step is to show the two distributions of the echo attenuation values obtained from the third step, to compute basic statistics for the two distributions, and to use the results to determine which composite plate has the stronger mechanical strength overall.

- [ ] Program with comments for statistical analysis of ultrasonic attenuation
- [ ] Ultrasonic attenuation histograms
- [ ] Statistics derived from ultrasonic attenuation histograms
- [ ] Mechanically stronger composite plate identified with justification
