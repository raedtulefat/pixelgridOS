import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

/// A single layer sampled by the fake-pixels renderer.
class FakePixelsLayer {
  const FakePixelsLayer({
    required this.assetPath,
    this.priority = 0,
    this.mirroredX = false,
  });

  /// Asset path as declared in Flutter assets (e.g. `assets/ui/logo.png`).
  final String assetPath;

  /// Draw order when overlapping. Higher priority draws later.
  final int priority;

  /// Mirrors source sampling horizontally.
  final bool mirroredX;
}

/// Renders a constant-size fake-pixel grid and fills cells by sampling PNG data.
class FakePixelsEngine {
  FakePixelsEngine({
    double cellSize = 16,
    this.alphaThreshold = 24,
    Color lineColor = const Color(0xFF000000),
    double lineStrokeWidth = 0.125,
    bool useShadedColors = true,
  })  : _cellSize = cellSize,
        _lineStrokeWidth = lineStrokeWidth,
        _useShadedColors = useShadedColors,
        _linePaint = Paint()
          ..color = lineColor
          ..style = PaintingStyle.stroke
          ..isAntiAlias = false,
        _fillPaint = Paint()
          ..style = PaintingStyle.fill
          ..isAntiAlias = false;

  double get cellSize => _cellSize;

  set cellSize(double value) {
    if (!value.isFinite || value <= 0) {
      return;
    }
    _cellSize = value;
  }

  bool get useShadedColors => _useShadedColors;

  set useShadedColors(bool value) {
    _useShadedColors = value;
  }

  double get lineStrokeWidth => _lineStrokeWidth;

  set lineStrokeWidth(double value) {
    if (!value.isFinite || value <= 0) {
      return;
    }
    _lineStrokeWidth = value;
  }

  double _cellSize;
  double _lineStrokeWidth;
  bool _useShadedColors;
  final int alphaThreshold;

  final Paint _linePaint;
  final Paint _fillPaint;

  final Map<String, _AlphaMask?> _alphaMasksByAsset = <String, _AlphaMask?>{};
  final Map<String, Future<void>> _pendingLoadsByAsset =
      <String, Future<void>>{};

  List<FakePixelsLayer> _layers = const <FakePixelsLayer>[];

  void setLayers(List<FakePixelsLayer> layers) {
    _layers = List<FakePixelsLayer>.unmodifiable(layers);
  }

  void render({
    required Canvas canvas,
    required Rect viewport,
  }) {
    if (viewport.width <= 0 || viewport.height <= 0 || cellSize <= 0) {
      return;
    }

    final startColumn = 0;
    final endColumn = (viewport.width / cellSize).ceil();
    final startRow = 0;
    final endRow = (viewport.height / cellSize).ceil();

    final renderSamples = <_RenderSample>[];
    var layerOrder = 0;
    for (final layer in _layers) {
      layerOrder += 1;
      _ensureMaskLoaded(layer.assetPath);
      final alphaMask = _alphaMasksByAsset[layer.assetPath];
      if (alphaMask == null) {
        continue;
      }

      final sampleRect = _containCenteredRect(
        viewport: viewport,
        sourceWidth: alphaMask.width.toDouble(),
        sourceHeight: alphaMask.height.toDouble(),
      );
      if (sampleRect.width <= 0 || sampleRect.height <= 0) {
        continue;
      }

      renderSamples.add(
        _RenderSample(
          layer: layer,
          alphaMask: alphaMask,
          sampleRect: sampleRect,
          layerOrder: layerOrder,
        ),
      );
    }

    renderSamples.sort((a, b) {
      final byPriority = a.layer.priority.compareTo(b.layer.priority);
      if (byPriority != 0) {
        return byPriority;
      }
      return a.layerOrder.compareTo(b.layerOrder);
    });

    for (final renderSample in renderSamples) {
      _renderLayerCells(
        canvas: canvas,
        viewport: viewport,
        startColumn: startColumn,
        endColumn: endColumn,
        startRow: startRow,
        endRow: endRow,
        renderSample: renderSample,
      );
    }

    _linePaint.strokeWidth = _resolvedLineStrokeWidth();

    for (var column = startColumn; column <= endColumn; column += 1) {
      final x = viewport.left + column * cellSize;
      canvas.drawLine(
          Offset(x, viewport.top), Offset(x, viewport.bottom), _linePaint);
    }

    for (var row = startRow; row <= endRow; row += 1) {
      final y = viewport.top + row * cellSize;
      canvas.drawLine(
          Offset(viewport.left, y), Offset(viewport.right, y), _linePaint);
    }
  }

  void _renderLayerCells({
    required Canvas canvas,
    required Rect viewport,
    required int startColumn,
    required int endColumn,
    required int startRow,
    required int endRow,
    required _RenderSample renderSample,
  }) {
    final sampleRect = renderSample.sampleRect;

    final sampleStartColumn =
        ((sampleRect.left - viewport.left) / cellSize).floor();
    final sampleEndColumn =
        ((sampleRect.right - viewport.left) / cellSize).ceil() - 1;
    final sampleStartRow = ((sampleRect.top - viewport.top) / cellSize).floor();
    final sampleEndRow =
        ((sampleRect.bottom - viewport.top) / cellSize).ceil() - 1;

    final fillStartColumn = math.max(startColumn, sampleStartColumn);
    final fillEndColumn = math.min(endColumn, sampleEndColumn);
    final fillStartRow = math.max(startRow, sampleStartRow);
    final fillEndRow = math.min(endRow, sampleEndRow);

    if (fillStartColumn > fillEndColumn || fillStartRow > fillEndRow) {
      return;
    }

    for (var row = fillStartRow; row <= fillEndRow; row += 1) {
      final cellTop = viewport.top + row * cellSize;
      final cellBottom = cellTop + cellSize;
      for (var column = fillStartColumn; column <= fillEndColumn; column += 1) {
        final cellLeft = viewport.left + column * cellSize;
        final cellRight = cellLeft + cellSize;
        final sampledColor = _sampleColorForCell(
          cellLeft: cellLeft,
          cellTop: cellTop,
          cellRight: cellRight,
          cellBottom: cellBottom,
          sampleRect: sampleRect,
          alphaMask: renderSample.alphaMask,
          mirroredX: renderSample.layer.mirroredX,
        );
        if (sampledColor == null) {
          continue;
        }

        _fillPaint.color = sampledColor;
        canvas.drawRect(
          Rect.fromLTWH(cellLeft, cellTop, cellSize, cellSize),
          _fillPaint,
        );
      }
    }
  }

  Color? _sampleColorForCell({
    required double cellLeft,
    required double cellTop,
    required double cellRight,
    required double cellBottom,
    required Rect sampleRect,
    required _AlphaMask alphaMask,
    required bool mirroredX,
  }) {
    final intersectionLeft = math.max(cellLeft, sampleRect.left);
    final intersectionTop = math.max(cellTop, sampleRect.top);
    final intersectionRight = math.min(cellRight, sampleRect.right);
    final intersectionBottom = math.min(cellBottom, sampleRect.bottom);

    if (intersectionRight <= intersectionLeft ||
        intersectionBottom <= intersectionTop) {
      return null;
    }

    var uMin = (intersectionLeft - sampleRect.left) / sampleRect.width;
    var uMax = (intersectionRight - sampleRect.left) / sampleRect.width;
    final vMin = (intersectionTop - sampleRect.top) / sampleRect.height;
    final vMax = (intersectionBottom - sampleRect.top) / sampleRect.height;

    if (mirroredX) {
      final originalUMin = uMin;
      uMin = 1 - uMax;
      uMax = 1 - originalUMin;
    }

    if (useShadedColors) {
      return alphaMask.averageOpaqueColorInNormalizedRect(
        uMin: uMin,
        uMax: uMax,
        vMin: vMin,
        vMax: vMax,
      );
    }

    return alphaMask.exactOpaqueColorInNormalizedRect(
      uMin: uMin,
      uMax: uMax,
      vMin: vMin,
      vMax: vMax,
    );
  }

  Rect _containCenteredRect({
    required Rect viewport,
    required double sourceWidth,
    required double sourceHeight,
  }) {
    if (sourceWidth <= 0 || sourceHeight <= 0) {
      return Rect.zero;
    }

    final viewportAspect = viewport.width / viewport.height;
    final sourceAspect = sourceWidth / sourceHeight;

    double targetWidth;
    double targetHeight;

    if (sourceAspect > viewportAspect) {
      targetWidth = viewport.width;
      targetHeight = targetWidth / sourceAspect;
    } else {
      targetHeight = viewport.height;
      targetWidth = targetHeight * sourceAspect;
    }

    final left = viewport.left + (viewport.width - targetWidth) / 2;
    final top = viewport.top + (viewport.height - targetHeight) / 2;

    return Rect.fromLTWH(left, top, targetWidth, targetHeight);
  }

  void _ensureMaskLoaded(String assetPath) {
    if (_alphaMasksByAsset.containsKey(assetPath)) {
      return;
    }
    if (_pendingLoadsByAsset.containsKey(assetPath)) {
      return;
    }

    _alphaMasksByAsset[assetPath] = null;
    _pendingLoadsByAsset[assetPath] = _loadAlphaMask(assetPath);
  }

  Future<void> _loadAlphaMask(String assetPath) async {
    try {
      final data = await _loadAssetBytes(assetPath);
      final image = await _decodeImage(data);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (byteData == null) {
        _alphaMasksByAsset[assetPath] = null;
        return;
      }
      final bytes = byteData.buffer.asUint8List();
      _alphaMasksByAsset[assetPath] = _AlphaMask.fromRgbaBytes(
        width: image.width,
        height: image.height,
        rgbaBytes: bytes,
        alphaThreshold: alphaThreshold,
      );
    } catch (_) {
      _alphaMasksByAsset[assetPath] = null;
    } finally {
      _pendingLoadsByAsset.remove(assetPath);
    }
  }

  Future<ByteData> _loadAssetBytes(String assetPath) async {
    try {
      return await rootBundle.load(assetPath);
    } catch (_) {
      if (assetPath.startsWith('assets/')) {
        rethrow;
      }
      return rootBundle.load('assets/$assetPath');
    }
  }

  Future<ui.Image> _decodeImage(ByteData data) async {
    final bytes = Uint8List.view(data.buffer);
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  double _resolvedLineStrokeWidth() {
    final views = ui.PlatformDispatcher.instance.views;
    final dpr = views.isEmpty ? 1.0 : views.first.devicePixelRatio;
    final minimumVisibleStroke = dpr <= 0 ? 1.0 : (1.0 / dpr);
    return math.max(lineStrokeWidth, minimumVisibleStroke);
  }
}

class _RenderSample {
  const _RenderSample({
    required this.layer,
    required this.alphaMask,
    required this.sampleRect,
    required this.layerOrder,
  });

  final FakePixelsLayer layer;
  final _AlphaMask alphaMask;
  final Rect sampleRect;
  final int layerOrder;
}

class _AlphaMask {
  const _AlphaMask({
    required this.width,
    required this.height,
    required this.rgbaBytes,
    required this.opaqueCountPrefixSums,
    required this.redPrefixSums,
    required this.greenPrefixSums,
    required this.bluePrefixSums,
  });

  factory _AlphaMask.fromRgbaBytes({
    required int width,
    required int height,
    required Uint8List rgbaBytes,
    required int alphaThreshold,
  }) {
    final prefixWidth = width + 1;
    final prefixHeight = height + 1;
    final prefixLength = prefixWidth * prefixHeight;

    final opaqueCountPrefixSums =
        List<int>.filled(prefixLength, 0, growable: false);
    final redPrefixSums = List<int>.filled(prefixLength, 0, growable: false);
    final greenPrefixSums = List<int>.filled(prefixLength, 0, growable: false);
    final bluePrefixSums = List<int>.filled(prefixLength, 0, growable: false);

    for (var y = 0; y < height; y += 1) {
      for (var x = 0; x < width; x += 1) {
        final pixelIndex = (y * width + x) * 4;
        final redChannel = rgbaBytes[pixelIndex];
        final greenChannel = rgbaBytes[pixelIndex + 1];
        final blueChannel = rgbaBytes[pixelIndex + 2];
        final alpha = rgbaBytes[pixelIndex + 3];
        final isOpaque = alpha >= alphaThreshold;
        final isBlack =
            redChannel == 0 && greenChannel == 0 && blueChannel == 0;
        final isActivePixel = isOpaque && !isBlack;

        final opaqueValue = isActivePixel ? 1 : 0;
        final red = isActivePixel ? redChannel : 0;
        final green = isActivePixel ? greenChannel : 0;
        final blue = isActivePixel ? blueChannel : 0;

        final targetIndex = (y + 1) * prefixWidth + (x + 1);
        final leftIndex = targetIndex - 1;
        final topIndex = targetIndex - prefixWidth;
        final topLeftIndex = topIndex - 1;

        opaqueCountPrefixSums[targetIndex] = opaqueValue +
            opaqueCountPrefixSums[leftIndex] +
            opaqueCountPrefixSums[topIndex] -
            opaqueCountPrefixSums[topLeftIndex];

        redPrefixSums[targetIndex] = red +
            redPrefixSums[leftIndex] +
            redPrefixSums[topIndex] -
            redPrefixSums[topLeftIndex];

        greenPrefixSums[targetIndex] = green +
            greenPrefixSums[leftIndex] +
            greenPrefixSums[topIndex] -
            greenPrefixSums[topLeftIndex];

        bluePrefixSums[targetIndex] = blue +
            bluePrefixSums[leftIndex] +
            bluePrefixSums[topIndex] -
            bluePrefixSums[topLeftIndex];
      }
    }

    return _AlphaMask(
      width: width,
      height: height,
      rgbaBytes: rgbaBytes,
      opaqueCountPrefixSums: opaqueCountPrefixSums,
      redPrefixSums: redPrefixSums,
      greenPrefixSums: greenPrefixSums,
      bluePrefixSums: bluePrefixSums,
    );
  }

  final int width;
  final int height;
  final Uint8List rgbaBytes;
  final List<int> opaqueCountPrefixSums;
  final List<int> redPrefixSums;
  final List<int> greenPrefixSums;
  final List<int> bluePrefixSums;

  Color? averageOpaqueColorInNormalizedRect({
    required double uMin,
    required double uMax,
    required double vMin,
    required double vMax,
  }) {
    if (width <= 0 || height <= 0) {
      return null;
    }

    final bounds = _normalizedRectBounds(
      uMin: uMin,
      uMax: uMax,
      vMin: vMin,
      vMax: vMax,
    );
    if (bounds == null) {
      return null;
    }
    final (left, right, top, bottom) = bounds;

    final opaqueCount = _sumInRect(
      opaqueCountPrefixSums,
      left: left,
      top: top,
      rightExclusive: right,
      bottomExclusive: bottom,
    );
    if (opaqueCount <= 0) {
      return null;
    }

    final redTotal = _sumInRect(
      redPrefixSums,
      left: left,
      top: top,
      rightExclusive: right,
      bottomExclusive: bottom,
    );
    final greenTotal = _sumInRect(
      greenPrefixSums,
      left: left,
      top: top,
      rightExclusive: right,
      bottomExclusive: bottom,
    );
    final blueTotal = _sumInRect(
      bluePrefixSums,
      left: left,
      top: top,
      rightExclusive: right,
      bottomExclusive: bottom,
    );

    final red = (redTotal / opaqueCount).round().clamp(0, 255);
    final green = (greenTotal / opaqueCount).round().clamp(0, 255);
    final blue = (blueTotal / opaqueCount).round().clamp(0, 255);

    return Color.fromARGB(255, red, green, blue);
  }

  Color? exactOpaqueColorInNormalizedRect({
    required double uMin,
    required double uMax,
    required double vMin,
    required double vMax,
    int strictAlphaThreshold = 250,
  }) {
    if (width <= 0 || height <= 0) {
      return null;
    }

    final bounds = _normalizedRectBounds(
      uMin: uMin,
      uMax: uMax,
      vMin: vMin,
      vMax: vMax,
    );
    if (bounds == null) {
      return null;
    }
    final (left, right, top, bottom) = bounds;

    for (var y = top; y < bottom; y += 1) {
      for (var x = left; x < right; x += 1) {
        final index = (y * width + x) * 4;
        final red = rgbaBytes[index];
        final green = rgbaBytes[index + 1];
        final blue = rgbaBytes[index + 2];
        final alpha = rgbaBytes[index + 3];

        final isBlack = red == 0 && green == 0 && blue == 0;
        if (isBlack || alpha < strictAlphaThreshold) {
          continue;
        }

        return Color.fromARGB(255, red, green, blue);
      }
    }

    return null;
  }

  (int, int, int, int)? _normalizedRectBounds({
    required double uMin,
    required double uMax,
    required double vMin,
    required double vMax,
  }) {
    final clampedUMin = uMin.clamp(0.0, 1.0);
    final clampedUMax = uMax.clamp(0.0, 1.0);
    final clampedVMin = vMin.clamp(0.0, 1.0);
    final clampedVMax = vMax.clamp(0.0, 1.0);

    if (clampedUMax <= clampedUMin || clampedVMax <= clampedVMin) {
      return null;
    }

    var left = (clampedUMin * width).floor();
    var right = (clampedUMax * width).ceil();
    var top = (clampedVMin * height).floor();
    var bottom = (clampedVMax * height).ceil();

    if (left < 0) left = 0;
    if (left > width - 1) left = width - 1;
    if (right < 1) right = 1;
    if (right > width) right = width;

    if (top < 0) top = 0;
    if (top > height - 1) top = height - 1;
    if (bottom < 1) bottom = 1;
    if (bottom > height) bottom = height;

    if (right <= left || bottom <= top) {
      return null;
    }

    return (left, right, top, bottom);
  }

  int _sumInRect(
    List<int> prefixSums, {
    required int left,
    required int top,
    required int rightExclusive,
    required int bottomExclusive,
  }) {
    final prefixWidth = width + 1;
    final a = prefixSums[bottomExclusive * prefixWidth + rightExclusive];
    final b = prefixSums[top * prefixWidth + rightExclusive];
    final c = prefixSums[bottomExclusive * prefixWidth + left];
    final d = prefixSums[top * prefixWidth + left];
    return a - b - c + d;
  }
}
