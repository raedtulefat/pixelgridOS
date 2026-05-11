import 'package:flutter/painting.dart';

import 'fake_pixels_engine.dart';

abstract final class FakePixelsLayerGroup {
  static const String stageBase = 'stage.base';
  static const String stageUi = 'stage.ui';
}

abstract final class FakePixelsLayerId {
  static const String stageBase = 'stage-base';
  static const String stageUi = 'stage-ui';
}

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
  cellSize: 4,
  alphaThreshold: 24,
  lineColor: Color(0xFF000000),
  lineStrokeWidth: 0.25,
  layers: <FakePixelsLayer>[
    FakePixelsLayer(
      id: FakePixelsLayerId.stageBase,
      group: FakePixelsLayerGroup.stageBase,
      assetPath: 'assets/ui/logo/logo1.png',
      priority: 10,
      visible: true,
    ),
    FakePixelsLayer(
      id: FakePixelsLayerId.stageUi,
      group: FakePixelsLayerGroup.stageUi,
      assetPath: 'assets/ui/logo/logo1.png',
      priority: 210,
      visible: false,
    ),
  ],
);
