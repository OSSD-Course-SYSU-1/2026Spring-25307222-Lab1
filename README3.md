# SimpleCalculator 函数绘图功能说明

## 功能概述

本次在原有科学计算器基础上新增了函数绘图功能，使计算器可以像基础图形计算器一样输入函数表达式或简单方程，并在右侧坐标系中绘制函数图像。

为了给绘图区留出足够空间，应用页面改为横屏布局：

```text
左侧：按键区
右侧上方：表达式、普通计算结果、绘图提示
右侧下方：坐标系和函数曲线
```

原始 `README.md` 保持不变；已有的 `README2.md` 继续记录根号、括号、平方、立方、阶乘等科学计算功能。

## 新增能力

### 1. 横屏布局

页面由原来的竖向计算器布局改为横向双栏布局：

- 左侧只放按键，减少视觉拥挤。
- 右侧上方放表达式、计算结果和绘图提示。
- 右侧下方放坐标系和函数曲线。
- 按键和画布整体缩小，避免在虚拟机横屏中显示不完整。
- `module.json5` 中将 Ability 方向设置为横屏：

```json5
"orientation": "landscape"
```

### 2. 新增变量、常数和等式输入

按键区新增 `x`、`y`、`π`、`e` 和 `=`，可以输入更自由的函数表达式：

```text
x
x²
x³
2x + 1
√x
√(x² + 1)
x = 3
y = x² + 1
π
e
```

输入阶段支持隐式乘法：

```text
2x        等价于 2 × x
x(2 + x)  等价于 x × (2 + x)
2√x       等价于 2 × √x
```

### 3. 新增“绘图”按钮

按键区新增 `绘图` 按钮。

点击 `绘图` 会根据当前表达式绘制图像：

- `x² + 1` 会按 `y = x² + 1` 绘制。
- `y = x² + 1` 会绘制对应函数曲线。
- `4` 会按 `y = 4` 绘制水平直线。
- `x = 3` 会绘制竖直直线。
- `x = 9y` 会按隐式方程绘制对应直线。

如果表达式中包含 `x` 或等式，点击原来的等号按钮也会触发绘图，而不是普通数值计算。

### 4. 新增 Canvas 绘图区

右侧绘图区使用 ArkUI `Canvas` 绘制：

- 坐标轴
- 网格线
- `X`、`Y` 轴标识
- 原点 `O`
- 函数曲线

坐标轴使用深色线条，函数图像使用醒目的红色线条，便于区分。

当前默认绘图范围为：

```text
x ∈ [-10, 10]
y ∈ [-10, 10]
```

程序会在这个范围内对 `x` 进行采样，并计算每个采样点对应的 `y` 值，再映射到 Canvas 坐标上绘制曲线。

## 支持的函数表达式

当前函数绘图支持已有计算器的大部分运算：

| 类型 | 示例 |
| --- | --- |
| 四则运算 | `x + 1`、`2x - 3`、`x ÷ 2` |
| 括号 | `(x + 1) × (x - 1)` |
| 根号 | `√x`、`√(x + 4)` |
| 平方 | `x²`、`(x + 1)²` |
| 立方 | `x³` |
| 常数 | `π`、`e`、`4` |
| 显式等式 | `y = x² + 1`、`x = 3`、`x = 9y` |
| 混合表达式 | `√(x² + 1)`、`x² + 2x + 1` |

阶乘 `!` 仍然保留，但它更适合普通数值计算；在连续函数绘图中通常不建议作为主要图像函数使用。

## 使用示例

### 示例 1：绘制直线

输入：

```text
x
```

点击：

```text
绘图
```

结果：绘制 `y = x`。

### 示例 2：绘制抛物线

输入：

```text
x²
```

点击 `绘图` 后，会绘制 `y = x²`。

### 示例 3：绘制平移后的二次函数

输入：

```text
x² + 2x + 1
```

等价于：

```text
(x + 1)²
```

点击 `绘图` 后，会绘制对应抛物线。

### 示例 4：绘制根号函数

输入：

```text
√x
```

点击 `绘图` 后，会绘制 `y = √x`。当 `x < 0` 时计算结果非法，绘图逻辑会自动跳过这些点。

### 示例 5：绘制复合函数

输入：

```text
√(x² + 1)
```

点击 `绘图` 后，会绘制该复合函数。

### 示例 6：绘制常数函数

输入：

```text
4
```

点击 `绘图` 后，会绘制水平直线 `y = 4`。

### 示例 7：绘制竖直直线

输入：

```text
x = 3
```

点击 `绘图` 后，会绘制竖直直线 `x = 3`。

### 示例 8：绘制显式 y 等式

输入：

```text
y = x² + 1
```

点击 `绘图` 后，会绘制 `y = x² + 1`。

### 示例 9：绘制隐式方程

输入：

```text
x = 9y
```

点击 `绘图` 后，会绘制这条直线。程序会对平面上的点进行采样，寻找满足左右两侧近似相等的位置。

## 主要修改文件

### `entry/src/main/module.json5`

设置应用方向为横屏：

```json5
"orientation": "landscape"
```

### `entry/src/main/ets/common/constants/CommonConstants.ets`

新增：

- `VARIABLE_X`
- `VARIABLE_Y`
- `PI`
- `EQUATION_EQUAL`
- `DRAW`

用于表示变量、常数、等式符号和绘图命令。

### `entry/src/main/ets/common/util/CalculateUtil.ets`

将表达式计算方法扩展为支持变量代入：

```ts
parseExpression(expressions: Array<string>, variableX?: number): string
```

当传入 `variableX` 时，表达式中的 `x` 会被替换为对应数值，然后继续走原来的表达式解析和计算流程。

此外，表达式中的 `π` 和 `e` 会被转换为 `Math.PI` 和 `Math.E` 参与计算。

例如：

```text
表达式：x² + 2x + 1
x = 2
结果：9
```

### `entry/src/main/ets/pages/HomePage.ets`

主要负责函数绘图交互和 Canvas 绘制：

- 新增 `graphPanel` 绘图区。
- 新增 `inputVariable`，处理 `x` 输入。
- 新增 `inputSimpleToken`，处理 `y`、`π`、`e` 等简单 token。
- 新增 `inputEquationEqual`，处理表达式中的 `=`。
- 新增 `drawGraph`，负责采样并绘制函数曲线。
- 新增 `drawFunctionExpression`，处理 `y=f(x)` 和常数函数。
- 新增 `drawVerticalExpression`，处理 `x=a` 竖直直线。
- 新增 `drawImplicitExpression`，处理 `x=9y` 这类不能直接写成 `y=f(x)` 的简单隐式方程。
- 新增 `drawAxes` 和 `drawGrid`，绘制坐标轴和网格。
- 新增 `mapXToCanvas` 和 `mapYToCanvas`，完成数学坐标到 Canvas 坐标的转换。

绘图核心逻辑：

```ts
for (let pixelX = 0; pixelX <= this.graphWidth; pixelX++) {
  let xValue = this.graphXMin + (pixelX / this.graphWidth) * (this.graphXMax - this.graphXMin);
  let yText = CalculateUtil.parseExpression(this.deepCopy(), xValue);
  let yValue = Number(yText);
  ...
}
```

### `entry/src/main/ets/viewmodel/PresskeysViewModel.ets`

新增 `x` 和 `绘图` 两个按键：

```ts
new PressKeysBean(1, '24vp', '43vp', CommonConstants.VARIABLE_X)
new PressKeysBean(1, '48vp', '43vp', CommonConstants.DRAW)
```

### `entry/src/main/resources/base/element/float.json`

调整按键高度、间距和顶部边距，使横屏布局下按键区更紧凑。

## 实现思路

函数绘图的关键是“表达式重复求值”：

1. 用户输入表达式，可以是 `x²`、`y=x²`、`x=3`、`x=9y` 或 `4`。
2. 点击 `绘图`。
3. 程序判断表达式类型。
4. 对普通函数，从 `x = -10` 到 `x = 10` 进行采样。
5. 每个采样点调用 `CalculateUtil.parseExpression(expressions, xValue)`。
6. 得到 `y` 后，将数学坐标转换成 Canvas 坐标。
7. 把有效点连接成曲线。
8. 对隐式方程，程序会同时采样 `x` 和 `y`，寻找左右两侧差值接近 0 或发生符号变化的位置。

如果某个点计算结果非法，例如 `√x` 在 `x < 0` 时无实数结果，程序会跳过该点，避免整条曲线报错。

## 当前限制

- 绘图范围固定为 `x [-10, 10]`、`y [-10, 10]`。
- 暂不支持拖动、缩放和平移坐标系。
- 暂不支持 `sin`、`cos`、`tan`、`log`、`ln` 等函数。
- 等式绘图目前重点支持 `y=f(x)`、`f(x)=y`、`x=a`、`a=x`，并支持基础隐式方程采样。
- 阶乘适合离散整数计算，不适合作为连续函数绘图的主要表达式。

## 后续可改进方向

- 增加坐标范围输入。
- 支持手势缩放和平移。
- 支持三角函数和对数函数。
- 支持多条函数曲线同时绘制。
- 增加函数表达式历史记录。
