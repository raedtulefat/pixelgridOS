import 'package:flame/game.dart';
import 'package:flutter/foundation.dart' show ValueListenable, ValueNotifier;
import 'package:flutter/gestures.dart'
    show PointerScrollEvent, PointerSignalEvent;
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart'
    show PointerCancelEvent, PointerDownEvent, PointerMoveEvent, PointerUpEvent;
import 'package:pixelgrid/fake_pixels/fake_pixels_config.dart';
import 'package:pixelgrid/fake_pixels/fake_pixels_engine.dart';
import 'package:pixelgrid/os/debug/debug_ui_controller.dart';
import 'package:pixelgrid/os/os_mode.dart';

class ShellOsImpl extends FlameGame {
  static final Paint _backgroundPaint = Paint()
    ..color = const Color(0xFF000000);
  final FakePixelsEngine _fakePixels = FakePixelsEngine(
    cellSize: defaultFakePixelsConfig.cellSize,
    alphaThreshold: defaultFakePixelsConfig.alphaThreshold,
    lineColor: defaultFakePixelsConfig.lineColor,
    lineStrokeWidth: defaultFakePixelsConfig.lineStrokeWidth,
    useShadedColors: false,
  );
  final ValueNotifier<double> _fakePixelsCellSize =
      ValueNotifier<double>(defaultFakePixelsConfig.cellSize);
  final ValueNotifier<bool> _fakePixelsShadedColors =
      ValueNotifier<bool>(false);
  final ValueNotifier<double> _fakePixelsGridLineWidth =
      ValueNotifier<double>(defaultFakePixelsConfig.lineStrokeWidth);
  final ValueNotifier<String> _fakePixelsLogoAsset = ValueNotifier<String>(
    defaultFakePixelsConfig.layers.first.assetPath,
  );
  final ValueNotifier<bool> _viewportGesturesEnabled =
      ValueNotifier<bool>(true);
  final ValueNotifier<int> _viewportTransformTick = ValueNotifier<int>(0);

  final ValueNotifier<OsMode> _osMode = ValueNotifier<OsMode>(OsMode.home);
  final ValueNotifier<bool> _osMenuVisible = ValueNotifier<bool>(false);
  final ValueNotifier<DebugUiState> _debugUiState =
      ValueNotifier<DebugUiState>(const DebugUiState());

  final Map<int, Offset> _activePointers = <int, Offset>{};

  double _stageScale = 1;
  Offset _stageOffset = Offset.zero;
  double? _twoFingerDistance;
  Offset? _twoFingerFocalPoint;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    setFakePixelsLogoAsset(_fakePixelsLogoAsset.value);
    _syncStageTransform();
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

    _syncStageTransform();

    _fakePixels.render(
      canvas: canvas,
      viewport: screenRect,
    );

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

  ValueListenable<double> get fakePixelsGridLineWidthListenable =>
      _fakePixelsGridLineWidth;

  double get fakePixelsGridLineWidth => _fakePixelsGridLineWidth.value;

  ValueListenable<String> get fakePixelsLogoAssetListenable =>
      _fakePixelsLogoAsset;

  String get fakePixelsLogoAsset => _fakePixelsLogoAsset.value;

  ValueListenable<bool> get viewportGesturesEnabledListenable =>
      _viewportGesturesEnabled;

  bool get viewportGesturesEnabled => _viewportGesturesEnabled.value;

  ValueListenable<int> get viewportTransformTickListenable =>
      _viewportTransformTick;

  bool get isViewportAtDefault =>
      _stageScale == 1 && _stageOffset == Offset.zero;

  double get stageZoomLevel => _stageScale;

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

  void setFakePixelsGridLineWidth(double width) {
    if (!width.isFinite || width <= 0) {
      return;
    }
    _fakePixels.lineStrokeWidth = width;
    if (_fakePixelsGridLineWidth.value == width) {
      return;
    }
    _fakePixelsGridLineWidth.value = width;
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

  void setViewportGesturesEnabled(bool enabled) {
    if (_viewportGesturesEnabled.value == enabled) {
      return;
    }
    _viewportGesturesEnabled.value = enabled;
    if (!enabled) {
      resetViewportTransform();
    }
  }

  void resetViewportTransform() {
    _stageScale = 1;
    _stageOffset = Offset.zero;
    _twoFingerDistance = null;
    _twoFingerFocalPoint = null;
    _activePointers.clear();
    _syncStageTransform();
    _notifyViewportTransformChanged();
  }

  void zoomViewportInStep() {
    if (!_viewportGesturesEnabled.value) {
      return;
    }
    _zoomAtStageCenter(1.15);
  }

  void zoomViewportOutStep() {
    if (!_viewportGesturesEnabled.value) {
      return;
    }
    _zoomAtStageCenter(1 / 1.15);
  }

  void panViewportBy(Offset delta) {
    if (!_viewportGesturesEnabled.value || delta == Offset.zero) {
      return;
    }
    _stageOffset += delta;
    _syncStageTransform();
    _notifyViewportTransformChanged();
  }

  void toggleDebugOverlay({bool fromMenuOverlay = false}) {
    setOsMenuVisible(!_osMenuVisible.value);
  }

  Future<void> refreshShell() async {
    _osMode.value = OsMode.home;
  }

  void handlePointerSignal(PointerSignalEvent event) {
    if (!_viewportGesturesEnabled.value) {
      return;
    }
    if (event is! PointerScrollEvent) {
      return;
    }

    final zoomRatio = (1 - (event.scrollDelta.dy * 0.0015)).clamp(0.8, 1.25);
    _zoomAround(
      focalPoint: event.localPosition,
      nextScale: _clampedScale(_stageScale * zoomRatio),
    );
  }

  void handlePointerDown(PointerDownEvent event) {
    if (!_viewportGesturesEnabled.value) {
      return;
    }
    _activePointers[event.pointer] = event.localPosition;
    _syncTwoFingerGestureState();
  }

  void handlePointerMove(PointerMoveEvent event) {
    if (!_viewportGesturesEnabled.value) {
      return;
    }

    final previous = _activePointers[event.pointer];
    if (previous == null) {
      _activePointers[event.pointer] = event.localPosition;
      _syncTwoFingerGestureState();
      return;
    }

    _activePointers[event.pointer] = event.localPosition;

    if (_activePointers.length == 1) {
      final panDelta = event.localPosition - previous;
      if (panDelta != Offset.zero) {
        _stageOffset += panDelta;
        _syncStageTransform();
        _notifyViewportTransformChanged();
      }
      return;
    }

    if (_activePointers.length < 2) {
      return;
    }

    final values = _activePointers.values.take(2).toList(growable: false);
    final p1 = values[0];
    final p2 = values[1];
    final distance = (p2 - p1).distance;
    final focalPoint = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);

    final previousDistance = _twoFingerDistance;
    final previousFocal = _twoFingerFocalPoint;

    if (previousDistance != null && previousDistance > 0 && distance > 0) {
      final nextScale =
          _clampedScale(_stageScale * (distance / previousDistance));
      _zoomAround(
        focalPoint: focalPoint,
        nextScale: nextScale,
      );
    }

    if (previousFocal != null) {
      final panDelta = focalPoint - previousFocal;
      if (panDelta != Offset.zero) {
        _stageOffset += panDelta;
        _syncStageTransform();
        _notifyViewportTransformChanged();
      }
    }

    _twoFingerDistance = distance;
    _twoFingerFocalPoint = focalPoint;
  }

  void handlePointerUp(PointerUpEvent event) {
    _activePointers.remove(event.pointer);
    _syncTwoFingerGestureState();
  }

  void handlePointerCancel(PointerCancelEvent event) {
    _activePointers.remove(event.pointer);
    _syncTwoFingerGestureState();
  }

  void _syncTwoFingerGestureState() {
    if (_activePointers.length < 2) {
      _twoFingerDistance = null;
      _twoFingerFocalPoint = null;
      return;
    }

    final values = _activePointers.values.take(2).toList(growable: false);
    final p1 = values[0];
    final p2 = values[1];
    _twoFingerDistance = (p2 - p1).distance;
    _twoFingerFocalPoint = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
  }

  void _zoomAround({
    required Offset focalPoint,
    required double nextScale,
  }) {
    final previousScale = _stageScale;
    if (nextScale == previousScale) {
      return;
    }
    final viewportCenter = _viewportCenter;
    final stageFocal =
        (focalPoint - viewportCenter - _stageOffset) / previousScale;
    _stageScale = nextScale;
    _stageOffset = focalPoint - viewportCenter - (stageFocal * _stageScale);
    _syncStageTransform();
    _notifyViewportTransformChanged();
  }

  void _zoomAtStageCenter(double ratio) {
    if (size.x <= 0 || size.y <= 0) {
      return;
    }
    final focalPoint = _viewportCenter + _stageOffset;
    _zoomAround(
      focalPoint: focalPoint,
      nextScale: _clampedScale(_stageScale * ratio),
    );
  }

  Offset get _viewportCenter => Offset(size.x / 2, size.y / 2);

  void _syncStageTransform() {
    _fakePixels.setStageTransform(
      scale: _stageScale,
      offset: _stageOffset,
    );
  }

  void _notifyViewportTransformChanged() {
    _viewportTransformTick.value = _viewportTransformTick.value + 1;
  }

  double _clampedScale(double value) {
    if (!value.isFinite || value <= 0) {
      return _stageScale;
    }
    return value;
  }

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
      case DebugUiLayer.actorTouchBounds:
        return state.copyWith(actorTouchBounds: enabled);
    }
  }
}
