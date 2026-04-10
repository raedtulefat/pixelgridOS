import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class SettingsStorage {
  static const String _keysKey = 'settings.toggles.keys';
  static const String _togglePrefix = 'settings.toggle.';
  static const String _legacySettingsKey = 'settings.toggles';

  Future<Map<String, bool>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getStringList(_keysKey);
      if (keys != null && keys.isNotEmpty) {
        final result = <String, bool>{};
        for (final key in keys) {
          final stored = prefs.getBool('$_togglePrefix$key');
          if (stored != null) {
            result[key] = stored;
          }
        }
        return result;
      }

      // Legacy format: list of "key=value" strings.
      final legacy = prefs.getStringList(_legacySettingsKey);
      if (legacy != null && legacy.isNotEmpty) {
        final result = <String, bool>{};
        for (final entry in legacy) {
          final parts = entry.split('=');
          if (parts.length != 2) {
            continue;
          }
          final key = parts.first;
          final value = parts.last.toLowerCase() == 'true';
          result[key] = value;
        }
        // Migrate forward.
        await save(result);
        await prefs.remove(_legacySettingsKey);
        return result;
      }

      return <String, bool>{};
    } catch (_) {
      return <String, bool>{};
    }
  }

  Future<void> save(Map<String, bool> values) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = values.keys.toList(growable: false);
      await prefs.setStringList(_keysKey, keys);
      for (final entry in values.entries) {
        await prefs.setBool('$_togglePrefix${entry.key}', entry.value);
      }
      await prefs.remove(_legacySettingsKey);
    } catch (_) {
      // Ignore storage failures; settings are non-critical.
    }
  }
}
