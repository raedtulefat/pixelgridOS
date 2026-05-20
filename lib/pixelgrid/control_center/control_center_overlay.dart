import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show HardwareKeyboard, KeyDownEvent, KeyEvent, LogicalKeyboardKey;
import 'package:image_picker/image_picker.dart';
import 'package:pixelgrid/pixelgrid.dart';
import 'package:pixelgrid/pixelgrid/fake_pixels/logo_asset_catalog.dart';
import 'package:pixelgrid/pixelgrid/fake_pixels/uploaded_image_asset_store.dart';
import 'package:pixelgrid/pixelgrid/control_center/control_center_style.dart';
import 'package:pixelgrid/pixelgrid/control_center/control_center_settings.dart';
import 'package:pixelgrid/pixelgrid/settings/settings_applier.dart';
import 'package:pixelgrid/pixelgrid/settings/settings_controller.dart';
import 'package:pixelgrid/pixelgrid/settings/settings_keys.dart';
import 'package:pixelgrid/pixelgrid/settings/settings_storage.dart';
import 'package:pixelgrid/pixelgrid/ui/menu_column.dart';
import 'package:pixelgrid/pixelgrid/ui/modal.dart';
import 'package:pixelgrid/pixelgrid/ui/pixel/pixel_border_button.dart';

const String _kTestHubFocusText =
    'Focus: Canvas home shows full-screen tiles, control center, and fake app screens.';
const String _kQaPromptFallbackText =
    'Focus: Open the hamburger menu, launch each fake app screen, and verify tile grid remains visible behind overlays.';

class ControlCenterOverlay extends StatefulWidget {
  const ControlCenterOverlay({
    super.key,
    required this.pixelGrid,
  });

  static const String testHubFocusText = _kTestHubFocusText;
  static const String qaPromptFallbackText = _kQaPromptFallbackText;

  final PixelGrid pixelGrid;

  @override
  State<ControlCenterOverlay> createState() => _ControlCenterOverlayState();
}

class _ControlCenterOverlayState extends State<ControlCenterOverlay> {
  bool _showPrompt = false;
  bool _showControlCenter = false;
  bool _showSettingsModal = false;
  int _settingsTabIndex = 0;
  List<String> _uploadedAssetOptions = const <String>[];
  List<String> _baseAssetOptions = const <String>[];
  List<String> _uiAssetOptions = const <String>[];
  String? _selectedBaseAsset;
  String? _selectedUiAsset;
  bool _showViewportZoomControls = false;

  final SettingsController _settings = SettingsController(SettingsStorage());
  final SettingsApplier _settingsApplier = SettingsApplier();
  final ImagePicker _imagePicker = ImagePicker();
  late final VoidCallback _debugMenuListener;

  @override
  void initState() {
    super.initState();
    _debugMenuListener = _handleControlCenterVisibility;
    widget.pixelGrid.controlCenterVisibilityListenable
        .addListener(_debugMenuListener);
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
    _loadSettings();
  }

  @override
  void didUpdateWidget(covariant ControlCenterOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pixelGrid == widget.pixelGrid) {
      return;
    }

    oldWidget.pixelGrid.controlCenterVisibilityListenable
        .removeListener(_debugMenuListener);
    widget.pixelGrid.controlCenterVisibilityListenable
        .addListener(_debugMenuListener);
    _applySettingsToPlatform();
  }

  @override
  void dispose() {
    widget.pixelGrid.controlCenterVisibilityListenable
        .removeListener(_debugMenuListener);
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    super.dispose();
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (!mounted || event is! KeyDownEvent) {
      return false;
    }

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      if (_showSettingsModal) {
        _closeSettingsModal();
        return true;
      }

      widget.pixelGrid.toggleControlCenter(fromControlCenter: true);
      return true;
    }

    final panStep = widget.pixelGrid.fakePixelsCellSize * 25;
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      widget.pixelGrid.panViewportBy(Offset(-panStep, 0));
      return true;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      widget.pixelGrid.panViewportBy(Offset(panStep, 0));
      return true;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      widget.pixelGrid.panViewportBy(Offset(0, -panStep));
      return true;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      widget.pixelGrid.panViewportBy(Offset(0, panStep));
      return true;
    }

    return false;
  }

  Future<void> _loadSettings() async {
    await _settings.load();
    final bundledBaseOptions = await LogoAssetCatalog.loadOptionsForFolder(
      'assets/ui/logo',
    );
    final bundledUiOptions = await LogoAssetCatalog.loadOptionsForFolder(
      'assets/ui/logo',
    );
    final savedBaseAsset = _settings.getStringByKey(
      SettingKey.fakePixelsBaseAsset,
      defaultValue: _settings.getStringByKey(
        SettingKey.fakePixelsLogoAsset,
        defaultValue: '',
      ),
    );
    final savedUiAsset = _settings.getStringByKey(
      SettingKey.fakePixelsUiAsset,
      defaultValue: '',
    );
    final uploadedOptions = _uploadedAssetsFromSettings(
      include: <String>[savedBaseAsset, savedUiAsset],
    );
    final baseOptions = _combineAssetOptions(
      bundledOptions: bundledBaseOptions,
      uploadedOptions: uploadedOptions,
    );
    final uiOptions = _combineAssetOptions(
      bundledOptions: bundledUiOptions,
      uploadedOptions: uploadedOptions,
    );
    unawaited(_persistUploadedAssets(uploadedOptions));
    if (!mounted) {
      return;
    }
    setState(() {
      _uploadedAssetOptions = uploadedOptions;
      _baseAssetOptions = baseOptions;
      _uiAssetOptions = uiOptions;
    });
    _applySettingsToPlatform();
  }

  Future<void> _updateSetting(SettingToggle setting, bool next,
      {required bool persist}) async {
    if (persist) {
      await _settings.set(setting, next);
    }
    _applySettingsToPlatform();
  }

  void _applySettingsToPlatform() {
    final settings = _settings.snapshot();
    final storedTabIndex = _settings.getIntByKey(
      SettingKey.settingsLastOpenTab,
      defaultValue: 0,
    );
    final resolvedTabIndex =
        storedTabIndex.clamp(0, ControlCenterSettings.tabCount - 1).toInt();
    if (_settingsTabIndex != resolvedTabIndex) {
      setState(() {
        _settingsTabIndex = resolvedTabIndex;
      });
    }

    final pixResolution = _settings.getDoubleByKey(
      SettingKey.fakePixelsResolution,
      defaultValue: 4,
    );
    final pixShades = _settings.getBoolByKey(
      SettingKey.fakePixelsUseShades,
      defaultValue: false,
    );
    final pixGridLineWidth = _settings.getDoubleByKey(
      SettingKey.fakePixelsGridLineWidth,
      defaultValue: 0.25,
    );
    final pixGesturesEnabled = _settings.getBoolByKey(
      SettingKey.fakePixelsGestureControlsEnabled,
      defaultValue: true,
    );

    final fallbackBaseAsset = LogoAssetCatalog.fallbackFrom(_baseAssetOptions);
    final fallbackUiAsset = LogoAssetCatalog.fallbackFrom(_uiAssetOptions);

    final savedBaseAsset = _settings.getStringByKey(
      SettingKey.fakePixelsBaseAsset,
      defaultValue: _settings.getStringByKey(
        SettingKey.fakePixelsLogoAsset,
        defaultValue: fallbackBaseAsset ?? '',
      ),
    );
    final savedUiAsset = _settings.getStringByKey(
      SettingKey.fakePixelsUiAsset,
      defaultValue: fallbackUiAsset ?? '',
    );
    final savedUiVisible = _settings.getBoolByKey(
      SettingKey.fakePixelsUiVisible,
      defaultValue: false,
    );

    final resolvedBaseAsset = _resolveAsset(
      options: _baseAssetOptions,
      requested: savedBaseAsset,
      fallback: fallbackBaseAsset,
    );
    final resolvedUiAsset = _resolveAsset(
      options: _uiAssetOptions,
      requested: savedUiAsset,
      fallback: fallbackUiAsset,
    );

    widget.pixelGrid
      ..setFakePixelsCellSize(pixResolution)
      ..setFakePixelsShadedColorsEnabled(pixShades)
      ..setFakePixelsGridLineWidth(pixGridLineWidth)
      ..setViewportGesturesEnabled(pixGesturesEnabled);

    if (!pixGesturesEnabled && _showViewportZoomControls && mounted) {
      setState(() {
        _showViewportZoomControls = false;
      });
    }

    if (resolvedBaseAsset != null) {
      widget.pixelGrid.setFakePixelsBaseAsset(resolvedBaseAsset);
      if (_selectedBaseAsset != resolvedBaseAsset && mounted) {
        setState(() {
          _selectedBaseAsset = resolvedBaseAsset;
        });
      }
      if (savedBaseAsset != resolvedBaseAsset) {
        _settings.setStringByKey(
          SettingKey.fakePixelsBaseAsset,
          resolvedBaseAsset,
        );
      }
    }

    if (resolvedUiAsset != null) {
      widget.pixelGrid.setFakePixelsUiAsset(resolvedUiAsset);
      if (_selectedUiAsset != resolvedUiAsset && mounted) {
        setState(() {
          _selectedUiAsset = resolvedUiAsset;
        });
      }
      if (savedUiAsset != resolvedUiAsset) {
        _settings.setStringByKey(
          SettingKey.fakePixelsUiAsset,
          resolvedUiAsset,
        );
      }
    }

    widget.pixelGrid.setFakePixelsUiVisible(savedUiVisible);

    _settingsApplier.applyAll(
      settings: settings,
      setPromptBannerVisible: _setPromptBannerVisible,
    );
  }

  void _setPromptBannerVisible(bool showPrompt) {
    if (_showPrompt == showPrompt) {
      return;
    }
    setState(() {
      _showPrompt = showPrompt;
    });
  }

  void _handleControlCenterVisibility() {
    final isVisible = widget.pixelGrid.isControlCenterVisible;
    if (_showControlCenter == isVisible) {
      return;
    }
    setState(() {
      _showControlCenter = isVisible;
      if (isVisible) {
        _showSettingsModal = false;
      }
    });
  }

  void _toggleControlCenter() {
    widget.pixelGrid.setControlCenterVisible(!_showControlCenter);
  }

  void _openSettingsModal() {
    setState(() {
      _showSettingsModal = true;
      _showControlCenter = false;
    });
    widget.pixelGrid.setControlCenterVisible(false);
  }

  void _closeSettingsModal() {
    setState(() {
      _showSettingsModal = false;
    });
  }

  String _formatNumericLabel(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }

  void _adjustPixelSize(double delta) {
    final current = widget.pixelGrid.fakePixelsCellSize;
    final next = current + delta;
    if (!next.isFinite || next <= 0) {
      return;
    }
    widget.pixelGrid.setFakePixelsCellSize(next);
    unawaited(
      _settings.setDoubleByKey(
        SettingKey.fakePixelsResolution,
        next,
      ),
    );
  }

  String? _resolveAsset({
    required List<String> options,
    required String requested,
    required String? fallback,
  }) {
    if (options.isEmpty) {
      return null;
    }
    if (requested.isNotEmpty && options.contains(requested)) {
      return requested;
    }
    if (fallback != null && options.contains(fallback)) {
      return fallback;
    }
    return options.first;
  }

  List<String> _uploadedAssetsFromSettings({
    Iterable<String> include = const <String>[],
  }) {
    return _uniqueUploadedAssets(
      <String>[
        ..._settings.getStringListByKey(
          SettingKey.fakePixelsUploadedAssets,
          defaultValue: const <String>[],
        ),
        ...include,
      ],
    );
  }

  List<String> _uniqueUploadedAssets(Iterable<String> assetPaths) {
    final result = <String>[];
    for (final assetPath in assetPaths) {
      if (!isUploadedImageAssetPath(assetPath)) {
        continue;
      }
      if (result.contains(assetPath)) {
        continue;
      }
      result.add(assetPath);
    }
    return List<String>.unmodifiable(result);
  }

  List<String> _combineAssetOptions({
    required List<String> bundledOptions,
    required List<String> uploadedOptions,
  }) {
    return List<String>.unmodifiable(<String>[
      ...uploadedOptions,
      for (final option in bundledOptions)
        if (!uploadedOptions.contains(option)) option,
    ]);
  }

  List<String> _replaceUploadedAssetOptions(
    List<String> options,
    List<String> uploadedOptions,
  ) {
    final bundledOptions = options
        .where((option) => !isUploadedImageAssetPath(option))
        .toList(growable: false);
    return _combineAssetOptions(
      bundledOptions: bundledOptions,
      uploadedOptions: uploadedOptions,
    );
  }

  Future<void> _persistUploadedAssets(List<String> assetPaths) {
    return _settings.setStringListByKey(
      SettingKey.fakePixelsUploadedAssets,
      _uniqueUploadedAssets(assetPaths),
    );
  }

  Future<String?> _pickUploadedAsset() async {
    try {
      final pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedImage == null) {
        return null;
      }
      final bytes = await pickedImage.readAsBytes();
      if (bytes.isEmpty) {
        return null;
      }
      return saveUploadedImageAsset(
        bytes: bytes,
        sourceName: pickedImage.name,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _uploadBaseAsset() async {
    final assetPath = await _pickUploadedAsset();
    if (assetPath == null) {
      return;
    }
    final uploadedOptions = _uniqueUploadedAssets(
      <String>[assetPath, ..._uploadedAssetOptions],
    );
    widget.pixelGrid.setFakePixelsBaseAsset(assetPath);
    await _persistUploadedAssets(uploadedOptions);
    await _settings.setStringByKey(
      SettingKey.fakePixelsBaseAsset,
      assetPath,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _uploadedAssetOptions = uploadedOptions;
      _baseAssetOptions = _replaceUploadedAssetOptions(
        _baseAssetOptions,
        uploadedOptions,
      );
      _uiAssetOptions = _replaceUploadedAssetOptions(
        _uiAssetOptions,
        uploadedOptions,
      );
      _selectedBaseAsset = assetPath;
    });
  }

  Future<void> _uploadUiAsset() async {
    final assetPath = await _pickUploadedAsset();
    if (assetPath == null) {
      return;
    }
    final uploadedOptions = _uniqueUploadedAssets(
      <String>[assetPath, ..._uploadedAssetOptions],
    );
    widget.pixelGrid.setFakePixelsUiAsset(assetPath);
    await _persistUploadedAssets(uploadedOptions);
    await _settings.setStringByKey(
      SettingKey.fakePixelsUiAsset,
      assetPath,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _uploadedAssetOptions = uploadedOptions;
      _baseAssetOptions = _replaceUploadedAssetOptions(
        _baseAssetOptions,
        uploadedOptions,
      );
      _uiAssetOptions = _replaceUploadedAssetOptions(
        _uiAssetOptions,
        uploadedOptions,
      );
      _selectedUiAsset = assetPath;
    });
  }

  Future<void> _deleteUploadedAsset(String assetPath) async {
    if (!isUploadedImageAssetPath(assetPath)) {
      return;
    }

    final uploadedOptions = _uploadedAssetOptions
        .where((option) => option != assetPath)
        .toList(growable: false);
    final baseOptions = _replaceUploadedAssetOptions(
      _baseAssetOptions,
      uploadedOptions,
    );
    final uiOptions = _replaceUploadedAssetOptions(
      _uiAssetOptions,
      uploadedOptions,
    );
    final nextBaseAsset = _selectedBaseAsset == assetPath
        ? LogoAssetCatalog.fallbackFrom(baseOptions)
        : null;
    final nextUiAsset = _selectedUiAsset == assetPath
        ? LogoAssetCatalog.fallbackFrom(uiOptions)
        : null;

    await deleteUploadedImageAsset(assetPath);
    await _persistUploadedAssets(uploadedOptions);

    if (nextBaseAsset != null) {
      widget.pixelGrid.setFakePixelsBaseAsset(nextBaseAsset);
      await _settings.setStringByKey(
        SettingKey.fakePixelsBaseAsset,
        nextBaseAsset,
      );
    }
    if (nextUiAsset != null) {
      widget.pixelGrid.setFakePixelsUiAsset(nextUiAsset);
      await _settings.setStringByKey(
        SettingKey.fakePixelsUiAsset,
        nextUiAsset,
      );
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _uploadedAssetOptions = uploadedOptions;
      _baseAssetOptions = baseOptions;
      _uiAssetOptions = uiOptions;
      if (_selectedBaseAsset == assetPath) {
        _selectedBaseAsset = nextBaseAsset;
      }
      if (_selectedUiAsset == assetPath) {
        _selectedUiAsset = nextUiAsset;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          right: 16,
          top: 16,
          child: SafeArea(
            minimum: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _SettingsButton(
                  isOpen: _showControlCenter,
                  onPressed: _toggleControlCenter,
                ),
                if (_showPrompt) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 320,
                    child: _DebugPromptBannerBody(text: _kQaPromptFallbackText),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (_showControlCenter)
          Positioned.fill(
            child: Modal(
              title: 'Control Center',
              onClose: _toggleControlCenter,
              child: MenuColumn(
                spacing: 12,
                children: [
                  PixelBorderButton(
                    label: 'Settings',
                    fillColor: menuFillDark,
                    textColor: menuTextLight,
                    onPressed: _openSettingsModal,
                  ),
                ],
              ),
            ),
          ),
        if (_showSettingsModal)
          Positioned.fill(
            child: Modal(
              title: 'Settings',
              onClose: _closeSettingsModal,
              child: ControlCenterSettings(
                pixelGrid: widget.pixelGrid,
                showPrompt: _showPrompt,
                baseAssetOptions: _baseAssetOptions,
                uiAssetOptions: _uiAssetOptions,
                selectedBaseAsset: _selectedBaseAsset,
                selectedUiAsset: _selectedUiAsset,
                uiLayerVisible: widget.pixelGrid.fakePixelsUiVisible,
                initialTabIndex: _settingsTabIndex,
                onTabChanged: (index) async {
                  final resolved = index
                      .clamp(0, ControlCenterSettings.tabCount - 1)
                      .toInt();
                  if (_settingsTabIndex != resolved && mounted) {
                    setState(() {
                      _settingsTabIndex = resolved;
                    });
                  }
                  await _settings.setIntByKey(
                    SettingKey.settingsLastOpenTab,
                    resolved,
                  );
                },
                onSettingChanged: (setting, value) {
                  _updateSetting(setting, value ?? false, persist: true);
                },
                onPixResolutionChanged: (value) async {
                  widget.pixelGrid.setFakePixelsCellSize(value);
                  await _settings.setDoubleByKey(
                    SettingKey.fakePixelsResolution,
                    value,
                  );
                },
                onPixShadesChanged: (enabled) async {
                  widget.pixelGrid.setFakePixelsShadedColorsEnabled(enabled);
                  await _settings.setBoolByKey(
                    SettingKey.fakePixelsUseShades,
                    enabled,
                  );
                },
                onPixGridLineWidthChanged: (value) async {
                  widget.pixelGrid.setFakePixelsGridLineWidth(value);
                  await _settings.setDoubleByKey(
                    SettingKey.fakePixelsGridLineWidth,
                    value,
                  );
                },
                onPixGestureControlsChanged: (enabled) async {
                  widget.pixelGrid.setViewportGesturesEnabled(enabled);
                  await _settings.setBoolByKey(
                    SettingKey.fakePixelsGestureControlsEnabled,
                    enabled,
                  );
                },
                onBaseAssetChanged: (assetPath) async {
                  widget.pixelGrid.setFakePixelsBaseAsset(assetPath);
                  await _settings.setStringByKey(
                    SettingKey.fakePixelsBaseAsset,
                    assetPath,
                  );
                  if (!mounted) {
                    return;
                  }
                  setState(() {
                    _selectedBaseAsset = assetPath;
                  });
                },
                onUiAssetChanged: (assetPath) async {
                  widget.pixelGrid.setFakePixelsUiAsset(assetPath);
                  await _settings.setStringByKey(
                    SettingKey.fakePixelsUiAsset,
                    assetPath,
                  );
                  if (!mounted) {
                    return;
                  }
                  setState(() {
                    _selectedUiAsset = assetPath;
                  });
                },
                onBaseAssetUpload: _uploadBaseAsset,
                onUiAssetUpload: _uploadUiAsset,
                onUploadedAssetDelete: _deleteUploadedAsset,
                onUiLayerVisibleChanged: (visible) async {
                  widget.pixelGrid.setFakePixelsUiVisible(visible);
                  await _settings.setBoolByKey(
                    SettingKey.fakePixelsUiVisible,
                    visible,
                  );
                },
              ),
            ),
          ),
        Positioned(
          left: 16,
          top: 16,
          child: SafeArea(
            minimum: const EdgeInsets.only(top: 8),
            child: ValueListenableBuilder<bool>(
              valueListenable:
                  widget.pixelGrid.viewportGesturesEnabledListenable,
              builder: (context, gesturesEnabled, _) {
                if (!gesturesEnabled) {
                  return const SizedBox.shrink();
                }
                return ValueListenableBuilder<int>(
                  valueListenable:
                      widget.pixelGrid.viewportTransformTickListenable,
                  builder: (context, tick, child) {
                    return ValueListenableBuilder<double>(
                      valueListenable:
                          widget.pixelGrid.fakePixelsCellSizeListenable,
                      builder: (context, pixelSize, child) {
                        final isDefault = widget.pixelGrid.isViewportAtDefault;
                        final zoomLevel = widget.pixelGrid.stageZoomLevel;
                        final zoomLabel =
                            '${(zoomLevel * 100).toStringAsFixed(0)}%';
                        final pixelSizeLabel = _formatNumericLabel(pixelSize);
                        return _ViewportResetButton(
                          isDefault: isDefault,
                          showZoomButtons: _showViewportZoomControls,
                          zoomLabel: zoomLabel,
                          pixelSizeLabel: pixelSizeLabel,
                          onPressed: () {
                            setState(() {
                              _showViewportZoomControls =
                                  !_showViewportZoomControls;
                            });
                            widget.pixelGrid.resetViewportTransform();
                          },
                          onZoomIn: widget.pixelGrid.zoomViewportInStep,
                          onZoomOut: widget.pixelGrid.zoomViewportOutStep,
                          onPixelSizeIncrease: () => _adjustPixelSize(1),
                          onPixelSizeDecrease: () => _adjustPixelSize(-1),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsButton extends StatelessWidget {
  const _SettingsButton({
    required this.isOpen,
    required this.onPressed,
  });

  final bool isOpen;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isOpen ? 'Hide menu' : 'Show menu',
      child: Material(
        color: Colors.black,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Icon(
              isOpen ? Icons.menu_open : Icons.menu,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}

class _ViewportResetButton extends StatelessWidget {
  const _ViewportResetButton({
    required this.isDefault,
    required this.showZoomButtons,
    required this.zoomLabel,
    required this.pixelSizeLabel,
    required this.onPressed,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onPixelSizeIncrease,
    required this.onPixelSizeDecrease,
  });

  final bool isDefault;
  final bool showZoomButtons;
  final String zoomLabel;
  final String pixelSizeLabel;
  final VoidCallback onPressed;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onPixelSizeIncrease;
  final VoidCallback onPixelSizeDecrease;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Tooltip(
          message: isDefault ? 'Zoom controls' : 'Reset view',
          child: Material(
            color: Colors.black,
            borderRadius: BorderRadius.circular(999),
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: onPressed,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Icon(
                  Icons.filter_center_focus,
                  color: isDefault ? Colors.white38 : Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
        if (showZoomButtons) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ViewportIconButton(
                tooltip: 'Zoom out',
                icon: Icons.remove,
                onPressed: onZoomOut,
              ),
              const SizedBox(width: 8),
              Text(
                zoomLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              _ViewportIconButton(
                tooltip: 'Zoom in',
                icon: Icons.add,
                onPressed: onZoomIn,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ViewportIconButton(
                tooltip: 'Decrease pixel size',
                icon: Icons.remove,
                onPressed: onPixelSizeDecrease,
              ),
              const SizedBox(width: 8),
              Text(
                'Pix $pixelSizeLabel',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              _ViewportIconButton(
                tooltip: 'Increase pixel size',
                icon: Icons.add,
                onPressed: onPixelSizeIncrease,
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ViewportIconButton extends StatelessWidget {
  const _ViewportIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.black,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Icon(
              icon,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}

class _DebugPromptBannerBody extends StatelessWidget {
  const _DebugPromptBannerBody({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xEB4A0E0E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13,
            height: 1.3,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
