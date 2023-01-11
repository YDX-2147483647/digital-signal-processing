# Plan B

## 源起

### 时域卷积去噪几乎不影响最终结果

去噪并非目的，只是理解信号的手段。

本项目希望评估板材质量，方法是测量前后面回波衰减程度。

任务书对去噪（noise reduction）的阐释如下[^u]，这一步的目标在时域分为两块，“回波部分”要求尽可能不改变原始信号，“其它部分”则要求尽可能为零。

[^u]:原文未分点，无下划线强调。后同。

> A good filter should yield an output signal that is …
>
> - as <u>similar to the original</u> signal as possible <u>in</u> the two ultrasonic echo intervals (with minimum amplitude distortion)  …
> - and as <u>near to zero</u> as possible <u>outside</u> the two ultrasonic echo intervals.

在后续步骤（attenuation estimation）中，又规定了如下处理方法。

> … extraction of the two <u>peak values</u> from the front wall and back wall echoes in each ultrasonic signal …

这意味着，**<u>最终判决结果只取决于“回波部分”</u>**（的时域峰值），**根本不涉及“其它部分”**。换句话说，即使不计算“其它部分”的时域，也能做出完全一样的判决。

因此，前面列的第二点目标其实没有用，完全不必管“其它部分”处理成什么样，只要追求第一点，让“回波部分”保持原貌即可。那么，什么滤波器最能保持信号原貌呢？Dirac δ！也就是不滤波……

——这样说当然太绝对了：回波部分也存在噪声，时域卷积可以抑制这部分噪声。“回波部分”希望贴近原始“<u>信号</u>”，并不直接希望贴近原始“<u>数据</u>”；只是本项目信噪比本来就高，二者很接近罢了。

总之，时域卷积去噪的必要性至少需打个问号，与其它路线比较比较再做决定。

### 时域还是频域？

#### 一般场景

本项目属于“事后”分析，不追求实时性，运算复杂度不用优先考虑。以下重点关注方法的有效性。

<figure>
    <img src='../asset/Cosine_Series_Plus_Noise.png' style='max-width: 60%;'>
    <figcaption>在一般场景中，信号、噪声在时域混成一团，难以分辨｜<a href='https://commons.wikimedia.org/wiki/File:Cosine_Series_Plus_Noise.png'>Wikimedia Commons</a></figcaption>
</figure>

如上图，在一般信号处理场景（如通信），信号、噪声都一直持续，在时域混成一团，难以分辨。

<figure>
    <img src='../asset/Cosine_Series_Plus_Noise_TFM.png' style='max-width: 60%;'>
    <figcaption>在一般场景中，噪声在频域仍然分散，但信号相对集中，十分明显｜<a href='https://commons.wikimedia.org/wiki/File:Cosine_Series_Plus_Noise_TFM.png'>Wikimedia Commons</a></figcaption>
</figure>

在频域就不一样了。噪声一般是白噪声，分散在各个频率上；而信号集中在几个频率段附近，十分明显。二者虽也略微重叠，但不像时域那样完全混乱了。

滤波器时域卷积，频域相乘。它在频域保留信号的频率段，抛弃其它频率，从而挑出信号。

注意在信号、噪声在频域重叠部分，信号没被抑制，噪声也没被抑制。然而这部分信号占信号的绝大多数，这部分噪声却只占噪声的一小部分。两相比较，信号、噪声的能量比大为提高，剩下那点~儿~噪声就可忽略不计了。

简而言之，一般场景下**<u>信号在时域分散、频域集中</u>**，而噪声在时域、频域都分散，故时域卷积（频域相乘）滤波器能有效分离出信号。

#### 本场景

本场景并非如此。

之所以用超声波探伤，在物理上是因为它有如下特点。（与声波、次声波等更低频的机械波相比）

|  物理特点  |                         对探伤的价值                         |
| :--------: | :----------------------------------------------------------: |
|   波长短   |                         空间分辨率高                         |
| 能流密度高 | 短时间就有足够能量体现缺陷<br>⇒ 时间分辨率高，能分出前、后面的回波 |
|   周期短   |                              —                               |

于是，这里信号的时域、频域特点就和一般不同，简直快反过来了。噪声特点同前。如下图。

<figure>
    <div style='display: grid; grid-template-columns: repeat(2, auto); gap: 1em;'>
        <img src='../asset/Cosine_Series_Plus_Noise.png'>
        <img src='../asset/Cosine_Series_Plus_Noise_TFM.png'>
    </div>
    <figcaption>一般场景中，时域、频域情况｜出处同前</figcaption>
</figure>

<figure>
    <div style='display: grid; grid-template-columns: repeat(2, auto); gap: 1em;'>
        <img src="../fig/time-center.jpg">
        <img src="../fig/freq-center.jpg">
    </div>
    <figcaption>本场景中，时域、频域情况</figcaption>
</figure>

定量地看本场景，**<u>信号在两域集中程度相近，时域略胜一筹</u>**。甚至时域是实打实的宽度，频域只是第一谱零点带宽。


|       域 | 信号宽度 | 噪声宽度 | 重叠比例 |
| -------: | :------: | :------: | :------: |
| **时域** | ~0.3 μs  |  ~9 μs   |    3%    |
| **频域** |  ~5 MHz  | 100 MHz  |    5%    |

> 为简洁，上表措辞含糊，一一解释如下。
>
> - 信号宽度
>
>   - 时域：每一次回波的持续时间。
>   - 频域：回波频谱的第一谱零点带宽。
>
> - 噪声宽度：
>
>   - 时域：噪声持续时间，也就是数据记录时间。
>   - 频域：噪声频谱本无限，然因时域离散采样，混叠成了 0–100 MHz。
>
> - 重叠比例：信号、噪声宽度之比。
>
>   因为无论哪个域，噪声宽度都是满的，二者重叠范围就是信号范围。
>
>   重叠比例与信号集中程度负相关。
>
> 此表只考虑了集中程度，未考虑能量——由 Parseval 定理，无论在哪域能量都不变。比较不同信号时才需考虑能量。

这样看来，一般滤波器是到频域相乘，反而是把信号、噪声搅一搅再处理，无甚好处；不如直接在时域处理。

## 算法

### 划分区域`time_cut.m`、`freq_cut.m`

无论在哪域裁切，都需确定上下限。这里以时域为例介绍。

`time_cut`函数在时域将数据切分为信号和噪声。

- **输入**`data(#time, #slice)`：所有样本的数据。

  各样本会分别处理，第二维只是为了方便向量化。

- **选项**
  
  - `MinMagnitude`；可判为信号的最小振幅，相对最大振幅而言，默认 0.2。
  - `SamplingRate`：采样率，Hz，默认 100 MHz。
  - `DurationEstimated`：估计信号持续时间，默认为 0.3 μs。
  
- **输出**`t(#time, #slice)`：每一点的类型判断结果，**<u>1表示信号，0表示噪声</u>**。

下面是具体实现。

1. **变动时间，将数据绝对值的最大值作为“最大振幅”。**

   ```matlab
   % max_overall(1, #slice)
   max_overall = max(abs(data));
   ```

2. **大于“最大振幅” × `MinMagnitude`的，初步判断为信号。**

   ```matlab
   t = double(abs(data) > max_overall * MinMagnitude);
   ```

3. **将孤立的信号修正为噪声，将连片信号夹杂的噪声修正为信号。**

   这里会抑制开头结尾，不过没关系，反正那里没信号。

   `DurationEstimated * SamplingRate`是估计信号持续*点数*，`window_length`取一与它接近的奇数。

   ```matlab
   window_length = round(DurationEstimated * SamplingRate / 2) * 2 - 1;
   t = connect_and_drop(t, "WindowLength", window_length);
   ```

   这一步会在之后进一步解释。

4. **检查。**

   如果某些样本检出的回波次数不是2，会发出警告。

   ```matlab
   n_echo = sum(diff(t) == 1);
   
   if any(n_echo ~= 2)
       warning("每份样本都应检出两次回波，但有些样本异常。各样本检出回波次数为 [%s]。", ...
           join(string(n_echo)));
   end
   ```

### 连邻弃孤`connect_and_drop.m`

上面第三步就用到了`connect_and_drop`。

#### 作用

- **连接相邻点**（connect）

  信号正负振荡，单纯检测取值会漏掉许多零点，其实它们也是信号，应判为 1。
  $$
  \begin{array}{c}
  1 & \color{red} 0 & 1 & 1 & \color{red} 0 & 1 & 1 & \color{red} 0 & 1 \\
  & \downarrow &&& \downarrow &&& \downarrow \\
  1 & \color{green} 1 & 1 & 1 & \color{green} 1 & 1 & 1 & \color{green} 1 & 1 \\
  \end{array}
  $$

  > 为简便，只讨论单个样本，实际程序支持多个样本向量化。

- **丢弃孤立点**（drop）

  没有信号处，噪声可能偶尔突发越过门限，但往往孤立，这些误判应修正为 0。
  $$
  \begin{array}{c}
  0 & 0 & 0 & \color{red} 1 & 0 & 0 & 0 \\
  &&& \downarrow \\
  0 & 0 & 0 & \color{green} 0 & 0 & 0 & 0 \\
  \end{array}
  $$

#### 设计

- **输入**`x(#time或#freq, #slice)`：0、1数据。

    数据形式同`time_cut`、`freq_cut`的输出。

    `connect_and_drop`并不知道数据在哪个域，它的第一个维度任意。

    和刚才一样，每个 slice 分别处理，第二维只是为了方便向量化。

- **选项**
    
    - `WindowLength`：窗长，最好是奇数。
    
      `connect_and_drop`不涉及物理情景，直接用点数指定窗长。
    
- **输出**`y(#time或#freq, #slice)`：同`x`，只是修正了误判。

#### 实现

1. **扩散**

  ```matlab
  y = conv2(x, ones([WindowLength 1]), 'same');
  ```

  每个 1 向外“扩散”。

  - 相邻点两边的 1 会覆盖中间的 0。
    $$
    \begin{array}{clcccrc}
    &   \cdots & 1 & \color{red}0 & 1 & \cdots \\
    &        ↙ & ↓ &     ↘\,↙     & ↓ & ↘ \\
    \cdots & 3 & 2 &  \boxed{2}   & 2 & 3 & \cdots \\
    \end{array}
    $$

    > 以上窗长为 3。

  - 孤立点也会扩散，要等到之后才除掉。

2. **logical or**

  ```matlab
  y = double(y > 1);
  ```

  - 相邻点两边的 1 还是 1，中间的 0 则修正为 1 了。
  - 孤立点变成了一小串 1。

  这两步下来，相当于对每个窗内的数据进行逻辑或。例如前面以 0 为中心的窗取到 1 0 1，逻辑或得 1。

3. **反向扩散**

  首先 0、1 互换，`1 - y`。然后像刚才一样卷积。

  ```matlab
  y = conv2(1 - y, ones([WindowLength - 2 1]), 'same');
  ```

  原有 1 的边缘向内收缩。

  - 相邻点内部不受影响。
  - 孤立点会收缩消失。（之前在 1. 扩散部分会抵消）

4. **logical and, then logical not**

  ```matlab
  y = double(y < 1);
  ```

  反转 0、1 抵消前一步，其余同 2.。

## 记录

### 对照组

先来看对照组：用带通滤波器去噪，在频域裁切，选出频率。

实际滤波器的频率响应通带不平、阻带衰减有限。这里先用理想*矩形*频率响应（记作 cliff）试验。如下图，根据第一步 signal analysis 得出的频谱（左半图），用前述算法确定滤波器的上下截止频率，进而给出滤波器的特性（右半图）。

<figure>
    <div style='display: grid; grid-template-columns: 1fr 2fr; gap: 1em;'>
        <img src="../fig/freq-center.jpg">
        <img src="../fig/Plan_B/control-cliff-cut.jpg">
    </div>
    <figcaption>频域切分情况<br>左：数据的频谱；右：滤波器的单位冲激响应（上）和幅频响应（下）。</figcaption>
</figure>

> 为最后公平比较，X、Y 最好采用相同滤波器。这里只是试验，仅用两份样本示意，先略去后续步骤。

如下图，直接在频域相乘实现滤波，分解出信号、噪声。

<figure>
    <img src="../fig/Plan_B/control-cliff-freq.jpg" style='max-width: 60%;'>
    <figcaption>频域裁切结果<br>上：信号；下：噪声。</figcaption>
</figure>

还原到时域如下。

<figure>
    <img src="../fig/Plan_B/control-cliff-time.jpg">
    <figcaption>频域裁切结果的时域序列<br>上：信号；下：噪声。</figcaption>
</figure>

<figure>
    <img src="../fig/Plan_B/control-cliff-compare.jpg">
    <figcaption>频域裁切效果<br>实线：处理后的信号；点：原始数据。<br>上：X；下：Y。</figcaption>
</figure>

- 频域切得干干净净。
- 在回波以外的时间，抑制了噪声，但不同频率的噪声抑制程度不同，与信号同频的噪声没被抑制。
- 两次回波时间上，数据几乎没变化，主要是更平滑，有峰值降低、持续时间变长的轻微趋势。

以上 cliff 滤波器完全没有过渡带。若引入过渡带（记作 slope，如下图），可能抑制回波持续时间变长的趋势。

> 过渡带是高斯式，半径从带宽的 1/20 试到 1/2，最终效果都差不多。以下是按 1/10 画的。

<figure>
    <div style='display: grid; grid-template-columns: repeat(2, auto); gap: 1em;'>
        <img src="../fig/Plan_B/control-slope-cut.jpg">
        <img src="../fig/Plan_B/control-slope-freq.jpg">
    </div>
    <figcaption>频域切分情况和裁切结果（slope）<br>图象意义同 cliff。</figcaption>
</figure>

但实际做出来如下图，差别不大。

<figure>
    <div style='display: grid; grid-template-columns: repeat(2, auto); gap: 1em;'>
        <img src="../fig/Plan_B/control-slope-time.jpg">
        <img src="../fig/Plan_B/control-slope-compare.jpg">
    </div>
    <figcaption>频域裁切在时域的效果（slope）<br>图象意义同 cliff。</figcaption>
</figure>

## References

- [私有函数 - MATLAB & Simulink - MathWorks 中国](https://ww2.mathworks.cn/help/matlab/matlab_prog/private-functions.html)
- [结构体数组 - MATLAB - MathWorks 中国](https://ww2.mathworks.cn/help/releases/R2020b/matlab/ref/struct.html)
