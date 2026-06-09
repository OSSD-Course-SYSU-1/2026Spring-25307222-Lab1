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

import { CommonConstants, Priority, SymbolicEnumeration } from '../constants/CommonConstants';
import CheckEmptyUtil from './CheckEmptyUtil';

class CalculateUtil {
  /**
   * Determines whether it is an operator.
   *
   * @param value The symbol.
   * @return Is Operator.
   */
  isSymbol(value: string) {
    if (CheckEmptyUtil.isEmpty(value)) {
      return ;
    }
    return (CommonConstants.OPERATORS.indexOf(value) !== -1);
  }

  isBinarySymbol(value: string): boolean {
    return value === CommonConstants.ADD || value === CommonConstants.MIN ||
      value === CommonConstants.MUL || value === CommonConstants.DIV ||
      value === CommonConstants.POWER;
  }

  isPrefixSymbol(value: string): boolean {
    return value === CommonConstants.SQRT || value === CommonConstants.SIN ||
      value === CommonConstants.COS || value === CommonConstants.TAN;
  }

  isPostfixSymbol(value: string): boolean {
    return value === CommonConstants.SQUARE || value === CommonConstants.CUBE ||
      value === CommonConstants.FACTORIAL;
  }

  isLeftParenthesis(value: string): boolean {
    return value === CommonConstants.LEFT_PARENTHESIS;
  }

  isRightParenthesis(value: string): boolean {
    return value === CommonConstants.RIGHT_PARENTHESIS;
  }

  /**
   * Get Operator Precedence.
   *
   * @param value The symbol.
   * @return Priority.
   */
  getPriority(value: string): number {
    if (CheckEmptyUtil.isEmpty(value)) {
      return Priority.LOW;
    }
    let result = 0;
    switch (value) {
      case SymbolicEnumeration.ADD:
      case SymbolicEnumeration.MIN:
        result = Priority.MEDIUM;
        break;
      case SymbolicEnumeration.MUL:
      case SymbolicEnumeration.DIV:
        result = Priority.HIGH;
        break;
      case SymbolicEnumeration.POWER:
      case SymbolicEnumeration.SQRT:
      case SymbolicEnumeration.SIN:
      case SymbolicEnumeration.COS:
      case SymbolicEnumeration.TAN:
      case SymbolicEnumeration.SQUARE:
      case SymbolicEnumeration.CUBE:
      case SymbolicEnumeration.FACTORIAL:
        result = Priority.HIGHEST;
        break;
      default:
        result = Priority.LOW;
        break;
    }
    return result;
  }

  /**
   * Determine the priority of addition, subtraction, multiplication, and division.
   *
   * @param arg1 Parameter 1.
   * @param arg2 Parameter 2.
   * @return Compare Priority Results.
   */
  comparePriority(arg1: string, arg2: string): boolean {
    if (CheckEmptyUtil.isEmpty(arg1) || CheckEmptyUtil.isEmpty(arg2)) {
      return false;
    }
    return (this.getPriority(arg1) <= this.getPriority(arg2));
  }

  /**
   * Expression Processing.
   *
   * @param expressions Expressions.
   */
  parseExpression(expressions: Array<string>, variableX?: number, variableY?: number): string {
    if (CheckEmptyUtil.isEmpty(expressions)) {
      return 'NaN';
    }
    expressions = this.normalizeExpression(expressions, variableX, variableY);
    if (CheckEmptyUtil.isEmpty(expressions)) {
      return 'NaN';
    }
    let last = expressions[expressions.length - 1];
    if (this.isBinarySymbol(last)) {
      expressions.pop();
    } else if (this.isPrefixSymbol(last) || this.isLeftParenthesis(last)) {
      return 'NaN';
    }
    let outputStack: string[] = [];
    let outputQueue: string[] = [];
    while (expressions.length > 0) {
      let current: string | undefined = expressions.shift();
      if (current !== undefined) {
        if (this.isLeftParenthesis(current)) {
          outputStack.push(current);
        } else if (this.isRightParenthesis(current)) {
          let hasLeftParenthesis = false;
          while (outputStack.length > 0) {
            let popValue: string | undefined = outputStack.pop();
            if (popValue !== undefined) {
              if (this.isLeftParenthesis(popValue)) {
                hasLeftParenthesis = true;
                break;
              }
              outputQueue.push(popValue);
            }
          }
          if (!hasLeftParenthesis) {
            return 'NaN';
          }
        } else if (this.isPostfixSymbol(current)) {
          outputQueue.push(current);
        } else if (this.isPrefixSymbol(current)) {
          outputStack.push(current);
        } else if (this.isBinarySymbol(current)) {
          while (outputStack.length > 0 &&
            !this.isLeftParenthesis(outputStack[outputStack.length - 1]) &&
            this.comparePriority(current, outputStack[outputStack.length - 1])) {
            let popValue: string | undefined = outputStack.pop();
            if (popValue !== undefined) {
              outputQueue.push(popValue);
            }
          }
          outputStack.push(current);
        } else {
          // Processing the numbers.
          outputQueue.push(current);
        }
      }
    }
    while (outputStack.length > 0) {
      let popValue: string | undefined = outputStack.pop();
      if (popValue !== undefined) {
        if (this.isLeftParenthesis(popValue) || this.isRightParenthesis(popValue)) {
          return 'NaN';
        }
        outputQueue.push(popValue);
      }
    }
    return this.dealQueue(outputQueue);
  }

  normalizeExpression(expressions: Array<string>, variableX?: number, variableY?: number): Array<string> {
    let result: Array<string> = [];
    expressions.forEach((item: string) => {
      if (item.indexOf(CommonConstants.PERCENT_SIGN) !== -1) {
        let numberValue = item.slice(0, item.length - 1);
        if (CheckEmptyUtil.isEmpty(numberValue)) {
          return;
        }
        result.push((this.mulOrDiv(numberValue, CommonConstants.ONE_HUNDRED, CommonConstants.DIV)).toString());
      } else if (item === CommonConstants.VARIABLE_X) {
        result.push((variableX !== undefined) ? variableX.toString() : item);
      } else if (item === CommonConstants.VARIABLE_Y) {
        result.push((variableY !== undefined) ? variableY.toString() : item);
      } else if (item === CommonConstants.PI) {
        result.push(Math.PI.toString());
      } else if (item === CommonConstants.E) {
        result.push(Math.E.toString());
      } else {
        result.push(item);
      }
    });
    return result;
  }

  /**
   * Processing expressions in queues.
   *
   * @param queue Expression Queue.
   * @return The end result.
   */
  dealQueue(queue: Array<string>): string {
    if (CheckEmptyUtil.isEmpty(queue)) {
      return 'NaN';
    }
    let outputStack: string[] = [];
    while (queue.length > 0) {
      let current: string | undefined = queue.shift();
      if (current !== undefined) {
        if (!this.isSymbol(current)) {
          outputStack.push(current);
        } else if (this.isPrefixSymbol(current) || this.isPostfixSymbol(current)) {
          let value: string | undefined = outputStack.pop();
          if (value !== undefined) {
            let calResultValue: string = this.calUnaryResult(value, current);
            if (calResultValue === 'NaN') {
              return 'NaN';
            }
            outputStack.push(calResultValue);
          }
        } else if (this.isBinarySymbol(current)) {
          let second: string | undefined = outputStack.pop();
          let first: string | undefined = outputStack.pop();
          if (first !== undefined && second !== undefined) {
            let calResultValue: string = this.calResult(first, second, current)
            if (calResultValue === 'NaN') {
              return 'NaN';
            }
            outputStack.push(calResultValue);
          }
        }
      }
    }
    if (outputStack.length !== 1) {
      return 'NaN';
    } else {
      let end: string = outputStack[0]?.endsWith(CommonConstants.DOTS) ?
        outputStack[0].substring(0, outputStack[0].length - 1) : outputStack[0];
      return end;
    }
  }

  /**
   * Calculation result.
   *
   * @param arg1 Number 1.
   * @param arg2 Number 2.
   * @param symbol Operators.
   * @return Calculation result.
   */
  calResult(arg1: string, arg2: string, symbol: string): string {
    if (CheckEmptyUtil.isEmpty(arg1) || CheckEmptyUtil.isEmpty(arg2) || CheckEmptyUtil.isEmpty(symbol)) {
      return 'NaN';
    }
    let result = 0;
    switch (symbol) {
      case SymbolicEnumeration.ADD:
        result = this.add(arg1, arg2, CommonConstants.ADD);
        break;
      case SymbolicEnumeration.MIN:
        result = this.add(arg1, arg2, CommonConstants.MIN);
        break;
      case SymbolicEnumeration.MUL:
        result = this.mulOrDiv(arg1, arg2, CommonConstants.MUL);
        break;
      case SymbolicEnumeration.DIV:
        result = this.mulOrDiv(arg1, arg2, CommonConstants.DIV);
        break;
      case SymbolicEnumeration.POWER:
        result = Math.pow(Number(arg1), Number(arg2));
        break;
      default:
        break;
    }
    return this.numberToScientificNotation(result);
  }

  calUnaryResult(arg: string, symbol: string): string {
    if (CheckEmptyUtil.isEmpty(arg) || CheckEmptyUtil.isEmpty(symbol)) {
      return 'NaN';
    }
    switch (symbol) {
      case SymbolicEnumeration.SQRT:
        return this.sqrt(arg);
      case SymbolicEnumeration.SIN:
        return this.trigonometric(arg, CommonConstants.SIN);
      case SymbolicEnumeration.COS:
        return this.trigonometric(arg, CommonConstants.COS);
      case SymbolicEnumeration.TAN:
        return this.trigonometric(arg, CommonConstants.TAN);
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

  /**
   * Square root operation.
   *
   * @param arg Number.
   * @return Square root result.
   */
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

  power(arg: string, exponent: number): string {
    if (CheckEmptyUtil.isEmpty(arg)) {
      return 'NaN';
    }
    return this.numberToScientificNotation(Math.pow(Number(arg), exponent));
  }

  trigonometric(arg: string, functionName: string): string {
    if (CheckEmptyUtil.isEmpty(arg)) {
      return 'NaN';
    }
    let value = Number(arg);
    if (Number.isNaN(value)) {
      return 'NaN';
    }
    let result = 0;
    switch (functionName) {
      case CommonConstants.SIN:
        result = Math.sin(value);
        break;
      case CommonConstants.COS:
        result = Math.cos(value);
        break;
      case CommonConstants.TAN:
        result = Math.tan(value);
        break;
      default:
        return 'NaN';
    }
    if (Math.abs(result) < 1e-12) {
      result = 0;
    }
    return this.numberToScientificNotation(result);
  }

  factorial(arg: string): string {
    if (CheckEmptyUtil.isEmpty(arg)) {
      return 'NaN';
    }
    let value = Number(arg);
    if (Number.isNaN(value) || value < 0 || Math.floor(value) !== value || value > 170) {
      return 'NaN';
    }
    let result = 1;
    for (let index = 2; index <= value; index++) {
      result *= index;
    }
    return this.numberToScientificNotation(result);
  }

  /**
   * Addition and subtraction operation.
   *
   * @param arg1 Number 1.
   * @param arg2 Number 2.
   * @param symbol Operators.
   * @return Addition and subtraction results.
   */
  add(arg1: string, arg2: string, symbol: string): number {
    let addFlag = (symbol === CommonConstants.ADD);
    if (this.containScientificNotation(arg1) || this.containScientificNotation(arg2)) {
      if (addFlag) {
        return Number(arg1) + Number(arg2);
      }
      return Number(arg1) - Number(arg2);
    }
    arg1 = (arg1 === CommonConstants.ZERO_DOTS) ? '0' : arg1;
    arg2 = (arg2 === CommonConstants.ZERO_DOTS) ? '0' : arg2;
    let leftArr = arg1.split(CommonConstants.DOTS);
    let rightArr = arg2.split(CommonConstants.DOTS);
    let leftLen = leftArr.length > 1 ? leftArr[1] : '';
    let rightLen = rightArr.length > 1 ? rightArr[1] : '';
    let maxLen = Math.max(leftLen.length, rightLen.length);
    let multiples = Math.pow(CommonConstants.TEN, maxLen);
    if (addFlag) {
      return Number(((Number(arg1) * multiples + Number(arg2) * multiples) / multiples).toFixed(maxLen));
    }
    return Number(((Number(arg1) * multiples - Number(arg2) * multiples) / multiples).toFixed(maxLen));
  }

  /**
   * multiplication and division operation.
   *
   * @param arg1 Number 1.
   * @param arg2 Number 2.
   * @param symbol Operators.
   * @return Multiply and divide result.
   */
  mulOrDiv(arg1: string, arg2: string, symbol: string): number {
    let mulFlag = (symbol === CommonConstants.MUL);
    if (this.containScientificNotation(arg1) || this.containScientificNotation(arg2)) {
      if (mulFlag) {
        return Number(arg1) * Number(arg2);
      }
      return Number(arg1) / Number(arg2);
    }
    let leftLen = arg1.split(CommonConstants.DOTS)[1] ? arg1.split(CommonConstants.DOTS)[1].length : 0;
    let rightLen = arg2.split(CommonConstants.DOTS)[1] ? arg2.split(CommonConstants.DOTS)[1].length : 0;
    if (mulFlag) {
      return Number(arg1.replace(CommonConstants.DOTS, '')) *
        Number(arg2.replace(CommonConstants.DOTS, '')) / Math.pow(CommonConstants.TEN, leftLen + rightLen);
    }
    return Number(arg1.replace(CommonConstants.DOTS, '')) /
      (Number(arg2.replace(CommonConstants.DOTS, '')) / Math.pow(CommonConstants.TEN, rightLen - leftLen));
  }

  /**
   * Whether the operand contains scientific notation
   *
   * @param arg Number.
   * @return Whether scientific notation is included
   */
  containScientificNotation(arg: string) {
    return (arg.indexOf(CommonConstants.E) !== -1);
  }

  /**
   * Results converted to scientific notation.
   *
   * @param result Digital Results.
   */
  numberToScientificNotation(result: number) {
    if (Number.isNaN(result) || result === Number.NEGATIVE_INFINITY || result === Number.POSITIVE_INFINITY) {
      return 'NaN';
    }
    let resultStr = JSON.stringify(result);
    if (this.containScientificNotation(resultStr)) {
      return resultStr;
    }
    let prefixNumber = (resultStr.indexOf(CommonConstants.MIN) === -1) ? 1 : -1;
    result *= prefixNumber;
    if (resultStr.replace(CommonConstants.DOTS, '').replace(CommonConstants.MIN, '').length <
      CommonConstants.NUM_MAX_LEN) {
      return resultStr;
    }
    let suffix = (Math.floor(Math.log(result) / Math.LN10));
    let prefix = (result * Math.pow(CommonConstants.TEN, -suffix) * prefixNumber);
    return (prefix + CommonConstants.E + suffix);
  }
}

export default new CalculateUtil();
