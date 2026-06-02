import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';

const CONTINUATION_STATE_KEY: string = 'calculatorContinuationState';
const CONTINUATION_SIGNAL_KEY: string = 'calculatorContinuationSignal';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    this.restoreContinuationData(want);
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam) {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onNewWant');
    this.restoreContinuationData(want);
  }

  onContinue(wantParam: Record<string, Object>): AbilityConstant.OnContinueResult {
    let stateText = AppStorage.get<string>(CONTINUATION_STATE_KEY);
    if (stateText !== undefined && stateText.length > 0) {
      wantParam[CONTINUATION_STATE_KEY] = stateText;
      hilog.info(0x0000, 'testTag', 'Calculator state prepared for continuation.');
    }
    return AbilityConstant.OnContinueResult.AGREE;
  }

  onDestroy() {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage) {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    let mainWindow: window.Window | undefined = undefined;
    try {
      mainWindow = windowStage.getMainWindowSync();
      mainWindow.setPreferredOrientation(window.Orientation.LANDSCAPE).then(() => {
        hilog.info(0x0000, 'testTag', '%{public}s', 'Succeeded in setting landscape orientation');
      }).catch((error) => {
        hilog.error(0x0000, 'testTag', 'Failed to set landscape orientation. Cause: %{public}s',
          JSON.stringify(error) ?? '');
      });
    } catch (error) {
      hilog.error(0x0000, 'testTag', 'Failed to get main window. Cause: %{public}s',
        JSON.stringify(error) ?? '');
    }
    windowStage.loadContent('pages/HomePage', (err, data) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content. Data: %{public}s', JSON.stringify(data) ?? '');

      if (mainWindow !== undefined) {
        let uiContext = mainWindow.getUIContext()
        AppStorage.setOrCreate('uiContext', uiContext);
      }
    });
  }

  onWindowStageDestroy() {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground() {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground() {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }

  private restoreContinuationData(want: Want) {
    if (want.parameters === undefined) {
      return;
    }
    let stateValue = want.parameters[CONTINUATION_STATE_KEY];
    if (typeof stateValue !== 'string' || stateValue.length === 0) {
      return;
    }
    AppStorage.setOrCreate(CONTINUATION_STATE_KEY, stateValue);
    AppStorage.setOrCreate(CONTINUATION_SIGNAL_KEY, Date.now().toString());
    hilog.info(0x0000, 'testTag', 'Calculator state restored from continuation.');
  }
}
