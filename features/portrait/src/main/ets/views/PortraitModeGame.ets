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

import { window } from "@kit.ArkUI";
import { common } from "@kit.AbilityKit";
import { CommonConstants, Logger } from "base";
import { PortraitConstants } from "../constants/PortraitConstants";

@Builder
export function PortraitModeGameBuilder() {
  PortraitModeGame()
}

@Component
export struct PortraitModeGame {
  @StorageLink(CommonConstants.WIDTH_BREAK_POINT) widthBp: WidthBreakpoint = WidthBreakpoint.WIDTH_SM;
  windowObj: window.Window | undefined = undefined;
  @State blockArr: number[] = [];
  @State blockColorArr: Resource[] = PortraitConstants.BLOCK_COLOR_ARR;

  aboutToAppear(): void {
    try {
      this.windowObj = (this.getUIContext().getHostContext() as common.UIAbilityContext).windowStage.getMainWindowSync()
    } catch (err) {
      Logger.error(`Invoke set preferred orientation failed, code is ${err.code}, message is ${err.message}`)
    }

    this.windowObj?.setPreferredOrientation(window.Orientation.PORTRAIT)
      .catch((err: BusinessError) => {
        Logger.error(`Invoke set preferred orientation failed, code is ${err.code}, message is ${err.message}`)
      });
    this.initBlockArray();
  }

  aboutToDisappear() {
    this.windowObj?.setPreferredOrientation(window.Orientation.UNSPECIFIED)
      .catch((err: BusinessError) => {
        Logger.error(`Invoke set preferred orientation failed, code is ${err.code}, message is ${err.message}`)
      });
  }

  // 设置FlowItem的宽/高数组
  initBlockArray() {
    for (let i = 0; i < 64; i++) {
      this.blockArr.push(i);
    }
  }

  randomColor() {
    return this.blockColorArr[Math.floor(Math.random() * 3)];
  }

  build() {
    NavDestination() {
      Column({ space: 8 }) {
        Text($r("app.string.Level2"))
          .width(CommonConstants.FULL_PERCENT)
          .textAlign(TextAlign.Start)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .textIndent(12)
          .fontColor($r('app.color.title_font_color'))
        List() {
          ForEach(this.blockArr, () => {
            ListItem() {
              Column() {
                Text()
                  .width("70%")
                  .aspectRatio(1)
                  .backgroundColor(this.randomColor())
              }
              .width(CommonConstants.FULL_PERCENT)
              .height(CommonConstants.FULL_PERCENT)
              .alignItems(HorizontalAlign.Center)
              .justifyContent(FlexAlign.Center)
            }
            .border({ width: { right: 1, bottom: 1 }, color: $r('app.color.border_color') })
            .aspectRatio(1)
          }, (item: number) => item.toString())
        }
        .width(CommonConstants.FULL_PERCENT)
        .height("auto")
        .lanes(8)
        .border({ width: { top: 1, left: 1 }, color: $r('app.color.border_color') })
        .scrollBar(BarState.Off)
        .backgroundColor($r('app.color.portrait_bg'))
      }
      .height(CommonConstants.FULL_PERCENT)
      .width(CommonConstants.FULL_PERCENT)
      .padding({
        left: 16,
        right: 16,
        top: 28
      })
    }
    .height(CommonConstants.FULL_PERCENT)
    .width(CommonConstants.FULL_PERCENT)
    .title($r("app.string.portrait_game"), { backgroundColor: $r('app.color.common_background_color') })
    .backgroundColor($r('app.color.common_background_color'))
  }
}