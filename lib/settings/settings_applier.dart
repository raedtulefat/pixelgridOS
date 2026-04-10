import 'package:game_shell/os.dart';
import 'package:game_shell/settings/settings_controller.dart';

class SettingsApplier {
  void applyAll({
    required ShellOs os,
    required Map<SettingToggle, bool> settings,
    required void Function(bool showPrompt) setPromptBannerVisible,
  }) {
    final promptBanner = settings[SettingToggle.promptBanner];
    if (promptBanner != null) {
      setPromptBannerVisible(promptBanner);
    }

    final debugEnabled = settings[SettingToggle.debugEnabled] ?? true;

    for (final entry in _debugFlagForSetting.entries) {
      final value = settings[entry.key];
      if (value == null) {
        continue;
      }
      os.setDebugUiFlag(entry.value, debugEnabled ? value : false);
    }
  }
}

const Map<SettingToggle, DebugUiLayer> _debugFlagForSetting =
    <SettingToggle, DebugUiLayer>{
  SettingToggle.debugInfoText: DebugUiLayer.infoText,
  SettingToggle.debugShellLogs: DebugUiLayer.shellLogs,
  SettingToggle.debugSurfaceOutline: DebugUiLayer.surfaceOutline,
  SettingToggle.debugTileGrid: DebugUiLayer.tileGrid,
};
