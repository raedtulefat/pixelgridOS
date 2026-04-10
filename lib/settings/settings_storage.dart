import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SettingsStorage {
  static const String _settingsJsonKey = 'settings.json';
  static const String _keysKey = 'settings.toggles.keys';
  static const String _togglePrefix = 'settings.toggle.';
  static const String _legacySettingsKey = 'settings.toggles';

  Future<Map<String, dynamic>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final rawJson = prefs.getString(_settingsJsonKey);
      if (rawJson != null && rawJson.isNotEmpty) {
        final decoded = jsonDecode(rawJson);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      }

      final migrated = await _migrateLegacyValues(prefs);
      if (migrated.isNotEmpty) {
        await save(migrated);
      }
      return migrated;
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  Future<void> save(Map<String, dynamic> values) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(values);
      await prefs.setString(_settingsJsonKey, encoded);

      // Cleanup legacy keys once JSON storage is active.
      await prefs.remove(_keysKey);
      await prefs.remove(_legacySettingsKey);
      final allKeys = prefs.getKeys();
      for (final key in allKeys) {
        if (key.startsWith(_togglePrefix)) {
          await prefs.remove(key);
        }
      }
    } catch (_) {
      // Ignore storage failures; settings are non-critical.
    }
  }

  Future<Map<String, dynamic>> _migrateLegacyValues(
    SharedPreferences prefs,
  ) async {
    final result = <String, dynamic>{};

    final keys = prefs.getStringList(_keysKey);
    if (keys != null && keys.isNotEmpty) {
      for (final key in keys) {
        final stored = prefs.getBool('$_togglePrefix$key');
        if (stored != null) {
          result[key] = stored;
        }
      }
      return result;
    }

    final legacy = prefs.getStringList(_legacySettingsKey);
    if (legacy != null && legacy.isNotEmpty) {
      for (final entry in legacy) {
        final parts = entry.split('=');
        if (parts.length != 2) {
          continue;
        }
        result[parts.first] = parts.last.toLowerCase() == 'true';
      }
    }

    return result;
  }
}
