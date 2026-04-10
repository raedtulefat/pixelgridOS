import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show HardwareKeyboard, KeyDownEvent, KeyEvent, LogicalKeyboardKey;
import 'package:game_shell/os.dart';
import 'package:game_shell/fake_pixels/logo_asset_catalog.dart';
import 'package:game_shell/menus/menu_style.dart';
import 'package:game_shell/menus/settings_menu.dart';
import 'package:game_shell/settings/settings_applier.dart';
import 'package:game_shell/settings/settings_controller.dart';
import 'package:game_shell/settings/settings_keys.dart';
import 'package:game_shell/settings/settings_storage.dart';
import 'package:game_shell/ui/menu_column.dart';
import 'package:game_shell/ui/modal.dart';
import 'package:game_shell/ui/pixel/pixel_border_button.dart';

const String _kTestHubFocusText =
    'Focus: Shell home shows full-screen tiles, hamburger menu, and fake app screens.';
const String _kQaPromptFallbackText =
    'Focus: Open the hamburger menu, launch each fake app screen, and verify tile grid remains visible behind overlays.';

enum _FakeScreen {
  phone,
  messages,
  browser,
  files,
}

class MenuOverlay extends StatefulWidget {
  const MenuOverlay({
    required this.os,
  }) : super();

  static const String testHubFocusText = _kTestHubFocusText;
  static const String qaPromptFallbackText = _kQaPromptFallbackText;

  final ShellOs os;

  @override
  State<MenuOverlay> createState() => _MenuOverlayState();
}

class _MenuOverlayState extends State<MenuOverlay> {
  bool _showPrompt = true;
  bool _showOsMenu = false;
  bool _showSettingsModal = false;
  bool _developerMode = false;
  bool _debugEnabled = true;
  int _settingsTabIndex = 0;
  List<String> _logoAssetOptions = const <String>[];
  String? _selectedLogoAsset;
  _FakeScreen? _activeScreen;
  bool _showViewportZoomControls = false;

  final SettingsController _settings = SettingsController(SettingsStorage());
  final SettingsApplier _settingsApplier = SettingsApplier();
  late Future<void> _settingsLoadFuture;
  late final VoidCallback _debugMenuListener;

  @override
  void initState() {
    super.initState();
    _debugMenuListener = _handleDebugMenuVisibility;
    widget.os.osMenuVisibilityListenable.addListener(_debugMenuListener);
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
    _settingsLoadFuture = _loadSettings();
  }

  @override
  void didUpdateWidget(covariant MenuOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.os == widget.os) {
      return;
    }

    oldWidget.os.osMenuVisibilityListenable.removeListener(_debugMenuListener);
    widget.os.osMenuVisibilityListenable.addListener(_debugMenuListener);
    _applySettingsToOs();
  }

  @override
  void dispose() {
    widget.os.osMenuVisibilityListenable.removeListener(_debugMenuListener);
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    super.dispose();
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (!mounted || event is! KeyDownEvent) {
      return false;
    }

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      if (_activeScreen != null) {
        setState(() {
          _activeScreen = null;
        });
        return true;
      }

      if (_showSettingsModal) {
        _closeSettingsModal();
        return true;
      }

      widget.os.toggleDebugOverlay(fromMenuOverlay: true);
      return true;
    }

    final panStep = widget.os.fakePixelsCellSize * 25;
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      widget.os.panViewportBy(Offset(-panStep, 0));
      return true;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      widget.os.panViewportBy(Offset(panStep, 0));
      return true;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      widget.os.panViewportBy(Offset(0, -panStep));
      return true;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      widget.os.panViewportBy(Offset(0, panStep));
      return true;
    }

    return false;
  }

  Future<void> _loadSettings() async {
    await _settings.load();
    final logoOptions = await LogoAssetCatalog.loadOptions();
    if (!mounted) {
      return;
    }
    setState(() {
      _logoAssetOptions = logoOptions;
    });
    _applySettingsToOs();
  }

  Future<void> _updateSetting(SettingToggle setting, bool next,
      {required bool persist}) async {
    if (persist) {
      await _settings.set(setting, next);
    }
    _applySettingsToOs();
  }

  void _applySettingsToOs() {
    final settings = _settings.snapshot();
    final developerMode = settings[SettingToggle.developerMode] ?? false;
    final debugEnabled = settings[SettingToggle.debugEnabled] ?? true;
    final storedTabIndex = _settings.getIntByKey(
      SettingKey.settingsLastOpenTab,
      defaultValue: 0,
    );
    final resolvedTabIndex =
        storedTabIndex.clamp(0, SettingsMenu.tabCount - 1).toInt();
    if (_developerMode != developerMode ||
        _debugEnabled != debugEnabled ||
        _settingsTabIndex != resolvedTabIndex) {
      setState(() {
        _developerMode = developerMode;
        _debugEnabled = debugEnabled;
        _settingsTabIndex = resolvedTabIndex;
      });
    }

    final pixResolution = _settings.getDoubleByKey(
      SettingKey.fakePixelsResolution,
      defaultValue: 16,
    );
    final pixShades = _settings.getBoolByKey(
      SettingKey.fakePixelsUseShades,
      defaultValue: true,
    );
    final pixGridLineWidth = _settings.getDoubleByKey(
      SettingKey.fakePixelsGridLineWidth,
      defaultValue: 0.25,
    );
    final pixGesturesEnabled = _settings.getBoolByKey(
      SettingKey.fakePixelsGestureControlsEnabled,
      defaultValue: true,
    );

    final fallbackLogoAsset = LogoAssetCatalog.fallbackFrom(_logoAssetOptions);
    final savedLogoAsset = _settings.getStringByKey(
      SettingKey.fakePixelsLogoAsset,
      defaultValue: fallbackLogoAsset ?? '',
    );
    final resolvedLogoAsset = _resolveLogoAsset(
      requested: savedLogoAsset,
      fallback: fallbackLogoAsset,
    );

    widget.os
      ..setFakePixelsCellSize(pixResolution)
      ..setFakePixelsShadedColorsEnabled(pixShades)
      ..setFakePixelsGridLineWidth(pixGridLineWidth)
      ..setViewportGesturesEnabled(pixGesturesEnabled);

    if (!pixGesturesEnabled && _showViewportZoomControls && mounted) {
      setState(() {
        _showViewportZoomControls = false;
      });
    }

    if (resolvedLogoAsset != null) {
      widget.os.setFakePixelsLogoAsset(resolvedLogoAsset);
      if (_selectedLogoAsset != resolvedLogoAsset && mounted) {
        setState(() {
          _selectedLogoAsset = resolvedLogoAsset;
        });
      }
      if (savedLogoAsset != resolvedLogoAsset) {
        _settings.setStringByKey(
          SettingKey.fakePixelsLogoAsset,
          resolvedLogoAsset,
        );
      }
    }

    _settingsApplier.applyAll(
      os: widget.os,
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

  void _handleDebugMenuVisibility() {
    final isVisible = widget.os.isOsMenuVisible;
    if (_showOsMenu == isVisible) {
      return;
    }
    setState(() {
      _showOsMenu = isVisible;
      if (isVisible) {
        _showSettingsModal = false;
      }
    });
  }

  void _toggleOsMenu() {
    widget.os.setOsMenuVisible(!_showOsMenu);
  }

  void _openSettingsModal() {
    setState(() {
      _showSettingsModal = true;
      _showOsMenu = false;
    });
    widget.os.setOsMenuVisible(false);
  }

  void _closeSettingsModal() {
    setState(() {
      _showSettingsModal = false;
    });
  }

  void _openFakeScreen(_FakeScreen screen) {
    setState(() {
      _activeScreen = screen;
      _showOsMenu = false;
    });
    widget.os.setOsMenuVisible(false);
  }

  String? _resolveLogoAsset({
    required String requested,
    required String? fallback,
  }) {
    if (_logoAssetOptions.isEmpty) {
      return null;
    }
    if (requested.isNotEmpty && _logoAssetOptions.contains(requested)) {
      return requested;
    }
    if (fallback != null && _logoAssetOptions.contains(fallback)) {
      return fallback;
    }
    return _logoAssetOptions.first;
  }

  Future<T?> _runWithLoading<T>(Future<T> Function() task) async {
    await _settingsLoadFuture;
    return task();
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
                  isOpen: _showOsMenu,
                  onPressed: _toggleOsMenu,
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
        if (_showOsMenu)
          Positioned.fill(
            child: Modal(
              title: 'Shell Menu',
              onClose: _toggleOsMenu,
              child: MenuColumn(
                spacing: 12,
                children: [
                  PixelBorderButton(
                    label: 'Phone',
                    fillColor: menuFillPrimary,
                    textColor: menuTextDark,
                    onPressed: () => _openFakeScreen(_FakeScreen.phone),
                  ),
                  PixelBorderButton(
                    label: 'Messages',
                    fillColor: menuFillPrimary,
                    textColor: menuTextDark,
                    onPressed: () => _openFakeScreen(_FakeScreen.messages),
                  ),
                  PixelBorderButton(
                    label: 'Browser',
                    fillColor: menuFillPrimary,
                    textColor: menuTextDark,
                    onPressed: () => _openFakeScreen(_FakeScreen.browser),
                  ),
                  PixelBorderButton(
                    label: 'Files',
                    fillColor: menuFillPrimary,
                    textColor: menuTextDark,
                    onPressed: () => _openFakeScreen(_FakeScreen.files),
                  ),
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
              child: SettingsMenu(
                os: widget.os,
                developerMode: _developerMode,
                debugEnabled: _debugEnabled,
                showPrompt: _showPrompt,
                logoAssetOptions: _logoAssetOptions,
                selectedLogoAsset: _selectedLogoAsset,
                initialTabIndex: _settingsTabIndex,
                onTabChanged: (index) async {
                  final resolved =
                      index.clamp(0, SettingsMenu.tabCount - 1).toInt();
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
                  widget.os.setFakePixelsCellSize(value);
                  await _settings.setDoubleByKey(
                    SettingKey.fakePixelsResolution,
                    value,
                  );
                },
                onPixShadesChanged: (enabled) async {
                  widget.os.setFakePixelsShadedColorsEnabled(enabled);
                  await _settings.setBoolByKey(
                    SettingKey.fakePixelsUseShades,
                    enabled,
                  );
                },
                onPixGridLineWidthChanged: (value) async {
                  widget.os.setFakePixelsGridLineWidth(value);
                  await _settings.setDoubleByKey(
                    SettingKey.fakePixelsGridLineWidth,
                    value,
                  );
                },
                onPixGestureControlsChanged: (enabled) async {
                  widget.os.setViewportGesturesEnabled(enabled);
                  await _settings.setBoolByKey(
                    SettingKey.fakePixelsGestureControlsEnabled,
                    enabled,
                  );
                },
                onLogoAssetChanged: (assetPath) async {
                  widget.os.setFakePixelsLogoAsset(assetPath);
                  await _settings.setStringByKey(
                    SettingKey.fakePixelsLogoAsset,
                    assetPath,
                  );
                  if (!mounted) {
                    return;
                  }
                  setState(() {
                    _selectedLogoAsset = assetPath;
                  });
                },
                runWithLoading: _runWithLoading,
                onRequestClose: _closeSettingsModal,
              ),
            ),
          ),
        if (_activeScreen != null)
          Positioned.fill(
            child: _FakeScreenOverlay(
              screen: _activeScreen!,
              onClose: () {
                setState(() {
                  _activeScreen = null;
                });
              },
            ),
          ),
        Positioned(
          left: 16,
          top: 16,
          child: SafeArea(
            minimum: const EdgeInsets.only(top: 8),
            child: ValueListenableBuilder<bool>(
              valueListenable: widget.os.viewportGesturesEnabledListenable,
              builder: (context, gesturesEnabled, _) {
                if (!gesturesEnabled) {
                  return const SizedBox.shrink();
                }
                return ValueListenableBuilder<int>(
                  valueListenable: widget.os.viewportTransformTickListenable,
                  builder: (context, tick, child) {
                    final isDefault = widget.os.isViewportAtDefault;
                    final zoomLevel = widget.os.stageZoomLevel;
                    final zoomLabel = '${(zoomLevel * 100).toStringAsFixed(0)}%';
                    return _ViewportResetButton(
                      isDefault: isDefault,
                      showZoomButtons: _showViewportZoomControls,
                      zoomLabel: zoomLabel,
                      onPressed: () {
                        if (isDefault) {
                          if (!_showViewportZoomControls) {
                            setState(() {
                              _showViewportZoomControls = true;
                            });
                          }
                          return;
                        }
                        setState(() {
                          _showViewportZoomControls = false;
                        });
                        widget.os.resetViewportTransform();
                      },
                      onZoomIn: widget.os.zoomViewportInStep,
                      onZoomOut: widget.os.zoomViewportOutStep,
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
    required this.onPressed,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  final bool isDefault;
  final bool showZoomButtons;
  final String zoomLabel;
  final VoidCallback onPressed;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

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
                tooltip: 'Zoom in',
                icon: Icons.add,
                onPressed: onZoomIn,
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
                tooltip: 'Zoom out',
                icon: Icons.remove,
                onPressed: onZoomOut,
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

class _FakeScreenOverlay extends StatelessWidget {
  const _FakeScreenOverlay({
    required this.screen,
    required this.onClose,
  });

  final _FakeScreen screen;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final title = switch (screen) {
      _FakeScreen.phone => 'Phone',
      _FakeScreen.messages => 'Messages',
      _FakeScreen.browser => 'Browser',
      _FakeScreen.files => 'Files',
    };

    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Modal(
            title: '$title (Mock)',
            onClose: onClose,
            child: MenuColumn(
              spacing: 12,
              children: [
                const Text(
                  'Placeholder screen for shell prototyping.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
                PixelBorderButton(
                  label: 'Primary action',
                  fillColor: menuFillPrimary,
                  textColor: menuTextDark,
                  onPressed: () {},
                ),
                PixelBorderButton(
                  label: 'Secondary action',
                  fillColor: menuFillDark,
                  textColor: menuTextLight,
                  onPressed: () {},
                ),
                PixelBorderButton(
                  label: 'Close',
                  fillColor: menuFillDark,
                  textColor: menuTextLight,
                  onPressed: onClose,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
