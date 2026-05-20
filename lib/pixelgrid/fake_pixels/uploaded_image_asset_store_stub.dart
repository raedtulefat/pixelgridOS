import 'dart:typed_data';

const String _uploadedImageAssetScheme = 'pixelgrid-upload';
const String _uploadedImageAssetHost = 'local';
const String _uploadedImageAssetPrefix = '$_uploadedImageAssetScheme://';

final Map<String, Uint8List> _bytesByAssetPath = <String, Uint8List>{};

bool isUploadedImageAssetPath(String assetPath) {
  return assetPath.startsWith(_uploadedImageAssetPrefix);
}

Future<String> saveUploadedImageAsset({
  required Uint8List bytes,
  required String sourceName,
}) async {
  final fileName = _uniqueUploadedFileName(sourceName);
  final assetPath = _assetPathForFileName(fileName);
  _bytesByAssetPath[assetPath] = Uint8List.fromList(bytes);
  return assetPath;
}

Future<Uint8List?> loadUploadedImageAssetBytes(String assetPath) async {
  final bytes = _bytesByAssetPath[assetPath];
  if (bytes == null) {
    return null;
  }
  return Uint8List.fromList(bytes);
}

Future<void> deleteUploadedImageAsset(String assetPath) async {
  _bytesByAssetPath.remove(assetPath);
}

String uploadedImageAssetLabel(String assetPath) {
  final fileName = _fileNameFromAssetPath(assetPath);
  if (fileName == null) {
    return 'Uploaded image';
  }
  final separatorIndex = fileName.indexOf('_');
  if (separatorIndex < 0 || separatorIndex == fileName.length - 1) {
    return fileName;
  }
  return fileName.substring(separatorIndex + 1);
}

String _assetPathForFileName(String fileName) {
  return Uri(
    scheme: _uploadedImageAssetScheme,
    host: _uploadedImageAssetHost,
    path: '/$fileName',
  ).toString();
}

String? _fileNameFromAssetPath(String assetPath) {
  final uri = Uri.tryParse(assetPath);
  if (uri == null || uri.scheme != _uploadedImageAssetScheme) {
    return null;
  }
  if (uri.pathSegments.isNotEmpty) {
    return uri.pathSegments.last;
  }
  if (uri.host.isNotEmpty && uri.host != _uploadedImageAssetHost) {
    return uri.host;
  }
  return null;
}

String _uniqueUploadedFileName(String sourceName) {
  final stamp = DateTime.now().millisecondsSinceEpoch;
  final baseName = _safeBaseName(sourceName);
  final extension = _safeExtension(sourceName);
  return '${stamp}_$baseName$extension';
}

String _safeBaseName(String sourceName) {
  var name = sourceName.split('/').last.split(r'\').last;
  final dotIndex = name.lastIndexOf('.');
  if (dotIndex > 0) {
    name = name.substring(0, dotIndex);
  }
  final normalized = name
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9_-]+'), '-')
      .replaceAll(RegExp(r'-+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
  if (normalized.isEmpty) {
    return 'image';
  }
  return normalized.length <= 48 ? normalized : normalized.substring(0, 48);
}

String _safeExtension(String sourceName) {
  final fileName = sourceName.split('/').last.split(r'\').last;
  final dotIndex = fileName.lastIndexOf('.');
  if (dotIndex < 0 || dotIndex == fileName.length - 1) {
    return '.png';
  }
  final extension = fileName.substring(dotIndex).toLowerCase();
  if (!RegExp(r'^\.[a-z0-9]{1,8}$').hasMatch(extension)) {
    return '.png';
  }
  return extension;
}
