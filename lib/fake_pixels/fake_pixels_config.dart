import 'package:flutter/painting.dart';

import 'fake_pixels_engine.dart';

class FakePixelsConfig {
  const FakePixelsConfig({
    required this.cellSize,
    required this.alphaThreshold,
    required this.lineColor,
    required this.lineStrokeWidth,
    required this.layers,
  });

  final double cellSize;
  final int alphaThreshold;
  final Color lineColor;
  final double lineStrokeWidth;
  final List<FakePixelsLayer> layers;
}

const FakePixelsConfig defaultFakePixelsConfig = FakePixelsConfig(
  cellSize: 16,
  alphaThreshold: 24,
  lineColor: Color(0xFF000000),
  lineStrokeWidth: 0.125,
  layers: <FakePixelsLayer>[
    FakePixelsLayer(assetPath: 'assets/ui/logo/logo1.png'),
  ],
);
