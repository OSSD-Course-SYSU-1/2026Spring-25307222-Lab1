/*
 * Copyright (c) 2026 Huawei Device Co., Ltd.
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

import { UIAbility } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { CommonConstants, Logger } from 'base';


const DOMAIN = 0x0000;

// [Start UIAbility]
export default class EntryAbility extends UIAbility {
  uiContext?: UIContext;
  onWindowSizeChange: (windowSize: window.Size) => void = () => {
    let widthBp: WidthBreakpoint = this.uiContext!.getWindowWidthBreakpoint();
    AppStorage.setOrCreate(CommonConstants.WIDTH_BREAK_POINT, widthBp);
    let heightBp: HeightBreakpoint = this.uiContext!.getWindowHeightBreakpoint();
    AppStorage.setOrCreate(CommonConstants.HEIGHT_BREAK_POINT, heightBp);
  }

  // [StartExclude UIAbility]
  onCreate(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }
  // [EndExclude UIAbility]

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // [StartExclude UIAbility]
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    // [EndExclude UIAbility]

    windowStage.loadContent('pages/Index', (err) => {
      // [StartExclude UIAbility]
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
      // [EndExclude UIAbility]

      windowStage.getMainWindow().then((data: window.Window) => {
        try {
          this.uiContext = data.getUIContext();
        } catch (err) {
          Logger.error(`Invoke set preferred orientation failed, code is ${err.code}, message is ${err.message}`)
        }

        let widthBp: WidthBreakpoint = this.uiContext!.getWindowWidthBreakpoint();
        AppStorage.setOrCreate(CommonConstants.WIDTH_BREAK_POINT, widthBp);

        let heightBp: HeightBreakpoint = this.uiContext!.getWindowHeightBreakpoint();
        AppStorage.setOrCreate(CommonConstants.HEIGHT_BREAK_POINT, heightBp);

        data.on('windowSizeChange', this.onWindowSizeChange);
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, 'testTag', `Error occured, error code: ${err.code}, error message: ${err.message}`);
      })

    });
  }

  // [StartExclude UIAbility]
  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
  // [EndExclude UIAbility]
}
// [End UIAbility]

