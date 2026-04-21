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
import { CardListModel } from "../model/CardListModel";

export class CardListViewModel {
  private cardList: CardListModel[] = [];

  constructor() {
    this.initCardList()
  }

  initCardList() {
    this.cardList.push(new CardListModel($r("app.string.homepage"), 'FOLLOW_DESKTOP', 'Home'))
    this.cardList.push(new CardListModel($r("app.string.portrait_mode_game"), 'PORTRAIT', 'PortraitModeGame'))
    this.cardList.push(new CardListModel($r("app.string.landscape_mode_game"), 'LANDSCAPE', 'LandscapeModeGame'))
    this.cardList.push(new CardListModel($r("app.string.photos"), 'AUTO_ROTATION_UNSPECIFIED', 'Photos'))
    this.cardList.push(new CardListModel($r("app.string.stock"), 'FOLLOW_DESKTOP', 'StockDetail'))
    this.cardList.push(new CardListModel($r("app.string.video"), 'AUTO_ROTATION_LANDSCAPE_RESTRICTED', 'VideoDetail'))
  }

  getCardList(): CardListModel[] {
    return this.cardList
  }
}