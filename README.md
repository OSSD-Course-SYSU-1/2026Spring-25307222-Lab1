# SimpleCalculator

SimpleCalculator 是一个基于 HarmonyOS ArkTS 开发的简易计算器应用。项目实现了基础的四则运算、百分号、删除、清空、等号计算、结果预览以及大数字科学计数法显示等功能。

## 项目结构

```text
SimpleCalculator-master
├── AppScope/                              # 应用级配置和资源
├── entry/                                 # 主业务模块
│   └── src/main/
│       ├── ets/
│       │   ├── entryability/
│       │   │   └── EntryAbility.ts        # 应用入口 Ability
│       │   ├── pages/
│       │   │   └── HomePage.ets           # 计算器主页面
│       │   ├── viewmodel/
│       │   │   ├── PressKeysItem.ets      # 按键数据模型
│       │   │   └── PresskeysViewModel.ets # 按键布局数据
│       │   └── common/
│       │       ├── constants/
│       │       │   └── CommonConstants.ets# 公共常量和枚举
│       │       └── util/
│       │           ├── CalculateUtil.ets  # 表达式解析和计算工具
│       │           ├── CheckEmptyUtil.ets # 空值判断工具
│       │           └── Logger.ets         # 日志工具
│       ├── module.json5                   # 模块配置
│       └── resources/                     # 字符串、颜色、尺寸、图片资源
├── hvigor/                                # 构建工具配置
├── build-profile.json5                    # 工程构建配置
├── hvigorfile.ts                          # Hvigor 构建脚本
└── oh-package.json5                       # 工程包配置
```

## 功能概述

- 支持数字 `0-9` 输入。
- 支持小数点 `.` 输入，并限制同一个数字只能输入一个小数点。
- 支持加、减、乘、除四则运算。
- 支持百分号 `%`，例如 `50%` 会按 `50 / 100` 参与计算。
- 支持清空、逐位删除和等号确认。
- 输入表达式时会实时预览计算结果。
- 计算结果过长时会转换为科学计数法。
- 除数为 `0` 或非法表达式会显示错误信息。

## 应用入口分析：EntryAbility.ts

文件位置：`entry/src/main/ets/entryability/EntryAbility.ts`

`EntryAbility` 继承自 HarmonyOS 的 `UIAbility`，负责应用生命周期和页面加载。

### onCreate

```ts
onCreate(want: Want, launchParam: AbilityConstant.LaunchParam)
```

应用 Ability 创建时触发。当前代码主要通过 `hilog.info` 打印生命周期日志，方便调试应用启动过程。

### onWindowStageCreate

```ts
onWindowStageCreate(windowStage: window.WindowStage)
```

窗口创建时触发，是本应用最关键的入口逻辑：

1. 调用 `windowStage.loadContent('pages/HomePage', ...)` 加载主页面。
2. 如果加载失败，使用 `hilog.error` 打印错误。
3. 如果加载成功，获取当前窗口的 `UIContext`。
4. 将 `UIContext` 保存到 `AppStorage` 中，键名为 `uiContext`。

保存 `UIContext` 的原因是后续 `HomePage.ets` 中的 `resourceToString` 方法需要通过上下文读取资源字符串，例如错误提示 `error`。

### 其他生命周期方法

`onDestroy`、`onWindowStageDestroy`、`onForeground`、`onBackground` 都用于打印日志，分别对应 Ability 销毁、窗口销毁、进入前台、进入后台等生命周期事件。

## 主页面分析：HomePage.ets

文件位置：`entry/src/main/ets/pages/HomePage.ets`

`HomePage` 是计算器的主界面，也是输入处理和结果展示的核心组件。

### 状态变量

```ts
@State inputValue: string = '';
@State calValue: string = '';
private expressions: Array<string> = [];
```

- `inputValue`：显示在上方输入框中的表达式文本。
- `calValue`：显示在下方的实时计算结果。
- `expressions`：真正用于计算的表达式数组，例如输入 `12+3` 后可能保存为 `['12', '+', '3']`。

`@State` 修饰的变量发生变化时，ArkUI 会自动刷新界面。

### build 页面结构

`build()` 方法使用 ArkUI 声明式语法构建界面，整体由一个外层 `Column` 组成。

页面分为三部分：

1. 输入显示区：使用 `TextInput` 显示 `inputValue`。
2. 结果预览区：使用 `Text` 显示 `calValue`。
3. 按键区：使用 `ForEach` 遍历 `keysModel.getPressKeys()` 生成计算器按钮。

输入框会根据输入长度调整字体大小：

```ts
(this.inputValue.length > CommonConstants.INPUT_LENGTH_MAX)
  ? $r('app.float.font_size_text')
  : $r('app.float.font_size_input')
```

当表达式较长时，字体变小，避免内容溢出。

### 按键渲染逻辑

按键数据来自 `PresskeysViewModel.ets`。每个按键都有一个 `flag`：

- `flag === 0`：表示图标按键，例如清空、删除、加减乘除、等号。
- `flag === 1`：表示文字按键，例如数字、小数点、百分号。

点击按键时，根据 `flag` 调用不同方法：

```ts
if (keyItem.flag === 0) {
  this.inputSymbol(keyItem.value);
} else {
  this.inputNumber(keyItem.value);
}
```

### inputSymbol：处理操作符按键

```ts
inputSymbol(value: string)
```

该方法处理清空、删除、等号和四则运算符。

主要分支如下：

- `Symbol.CLEAN`：清空表达式和结果。
- `Symbol.DEL`：调用 `inputDelete` 删除最后一位。
- `Symbol.EQU`：调用 `getResult` 计算最终结果，并把结果作为新的输入值。
- 默认分支：调用 `inputOperators` 处理加、减、乘、除。

方法最后调用 `formatInputValue()`，把 `expressions` 数组重新格式化为界面展示字符串。

### inputNumber：处理数字、小数点和百分号

```ts
inputNumber(value: string)
```

该方法负责把数字类输入追加到 `expressions` 中。

处理流程：

1. 判断当前输入是否为空。
2. 取出表达式最后一项和倒数第二项。
3. 调用 `validateEnter` 判断当前字符是否允许输入。
4. 根据表达式结构决定是追加到当前数字，还是作为新数字入栈。
5. 更新 `inputValue`。
6. 如果输入的不是小数点，则调用 `getResult()` 实时计算。

例如：

- 输入 `1`：`expressions = ['1']`
- 再输入 `2`：`expressions = ['12']`
- 输入 `+`：`expressions = ['12', '+']`
- 输入 `3`：`expressions = ['12', '+', '3']`

### validateEnter：输入合法性校验

```ts
validateEnter(last: string, value: string)
```

该方法用于限制非法输入：

- 表达式开头不能直接输入 `%`。
- 负号后不能直接输入 `%`。
- 一个数字已经以 `%` 结尾时，不能继续追加字符。
- 同一个数字不能输入多个小数点。
- 单独的 `0` 后面不能继续输入其他数字，只允许输入 `.` 或 `%`。

这些规则可以避免出现 `%%`、`1..2`、`012` 等非法表达式。

### inputDelete：删除逻辑

```ts
inputDelete(len: number)
```

删除逻辑分两种情况：

- 如果最后一个表达式片段长度为 `1`，直接从 `expressions` 中移除这一项。
- 如果最后一个表达式片段长度大于 `1`，删除最后一个字符。

删除后如果表达式为空，会同时清空输入值和结果值。如果删除后最后一项不是操作符，则重新计算结果。

### inputOperators：运算符输入逻辑

```ts
inputOperators(len: number, value: string)
```

该方法处理 `+`、`-`、`×`、`÷` 的输入规则。

主要逻辑：

- 如果表达式为空且输入的是减号，允许作为负数开头。
- 如果表达式为空且输入其他运算符，直接忽略。
- 如果最后一项不是运算符，则把当前运算符加入表达式。
- 如果最后一项已经是运算符，则根据当前输入决定是否替换。
- 对连续运算符做简化处理，避免表达式结构混乱。

### getSymbol：按键值转真实运算符

```ts
getSymbol(value: string)
```

界面按键中的值是语义化字符串，例如 `add`、`min`、`mul`、`div`。该方法会把它们转换成真正参与计算的符号：

- `add` 转为 `+`
- `min` 转为 `-`
- `mul` 转为 `×`
- `div` 转为 `÷`

当前源码中乘除符号因为字符编码显示为 `脳` 和 `梅`，它们分别对应乘号和除号的计算标记。

### getResult：计算结果

```ts
async getResult()
```

该方法调用 `CalculateUtil.parseExpression(this.deepCopy())` 计算表达式。

使用 `deepCopy()` 的原因是 `parseExpression` 内部会改变传入数组，例如 `shift()`、`pop()`。如果直接传入原始 `expressions`，会破坏页面当前保存的表达式。

当计算结果为 `'NaN'` 时，界面显示资源文件中的 `error`；否则将结果赋值给 `calValue`。

### resultFormat 与 formatInputValue

```ts
resultFormat(value: string)
formatInputValue()
```

`resultFormat` 负责对数字进行千分位格式化。

`formatInputValue` 会遍历 `expressions`，对每一项调用 `resultFormat`，最后通过 `join('')` 拼接成展示用的表达式。

## 计算工具分析：CalculateUtil.ets

文件位置：`entry/src/main/ets/common/util/CalculateUtil.ets`

`CalculateUtil` 是项目的核心计算模块，负责判断运算符、处理优先级、解析表达式、计算最终结果。

### isSymbol：判断是否为运算符

```ts
isSymbol(value: string)
```

通过 `CommonConstants.OPERATORS.indexOf(value)` 判断当前字符串是否属于运算符集合。

### getPriority：获取运算符优先级

```ts
getPriority(value: string): number
```

优先级定义在 `Priority` 枚举中：

- `HIGH = 2`：乘法、除法。
- `MEDIUM = 1`：加法、减法。
- `LOW = 0`：其他情况。

该方法用于后续中缀表达式转后缀表达式。

### comparePriority：比较优先级

```ts
comparePriority(arg1: string, arg2: string): boolean
```

如果当前运算符 `arg1` 的优先级小于或等于栈顶运算符 `arg2`，返回 `true`。这表示栈顶运算符应该先出栈，保证乘除优先于加减，同级运算按从左到右计算。

### parseExpression：表达式解析

```ts
parseExpression(expressions: Array<string>): string
```

这是计算流程的核心方法，整体思路是把中缀表达式转为后缀表达式，再计算后缀表达式。

处理步骤：

1. 如果表达式为空，返回 `'NaN'`。
2. 遍历表达式，遇到 `%` 时转换为除以 `100` 的数字。
3. 如果最后一项是运算符，则删除最后一项，避免表达式以运算符结尾。
4. 使用 `outputStack` 保存运算符。
5. 使用 `outputQueue` 保存后缀表达式。
6. 遇到数字时放入 `outputQueue`。
7. 遇到运算符时，根据优先级决定是否弹出栈顶运算符。
8. 最后把栈中剩余运算符全部加入队列。
9. 调用 `dealQueue(outputQueue)` 得到最终结果。

例如表达式 `1 + 2 × 3` 会被转成后缀表达式：

```text
1 2 3 × +
```

这样计算时可以自然保证乘法先执行。

### dealQueue：计算后缀表达式

```ts
dealQueue(queue: Array<string>): string
```

该方法使用栈计算后缀表达式：

1. 遇到数字，压入 `outputStack`。
2. 遇到运算符，从栈中弹出两个数字。
3. 调用 `calResult(first, second, current)` 计算。
4. 把计算结果重新压回栈。
5. 队列处理完成后，如果栈中只剩一个值，则它就是最终结果。

如果最后栈中不是一个值，说明表达式非法，返回 `'NaN'`。

### calResult：根据运算符分发计算

```ts
calResult(arg1: string, arg2: string, symbol: string): string
```

该方法根据运算符调用不同计算函数：

- 加法、减法调用 `add`。
- 乘法、除法调用 `mulOrDiv`。

计算完成后，调用 `numberToScientificNotation` 判断是否需要转为科学计数法。

### add：加减法计算

```ts
add(arg1: string, arg2: string, symbol: string): number
```

直接使用 JavaScript 浮点数做小数加减容易出现精度问题，例如 `0.1 + 0.2` 可能得到 `0.30000000000000004`。

这里的处理方式是：

1. 计算两个数字小数位的最大长度。
2. 将两个数字同时乘以 `10` 的对应次方，转为整数运算。
3. 运算完成后再除回去。
4. 使用 `toFixed(maxLen)` 控制小数位。

这样可以减少常见小数加减的精度误差。

### mulOrDiv：乘除法计算

```ts
mulOrDiv(arg1: string, arg2: string, symbol: string): number
```

乘法会去掉小数点，把两个数转成整数相乘，再根据小数总位数除以对应的 `10` 的次方。

除法会根据两个数字的小数位数调整比例，尽量减少小数直接参与除法带来的精度问题。

如果参数中已经包含科学计数法，则直接使用 `Number` 做运算。

### numberToScientificNotation：科学计数法转换

```ts
numberToScientificNotation(result: number)
```

该方法处理过长数字和异常结果：

- 如果结果是正无穷或负无穷，返回 `'NaN'`。
- 如果结果已经包含 `e`，直接返回。
- 如果结果有效数字长度小于 `NUM_MAX_LEN`，直接返回普通字符串。
- 否则根据 `Math.log(result) / Math.LN10` 计算指数，并转换成 `前缀e指数` 的格式。

## 按键模型分析

### PressKeysItem.ets

文件位置：`entry/src/main/ets/viewmodel/PressKeysItem.ets`

`PressKeysBean` 是按键数据类：

```ts
export class PressKeysBean {
  flag: number;
  width: string;
  height: string;
  value: string;
  source?: Resource;
}
```

字段含义：

- `flag`：按键类型，`0` 表示图标按键，`1` 表示文字按键。
- `width`：按键内部图标或文字宽度。
- `height`：按键内部图标或文字高度。
- `value`：按键值，用于点击后的逻辑判断。
- `source`：图片资源，可选字段，图标按键会使用。

### PresskeysViewModel.ets

文件位置：`entry/src/main/ets/viewmodel/PresskeysViewModel.ets`

`PressKeysBeanViewModel` 的 `getPressKeys()` 方法返回一个二维数组，用于描述计算器按键布局。

每个内部数组表示一列按键：

```text
第 1 列：清空、7、4、1、%
第 2 列：除、8、5、2、0
第 3 列：乘、9、6、3、.
第 4 列：删除、减、加、等号
```

主页面通过 `ForEach` 遍历这个二维数组，动态渲染按键。这样 UI 结构和按键数据分离，后续调整按钮顺序或新增按钮时，只需要修改 ViewModel 数据。

## 常量分析：CommonConstants.ets

文件位置：`entry/src/main/ets/common/constants/CommonConstants.ets`

该文件集中定义项目中复用的常量和枚举。

### CommonConstants

主要常量包括：

- `FULL_PERCENT`：布局宽高使用的 `100%`。
- `OPERATORS`：运算符集合。
- `ADD`、`MIN`、`MUL`、`DIV`：真实参与表达式计算的运算符。
- `PERCENT_SIGN`：百分号。
- `DOTS`：小数点。
- `TWO`、`TEN`、`ONE_HUNDRED`：计算中常用数字。
- `INPUT_LENGTH_MAX`：输入框大字体显示的最大长度。
- `NUM_MAX_LEN`：普通数字显示的最大有效长度，超过后转科学计数法。
- `E`：科学计数法中的 `e`。
- `ZERO`、`ZERO_DOTS`：零和 `0.` 的字符串表示。

### Symbol

`Symbol` 枚举表示按键语义值：

```ts
ADD = 'add'
MIN = 'min'
MUL = 'mul'
DIV = 'div'
CLEAN = 'clean'
DEL = 'del'
EQU = 'equ'
```

这些值来自按键模型，点击图标按钮时会传给 `inputSymbol`。

### Priority

`Priority` 枚举表示运算符优先级：

- `HIGH`：乘除。
- `MEDIUM`：加减。
- `LOW`：默认低优先级。

### SymbolicEnumeration

`SymbolicEnumeration` 保存实际用于计算的运算符字符，供 `CalculateUtil` 判断和分发计算逻辑。

## 工具类分析

### CheckEmptyUtil.ets

文件位置：`entry/src/main/ets/common/util/CheckEmptyUtil.ets`

该工具类提供空值判断：

- `isEmpty(obj)`：判断对象或字符串是否为 `undefined`、`null` 或空字符串。
- `checkStrIsEmpty(str)`：判断字符串去除空格后是否为空。
- `isEmptyArr(arr)`：判断数组长度是否为 `0`。

项目中最常用的是 `isEmpty`，用于避免空值继续进入计算逻辑。

### Logger.ets

文件位置：`entry/src/main/ets/common/util/Logger.ets`

`Logger` 对 HarmonyOS 的 `hilog` 进行了简单封装，提供：

- `debug`
- `info`
- `warn`
- `error`

默认日志前缀为 `SimpleCalculator`，domain 为 `0xFF00`。这样项目内部可以用统一方式输出日志。

## 资源文件分析

### module.json5

文件位置：`entry/src/main/module.json5`

该文件声明模块信息：

- 模块名称为 `entry`。
- 模块类型为 `entry`。
- 设备类型为 `phone`。
- 主 Ability 为 `EntryAbility`。
- 页面列表引用 `$profile:main_pages`。
- 应用图标、名称、启动窗口背景等引用资源文件。

### main_pages.json

文件位置：`entry/src/main/resources/base/profile/main_pages.json`

该文件声明页面路由：

```json
{
  "src": [
    "pages/HomePage"
  ]
}
```

表示当前模块包含 `HomePage` 页面。

### element 资源

`entry/src/main/resources/base/element` 下包含：

- `string.json`：应用名称、模块描述、错误提示等字符串。
- `float.json`：字体大小、按键宽高、边距、圆角等尺寸。
- `color.json`：输入区、按键区、等号按钮、边框等颜色。

页面中通过 `$r('app.float.xxx')`、`$r('app.color.xxx')`、`$r('app.string.xxx')` 访问这些资源。

### media 资源

`entry/src/main/resources/base/media` 下包含计算器图标资源，例如：

- `ic_add.png`
- `ic_min.png`
- `ic_mul.png`
- `ic_div.png`
- `ic_del.png`
- `ic_clean.png`
- `ic_equ.png`

这些图片由 `PresskeysViewModel.ets` 引用，并在 `HomePage.ets` 中渲染为图标按键。

## 计算流程示例

以输入 `12 + 3 × 4 =` 为例：

1. 输入 `1` 和 `2`，`expressions` 变为 `['12']`。
2. 点击加号，`expressions` 变为 `['12', '+']`。
3. 输入 `3`，`expressions` 变为 `['12', '+', '3']`，实时结果为 `15`。
4. 点击乘号，`expressions` 变为 `['12', '+', '3', '×']`。
5. 输入 `4`，`expressions` 变为 `['12', '+', '3', '×', '4']`。
6. `CalculateUtil` 将中缀表达式转为后缀表达式 `12 3 4 × +`。
7. 后缀表达式计算结果为 `24`。
8. 点击等号后，`inputValue` 更新为 `24`，表达式重置为 `['24']`。

## 运行方式

1. 使用 DevEco Studio 打开项目。
2. 等待 Hvigor 同步工程依赖。
3. 选择 `entry` 模块。
4. 连接 HarmonyOS 设备或启动模拟器。
5. 点击运行按钮安装并启动应用。

## 代码特点

- 页面层和计算逻辑分离：`HomePage.ets` 负责交互和展示，`CalculateUtil.ets` 负责表达式计算。
- 按键布局数据化：按键由 ViewModel 提供，UI 通过遍历数据生成。
- 使用资源文件统一管理颜色、尺寸、字符串和图片。
- 通过中缀转后缀的方式处理运算符优先级，逻辑清晰。
- 对小数运算做了精度处理，减少常见浮点误差。

## 注意事项

- 源码中乘号和除号常量显示为 `脳`、`梅`，这通常是字符编码显示问题。逻辑上它们分别代表乘号和除号。
- `resultFormat` 中用于千分位格式化的正则写法较特殊，如果格式化没有生效，可以检查正则构造方式是否符合 ArkTS 运行环境。
- `parseExpression` 会修改传入数组，因此页面层通过 `deepCopy()` 传入副本，这是非常重要的保护逻辑。
