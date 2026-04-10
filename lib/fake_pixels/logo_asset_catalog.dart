import 'package:flutter/services.dart';

class LogoAssetCatalog {
  static final RegExp _logoFolderPattern = RegExp(
    r'^assets/ui/logo/.+\.(png|jpg|jpeg|webp)$',
    caseSensitive: false,
  );

  static final RegExp _endsWithSingleDigitOnePattern = RegExp(r'1$');

  static Future<List<String>> loadOptions() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final options = manifest
          .listAssets()
          .where((assetPath) => _logoFolderPattern.hasMatch(assetPath))
          .toList(growable: false)
        ..sort();
      return options;
    } catch (_) {
      return const <String>[];
    }
  }

  static String? fallbackFrom(List<String> options) {
    for (final option in options) {
      final fileName = option.split('/').last;
      final baseName = fileName.contains('.')
          ? fileName.substring(0, fileName.lastIndexOf('.'))
          : fileName;
      if (_endsWithSingleDigitOnePattern.hasMatch(baseName)) {
        return option;
      }
    }
    if (options.isEmpty) {
      return null;
    }
    return options.first;
  }
}
