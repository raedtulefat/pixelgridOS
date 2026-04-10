import 'package:game_shell/settings/settings_storage.dart';

enum SettingToggle {
  developerMode,
  promptBanner,
  debugEnabled,
  debugInfoText,
  debugShellLogs,
  debugSurfaceOutline,
  debugTileGrid,
}

class SettingsController {
  SettingsController(this._storage);

  final SettingsStorage _storage;
  final Map<SettingToggle, bool> _settings = <SettingToggle, bool>{};
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) {
      return;
    }
    final raw = await _storage.load();
    _settings.clear();
    for (final entry in raw.entries) {
      final toggle = _toggleForKey(entry.key);
      if (toggle == null) {
        continue;
      }
      _settings[toggle] = entry.value;
    }
    _loaded = true;
  }

  bool get(SettingToggle key, {required bool defaultValue}) {
    return _settings[key] ?? defaultValue;
  }

  Future<void> set(SettingToggle key, bool value) async {
    _settings[key] = value;
    await _storage.save(_serialize());
  }

  Map<SettingToggle, bool> snapshot() {
    return Map<SettingToggle, bool>.unmodifiable(_settings);
  }

  Map<String, bool> _serialize() {
    return <String, bool>{
      for (final entry in _settings.entries) entry.key.name: entry.value,
    };
  }

  SettingToggle? _toggleForKey(String key) {
    for (final toggle in SettingToggle.values) {
      if (toggle.name == key) {
        return toggle;
      }
    }
    return null;
  }
}
