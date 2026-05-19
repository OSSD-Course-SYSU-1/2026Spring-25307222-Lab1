# SimpleCalculator 新增根号功能说明

## 工程概述

SimpleCalculator 是一个基于 HarmonyOS ArkTS 开发的简易计算器应用。原工程已经支持数字输入、小数点、加减乘除、百分号、清空、删除、等号计算、实时结果预览和较长结果的科学计数法显示。

本次在原有基础上新增了根号 `√` 计算能力，使计算器可以处理平方根相关表达式。

## 新增功能

- 新增 `√` 根号按键。
- 支持直接计算平方根，例如 `√9 = 3`。
- 支持根号参与混合运算，例如 `√9 + 1 = 4`。
- 支持数字后直接输入根号，例如 `2√9`，程序会按 `2 × √9` 参与计算。
- 对负数开根号等非法结果，沿用原来的错误处理逻辑，显示 `error`。

## 修改文件

### `entry/src/main/ets/common/constants/CommonConstants.ets`

新增根号相关常量和枚举：

- 在 `OPERATORS` 运算符集合中加入 `√`。
- 新增 `CommonConstants.SQRT` 常量。
- 在 `Symbol` 枚举中新增 `SQRT = 'sqrt'`。
- 在 `SymbolicEnumeration` 枚举中新增 `SQRT = '√'`。
- 在 `Priority` 中新增 `HIGHEST`，使根号优先级高于乘除。

### `entry/src/main/ets/viewmodel/PresskeysViewModel.ets`

在按键布局中新增根号按键：

```ts
new PressKeysBean(1, '24vp', '43vp', CommonConstants.SQRT)
```

该按钮显示为文本 `√`，点击后进入符号处理流程。

### `entry/src/main/ets/pages/HomePage.ets`

主要负责根号输入逻辑：

- 点击 `√` 时调用 `inputSymbol`，而不是当成普通数字字符处理。
- 新增 `inputSqrt` 方法。
- 如果表达式为空，允许输入 `√`。
- 如果上一个输入是运算符，允许继续输入 `√`。
- 如果上一个输入是数字，自动补充乘号，形成 `数字 × √` 的表达式结构。
- 限制 `√%` 这类非法输入。

核心逻辑示例：

```ts
inputSqrt(len: number) {
  let last = len > 0 ? this.expressions[len - 1] : undefined;
  if (!last || CalculateUtil.isSymbol(last)) {
    if (last !== CommonConstants.SQRT) {
      this.expressions.push(CommonConstants.SQRT);
    }
    return;
  }
  this.expressions.push(CommonConstants.MUL);
  this.expressions.push(CommonConstants.SQRT);
}
```

### `entry/src/main/ets/common/util/CalculateUtil.ets`

主要负责根号计算逻辑：

- 将根号设为最高优先级运算符。
- 在后缀表达式计算时，把 `√` 当成一元运算符处理，只弹出一个操作数。
- 新增 `sqrt` 方法，使用 `Math.sqrt` 计算平方根。

核心逻辑示例：

```ts
sqrt(arg: string): string {
  if (CheckEmptyUtil.isEmpty(arg)) {
    return 'NaN';
  }
  let result = Math.sqrt(Number(arg));
  if (Number.isNaN(result)) {
    return 'NaN';
  }
  return this.numberToScientificNotation(result);
}
```

## 实现思路

原工程的表达式计算流程是：

1. 页面按键输入内容。
2. `HomePage.ets` 将输入转成 `expressions` 数组。
3. `CalculateUtil.ets` 将中缀表达式转成后缀表达式。
4. 根据后缀表达式计算最终结果。

根号属于一元运算符，不同于加减乘除需要两个操作数。因此新增功能时，重点是让 `√` 在表达式解析阶段拥有最高优先级，并在计算阶段只读取一个数字进行计算。

例如：

```text
√9 + 1
```

会先计算：

```text
√9 = 3
```

再计算：

```text
3 + 1 = 4
```

## 使用示例

```text
√9 = 3
√16 + 2 = 6
2√9 = 6
√2 = 1.4142135623730951
√-1 = error
```

## 注意事项

- 根号目前按平方根处理，不支持自定义 n 次方根。
- 根号作为一元运算符，只作用于它后面的一个数字。
- 如果要扩展括号功能，后续可以继续完善表达式解析逻辑，使 `√(9 + 7)` 这类表达式可用。
