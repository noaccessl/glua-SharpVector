## glua-SharpVector: Performance Test
Using [gluafuncbudget](https://github.com/noaccessl/glua-collectibles/blob/master/dev_gluafuncbudget.lua)\
CPU: i7-3770\
OS: Windows 10\
Code: [sharpvec_perftest.lua](./sharpvec_perftest.lua)

```
------------------------------------------------
GLuaFuncBudget Configuration:
	Branch: x64
	Realm: Menu
	Frames: 3,300
	Iterations/frame: 64
	Digit: 7
	Measure Unit: ms
	Comparison Basis: average
	Shown Categories: median average avgfps
```

<details><summary>LuaJIT 2.1.0-beta3 (x86-64 Branch)</summary>

###### Create
```
Budgeted-function (JIT ON): new Vector (100%)
	Median    0.0102403 ms
	Average   0.0138026 ms
	AvgFPS    84265.48

Budgeted-function (JIT ON): new SharpVector (1.9207%)
	Median    0.0002238 ms
	Average   0.0002651 ms
	AvgFPS    4358284.23

Budgeted-function (JIT ON): new SharpVector; no preallocation (1776.94%)
	Median    0.2043886 ms
	Average   0.2452650 ms
	AvgFPS    4896.32
```

###### SetUnpacked, Zero, Negate, GetNegated, Unpack
```
Budgeted-function (JIT ON): Vector:SetUnpacked (100%)
	Median    0.0076091 ms
	Average   0.0078023 ms
	AvgFPS    130002.69

Budgeted-function (JIT ON): SharpVector:SetUnpacked (1.44644%)
	Median    0.0000856 ms
	Average   0.0001129 ms
	AvgFPS    11664770.22

Budgeted-function (JIT ON): Vector:Zero (100%)
	Median    0.0058082 ms
	Average   0.0059812 ms
	AvgFPS    171142.21

Budgeted-function (JIT ON): SharpVector:Zero (2.18714%)
	Median    0.0000925 ms
	Average   0.0001308 ms
	AvgFPS    10750896.90

Budgeted-function (JIT ON): Vector:Negate (100%)
	Median    0.0064968 ms
	Average   0.0066807 ms
	AvgFPS    152584.13

Budgeted-function (JIT ON): SharpVector:Negate (2.89689%)
	Median    0.0001530 ms
	Average   0.0001935 ms
	AvgFPS    6472554.10

Budgeted-function (JIT ON): Vector:GetNegated (100%)
	Median    0.0099788 ms
	Average   0.0228818 ms
	AvgFPS    85414.69

Budgeted-function (JIT ON): SharpVector:GetNegated (28.5757%)
	Median    0.0065060 ms
	Average   0.0065386 ms
	AvgFPS    170259.55

Budgeted-function (JIT ON): Vector:Unpack (100%)
	Median    0.0080728 ms
	Average   0.0084661 ms
	AvgFPS    120761.58

Budgeted-function (JIT ON): SharpVector:Unpack (2.06567%)
	Median    0.0001142 ms
	Average   0.0001749 ms
	AvgFPS    8649562.78
```

###### Set, Add, Mul
```
Budgeted-function (JIT ON): Vector:Set (100%)
	Median    0.0066076 ms
	Average   0.0067050 ms
	AvgFPS    150844.31

Budgeted-function (JIT ON): SharpVector:Set (2.54392%)
	Median    0.0001382 ms
	Average   0.0001706 ms
	AvgFPS    7228504.32

Budgeted-function (JIT ON): Vector:Add (100%)
	Median    0.0070838 ms
	Average   0.0073100 ms
	AvgFPS    139804.75

Budgeted-function (JIT ON): SharpVector:Add (2.59784%)
	Median    0.0001530 ms
	Average   0.0001899 ms
	AvgFPS    6493909.43

Budgeted-function (JIT ON): Vector:Mul( number ) (100%)
	Median    0.0072825 ms
	Average   0.0075997 ms
	AvgFPS    135349.69

Budgeted-function (JIT ON): SharpVector:Mul( number ) (1.60748%)
	Median    0.0000982 ms
	Average   0.0001222 ms
	AvgFPS    10053476.18

Budgeted-function (JIT ON): Vector:Mul( vector ) (100%)
	Median    0.0090766 ms
	Average   0.0093487 ms
	AvgFPS    108820.60

Budgeted-function (JIT ON): SharpVector:Mul( vector ) (2.64556%)
	Median    0.0001804 ms
	Average   0.0002473 ms
	AvgFPS    5506090.66
```

###### Mul( matrix )
```
Budgeted-function (JIT ON): Vector:Mul( matrix ) (100%)
	Median    0.0085535 ms
	Average   0.0086954 ms
	AvgFPS    116198.18

Budgeted-function (JIT ON): SharpVector:Mul( matrix ) (102.534%)
	Median    0.0085513 ms
	Average   0.0089157 ms
	AvgFPS    115015.85
```

###### Length, Distance
```
Budgeted-function (JIT ON): Vector:Length (100%)
	Median    0.0055176 ms
	Average   0.0056120 ms
	AvgFPS    180431.30

Budgeted-function (JIT ON): SharpVector:Length (2.26304%)
	Median    0.0000822 ms
	Average   0.0001270 ms
	AvgFPS    10337884.05

Budgeted-function (JIT ON): Vector:Distance (100%)
	Median    0.0071272 ms
	Average   0.0073440 ms
	AvgFPS    138772.96

Budgeted-function (JIT ON): SharpVector:Distance (1.77023%)
	Median    0.0000891 ms
	Average   0.0001300 ms
	AvgFPS    11100699.36
```

###### Normalize, GetNormalized
```
Budgeted-function (JIT ON): Vector:Normalize (100%)
	Median    0.0054496 ms
	Average   0.0055299 ms
	AvgFPS    182739.50

Budgeted-function (JIT ON): SharpVector:Normalize (20.2158%)
	Median    0.0010506 ms
	Average   0.0011179 ms
	AvgFPS    941550.25

Budgeted-function (JIT ON): Vector:GetNormalized (100%)
	Median    0.0177455 ms
	Average   0.0189787 ms
	AvgFPS    54702.12

Budgeted-function (JIT ON): SharpVector:GetNormalized (30.9467%)
	Median    0.0057328 ms
	Average   0.0058733 ms
	AvgFPS    182099.23
```

###### Dot, Cross
```
Budgeted-function (JIT ON): Vector:Dot (100%)
	Median    0.0067264 ms
	Average   0.0068559 ms
	AvgFPS    147828.49

Budgeted-function (JIT ON): SharpVector:Dot (1.68172%)
	Median    0.0000845 ms
	Average   0.0001153 ms
	AvgFPS    11803470.26

Budgeted-function (JIT ON): Vector:Cross (100%)
	Median    0.0126910 ms
	Average   0.0141687 ms
	AvgFPS    73868.65

Budgeted-function (JIT ON): SharpVector:Cross (35.494%)
	Median    0.0048792 ms
	Average   0.0050291 ms
	AvgFPS    216642.38

Budgeted-function (JIT ON): SharpVector:Cross; output specified (2.03719%)
	Median    0.0002512 ms
	Average   0.0002886 ms
	AvgFPS    3939740.50
```

###### IsEqualTol, IsZero
```
Budgeted-function (JIT ON): Vector:IsEqualTol (100%)
	Median    0.0072026 ms
	Average   0.0073262 ms
	AvgFPS    137994.00

Budgeted-function (JIT ON): SharpVector:IsEqualTol (1.57191%)
	Median    0.0000868 ms
	Average   0.0001152 ms
	AvgFPS    11471682.17

Budgeted-function (JIT ON): Vector:IsZero (100%)
	Median    0.0060355 ms
	Average   0.0062354 ms
	AvgFPS    163313.19

Budgeted-function (JIT ON): SharpVector:IsZero (1.98127%)
	Median    0.0000879 ms
	Average   0.0001235 ms
	AvgFPS    11300425.92
```

###### ToTable
```
Budgeted-function (JIT ON): Vector:ToTable (100%)
	Median    0.0296668 ms
	Average   0.0302507 ms
	AvgFPS    33245.96

Budgeted-function (JIT ON): SharpVector:ToTable (0.428031%)
	Median    0.0000834 ms
	Average   0.0001295 ms
	AvgFPS    11985174.15

Budgeted-function (JIT ON): SharpVector:ToTable; output specified (0.753595%)
	Median    0.0001427 ms
	Average   0.0002280 ms
	AvgFPS    6970050.45
```

###### Random
```
Budgeted-function (JIT ON): Vector:Random (100%)
	Median    0.0099171 ms
	Average   0.0101053 ms
	AvgFPS    99844.67

Budgeted-function (JIT ON): SharpVector:Random (78.0313%)
	Median    0.0076274 ms
	Average   0.0078853 ms
	AvgFPS    129423.01
```

###### WithinAABox
```
Budgeted-function (JIT ON): Vector:WithinAABox (100%)
	Median    0.0083937 ms
	Average   0.0085641 ms
	AvgFPS    118369.10

Budgeted-function (JIT ON): SharpVector:WithinAABox (1.38465%)
	Median    0.0000879 ms
	Average   0.0001186 ms
	AvgFPS    11306873.39
```

###### Angle, AngleEx
```
Budgeted-function (JIT ON): Vector:Angle (100%)
	Median    0.0132677 ms
	Average   0.0490137 ms
	AvgFPS    51468.00

Budgeted-function (JIT ON): SharpVector:Angle (21.6935%)
	Median    0.0103259 ms
	Average   0.0106328 ms
	AvgFPS    95599.03

Budgeted-function (JIT ON): SharpVector:Angle; output specified (19.8393%)
	Median    0.0096442 ms
	Average   0.0097240 ms
	AvgFPS    103400.92

Budgeted-function (JIT ON): Vector:AngleEx (100%)
	Median    0.0156694 ms
	Average   0.0207957 ms
	AvgFPS    57364.12

Budgeted-function (JIT ON): SharpVector:AngleEx (66.6819%)
	Median    0.0134647 ms
	Average   0.0138670 ms
	AvgFPS    72950.41

Budgeted-function (JIT ON): SharpVector:AngleEx; output specified (69.7447%)
	Median    0.0141322 ms
	Average   0.0145039 ms
	AvgFPS    69576.90
```

###### Rotate
```
Budgeted-function (JIT ON): Vector:Rotate (100%)
	Median    0.0093107 ms
	Average   0.0095437 ms
	AvgFPS    106110.93

Budgeted-function (JIT ON): SharpVector:Rotate (85.0742%)
	Median    0.0079392 ms
	Average   0.0081192 ms
	AvgFPS    125829.88
```

###### Lerp
```
Budgeted-function (JIT ON): LerpVector (100%)
	Median    0.0072917 ms
	Average   0.0102214 ms
	AvgFPS    128872.94

Budgeted-function (JIT ON): SharpVector:Lerp (60.1198%)
	Median    0.0058253 ms
	Average   0.0061451 ms
	AvgFPS    174334.40

Budgeted-function (JIT ON): SharpVector:Lerp; output specified (3.16502%)
	Median    0.0002798 ms
	Average   0.0003235 ms
	AvgFPS    3557759.01
```

</details>

<details><summary>LuaJIT 2.0.4</summary>

###### Create
```
Budgeted-function (JIT ON): new Vector (100%)
	Median    0.0281012 ms
	Average   0.0303783 ms
	AvgFPS    37057.26

Budgeted-function (JIT ON): new SharpVector (10.0499%)
	Median    0.0029395 ms
	Average   0.0030530 ms
	AvgFPS    335210.39

Budgeted-function (JIT ON): new SharpVector; no preallocation (1046.35%)
	Median    0.2853857 ms
	Average   0.3178643 ms
	AvgFPS    3384.71
```

###### SetUnpacked, Zero, Negate, GetNegated, Unpack
```
Budgeted-function (JIT ON): Vector:SetUnpacked (100%)
	Median    0.0135183 ms
	Average   0.0142911 ms
	AvgFPS    78501.01

Budgeted-function (JIT ON): SharpVector:SetUnpacked (34.3935%)
	Median    0.0047371 ms
	Average   0.0049152 ms
	AvgFPS    209531.92

Budgeted-function (JIT ON): Vector:Zero (100%)
	Median    0.0152344 ms
	Average   0.0160753 ms
	AvgFPS    63100.81

Budgeted-function (JIT ON): SharpVector:Zero (30.9018%)
	Median    0.0046737 ms
	Average   0.0049676 ms
	AvgFPS    210237.57

Budgeted-function (JIT ON): Vector:Negate (100%)
	Median    0.0164124 ms
	Average   0.0171928 ms
	AvgFPS    59211.63

Budgeted-function (JIT ON): SharpVector:Negate (32.0284%)
	Median    0.0052550 ms
	Average   0.0055066 ms
	AvgFPS    186885.79

Budgeted-function (JIT ON): Vector:GetNegated (100%)
	Median    0.0256761 ms
	Average   0.0271329 ms
	AvgFPS    38421.90

Budgeted-function (JIT ON): SharpVector:GetNegated (34.1405%)
	Median    0.0087275 ms
	Average   0.0092633 ms
	AvgFPS    111711.34

Budgeted-function (JIT ON): Vector:Unpack (100%)
	Median    0.0147234 ms
	Average   0.0147357 ms
	AvgFPS    68935.12

Budgeted-function (JIT ON): SharpVector:Unpack (27.659%)
	Median    0.0040441 ms
	Average   0.0040757 ms
	AvgFPS    249143.38
```

###### Set, Add, Mul
```
Budgeted-function (JIT ON): Vector:Set (100%)
	Median    0.0215158 ms
	Average   0.0198705 ms
	AvgFPS    60927.75

Budgeted-function (JIT ON): SharpVector:Set (27.2786%)
	Median    0.0052236 ms
	Average   0.0054204 ms
	AvgFPS    192043.64

Budgeted-function (JIT ON): Vector:Add (100%)
	Median    0.0180575 ms
	Average   0.0186082 ms
	AvgFPS    54486.59

Budgeted-function (JIT ON): SharpVector:Add (21.8353%)
	Median    0.0039137 ms
	Average   0.0040632 ms
	AvgFPS    251668.00

Budgeted-function (JIT ON): Vector:Mul( number ) (100%)
	Median    0.0145766 ms
	Average   0.0147496 ms
	AvgFPS    68699.64

Budgeted-function (JIT ON): SharpVector:Mul( number ) (26.3573%)
	Median    0.0038035 ms
	Average   0.0038876 ms
	AvgFPS    262865.51

Budgeted-function (JIT ON): Vector:Mul( vector ) (100%)
	Median    0.0181657 ms
	Average   0.0184457 ms
	AvgFPS    54883.70

Budgeted-function (JIT ON): SharpVector:Mul( vector ) (28.5625%)
	Median    0.0048107 ms
	Average   0.0052686 ms
	AvgFPS    200010.12
```

###### Mul( matrix )
```
Budgeted-function (JIT ON): Vector:Mul( matrix ) (100%)
	Median    0.0259868 ms
	Average   0.0228716 ms
	AvgFPS    50616.25

Budgeted-function (JIT ON): SharpVector:Mul( matrix ) (170.127%)
	Median    0.0369571 ms
	Average   0.0389108 ms
	AvgFPS    26308.67
```

###### Length, Distance
```
Budgeted-function (JIT ON): Vector:Length (100%)
	Median    0.0233650 ms
	Average   0.0209806 ms
	AvgFPS    57353.47

Budgeted-function (JIT ON): SharpVector:Length (30.1686%)
	Median    0.0061123 ms
	Average   0.0063296 ms
	AvgFPS    163914.07

Budgeted-function (JIT ON): Vector:Distance (100%)
	Median    0.0225514 ms
	Average   0.0239036 ms
	AvgFPS    42557.97

Budgeted-function (JIT ON): SharpVector:Distance (26.5726%)
	Median    0.0059550 ms
	Average   0.0063518 ms
	AvgFPS    163406.45
```

###### Normalize, GetNormalized
```
Budgeted-function (JIT ON): Vector:Normalize (100%)
	Median    0.0117312 ms
	Average   0.0146552 ms
	AvgFPS    82957.12

Budgeted-function (JIT ON): SharpVector:Normalize (44.4208%)
	Median    0.0062485 ms
	Average   0.0065100 ms
	AvgFPS    160660.92

Budgeted-function (JIT ON): Vector:GetNormalized (100%)
	Median    0.0276147 ms
	Average   0.0303418 ms
	AvgFPS    34943.94

Budgeted-function (JIT ON): SharpVector:GetNormalized (32.4832%)
	Median    0.0097725 ms
	Average   0.0098560 ms
	AvgFPS    103758.46
```

###### Dot, Cross
```
Budgeted-function (JIT ON): Vector:Dot (100%)
	Median    0.0247582 ms
	Average   0.0258051 ms
	AvgFPS    51205.20

Budgeted-function (JIT ON): SharpVector:Dot (28.704%)
	Median    0.0071616 ms
	Average   0.0074071 ms
	AvgFPS    140960.56

Budgeted-function (JIT ON): Vector:Cross (100%)
	Median    0.0427182 ms
	Average   0.0449667 ms
	AvgFPS    22811.88

Budgeted-function (JIT ON): SharpVector:Cross (24.4161%)
	Median    0.0107435 ms
	Average   0.0109791 ms
	AvgFPS    93592.21

Budgeted-function (JIT ON): SharpVector:Cross; output specified (14.0963%)
	Median    0.0062962 ms
	Average   0.0063386 ms
	AvgFPS    166889.60
```

###### IsEqualTol, IsZero
```
Budgeted-function (JIT ON): Vector:IsEqualTol (100%)
	Median    0.0315982 ms
	Average   0.0288893 ms
	AvgFPS    44659.51

Budgeted-function (JIT ON): SharpVector:IsEqualTol (22.3917%)
	Median    0.0061880 ms
	Average   0.0064688 ms
	AvgFPS    161980.63

Budgeted-function (JIT ON): Vector:IsZero (100%)
	Median    0.0188305 ms
	Average   0.0196766 ms
	AvgFPS    51500.25

Budgeted-function (JIT ON): SharpVector:IsZero (29.4122%)
	Median    0.0051099 ms
	Average   0.0057873 ms
	AvgFPS    185649.95
```

###### ToTable
```
Budgeted-function (JIT ON): Vector:ToTable (100%)
	Median    0.1121169 ms
	Average   0.1168437 ms
	AvgFPS    8948.57

Budgeted-function (JIT ON): SharpVector:ToTable (4.82698%)
	Median    0.0054231 ms
	Average   0.0056400 ms
	AvgFPS    182988.00

Budgeted-function (JIT ON): SharpVector:ToTable; output specified (6.59745%)
	Median    0.0065426 ms
	Average   0.0077087 ms
	AvgFPS    140486.59
```

###### Random
```
Budgeted-function (JIT ON): Vector:Random (100%)
	Median    0.0383676 ms
	Average   0.0351873 ms
	AvgFPS    36531.58

Budgeted-function (JIT ON): SharpVector:Random (149.806%)
	Median    0.0509751 ms
	Average   0.0527126 ms
	AvgFPS    19422.22
```

###### WithinAABox
```
Budgeted-function (JIT ON): Vector:WithinAABox (100%)
	Median    0.0318231 ms
	Average   0.0312697 ms
	AvgFPS    38488.21

Budgeted-function (JIT ON): SharpVector:WithinAABox (22.8242%)
	Median    0.0070020 ms
	Average   0.0071370 ms
	AvgFPS    142382.63
```

###### Angle, AngleEx
```
Budgeted-function (JIT ON): Vector:Angle (100%)
	Median    0.0378737 ms
	Average   0.0356750 ms
	AvgFPS    31468.19

Budgeted-function (JIT ON): SharpVector:Angle (131.162%)
	Median    0.0457378 ms
	Average   0.0467921 ms
	AvgFPS    21600.56

Budgeted-function (JIT ON): SharpVector:Angle; output specified (119.254%)
	Median    0.0403467 ms
	Average   0.0425439 ms
	AvgFPS    24051.30

Budgeted-function (JIT ON): Vector:AngleEx (100%)
	Median    0.0431452 ms
	Average   0.0418688 ms
	AvgFPS    24114.04

Budgeted-function (JIT ON): SharpVector:AngleEx (191.787%)
	Median    0.0766040 ms
	Average   0.0802990 ms
	AvgFPS    12592.59

Budgeted-function (JIT ON): SharpVector:AngleEx; output specified (161.063%)
	Median    0.0654946 ms
	Average   0.0674351 ms
	AvgFPS    14948.35
```

###### Rotate
```
Budgeted-function (JIT ON): Vector:Rotate (100%)
	Median    0.0173603 ms
	Average   0.0183283 ms
	AvgFPS    55143.86

Budgeted-function (JIT ON): SharpVector:Rotate (263.392%)
	Median    0.0472673 ms
	Average   0.0482753 ms
	AvgFPS    20813.37
```

###### Lerp
```
Budgeted-function (JIT ON): LerpVector (100%)
	Median    0.0164731 ms
	Average   0.0173124 ms
	AvgFPS    62627.43

Budgeted-function (JIT ON): SharpVector:Lerp (50.1278%)
	Median    0.0090227 ms
	Average   0.0086783 ms
	AvgFPS    128031.98

Budgeted-function (JIT ON): SharpVector:Lerp; output specified (22.609%)
	Median    0.0036778 ms
	Average   0.0039141 ms
	AvgFPS    263061.28
```
</details>

---

Functions excluded from testing and why:
* Functions which use metamethods declared in the engine
	* As internally metamethods from `C` are called, equalizing the execution time with those metamethods
* `Sub`
	* The same addition but of negative numbers
* `Div`
	* The same multiplication but inverted
* `LengthSqr`, `Length2D`, `Length2DSqr`, `DistToSqr`, `Distance2D`, `Distance2DSqr`
	* `Length` & `Distance` is sufficient as those above are faster than these two
* `AsGModVector` & `Vector:Sharpened`
	* No twin function
* `ToColor`
	* Nearly identical to `Vector:ToColor` in terms of implementation
