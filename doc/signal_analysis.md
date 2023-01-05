# Signal analysis

## 记录

### 检查典型性`check_typicality.m`

```matlab
1. plate #1
  - 回波的整体的标准差是 10.21。（所有帧、所有位置）
  - 而同一帧中，（不同位置）回波的标准差平均只有 5.47，占 0.5%。
2. plate #2
  - 回波的整体的标准差是 10.21。（所有帧、所有位置）
  - 而同一帧中，（不同位置）回波的标准差平均只有 5.78，占 0.6%。
```

![](../fig/check_typicality-std.jpg)

![](../fig/check_typicality-all.jpg)

### 时域分析

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

  这样反推出的波速是 3 km/s 上下。不过老师的文档没说具体是什么材料，但一般金属中声速是 6 km/s，水中是 1.5 km/s，数量级大差不差。

- 无论是哪块板、哪次回波，**回波**基本都只**持续**一两个周期，就淹没在噪声中了。

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

  回波来自板的整体振动，不同位置相位不完全一致，空间平均会削弱振幅。噪声来自空气、仪器，不同位置没太大关联，空间平均削弱得更多。无论是哪种情况，这种削弱都是整体缩小，与时间无关。——这些现象都可以解释。

  另外，X 在 7 μs 附近还有个小峰，不过峰值没超过抑制前的噪声峰值（10），很可能是噪声累积而成的巧合。

## References

- [Load variables from file into workspace - MATLAB load - MathWorks China](https://ww2.mathworks.cn/help/releases/R2020b/matlab/ref/load.html?lang=en)
- [How to create a Matlab module - MATLAB Answers - MATLAB Central](https://ww2.mathworks.cn/matlabcentral/answers/398355-how-to-create-a-matlab-module)
- [包命名空间 - MATLAB & Simulink - MathWorks 中国](https://ww2.mathworks.cn/help/matlab/matlab_oop/scoping-classes-with-packages.html)
- [从 Windows 系统提示符启动 MATLAB 程序 - MATLAB - MathWorks 中国](https://ww2.mathworks.cn/help/matlab/ref/matlabwindows.html)
- [Run MATLAB Script From Command Line | Delft Stack](https://www.delftstack.com/howto/matlab/run-matlab-scripts-from-command-line/)
- [check if a file exists - MATLAB Answers - MATLAB Central](https://ww2.mathworks.cn/matlabcentral/answers/49414-check-if-a-file-exists)
- [matlab2tikz/test at master · matlab2tikz/matlab2tikz](https://github.com/matlab2tikz/matlab2tikz/tree/master/test)
- [删除长度为 1 的维度 - MATLAB squeeze - MathWorks 中国](https://ww2.mathworks.cn/help/releases/R2020b/matlab/ref/squeeze.html)
- [Solids and Metals - Speed of Sound](https://www.engineeringtoolbox.com/sound-speed-solids-d_713.html)
