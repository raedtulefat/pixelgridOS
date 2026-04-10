import 'package:flame/game.dart';
import 'package:flutter/foundation.dart' show ValueListenable, ValueNotifier;
import 'package:flutter/gestures.dart' show PointerSignalEvent;
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart'
    show PointerCancelEvent, PointerDownEvent, PointerMoveEvent, PointerUpEvent;
import 'package:game_shell/fake_pixels/fake_pixels_config.dart';
import 'package:game_shell/fake_pixels/fake_pixels_engine.dart';
import 'package:game_shell/os/debug/debug_ui_controller.dart';
import 'package:game_shell/os/os_mode.dart';

class ShellOsImpl extends FlameGame {
  static final Paint _backgroundPaint = Paint()
    ..color = const Color(0xFF000000);
  static final Paint _surfaceOutlinePaint = Paint()
    ..color = const Color(0xFF4A4A4A)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

  final FakePixelsEngine _fakePixels = FakePixelsEngine(
    cellSize: defaultFakePixelsConfig.cellSize,
    alphaThreshold: defaultFakePixelsConfig.alphaThreshold,
    lineColor: defaultFakePixelsConfig.lineColor,
    lineStrokeWidth: defaultFakePixelsConfig.lineStrokeWidth,
    useShadedColors: true,
  );
  final ValueNotifier<double> _fakePixelsCellSize =
      ValueNotifier<double>(defaultFakePixelsConfig.cellSize);
  final ValueNotifier<bool> _fakePixelsShadedColors = ValueNotifier<bool>(true);
  final ValueNotifier<String> _fakePixelsLogoAsset = ValueNotifier<String>(
    defaultFakePixelsConfig.layers.first.assetPath,
  );

  final ValueNotifier<OsMode> _osMode = ValueNotifier<OsMode>(OsMode.home);
  final ValueNotifier<bool> _osMenuVisible = ValueNotifier<bool>(false);
  final ValueNotifier<DebugUiState> _debugUiState = ValueNotifier<DebugUiState>(
    const DebugUiState(
      surfaceOutline: true,
    ),
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    setFakePixelsLogoAsset(_fakePixelsLogoAsset.value);
  }

  @override
  void render(Canvas canvas) {
    final canvasSize = size;
    if (canvasSize.x <= 0 || canvasSize.y <= 0) {
      super.render(canvas);
      return;
    }

    final screenRect = Rect.fromLTWH(0, 0, canvasSize.x, canvasSize.y);
    canvas.drawRect(screenRect, _backgroundPaint);

    _fakePixels.render(
      canvas: canvas,
      viewport: screenRect,
    );

    if (_debugUiState.value.surfaceOutline) {
      canvas.drawRect(screenRect.deflate(1), _surfaceOutlinePaint);
    }

    super.render(canvas);
  }

  ValueListenable<OsMode> get osModeListenable => _osMode;

  OsMode get osMode => _osMode.value;

  ValueListenable<bool> get osMenuVisibilityListenable => _osMenuVisible;

  bool get isOsMenuVisible => _osMenuVisible.value;

  ValueListenable<DebugUiState> get debugUiListenable => _debugUiState;

  ValueListenable<double> get fakePixelsCellSizeListenable =>
      _fakePixelsCellSize;

  double get fakePixelsCellSize => _fakePixelsCellSize.value;

  ValueListenable<bool> get fakePixelsShadedColorsListenable =>
      _fakePixelsShadedColors;

  bool get fakePixelsShadedColorsEnabled => _fakePixelsShadedColors.value;

  ValueListenable<String> get fakePixelsLogoAssetListenable =>
      _fakePixelsLogoAsset;

  String get fakePixelsLogoAsset => _fakePixelsLogoAsset.value;

  void setOsMenuVisible(bool visible) {
    if (_osMenuVisible.value == visible) {
      return;
    }
    _osMenuVisible.value = visible;
  }

  void setDebugUiFlag(DebugUiLayer layer, bool enabled) {
    _debugUiState.value =
        _updatedDebugState(_debugUiState.value, layer, enabled);
  }

  void setFakePixelsCellSize(double cellSize) {
    if (!cellSize.isFinite || cellSize <= 0) {
      return;
    }
    _fakePixels.cellSize = cellSize;
    if (_fakePixelsCellSize.value == cellSize) {
      return;
    }
    _fakePixelsCellSize.value = cellSize;
  }

  void setFakePixelsShadedColorsEnabled(bool enabled) {
    _fakePixels.useShadedColors = enabled;
    if (_fakePixelsShadedColors.value == enabled) {
      return;
    }
    _fakePixelsShadedColors.value = enabled;
  }

  void setFakePixelsLogoAsset(String assetPath) {
    if (assetPath.isEmpty) {
      return;
    }
    _fakePixels.setLayers(
      <FakePixelsLayer>[
        FakePixelsLayer(assetPath: assetPath),
      ],
    );
    if (_fakePixelsLogoAsset.value == assetPath) {
      return;
    }
    _fakePixelsLogoAsset.value = assetPath;
  }

  void toggleDebugOverlay({bool fromMenuOverlay = false}) {
    setOsMenuVisible(!_osMenuVisible.value);
  }

  Future<void> refreshShell() async {
    _osMode.value = OsMode.home;
  }

  void handlePointerSignal(PointerSignalEvent event) {}

  void handlePointerDown(PointerDownEvent event) {}

  void handlePointerMove(PointerMoveEvent event) {}

  void handlePointerUp(PointerUpEvent event) {}

  void handlePointerCancel(PointerCancelEvent event) {}

  DebugUiState _updatedDebugState(
    DebugUiState state,
    DebugUiLayer layer,
    bool enabled,
  ) {
    switch (layer) {
      case DebugUiLayer.grid:
        return state.copyWith(grid: enabled);
      case DebugUiLayer.floorHighlights:
        return state.copyWith(floorHighlights: enabled);
      case DebugUiLayer.wallHighlights:
        return state.copyWith(wallHighlights: enabled);
      case DebugUiLayer.walkables:
        return state.copyWith(walkables: enabled);
      case DebugUiLayer.tileInfo:
        return state.copyWith(tileInfo: enabled);
      case DebugUiLayer.infoText:
        return state.copyWith(infoText: enabled);
      case DebugUiLayer.healthBars:
        return state.copyWith(healthBars: enabled);
      case DebugUiLayer.playerTileHighlight:
        return state.copyWith(playerTileHighlight: enabled);
      case DebugUiLayer.pathFinder:
        return state.copyWith(pathFinder: enabled);
      case DebugUiLayer.shellLogs:
        return state.copyWith(shellLogs: enabled);
      case DebugUiLayer.surfaceOutline:
        return state.copyWith(surfaceOutline: enabled);
      case DebugUiLayer.actorTouchBounds:
        return state.copyWith(actorTouchBounds: enabled);
    }
  }
}
