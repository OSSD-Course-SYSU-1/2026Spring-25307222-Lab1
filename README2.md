# SimpleCalculator 功能扩展说明

## 项目简介

SimpleCalculator 是一个基于 HarmonyOS ArkTS 开发的简易计算器应用。原工程支持数字输入、小数点、加减乘除、百分号、清空、删除、等号计算、实时结果预览，以及较长结果的科学计数法显示。

本次在原工程基础上继续扩展了科学计算能力，新增根号、括号、平方、立方、阶乘等功能，并修复了输入和显示中的若干问题。

## 本次新增与优化内容

### 1. 新增根号计算

新增 `√` 根号按键，支持平方根表达式：

```text
√9 = 3
√16 + 2 = 6
2√9 = 6
√(9 + 7) = 4
√2 = 1.4142135623730951
√-1 = error
```

其中 `2√9` 会自动按 `2 × √9` 处理。

### 2. 新增括号功能

新增 `(` 和 `)` 按键，支持通过括号改变运算优先级：

```text
(2 + 3) × 4 = 20
2 × (3 + 4) = 14
√(9 + 7) = 4
```

如果在数字后直接输入左括号，程序会自动补充乘号，例如 `2(3 + 4)` 会按 `2 × (3 + 4)` 计算。

### 3. 新增平方、立方、阶乘

新增后缀运算符：

- `²`：平方，例如 `5² = 25`
- `³`：立方，例如 `3³ = 27`
- `!`：阶乘，例如 `5! = 120`

这些功能可以和括号混合使用：

```text
(2 + 3)² = 25
(1 + 2)! = 6
√(3² + 4²) = 5
```

阶乘只支持非负整数。负数、小数或过大的阶乘会返回 `error`。

### 4. 修复根号后数字重复的问题

在测试运行过程中发现，输入“数字 × 根号下数字”时，根号后的数字会被追加两次，导致表达式异常并显示 `error`。

原因是 `inputNumber` 中多个 `if` 分支会连续执行：根号后输入数字时，数字先被作为新表达式片段加入，又被后续“运算符后拼接数字”的逻辑再次追加。

修复方式是将相关判断改为互斥的 `else if` 流程，确保每次输入只进入一个分支。

### 5. 修复千分位格式化逻辑

原来的 `resultFormat` 使用了类似下面的写法：

```ts
new RegExp("/(\d)(?=(\d{3})+\.)/g")
```

这里把正则表达式连同 `/.../g` 写成了普通字符串，实际无法按预期进行千分位格式化。

现在改为真正的正则处理流程：

- 先移除旧逗号，避免重复格式化。
- 只匹配表达式中的数字片段。
- 对整数部分添加千分位。
- 遇到科学计数法结果时直接返回，避免破坏 `1.23e+20` 这类格式。

### 6. 新增 `.gitignore`

新增 `.gitignore`，用于忽略本地构建缓存、IDE 配置和构建产物：

```gitignore
.hvigor/
entry/build/
.idea/
*.hap
```

这样后续开发时不容易把本地缓存文件误提交到 GitHub。

## 涉及文件

### `.gitignore`

新增 Git 忽略规则，减少构建缓存和 IDE 文件对版本管理的干扰。

### `entry/src/main/ets/common/constants/CommonConstants.ets`

新增计算符号常量和枚举：

- `CommonConstants.SQRT`
- `CommonConstants.LEFT_PARENTHESIS`
- `CommonConstants.RIGHT_PARENTHESIS`
- `CommonConstants.SQUARE`
- `CommonConstants.CUBE`
- `CommonConstants.FACTORIAL`
- `SymbolicEnumeration.SQRT`
- `SymbolicEnumeration.SQUARE`
- `SymbolicEnumeration.CUBE`
- `SymbolicEnumeration.FACTORIAL`
- `Priority.HIGHEST`

同时将 `√`、`²`、`³`、`!` 加入运算符集合，使计算工具能够识别这些符号。

### `entry/src/main/ets/viewmodel/PresskeysViewModel.ets`

在按键布局中新增功能键：

```ts
new PressKeysBean(1, '24vp', '43vp', CommonConstants.LEFT_PARENTHESIS)
new PressKeysBean(1, '24vp', '43vp', CommonConstants.RIGHT_PARENTHESIS)
new PressKeysBean(1, '24vp', '43vp', CommonConstants.SQUARE)
new PressKeysBean(1, '24vp', '43vp', CommonConstants.CUBE)
new PressKeysBean(1, '24vp', '43vp', CommonConstants.FACTORIAL)
```

### `entry/src/main/resources/base/element/float.json`

将 `key_width` 从 `70vp` 调整为 `56vp`，为新增的第五列功能按键留出空间。

### `entry/src/main/ets/pages/HomePage.ets`

负责输入处理和页面显示。本次主要改动包括：

- 新增 `isTextSymbolKey`，让文本类功能键也进入符号处理流程。
- 新增 `inputLeftParenthesis` 和 `inputRightParenthesis`，处理括号输入。
- 新增 `inputPostfixOperator`，处理 `²`、`³`、`!`。
- 支持数字后输入 `√` 或 `(` 时自动补充乘号。
- 支持右括号或后缀运算符后继续输入数字时自动补充乘号。
- 修复根号后输入数字被重复追加的问题。
- 修复 `resultFormat` 千分位格式化逻辑。

括号输入示例逻辑：

```ts
inputLeftParenthesis(len: number) {
  let last = len > 0 ? this.expressions[len - 1] : undefined;
  if (!last || this.isBinaryOperator(last) || last === CommonConstants.LEFT_PARENTHESIS ||
    last === CommonConstants.SQRT) {
    this.expressions.push(CommonConstants.LEFT_PARENTHESIS);
    return;
  }
  this.expressions.push(CommonConstants.MUL);
  this.expressions.push(CommonConstants.LEFT_PARENTHESIS);
}
```

后缀运算符输入示例逻辑：

```ts
inputPostfixOperator(len: number, value: string) {
  let last = len > 0 ? this.expressions[len - 1] : undefined;
  if (!last || !this.isValueEnd(last)) {
    return;
  }
  this.expressions.push(value);
  this.getResult();
}
```

### `entry/src/main/ets/common/util/CalculateUtil.ets`

负责表达式解析和计算。本次主要改动包括：

- 新增对括号的中缀表达式解析。
- 将 `√` 作为前缀一元运算符处理。
- 将 `²`、`³`、`!` 作为后缀一元运算符处理。
- 新增 `power` 方法，用于平方和立方。
- 新增 `factorial` 方法，用于阶乘。
- 修复 `numberToScientificNotation` 对 `NaN` 的处理，避免非法结果被格式化成异常字符串。

一元运算统一入口：

```ts
calUnaryResult(arg: string, symbol: string): string {
  switch (symbol) {
    case SymbolicEnumeration.SQRT:
      return this.sqrt(arg);
    case SymbolicEnumeration.SQUARE:
      return this.power(arg, CommonConstants.TWO);
    case SymbolicEnumeration.CUBE:
      return this.power(arg, 3);
    case SymbolicEnumeration.FACTORIAL:
      return this.factorial(arg);
    default:
      return 'NaN';
  }
}
```

## 实现思路

原工程的计算流程是：

1. 用户点击页面按键。
2. `HomePage.ets` 将输入内容维护到 `expressions` 数组中。
3. `CalculateUtil.ets` 将中缀表达式转换为后缀表达式。
4. 根据后缀表达式计算最终结果。
5. 页面实时展示预览结果或错误信息。

扩展后，表达式中出现了三类新符号：

- 分组符号：`(`、`)`
- 前缀一元运算符：`√`
- 后缀一元运算符：`²`、`³`、`!`

因此解析时需要在原有加减乘除优先级的基础上增加括号处理，并让一元运算符只消耗一个操作数。

例如：

```text
√(3² + 4²)
```

内部计算顺序是：

```text
3² = 9
4² = 16
9 + 16 = 25
√25 = 5
```

## 建议测试用例

| 输入 | 期望结果 | 说明 |
| --- | --- | --- |
| `1 + 2` | `3` | 基础加法 |
| `2 × 3 + 4` | `10` | 运算符优先级 |
| `(2 + 3) × 4` | `20` | 括号优先级 |
| `2(3 + 4)` | `14` | 数字后左括号自动补乘号 |
| `50%` | `0.5` | 百分号 |
| `√9` | `3` | 根号基础计算 |
| `√(9 + 7)` | `4` | 根号作用于括号表达式 |
| `2√9` | `6` | 数字后直接输入根号 |
| `5²` | `25` | 平方 |
| `3³` | `27` | 立方 |
| `5!` | `120` | 阶乘 |
| `(2 + 3)²` | `25` | 括号表达式平方 |
| `√(3² + 4²)` | `5` | 多功能混合计算 |
| `√-1` | `error` | 非法平方根 |
| `2.5!` | `error` | 小数阶乘非法 |
| `1000 + 2000` | `3,000` | 千分位显示 |

## 后续可继续改进

- 增加单元测试，重点覆盖 `CalculateUtil.ets`。
- 优化按键布局，让科学计算功能区更美观。
- 支持更多科学计算功能，例如倒数、三角函数、幂运算 `xʸ`。
- 如果视频文件继续增多，可以考虑使用 GitHub Release 或 Git LFS，避免仓库体积持续膨胀。

## 注意事项

- 根号目前只按平方根处理，不支持自定义 n 次方根。
- 阶乘只支持非负整数，且过大的阶乘会显示 `error`。
- `.gitignore` 只会影响后续未跟踪文件；如果构建产物已经被 Git 跟踪，需要后续再单独执行移出版本管理的操作。
