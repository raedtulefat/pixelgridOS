import 'package:flutter/services.dart';

class LogoAssetCatalog {
  static final RegExp _endsWithSingleDigitOnePattern = RegExp(r'1$');
  static const Set<String> _excludedFileNames = <String>{
    'app_icon.jpg',
    'app_icon.png',
    'logo2.png',
  };

  static Future<List<String>> loadOptions() {
    return loadOptionsForFolder('assets/ui/logo');
  }

  static Future<List<String>> loadOptionsForFolder(String folderPath) async {
    final escapedFolder = RegExp.escape(folderPath);
    final folderPattern = RegExp(
      '^$escapedFolder' r'/.+\.(png|jpg|jpeg|webp)$',
      caseSensitive: false,
    );

    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final options = manifest
          .listAssets()
          .where((assetPath) => folderPattern.hasMatch(assetPath))
          .where((assetPath) {
        final fileName = assetPath.split('/').last.toLowerCase();
        return !_excludedFileNames.contains(fileName);
      }).toList(growable: false)
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
