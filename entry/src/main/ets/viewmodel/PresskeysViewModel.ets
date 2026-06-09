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

import { PressKeysBean } from './PressKeysItem';
import { CommonConstants } from '../common/constants/CommonConstants';

export class PressKeysBeanViewModel {

  /**
   * Key array data.
   */
  getPressKeys(): Array<Array<PressKeysBean>> {
    return [
      [
        new PressKeysBean(0, '32vp', '32vp', 'clean', $r('app.media.ic_clean')),
        new PressKeysBean(1, '19vp', '43vp', '7'),
        new PressKeysBean(1, '19vp', '43vp', '4'),
        new PressKeysBean(1, '19vp', '43vp', '1'),
        new PressKeysBean(1, '25vp', '43vp', '%')
      ],
      [
        new PressKeysBean(0, '32vp', '32vp', 'div', $r('app.media.ic_div')),
        new PressKeysBean(1, '19vp', '43vp', '8'),
        new PressKeysBean(1, '19vp', '43vp', '5'),
        new PressKeysBean(1, '19vp', '43vp', '2'),
        new PressKeysBean(1, '19vp', '43vp', '0')
      ],
      [
        new PressKeysBean(0, '32vp', '32vp', 'mul', $r('app.media.ic_mul')),
        new PressKeysBean(1, '19vp', '43vp', '9'),
        new PressKeysBean(1, '19vp', '43vp', '6'),
        new PressKeysBean(1, '19vp', '43vp', '3'),
        new PressKeysBean(1, '19vp', '43vp', '.')
      ],
      [
        new PressKeysBean(0, '30.48vp', '20vp', 'del', $r('app.media.ic_del')),
        new PressKeysBean(1, '24vp', '43vp', CommonConstants.SQRT),
        new PressKeysBean(0, '24vp', '24vp', 'min', $r('app.media.ic_min')),
        new PressKeysBean(0, '32vp', '32vp', 'add', $r('app.media.ic_add')),
        new PressKeysBean(0, '32vp', '32vp', 'equ', $r('app.media.ic_equ'))
      ],
      [
        new PressKeysBean(1, '24vp', '43vp', CommonConstants.LEFT_PARENTHESIS),
        new PressKeysBean(1, '24vp', '43vp', CommonConstants.RIGHT_PARENTHESIS),
        new PressKeysBean(1, '34vp', '43vp', CommonConstants.SQUARE_KEY),
        new PressKeysBean(1, '34vp', '43vp', CommonConstants.CUBE_KEY),
        new PressKeysBean(1, '24vp', '43vp', CommonConstants.FACTORIAL)
      ],
      [
        new PressKeysBean(1, '34vp', '43vp', CommonConstants.SIN),
        new PressKeysBean(1, '34vp', '43vp', CommonConstants.COS),
        new PressKeysBean(1, '34vp', '43vp', CommonConstants.TAN),
        new PressKeysBean(1, '24vp', '43vp', CommonConstants.VARIABLE_X),
        new PressKeysBean(1, '24vp', '43vp', CommonConstants.VARIABLE_Y)
      ],
      [
        new PressKeysBean(1, '24vp', '43vp', CommonConstants.PI),
        new PressKeysBean(1, '24vp', '43vp', CommonConstants.E),
        new PressKeysBean(1, '24vp', '43vp', CommonConstants.EQUATION_EQUAL),
        new PressKeysBean(1, '42vp', '43vp', CommonConstants.X_POWER_X),
        new PressKeysBean(1, '56vp', '43vp', CommonConstants.DRAW)
      ]
    ];
  }
}

let keysModel = new PressKeysBeanViewModel();
export default keysModel as PressKeysBeanViewModel;
