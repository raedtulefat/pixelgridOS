import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

const String _uploadedImageAssetScheme = 'pixelgrid-upload';
const String _uploadedImageAssetHost = 'local';
const String _uploadedImageAssetPrefix = '$_uploadedImageAssetScheme://';

bool isUploadedImageAssetPath(String assetPath) {
  return assetPath.startsWith(_uploadedImageAssetPrefix);
}

Future<String> saveUploadedImageAsset({
  required Uint8List bytes,
  required String sourceName,
}) async {
  final fileName = _uniqueUploadedFileName(sourceName);
  final directory = await _uploadsDirectory();
  await directory.create(recursive: true);
  final file = File(_joinPath(directory.path, fileName));
  await file.writeAsBytes(bytes, flush: true);
  return _assetPathForFileName(fileName);
}

Future<Uint8List?> loadUploadedImageAssetBytes(String assetPath) async {
  final fileName = _fileNameFromAssetPath(assetPath);
  if (fileName == null) {
    return null;
  }
  final directory = await _uploadsDirectory();
  final file = File(_joinPath(directory.path, fileName));
  if (!await file.exists()) {
    return null;
  }
  return file.readAsBytes();
}

Future<void> deleteUploadedImageAsset(String assetPath) async {
  final fileName = _fileNameFromAssetPath(assetPath);
  if (fileName == null) {
    return;
  }
  final directory = await _uploadsDirectory();
  final file = File(_joinPath(directory.path, fileName));
  if (await file.exists()) {
    await file.delete();
  }
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

Future<Directory> _uploadsDirectory() async {
  final supportDirectory = await getApplicationSupportDirectory();
  return Directory(_joinPath(supportDirectory.path, 'pixelgrid_uploads'));
}

String _joinPath(String directory, String child) {
  if (directory.endsWith(Platform.pathSeparator)) {
    return '$directory$child';
  }
  return '$directory${Platform.pathSeparator}$child';
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
