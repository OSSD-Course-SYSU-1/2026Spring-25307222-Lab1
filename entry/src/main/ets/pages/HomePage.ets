/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Logger from '../common/util/Logger';
import CalculateUtil from '../common/util/CalculateUtil';
import CheckEmptyUtil from '../common/util/CheckEmptyUtil';
import keysModel from '../viewmodel/PresskeysViewModel';
import { PressKeysBean } from '../viewmodel/PressKeysItem';
import { CommonConstants, Symbol } from '../common/constants/CommonConstants';

interface GraphItem {
  expressionText: string;
  expressions: Array<string>;
  color: string;
  visible: boolean;
}

@Entry
@Component
struct HomePage {
  @State inputValue: string = '';
  @State calValue: string = '';
  @State graphMessage: string = '输入表达式后点击绘图';
  @State graphItems: Array<GraphItem> = [];
  private expressions: Array<string> = [];
  private graphSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private graphContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.graphSettings);
  private readonly graphWidth: number = 350;
  private readonly graphHeight: number = 190;
  private readonly graphXMin: number = -10;
  private readonly graphXMax: number = 10;
  private readonly graphYMin: number = -10;
  private readonly graphYMax: number = 10;
  private readonly graphColors: Array<string> = ['#E11D48', '#2563EB', '#16A34A', '#F97316', '#7C3AED', '#0891B2'];

  build() {
    Row() {
      this.keyPanel()
      this.graphPanel()
    }
    .height(CommonConstants.FULL_PERCENT)
    .backgroundColor($r('app.color.column_back_color'))
  }

  @Builder
  keyPanel() {
    Column() {
      Row() {
        ForEach(keysModel.getPressKeys(), (columnItem: Array<PressKeysBean>, columnItemIndex?: number) => {
          Column() {
            ForEach(columnItem, (keyItem: PressKeysBean, keyItemIndex?: number) => {
              Column() {
                Column() {
                  if (keyItem.flag === 0) {
                    Image(keyItem.source !== undefined ? keyItem.source : '')
                      .width(keyItem.width)
                      .height(keyItem.height)
                  } else {
                    Text(keyItem.value)
                      .fontSize(this.getKeyFontSize(keyItem.value))
                      .width(keyItem.width)
                      .height(keyItem.height)
                      .textAlign(TextAlign.Center)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Clip })
                  }
                }
                .width(this.getKeyContainerWidth(keyItem.value))
                .height(
                  this.isTallEquals(columnItem, columnItemIndex, keyItemIndex) ?
                    $r('app.float.equals_height') : $r('app.float.key_height')
                )
                .borderWidth(1)
                .borderColor($r('app.color.border_color'))
                .borderRadius($r('app.float.border_radius'))
                .backgroundColor(
                  (keyItem.value === Symbol.EQU || keyItem.value === CommonConstants.DRAW) ?
                    $r('app.color.equals_back_color') : Color.White
                )
                .alignItems(HorizontalAlign.Center)
                .justifyContent(FlexAlign.Center)
                .onClick(() => {
                  if ((keyItem.flag === 0) || this.isTextSymbolKey(keyItem.value)) {
                    this.inputSymbol(keyItem.value);
                  } else {
                    this.inputNumber(keyItem.value);
                  }
                })
              }
              .layoutWeight(
                this.isTallEquals(columnItem, columnItemIndex, keyItemIndex) ? CommonConstants.TWO : 1
              )
              .width(CommonConstants.FULL_PERCENT)
              .justifyContent(FlexAlign.Center)
            }, (keyItem: PressKeysBean) => JSON.stringify(keyItem))
          }
          .layoutWeight(1)
          .margin({
            top: $r('app.float.margin_top'),
            bottom: $r('app.float.margin_bottom')
          })
        }, (item: Array<Array<PressKeysBean>>) => JSON.stringify(item))
      }
      .height(CommonConstants.FULL_PERCENT)
      .alignItems(VerticalAlign.Top)
      .margin({
        left: $r('app.float.margin_left'),
        right: $r('app.float.margin_right')
      })
    }
    .width('40%')
    .height(CommonConstants.FULL_PERCENT)
    .backgroundColor($r('app.color.row_back_color'))
  }

  @Builder
  graphPanel() {
    Column() {
      Column() {
        TextInput({ text: this.resultFormat(this.inputValue) })
          .height(36)
          .fontSize(22)
          .enabled(false)
          .fontColor(Color.Black)
          .textAlign(TextAlign.End)
          .backgroundColor($r('app.color.input_back_color'))

        Text(this.resultFormat(this.calValue))
          .fontSize(16)
          .fontColor($r('app.color.text_color'))
          .height(24)
          .width(CommonConstants.FULL_PERCENT)
          .textAlign(TextAlign.End)

        Text(this.graphMessage)
          .fontSize(14)
          .fontColor($r('app.color.text_color'))
          .height(22)
          .width(CommonConstants.FULL_PERCENT)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width(CommonConstants.FULL_PERCENT)
      .padding({ left: 12, right: 12, top: 6, bottom: 4 })

      this.graphListPanel()

      Canvas(this.graphContext)
        .width(this.graphWidth)
        .height(this.graphHeight)
        .backgroundColor(Color.White)
        .borderWidth(1)
        .borderColor($r('app.color.border_color'))
        .onReady(() => {
          this.drawAxes();
        })
    }
    .layoutWeight(1)
    .height(CommonConstants.FULL_PERCENT)
    .padding({ left: 10, right: 10, top: 6, bottom: 8 })
    .backgroundColor('#EEF6FF')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  graphListPanel() {
    Row() {
      Text('清图')
        .fontSize(12)
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
        .height(28)
        .width(50)
        .borderRadius(14)
        .backgroundColor('#0A84FF')
        .onClick(() => {
          this.clearGraphs();
        })

      Scroll() {
        Row() {
          ForEach(this.graphItems, (item: GraphItem, index?: number) => {
            Row() {
              Text('')
                .width(8)
                .height(8)
                .borderRadius(4)
                .backgroundColor(item.color)

              Text((item.visible ? '显示 ' : '隐藏 ') + item.expressionText)
                .fontSize(12)
                .fontColor(item.visible ? '#182431' : '#8A8A8A')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .layoutWeight(1)

              Text(item.visible ? '隐藏' : '显示')
                .fontSize(11)
                .fontColor(Color.White)
                .textAlign(TextAlign.Center)
                .height(24)
                .width(42)
                .borderRadius(12)
                .backgroundColor('#0A84FF')
                .onClick(() => {
                  if (index !== undefined) {
                    this.toggleGraph(index);
                  }
                })

              Text('单独')
                .fontSize(11)
                .fontColor(Color.White)
                .textAlign(TextAlign.Center)
                .height(24)
                .width(42)
                .borderRadius(12)
                .backgroundColor('#0A84FF')
                .onClick(() => {
                  if (index !== undefined) {
                    this.showOnlyGraph(index);
                  }
                })
            }
            .height(30)
            .width(230)
            .padding({ left: 6, right: 4 })
            .margin({ left: 6 })
            .borderWidth(1)
            .borderColor(item.visible ? item.color : '#C7D3E0')
            .borderRadius(6)
            .backgroundColor(Color.White)
          }, (item: GraphItem) => item.expressionText + item.color)
        }
      }
      .layoutWeight(1)
      .height(32)
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(34)
    .padding({ left: 12, right: 12 })
    .alignItems(VerticalAlign.Center)
  }

  isTallEquals(columnItem: Array<PressKeysBean>, columnItemIndex?: number, keyItemIndex?: number) {
    return (columnItem.length < 5) &&
      (columnItemIndex === (keysModel.getPressKeys().length - 1)) &&
      (keyItemIndex === (columnItem.length - 1));
  }

  getKeyFontSize(value: string): Resource | number {
    if (value === CommonConstants.DRAW) {
      return 14;
    }
    if (value === CommonConstants.X_POWER_X) {
      return 14;
    }
    if (value === CommonConstants.SQUARE_KEY || value === CommonConstants.CUBE_KEY) {
      return 20;
    }
    return (value === CommonConstants.DOTS) ? $r('app.float.font_size_dot') : $r('app.float.font_size_text');
  }

  getKeyContainerWidth(value: string): Resource | string {
    if (value === CommonConstants.DRAW || value === CommonConstants.X_POWER_X) {
      return '56vp';
    }
    if (value === CommonConstants.SQUARE_KEY || value === CommonConstants.CUBE_KEY) {
      return '52vp';
    }
    return $r('app.float.key_width');
  }

  isTextSymbolKey(value: string): boolean {
    return value === CommonConstants.SQRT || value === CommonConstants.LEFT_PARENTHESIS ||
      value === CommonConstants.RIGHT_PARENTHESIS || value === CommonConstants.SQUARE_KEY ||
      value === CommonConstants.CUBE_KEY || value === CommonConstants.X_POWER_X ||
      value === CommonConstants.SQUARE || value === CommonConstants.CUBE || value === CommonConstants.FACTORIAL ||
      value === CommonConstants.VARIABLE_X || value === CommonConstants.VARIABLE_Y ||
      value === CommonConstants.PI || value === CommonConstants.E ||
      value === CommonConstants.EQUATION_EQUAL || value === CommonConstants.DRAW;
  }

  isBinaryOperator(value: string): boolean {
    return value === CommonConstants.ADD || value === CommonConstants.MIN ||
      value === CommonConstants.MUL || value === CommonConstants.DIV ||
      value === CommonConstants.POWER;
  }

  isPostfixOperator(value: string): boolean {
    return value === CommonConstants.SQUARE || value === CommonConstants.CUBE ||
      value === CommonConstants.FACTORIAL;
  }

  isValueEnd(value: string): boolean {
    return !CheckEmptyUtil.isEmpty(value) && !this.isBinaryOperator(value) &&
      value !== CommonConstants.SQRT && value !== CommonConstants.LEFT_PARENTHESIS &&
      value !== CommonConstants.EQUATION_EQUAL;
  }

  isConstant(value: string): boolean {
    return value === CommonConstants.PI || value === CommonConstants.E;
  }

  hasVariableExpression(): boolean {
    return this.expressions.indexOf(CommonConstants.VARIABLE_X) !== -1;
  }

  hasEquationExpression(): boolean {
    return this.expressions.indexOf(CommonConstants.EQUATION_EQUAL) !== -1;
  }


  /**
   * Input Symbols.
   *
   * @param value Input Operators.
   */
  inputSymbol(value: string) {
    if (CheckEmptyUtil.isEmpty(value)) {
      return;
    }
    let len = this.expressions.length;
    switch (value) {
      case Symbol.CLEAN:
        this.expressions = [];
        this.inputValue = '';
        this.calValue = '';
        if (this.graphItems.length > 0) {
          this.redrawGraphs('已清空输入，图像保留');
        } else {
          this.graphMessage = '输入表达式后点击绘图';
          this.drawAxes();
        }
        break;
      case Symbol.DEL:
        this.inputDelete(len);
        break;
      case Symbol.EQU:
        if (len === 0) {
          return;
        }
        if (this.hasVariableExpression() || this.hasEquationExpression()) {
          this.drawGraph();
          return;
        }
        this.getResult().then((result: boolean) => {
          if (!result) {
            return;
          }
          this.inputValue = this.calValue;
          this.calValue = '';
          this.expressions = [];
          this.expressions.push(this.inputValue);
        })
        break;
      case CommonConstants.SQRT:
        this.inputSqrt(len);
        break;
      case CommonConstants.LEFT_PARENTHESIS:
        this.inputLeftParenthesis(len);
        break;
      case CommonConstants.RIGHT_PARENTHESIS:
        this.inputRightParenthesis(len);
        break;
      case CommonConstants.SQUARE_KEY:
        this.inputPowerShortcut(len, CommonConstants.SQUARE);
        break;
      case CommonConstants.CUBE_KEY:
        this.inputPowerShortcut(len, CommonConstants.CUBE);
        break;
      case CommonConstants.X_POWER_X:
        this.inputPowerOperator(len);
        break;
      case CommonConstants.SQUARE:
      case CommonConstants.CUBE:
      case CommonConstants.FACTORIAL:
        this.inputPostfixOperator(len, value);
        break;
      case CommonConstants.VARIABLE_X:
        this.inputVariable(len);
        break;
      case CommonConstants.VARIABLE_Y:
        this.inputSimpleToken(len, CommonConstants.VARIABLE_Y);
        break;
      case CommonConstants.PI:
      case CommonConstants.E:
        this.inputSimpleToken(len, value);
        break;
      case CommonConstants.EQUATION_EQUAL:
        this.inputEquationEqual(len);
        break;
      case CommonConstants.DRAW:
        this.drawGraph();
        break;
      default:
        this.inputOperators(len, value);
        break;
    }
    if (this.hasVariableExpression() || this.hasEquationExpression()) {
      this.calValue = '';
    }
    this.formatInputValue();
  }

  /**
   * Enter numbers.
   *
   * @param value Enter numbers.
   */
  inputNumber(value: string) {
    if (CheckEmptyUtil.isEmpty(value)) {
      return;
    }
    let len = this.expressions.length;
    let last = len > 0 ? this.expressions[len - 1] : '';
    let secondLast = len > 1 ? this.expressions[len - CommonConstants.TWO] : undefined;
    if (!this.validateEnter(last, value)) {
      return;
    }
    if ((last === CommonConstants.MIN) && (len === 1 || secondLast === CommonConstants.LEFT_PARENTHESIS ||
      secondLast === CommonConstants.SQRT || (secondLast !== undefined && this.isBinaryOperator(secondLast)))) {
      this.expressions[len - 1] += value;
    } else if (!last) {
      this.expressions.push(value);
    } else if (last === CommonConstants.SQRT || last === CommonConstants.LEFT_PARENTHESIS ||
      last === CommonConstants.EQUATION_EQUAL || this.isBinaryOperator(last)) {
      this.expressions.push(value);
    } else if (last === CommonConstants.RIGHT_PARENTHESIS || last === CommonConstants.VARIABLE_X ||
      last === CommonConstants.VARIABLE_Y || this.isConstant(last) || this.isPostfixOperator(last)) {
      this.expressions.push(CommonConstants.MUL);
      this.expressions.push(value);
    } else if (secondLast && (CalculateUtil.isSymbol(secondLast) ||
      secondLast === CommonConstants.LEFT_PARENTHESIS || secondLast === CommonConstants.SQRT)) {
      this.expressions[len -1] += value;
    } else {
      this.expressions[len - 1] += value;
    }
    this.formatInputValue();
    if (value !== CommonConstants.DOTS) {
      this.getResult();
    }
  }

  /**
   * Verify that you can enter.
   *
   * @param last Value of the last element.
   * @param value Current input value.
   * return Indicates whether to allow input.
   */
  validateEnter(last: string, value: string) {
    if (!last && value === CommonConstants.PERCENT_SIGN) {
      return false;
    }
    if ((last === CommonConstants.MIN || last === CommonConstants.SQRT ||
      last === CommonConstants.LEFT_PARENTHESIS || last === CommonConstants.EQUATION_EQUAL ||
      this.isBinaryOperator(last)) &&
      (value === CommonConstants.PERCENT_SIGN)) {
      return false;
    }
    if ((last === CommonConstants.RIGHT_PARENTHESIS || last === CommonConstants.VARIABLE_X ||
      last === CommonConstants.VARIABLE_Y || this.isConstant(last) || this.isPostfixOperator(last)) &&
      (value === CommonConstants.DOTS || value === CommonConstants.PERCENT_SIGN)) {
      return false;
    }
    if (last.endsWith(CommonConstants.PERCENT_SIGN)) {
      return false;
    }
    if ((last.indexOf(CommonConstants.DOTS) !== -1) && (value === CommonConstants.DOTS)) {
      return false;
    }
    if ((last === '0') && (value !== CommonConstants.DOTS) &&
      (value !== CommonConstants.PERCENT_SIGN)) {
      return false;
    }
    return true;
  }

  /**
   * Delete Key Trigger.
   *
   * @param len Expression Length.
   */
  inputDelete(len: number) {
    if (len === 0) {
      return;
    }
    let last = this.expressions[len - 1];
    let lastLen = last.length;
    if (lastLen === 1) {
      this.expressions.pop();
      len = this.expressions.length;
    } else {
      this.expressions[len - 1] = last.slice(0, last.length - 1);
    }
    if (len === 0) {
      this.inputValue = '';
      this.calValue = '';
      return;
    }
    if (!CalculateUtil.isSymbol(this.expressions[len - 1])) {
      this.getResult();
    }
  }

  /**
   * Triggered when input is added, subtracted, multiplied, and divided.
   *
   * @param len Expression Length.
   * @param value Current Input Value.
   */
  inputOperators(len: number, value: string) {
    let last = len > 0 ? this.expressions[len - 1] : undefined;
    let secondLast = len > 1 ? this.expressions[len - CommonConstants.TWO] : undefined;
    if ((!last || last === CommonConstants.LEFT_PARENTHESIS || last === CommonConstants.SQRT ||
      last === CommonConstants.EQUATION_EQUAL) && (value === Symbol.MIN)) {
      this.expressions.push(this.getSymbol(value));
      return;
    }
    if (!last) {
      return;
    }
    if (this.isPostfixOperator(last) || last === CommonConstants.RIGHT_PARENTHESIS) {
      this.expressions.push(this.getSymbol(value));
      return;
    }
    if (!CalculateUtil.isSymbol(last) && last !== CommonConstants.LEFT_PARENTHESIS) {
      this.expressions.push(this.getSymbol(value));
      return;
    }
    if ((value === Symbol.MIN) && last !== CommonConstants.SQRT &&
      (last === CommonConstants.MIN || last === CommonConstants.ADD)) {
      this.expressions.pop();
      this.expressions.push(this.getSymbol(value));
      return;
    }
    if (!secondLast) {
      return;
    }
    if (value !== Symbol.MIN) {
      this.expressions.pop();
    }
    if (CalculateUtil.isSymbol(secondLast)) {
      this.expressions.pop();
    }
    this.expressions.push(this.getSymbol(value));
  }

  /**
   * Triggered when input is square root.
   *
   * @param len Expression Length.
   */
  inputSqrt(len: number) {
    let last = len > 0 ? this.expressions[len - 1] : undefined;
    if (!last || this.isBinaryOperator(last) || last === CommonConstants.LEFT_PARENTHESIS ||
      last === CommonConstants.SQRT) {
      this.expressions.push(CommonConstants.SQRT);
      return;
    }
    this.expressions.push(CommonConstants.MUL);
    this.expressions.push(CommonConstants.SQRT);
  }

  inputVariable(len: number) {
    let last = len > 0 ? this.expressions[len - 1] : undefined;
    if (!last || this.isBinaryOperator(last) || last === CommonConstants.LEFT_PARENTHESIS ||
      last === CommonConstants.SQRT || last === CommonConstants.EQUATION_EQUAL) {
      this.expressions.push(CommonConstants.VARIABLE_X);
      return;
    }
    this.expressions.push(CommonConstants.MUL);
    this.expressions.push(CommonConstants.VARIABLE_X);
  }

  inputSimpleToken(len: number, value: string) {
    let last = len > 0 ? this.expressions[len - 1] : undefined;
    if (!last || this.isBinaryOperator(last) || last === CommonConstants.LEFT_PARENTHESIS ||
      last === CommonConstants.SQRT || last === CommonConstants.EQUATION_EQUAL) {
      this.expressions.push(value);
      return;
    }
    this.expressions.push(CommonConstants.MUL);
    this.expressions.push(value);
  }

  inputPowerShortcut(len: number, powerSymbol: string) {
    let last = len > 0 ? this.expressions[len - 1] : undefined;
    if (!last || this.isBinaryOperator(last) || last === CommonConstants.LEFT_PARENTHESIS ||
      last === CommonConstants.SQRT || last === CommonConstants.EQUATION_EQUAL) {
      this.expressions.push(CommonConstants.VARIABLE_X);
      this.expressions.push(powerSymbol);
      return;
    }
    if (this.isValueEnd(last)) {
      this.expressions.push(powerSymbol);
    }
  }

  inputPowerOperator(len: number) {
    let last = len > 0 ? this.expressions[len - 1] : undefined;
    if (!last || last === CommonConstants.EQUATION_EQUAL || last === CommonConstants.LEFT_PARENTHESIS ||
      last === CommonConstants.SQRT || (last !== undefined && this.isBinaryOperator(last) &&
      last !== CommonConstants.POWER)) {
      this.expressions.push(CommonConstants.VARIABLE_X);
      this.expressions.push(CommonConstants.POWER);
      this.expressions.push(CommonConstants.VARIABLE_X);
      return;
    }
    if (last === CommonConstants.POWER) {
      return;
    }
    if (this.isValueEnd(last)) {
      this.expressions.push(CommonConstants.POWER);
    }
  }

  inputEquationEqual(len: number) {
    let last = len > 0 ? this.expressions[len - 1] : undefined;
    if (!last || !this.isValueEnd(last) || this.expressions.indexOf(CommonConstants.EQUATION_EQUAL) !== -1) {
      return;
    }
    this.expressions.push(CommonConstants.EQUATION_EQUAL);
  }

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

  inputRightParenthesis(len: number) {
    let last = len > 0 ? this.expressions[len - 1] : undefined;
    if (!this.canCloseParenthesis() || !last || !this.isValueEnd(last) ||
      last === CommonConstants.LEFT_PARENTHESIS) {
      return;
    }
    this.expressions.push(CommonConstants.RIGHT_PARENTHESIS);
    this.getResult();
  }

  inputPostfixOperator(len: number, value: string) {
    let last = len > 0 ? this.expressions[len - 1] : undefined;
    if (!last || !this.isValueEnd(last)) {
      return;
    }
    this.expressions.push(value);
    this.getResult();
  }

  canCloseParenthesis(): boolean {
    let leftCount = 0;
    let rightCount = 0;
    this.expressions.forEach((item: string) => {
      if (item === CommonConstants.LEFT_PARENTHESIS) {
        leftCount++;
      }
      if (item === CommonConstants.RIGHT_PARENTHESIS) {
        rightCount++;
      }
    });
    return leftCount > rightCount;
  }

  drawGraph() {
    let expressions = this.deepCopy();
    if (expressions.length === 0) {
      this.graphMessage = '请输入表达式';
      this.redrawGraphs();
      return;
    }
    let message = this.addGraphItem(expressions);
    this.redrawGraphs(message);
  }

  addGraphItem(expressions: Array<string>): string {
    let expressionText = expressions.join('');
    let nextGraphItems = Array.from(this.graphItems);
    let existingIndex = -1;
    for (let index = 0; index < nextGraphItems.length; index++) {
      if (nextGraphItems[index].expressionText === expressionText) {
        existingIndex = index;
        break;
      }
    }
    let message = '';
    if (existingIndex !== -1) {
      nextGraphItems[existingIndex].visible = true;
      message = '已重新显示图像：' + expressionText;
    } else {
      nextGraphItems.push({
        expressionText: expressionText,
        expressions: Array.from(expressions),
        color: this.graphColors[nextGraphItems.length % this.graphColors.length],
        visible: true
      });
      message = '已添加图像：' + expressionText;
    }
    this.graphItems = nextGraphItems;
    return message;
  }

  clearGraphs() {
    this.graphItems = [];
    this.graphMessage = '已清空图像';
    this.drawAxes();
  }

  toggleGraph(index: number) {
    let nextGraphItems = Array.from(this.graphItems);
    if (index < 0 || index >= nextGraphItems.length) {
      return;
    }
    nextGraphItems[index].visible = !nextGraphItems[index].visible;
    this.graphItems = nextGraphItems;
    this.redrawGraphs();
  }

  showOnlyGraph(index: number) {
    let nextGraphItems = Array.from(this.graphItems);
    if (index < 0 || index >= nextGraphItems.length) {
      return;
    }
    nextGraphItems.forEach((item: GraphItem, itemIndex: number) => {
      item.visible = itemIndex === index;
    });
    this.graphItems = nextGraphItems;
    this.redrawGraphs();
  }

  redrawGraphs(message?: string) {
    this.drawAxes();
    if (this.graphItems.length === 0) {
      if (message !== undefined) {
        this.graphMessage = message;
      }
      return;
    }
    let visibleCount = 0;
    let successCount = 0;
    this.graphItems.forEach((item: GraphItem) => {
      if (!item.visible) {
        return;
      }
      visibleCount++;
      if (this.drawExpression(item.expressions, item.color)) {
        successCount++;
      }
    });
    if (message !== undefined) {
      this.graphMessage = successCount > 0 ? message : message + '，但当前范围内没有可绘制点';
      return;
    }
    if (visibleCount === 0) {
      this.graphMessage = '当前没有显示的图像';
      return;
    }
    this.graphMessage = successCount > 0 ?
      '已显示 ' + successCount + ' 条图像，范围 x/y [-10, 10]' : '当前范围内没有可绘制点';
  }

  drawExpression(expressions: Array<string>, color: string): boolean {
    let equalIndex = expressions.indexOf(CommonConstants.EQUATION_EQUAL);
    if (equalIndex !== -1) {
      let leftExpressions = expressions.slice(0, equalIndex);
      let rightExpressions = expressions.slice(equalIndex + 1);
      if (leftExpressions.length === 1 && leftExpressions[0] === CommonConstants.VARIABLE_X &&
        !this.hasToken(rightExpressions, CommonConstants.VARIABLE_Y)) {
        return this.drawVerticalExpression(rightExpressions, color);
      }
      if (rightExpressions.length === 1 && rightExpressions[0] === CommonConstants.VARIABLE_X &&
        !this.hasToken(leftExpressions, CommonConstants.VARIABLE_Y)) {
        return this.drawVerticalExpression(leftExpressions, color);
      }
      if (leftExpressions.length === 1 && leftExpressions[0] === CommonConstants.VARIABLE_Y) {
        return this.drawFunctionExpression(rightExpressions, color);
      }
      if (rightExpressions.length === 1 && rightExpressions[0] === CommonConstants.VARIABLE_Y) {
        return this.drawFunctionExpression(leftExpressions, color);
      }
      return this.drawImplicitExpression(leftExpressions, rightExpressions, color);
    }
    return this.drawFunctionExpression(expressions, color);
  }

  hasToken(expressions: Array<string>, token: string): boolean {
    return expressions.indexOf(token) !== -1;
  }

  drawFunctionExpression(expressions: Array<string>, color: string): boolean {
    if (expressions.length === 0 || expressions.indexOf(CommonConstants.VARIABLE_Y) !== -1) {
      return false;
    }
    if (expressions.indexOf(CommonConstants.VARIABLE_X) === -1) {
      let yText = CalculateUtil.parseExpression(Array.from(expressions));
      let yValue = Number(yText);
      if (yText === 'NaN' || Number.isNaN(yValue)) {
        return false;
      }
      return this.drawHorizontalLine(yValue, color);
    }
    this.graphContext.beginPath();
    this.graphContext.strokeStyle = color;
    this.graphContext.lineWidth = 3;
    let hasStarted = false;
    let validPointCount = 0;
    for (let pixelX = 0; pixelX <= this.graphWidth; pixelX++) {
      let xValue = this.graphXMin + (pixelX / this.graphWidth) * (this.graphXMax - this.graphXMin);
      let yText = CalculateUtil.parseExpression(Array.from(expressions), xValue);
      let yValue = Number(yText);
      if (yText === 'NaN' || Number.isNaN(yValue) ||
        yValue === Number.POSITIVE_INFINITY || yValue === Number.NEGATIVE_INFINITY ||
        yValue < this.graphYMin || yValue > this.graphYMax) {
        hasStarted = false;
        continue;
      }
      let pointY = this.mapYToCanvas(yValue);
      if (!hasStarted) {
        this.graphContext.moveTo(pixelX, pointY);
        hasStarted = true;
      } else {
        this.graphContext.lineTo(pixelX, pointY);
      }
      validPointCount++;
    }
    this.graphContext.stroke();
    return validPointCount > 0;
  }

  drawVerticalExpression(expressions: Array<string>, color: string): boolean {
    let xText = CalculateUtil.parseExpression(Array.from(expressions));
    let xValue = Number(xText);
    if (xText === 'NaN' || Number.isNaN(xValue)) {
      return false;
    }
    if (xValue < this.graphXMin || xValue > this.graphXMax) {
      return false;
    }
    let pointX = this.mapXToCanvas(xValue);
    this.graphContext.beginPath();
    this.graphContext.strokeStyle = color;
    this.graphContext.lineWidth = 3;
    this.graphContext.moveTo(pointX, 0);
    this.graphContext.lineTo(pointX, this.graphHeight);
    this.graphContext.stroke();
    return true;
  }

  drawImplicitExpression(leftExpressions: Array<string>, rightExpressions: Array<string>, color: string): boolean {
    this.graphContext.fillStyle = color;
    let pointCount = 0;
    let step = 3;
    let threshold = 0.2;
    for (let pixelX = 0; pixelX <= this.graphWidth; pixelX += step) {
      let previousDiff: number | undefined = undefined;
      let previousPixelY = 0;
      let xValue = this.graphXMin + (pixelX / this.graphWidth) * (this.graphXMax - this.graphXMin);
      for (let pixelY = 0; pixelY <= this.graphHeight; pixelY += step) {
        let yValue = this.graphYMax - (pixelY / this.graphHeight) * (this.graphYMax - this.graphYMin);
        let diff = this.evaluateDifference(leftExpressions, rightExpressions, xValue, yValue);
        if (diff === undefined) {
          previousDiff = undefined;
          continue;
        }
        if (Math.abs(diff) < threshold ||
          (previousDiff !== undefined && previousDiff * diff < 0)) {
          let drawY = (previousDiff !== undefined && previousDiff * diff < 0) ?
            Math.floor((previousPixelY + pixelY) / 2) : pixelY;
          this.graphContext.fillRect(pixelX, drawY, 2, 2);
          pointCount++;
        }
        previousDiff = diff;
        previousPixelY = pixelY;
      }
    }
    return pointCount > 0;
  }

  evaluateDifference(leftExpressions: Array<string>, rightExpressions: Array<string>, xValue: number,
    yValue: number): number | undefined {
    let leftText = CalculateUtil.parseExpression(Array.from(leftExpressions), xValue, yValue);
    let rightText = CalculateUtil.parseExpression(Array.from(rightExpressions), xValue, yValue);
    let leftValue = Number(leftText);
    let rightValue = Number(rightText);
    if (leftText === 'NaN' || rightText === 'NaN' || Number.isNaN(leftValue) || Number.isNaN(rightValue)) {
      return undefined;
    }
    return leftValue - rightValue;
  }

  drawHorizontalLine(yValue: number, color: string): boolean {
    if (yValue < this.graphYMin || yValue > this.graphYMax) {
      return false;
    }
    let pointY = this.mapYToCanvas(yValue);
    this.graphContext.beginPath();
    this.graphContext.strokeStyle = color;
    this.graphContext.lineWidth = 3;
    this.graphContext.moveTo(0, pointY);
    this.graphContext.lineTo(this.graphWidth, pointY);
    this.graphContext.stroke();
    return true;
  }

  drawAxes() {
    this.graphContext.clearRect(0, 0, this.graphWidth, this.graphHeight);
    this.graphContext.fillStyle = '#FFFFFF';
    this.graphContext.fillRect(0, 0, this.graphWidth, this.graphHeight);
    this.drawGrid();
    let xAxisY = this.mapYToCanvas(0);
    let yAxisX = this.mapXToCanvas(0);
    this.graphContext.beginPath();
    this.graphContext.strokeStyle = '#182431';
    this.graphContext.lineWidth = 1;
    this.graphContext.moveTo(0, xAxisY);
    this.graphContext.lineTo(this.graphWidth, xAxisY);
    this.graphContext.moveTo(yAxisX, 0);
    this.graphContext.lineTo(yAxisX, this.graphHeight);
    this.graphContext.stroke();
    this.graphContext.fillStyle = '#182431';
    this.graphContext.font = '18px sans-serif';
    this.graphContext.fillText('X', this.graphWidth - 22, xAxisY - 8);
    this.graphContext.fillText('Y', yAxisX + 8, 22);
    this.graphContext.fillText('0', yAxisX + 7, xAxisY + 20);
  }

  drawGrid() {
    this.graphContext.beginPath();
    this.graphContext.strokeStyle = '#D8E2EF';
    this.graphContext.lineWidth = 1;
    for (let index = -10; index <= 10; index += 2) {
      let pointX = this.mapXToCanvas(index);
      let pointY = this.mapYToCanvas(index);
      this.graphContext.moveTo(pointX, 0);
      this.graphContext.lineTo(pointX, this.graphHeight);
      this.graphContext.moveTo(0, pointY);
      this.graphContext.lineTo(this.graphWidth, pointY);
    }
    this.graphContext.stroke();
  }

  mapXToCanvas(xValue: number): number {
    return ((xValue - this.graphXMin) / (this.graphXMax - this.graphXMin)) * this.graphWidth;
  }

  mapYToCanvas(yValue: number): number {
    return this.graphHeight - ((yValue - this.graphYMin) / (this.graphYMax - this.graphYMin)) * this.graphHeight;
  }

  /**
   * Get Operator.
   *
   * @param value.
   * @return Operators.
   */
  getSymbol(value: string) {
    if (CheckEmptyUtil.isEmpty(value)) {
      return '';
    }
    let symbol = '';
    switch (value) {
      case Symbol.ADD:
        symbol = CommonConstants.ADD;
        break;
      case Symbol.MIN:
        symbol = CommonConstants.MIN;
        break;
      case Symbol.MUL:
        symbol = CommonConstants.MUL;
        break;
      case Symbol.DIV:
        symbol = CommonConstants.DIV;
        break;
      case CommonConstants.POWER:
        symbol = CommonConstants.POWER;
        break;
      case Symbol.SQRT:
        symbol = CommonConstants.SQRT;
        break;
      case Symbol.SQUARE:
        symbol = CommonConstants.SQUARE;
        break;
      case Symbol.CUBE:
        symbol = CommonConstants.CUBE;
        break;
      case Symbol.FACTORIAL:
        symbol = CommonConstants.FACTORIAL;
        break;
      case Symbol.LEFT_PARENTHESIS:
        symbol = CommonConstants.LEFT_PARENTHESIS;
        break;
      case Symbol.RIGHT_PARENTHESIS:
        symbol = CommonConstants.RIGHT_PARENTHESIS;
        break;
      default:
        break;
    }
    return symbol;
  }

  /**
   * Make a deep copy of an expression.
   *
   * @return deep copy expression.
   */
  deepCopy(): Array<string> {
    let copyExpressions: Array<string> = Array.from(this.expressions);
    return copyExpressions;
  }

  /**
   * Obtaining Results.
   *
   * @return Whether the result is incorrect.
   */
  async getResult() {
    if (this.hasVariableExpression() || this.hasEquationExpression()) {
      this.calValue = '';
      return true;
    }
    let calResult = CalculateUtil.parseExpression(this.deepCopy());
    if (calResult === 'NaN') {
      this.calValue = this.resourceToString($r('app.string.error'));
      return false;
    }
    this.calValue = calResult;
    return true;
  }

  /**
   * Number Formatting.
   *
   * @param value Formatting parameters.
   * @return Thousand percentile data.
   */
  resultFormat(value: string) {
    if (CheckEmptyUtil.isEmpty(value) || value.indexOf(CommonConstants.E) !== -1) {
      return value;
    }
    let normalized = value.replace(/,/g, '');
    return normalized.replace(/\d+(\.\d+)?/g, (item: string) => {
      let numberParts = item.split(CommonConstants.DOTS);
      numberParts[0] = numberParts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',');
      return (numberParts.length > 1) ? numberParts[0] + CommonConstants.DOTS + numberParts[1] : numberParts[0];
    });
  }

  /**
   * Convert a resource file to a string.
   *
   * @param resource Resource file.
   * @return Character string converted from the resource file.
   */
  resourceToString(resource: Resource): string {
    if (CheckEmptyUtil.isEmpty(resource)) {
      return '';
    }
    let result = '';
    try {
      const uiContext: UIContext | undefined = AppStorage.get('uiContext');
      let context = uiContext!.getHostContext()!;
      result = context.resourceManager.getStringSync(resource.id);
    } catch (error) {
      Logger.error('[CalculateModel] getResourceString fail: ' + JSON.stringify(error))
    }
    return result;
  }

  /**
   * Thousands in the formatting result.
   */
  formatInputValue() {
    let deepExpressions: Array<string> = [];
    this.deepCopy().forEach((item: string, index: number) => {
      deepExpressions[index] = this.resultFormat(item);
    });
    this.inputValue = deepExpressions.join('');
  }
}
