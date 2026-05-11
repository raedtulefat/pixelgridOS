import 'package:pixelgrid/pixelgrid/settings/settings_controller.dart';

class SettingsApplier {
  void applyAll({
    required Map<SettingToggle, bool> settings,
    required void Function(bool showPrompt) setPromptBannerVisible,
  }) {
    final promptBanner = settings[SettingToggle.promptBanner] ?? false;
    setPromptBannerVisible(promptBanner);
  }
}
