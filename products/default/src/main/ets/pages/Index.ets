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
import { CommonConstants } from 'base';
import { CardListModel } from '../model/CardListModel';
import { CardListViewModel } from '../viewmodel/CardListViewModel';

@Builder
export function IndexBuilder() {
  Index()
}

@Builder
function ListItemCard(params: CardListModel) {
  Row() {
    Column({ space: 2 }) {
      Text(params.title)
        .height(22)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
      Text(params.desc)
        .height(19)
        .fontSize(14)
        .fontColor($r("app.color.desc_font_color"))
        .maxLines(1)
    }
    .layoutWeight(1)
    .height(CommonConstants.FULL_PERCENT)
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)

    Image($r('app.media.ic_arrow_right_small'))
      .width(12)
      .height(24)
  }
  .width(CommonConstants.FULL_PERCENT)
  .height(CommonConstants.FULL_PERCENT)
  .padding({
    left: 12,
    right: 12
  })
  .alignItems(VerticalAlign.Center)
  .justifyContent(FlexAlign.SpaceBetween)
  .borderRadius(16)
  .backgroundColor($r('app.color.list_background_color'))
}

@Entry
@Component
struct Index {
  @StorageLink(CommonConstants.WIDTH_BREAK_POINT) widthBp: WidthBreakpoint = WidthBreakpoint.WIDTH_SM;
  pathStack: NavPathStack = new NavPathStack();
  private cardList: CardListModel[] = [];

  aboutToAppear(): void {
    this.cardList = new CardListViewModel().getCardList()
  }

  build() {
    Navigation(this.pathStack) {
      List() {
        ForEach(this.cardList, (item: CardListModel) => {
          ListItem() {
            ListItemCard(item)
          }
          .width(CommonConstants.FULL_PERCENT)
          .height(72)
          .padding({
            left: 16,
            right: 16
          })
          .margin({
            bottom: 8
          })
          .onClick(() => {
            this.pathStack.pushPathByName(item.pathName, null);
          })
        }, (item: CardListModel) => item.pathName)
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .scrollBar(BarState.Off)
      .alignListItem(ListItemAlign.Center)
      .backgroundColor($r('app.color.common_background_color'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      .margin({
        top: 4
      })
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .backgroundColor($r('app.color.common_background_color'))
    .mode(NavigationMode.Stack)
    .title($r('app.string.mode_list'))
    .titleMode(NavigationTitleMode.Mini)
    .hideBackButton(true)
  }
}