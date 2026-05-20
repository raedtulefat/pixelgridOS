import 'package:pixelgrid/pixelgrid/settings/settings_storage.dart';

enum SettingToggle {
  promptBanner,
}

class SettingsController {
  SettingsController(this._storage);

  final SettingsStorage _storage;
  final Map<String, dynamic> _settings = <String, dynamic>{};
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) {
      return;
    }
    final raw = await _storage.load();
    _settings
      ..clear()
      ..addAll(raw);
    _loaded = true;
  }

  bool get(SettingToggle key, {required bool defaultValue}) {
    return getBoolByKey(key.name, defaultValue: defaultValue);
  }

  Future<void> set(SettingToggle key, bool value) {
    return setBoolByKey(key.name, value);
  }

  bool getBoolByKey(String key, {required bool defaultValue}) {
    final value = _settings[key];
    if (value is bool) {
      return value;
    }
    return defaultValue;
  }

  double getDoubleByKey(String key, {required double defaultValue}) {
    final value = _settings[key];
    if (value is num) {
      return value.toDouble();
    }
    return defaultValue;
  }

  Future<void> setBoolByKey(String key, bool value) async {
    _settings[key] = value;
    await _storage.save(snapshotRaw());
  }

  Future<void> setDoubleByKey(String key, double value) async {
    _settings[key] = value;
    await _storage.save(snapshotRaw());
  }

  String getStringByKey(String key, {required String defaultValue}) {
    final value = _settings[key];
    if (value is String) {
      return value;
    }
    return defaultValue;
  }

  Future<void> setStringByKey(String key, String value) async {
    _settings[key] = value;
    await _storage.save(snapshotRaw());
  }

  List<String> getStringListByKey(
    String key, {
    required List<String> defaultValue,
  }) {
    final value = _settings[key];
    if (value is List) {
      return value.whereType<String>().toList(growable: false);
    }
    return defaultValue;
  }

  Future<void> setStringListByKey(String key, List<String> value) async {
    _settings[key] = List<String>.unmodifiable(value);
    await _storage.save(snapshotRaw());
  }

  int getIntByKey(String key, {required int defaultValue}) {
    final value = _settings[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return defaultValue;
  }

  Future<void> setIntByKey(String key, int value) async {
    _settings[key] = value;
    await _storage.save(snapshotRaw());
  }

  Map<SettingToggle, bool> snapshot() {
    return <SettingToggle, bool>{
      for (final toggle in SettingToggle.values)
        if (_settings[toggle.name] is bool)
          toggle: _settings[toggle.name] as bool,
    };
  }

  Map<String, dynamic> snapshotRaw() {
    return Map<String, dynamic>.unmodifiable(_settings);
  }
}
