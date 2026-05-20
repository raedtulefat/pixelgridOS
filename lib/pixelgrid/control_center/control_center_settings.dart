import "dart:convert";

import "package:flutter/material.dart";
import "package:http/http.dart" as http;

import "package:pixelgrid/pixelgrid.dart";
import "package:pixelgrid/pixelgrid/control_center/control_center_style.dart";
import "package:pixelgrid/pixelgrid/fake_pixels/uploaded_image_asset_store.dart";
import "package:pixelgrid/pixelgrid/settings/settings_controller.dart";
import "package:pixelgrid/pixelgrid/ui/menu_column.dart";
import "package:pixelgrid/pixelgrid/ui/modal.dart";
import "package:pixelgrid/pixelgrid/ui/pixel/pixel_border_button.dart";

enum _SettingsTab {
  config,
  debug,
  pix,
  assets,
  pi,
}

class ControlCenterSettings extends StatelessWidget {
  const ControlCenterSettings({
    super.key,
    required this.pixelGrid,
    required this.showPrompt,
    required this.baseAssetOptions,
    required this.uiAssetOptions,
    required this.selectedBaseAsset,
    required this.selectedUiAsset,
    required this.uiLayerVisible,
    required this.initialTabIndex,
    required this.onTabChanged,
    required this.onSettingChanged,
    required this.onPixResolutionChanged,
    required this.onPixShadesChanged,
    required this.onPixGridLineWidthChanged,
    required this.onPixGestureControlsChanged,
    required this.onBaseAssetChanged,
    required this.onUiAssetChanged,
    required this.onBaseAssetUpload,
    required this.onUiAssetUpload,
    required this.onUploadedAssetDelete,
    required this.onUiLayerVisibleChanged,
  });

  static const int tabCount = 5;

  final PixelGrid pixelGrid;
  final bool showPrompt;
  final List<String> baseAssetOptions;
  final List<String> uiAssetOptions;
  final String? selectedBaseAsset;
  final String? selectedUiAsset;
  final bool uiLayerVisible;
  final int initialTabIndex;
  final Future<void> Function(int index) onTabChanged;
  final void Function(SettingToggle, bool? value) onSettingChanged;
  final Future<void> Function(double value) onPixResolutionChanged;
  final Future<void> Function(bool enabled) onPixShadesChanged;
  final Future<void> Function(double value) onPixGridLineWidthChanged;
  final Future<void> Function(bool enabled) onPixGestureControlsChanged;
  final Future<void> Function(String assetPath) onBaseAssetChanged;
  final Future<void> Function(String assetPath) onUiAssetChanged;
  final Future<void> Function() onBaseAssetUpload;
  final Future<void> Function() onUiAssetUpload;
  final Future<void> Function(String assetPath) onUploadedAssetDelete;
  final Future<void> Function(bool visible) onUiLayerVisibleChanged;

  @override
  Widget build(BuildContext context) {
    final safeInitialTabIndex =
        initialTabIndex.clamp(0, _SettingsTab.values.length - 1);

    return DefaultTabController(
      length: _SettingsTab.values.length,
      initialIndex: safeInitialTabIndex,
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              indicatorColor: menuFillPrimary,
              onTap: (index) async {
                await onTabChanged(index);
              },
              tabs: const [
                Tab(
                  icon: Icon(Icons.tune),
                  text: "Config",
                ),
                Tab(
                  icon: Icon(Icons.bug_report),
                  text: "Debug",
                ),
                Tab(
                  icon: Icon(Icons.grid_4x4),
                  text: "Pix",
                ),
                Tab(
                  icon: Icon(Icons.image),
                  text: "Assets",
                ),
                Tab(
                  icon: Icon(Icons.smart_toy),
                  text: "Pi",
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                SingleChildScrollView(
                  child: _ControlCenterSettingsBody(
                    tab: _SettingsTab.config,
                    pixelGrid: pixelGrid,
                    showPrompt: showPrompt,
                    baseAssetOptions: baseAssetOptions,
                    uiAssetOptions: uiAssetOptions,
                    selectedBaseAsset: selectedBaseAsset,
                    selectedUiAsset: selectedUiAsset,
                    uiLayerVisible: uiLayerVisible,
                    onSettingChanged: onSettingChanged,
                    onPixResolutionChanged: onPixResolutionChanged,
                    onPixShadesChanged: onPixShadesChanged,
                    onPixGridLineWidthChanged: onPixGridLineWidthChanged,
                    onPixGestureControlsChanged: onPixGestureControlsChanged,
                    onBaseAssetChanged: onBaseAssetChanged,
                    onUiAssetChanged: onUiAssetChanged,
                    onBaseAssetUpload: onBaseAssetUpload,
                    onUiAssetUpload: onUiAssetUpload,
                    onUploadedAssetDelete: onUploadedAssetDelete,
                    onUiLayerVisibleChanged: onUiLayerVisibleChanged,
                  ),
                ),
                SingleChildScrollView(
                  child: _ControlCenterSettingsBody(
                    tab: _SettingsTab.debug,
                    pixelGrid: pixelGrid,
                    showPrompt: showPrompt,
                    baseAssetOptions: baseAssetOptions,
                    uiAssetOptions: uiAssetOptions,
                    selectedBaseAsset: selectedBaseAsset,
                    selectedUiAsset: selectedUiAsset,
                    uiLayerVisible: uiLayerVisible,
                    onSettingChanged: onSettingChanged,
                    onPixResolutionChanged: onPixResolutionChanged,
                    onPixShadesChanged: onPixShadesChanged,
                    onPixGridLineWidthChanged: onPixGridLineWidthChanged,
                    onPixGestureControlsChanged: onPixGestureControlsChanged,
                    onBaseAssetChanged: onBaseAssetChanged,
                    onUiAssetChanged: onUiAssetChanged,
                    onBaseAssetUpload: onBaseAssetUpload,
                    onUiAssetUpload: onUiAssetUpload,
                    onUploadedAssetDelete: onUploadedAssetDelete,
                    onUiLayerVisibleChanged: onUiLayerVisibleChanged,
                  ),
                ),
                SingleChildScrollView(
                  child: _ControlCenterSettingsBody(
                    tab: _SettingsTab.pix,
                    pixelGrid: pixelGrid,
                    showPrompt: showPrompt,
                    baseAssetOptions: baseAssetOptions,
                    uiAssetOptions: uiAssetOptions,
                    selectedBaseAsset: selectedBaseAsset,
                    selectedUiAsset: selectedUiAsset,
                    uiLayerVisible: uiLayerVisible,
                    onSettingChanged: onSettingChanged,
                    onPixResolutionChanged: onPixResolutionChanged,
                    onPixShadesChanged: onPixShadesChanged,
                    onPixGridLineWidthChanged: onPixGridLineWidthChanged,
                    onPixGestureControlsChanged: onPixGestureControlsChanged,
                    onBaseAssetChanged: onBaseAssetChanged,
                    onUiAssetChanged: onUiAssetChanged,
                    onBaseAssetUpload: onBaseAssetUpload,
                    onUiAssetUpload: onUiAssetUpload,
                    onUploadedAssetDelete: onUploadedAssetDelete,
                    onUiLayerVisibleChanged: onUiLayerVisibleChanged,
                  ),
                ),
                SingleChildScrollView(
                  child: _ControlCenterSettingsBody(
                    tab: _SettingsTab.assets,
                    pixelGrid: pixelGrid,
                    showPrompt: showPrompt,
                    baseAssetOptions: baseAssetOptions,
                    uiAssetOptions: uiAssetOptions,
                    selectedBaseAsset: selectedBaseAsset,
                    selectedUiAsset: selectedUiAsset,
                    uiLayerVisible: uiLayerVisible,
                    onSettingChanged: onSettingChanged,
                    onPixResolutionChanged: onPixResolutionChanged,
                    onPixShadesChanged: onPixShadesChanged,
                    onPixGridLineWidthChanged: onPixGridLineWidthChanged,
                    onPixGestureControlsChanged: onPixGestureControlsChanged,
                    onBaseAssetChanged: onBaseAssetChanged,
                    onUiAssetChanged: onUiAssetChanged,
                    onBaseAssetUpload: onBaseAssetUpload,
                    onUiAssetUpload: onUiAssetUpload,
                    onUploadedAssetDelete: onUploadedAssetDelete,
                    onUiLayerVisibleChanged: onUiLayerVisibleChanged,
                  ),
                ),
                SingleChildScrollView(
                  child: _ControlCenterSettingsBody(
                    tab: _SettingsTab.pi,
                    pixelGrid: pixelGrid,
                    showPrompt: showPrompt,
                    baseAssetOptions: baseAssetOptions,
                    uiAssetOptions: uiAssetOptions,
                    selectedBaseAsset: selectedBaseAsset,
                    selectedUiAsset: selectedUiAsset,
                    uiLayerVisible: uiLayerVisible,
                    onSettingChanged: onSettingChanged,
                    onPixResolutionChanged: onPixResolutionChanged,
                    onPixShadesChanged: onPixShadesChanged,
                    onPixGridLineWidthChanged: onPixGridLineWidthChanged,
                    onPixGestureControlsChanged: onPixGestureControlsChanged,
                    onBaseAssetChanged: onBaseAssetChanged,
                    onUiAssetChanged: onUiAssetChanged,
                    onBaseAssetUpload: onBaseAssetUpload,
                    onUiAssetUpload: onUiAssetUpload,
                    onUploadedAssetDelete: onUploadedAssetDelete,
                    onUiLayerVisibleChanged: onUiLayerVisibleChanged,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSectionHeader extends StatelessWidget {
  const _SettingsSectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }
}

class _ControlCenterSettingsBody extends StatelessWidget {
  const _ControlCenterSettingsBody({
    required this.tab,
    required this.pixelGrid,
    required this.showPrompt,
    required this.baseAssetOptions,
    required this.uiAssetOptions,
    required this.selectedBaseAsset,
    required this.selectedUiAsset,
    required this.uiLayerVisible,
    required this.onSettingChanged,
    required this.onPixResolutionChanged,
    required this.onPixShadesChanged,
    required this.onPixGridLineWidthChanged,
    required this.onPixGestureControlsChanged,
    required this.onBaseAssetChanged,
    required this.onUiAssetChanged,
    required this.onBaseAssetUpload,
    required this.onUiAssetUpload,
    required this.onUploadedAssetDelete,
    required this.onUiLayerVisibleChanged,
  });

  final _SettingsTab tab;
  final PixelGrid pixelGrid;
  final bool showPrompt;
  final List<String> baseAssetOptions;
  final List<String> uiAssetOptions;
  final String? selectedBaseAsset;
  final String? selectedUiAsset;
  final bool uiLayerVisible;
  final void Function(SettingToggle, bool? value) onSettingChanged;
  final Future<void> Function(double value) onPixResolutionChanged;
  final Future<void> Function(bool enabled) onPixShadesChanged;
  final Future<void> Function(double value) onPixGridLineWidthChanged;
  final Future<void> Function(bool enabled) onPixGestureControlsChanged;
  final Future<void> Function(String assetPath) onBaseAssetChanged;
  final Future<void> Function(String assetPath) onUiAssetChanged;
  final Future<void> Function() onBaseAssetUpload;
  final Future<void> Function() onUiAssetUpload;
  final Future<void> Function(String assetPath) onUploadedAssetDelete;
  final Future<void> Function(bool visible) onUiLayerVisibleChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: switch (tab) {
        _SettingsTab.config => _buildConfigTab(context),
        _SettingsTab.debug => _buildDebugTab(context),
        _SettingsTab.pix => _buildPixTab(context),
        _SettingsTab.assets => _buildAssetsTab(context),
        _SettingsTab.pi => _buildPiTab(context),
      },
    );
  }

  Widget _buildConfigTab(BuildContext context) {
    return const MenuColumn(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SettingsSectionHeader("Configurations"),
      ],
    );
  }

  Widget _buildDebugTab(BuildContext context) {
    return MenuColumn(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SettingsSectionHeader("Debug settings"),
        _SettingsCheckboxRow(
          label: "QA focus",
          value: showPrompt,
          onChanged: (value) => onSettingChanged(
            SettingToggle.promptBanner,
            value,
          ),
        ),
      ],
    );
  }

  Widget _buildPixTab(BuildContext context) {
    return MenuColumn(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SettingsSectionHeader("Fake pixels"),
        ValueListenableBuilder<double>(
          valueListenable: pixelGrid.fakePixelsCellSizeListenable,
          builder: (context, cellSize, _) {
            return PixelBorderButton(
              label: "Res: ${_formatCellSize(cellSize)}",
              fillColor: menuFillDark,
              textColor: menuTextLight,
              minHeight: 36,
              onPressed: () => _openPixResolutionModal(
                context,
                initialCellSize: cellSize,
              ),
            );
          },
        ),
        ValueListenableBuilder<bool>(
          valueListenable: pixelGrid.fakePixelsShadedColorsListenable,
          builder: (context, shadesEnabled, _) {
            return PixelBorderButton(
              label: "Shades: ${shadesEnabled ? 'ON' : 'OFF'}",
              fillColor: menuFillDark,
              textColor: menuTextLight,
              minHeight: 36,
              onPressed: () async {
                await onPixShadesChanged(!shadesEnabled);
              },
            );
          },
        ),
        ValueListenableBuilder<bool>(
          valueListenable: pixelGrid.viewportGesturesEnabledListenable,
          builder: (context, gesturesEnabled, _) {
            return PixelBorderButton(
              label: "Gesture controls: ${gesturesEnabled ? 'ON' : 'OFF'}",
              fillColor: menuFillDark,
              textColor: menuTextLight,
              minHeight: 36,
              onPressed: () async {
                await onPixGestureControlsChanged(!gesturesEnabled);
              },
            );
          },
        ),
        ValueListenableBuilder<double>(
          valueListenable: pixelGrid.fakePixelsGridLineWidthListenable,
          builder: (context, lineWidth, _) {
            return PixelBorderButton(
              label: "Grid width: ${_formatCellSize(lineWidth)}",
              fillColor: menuFillDark,
              textColor: menuTextLight,
              minHeight: 36,
              onPressed: () => _openPixGridWidthModal(
                context,
                initialGridWidth: lineWidth,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAssetsTab(BuildContext context) {
    return MenuColumn(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SettingsSectionHeader("Asset settings"),
        _buildAssetGroup(
          title: 'Stage base',
          options: baseAssetOptions,
          selected: selectedBaseAsset,
          onSelected: onBaseAssetChanged,
          onUpload: onBaseAssetUpload,
          onDeleteUploaded: onUploadedAssetDelete,
        ),
        const SizedBox(height: 4),
        PixelBorderButton(
          label: 'Stage UI visible: ${uiLayerVisible ? 'ON' : 'OFF'}',
          fillColor: menuFillDark,
          textColor: menuTextLight,
          minHeight: 36,
          onPressed: () async {
            await onUiLayerVisibleChanged(!uiLayerVisible);
          },
        ),
        _buildAssetGroup(
          title: 'Stage UI',
          options: uiAssetOptions,
          selected: selectedUiAsset,
          onSelected: onUiAssetChanged,
          onUpload: onUiAssetUpload,
          onDeleteUploaded: onUploadedAssetDelete,
        ),
      ],
    );
  }

  Widget _buildAssetGroup({
    required String title,
    required List<String> options,
    required String? selected,
    required Future<void> Function(String assetPath) onSelected,
    required Future<void> Function() onUpload,
    required Future<void> Function(String assetPath) onDeleteUploaded,
  }) {
    return MenuColumn(
      spacing: 6,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
        PixelBorderButton(
          label: 'Upload image',
          fillColor: menuFillPrimary,
          textColor: menuTextDark,
          minHeight: 36,
          onPressed: () async {
            await onUpload();
          },
        ),
        if (options.isEmpty)
          const Text(
            "No asset options found in assets/ui/logo/",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54),
          )
        else
          for (final option in options)
            _AssetOptionRow(
              label: _assetLabel(option),
              selected: option == selected,
              canDelete: isUploadedImageAssetPath(option),
              onSelected: () async {
                await onSelected(option);
              },
              onDelete: () async {
                await onDeleteUploaded(option);
              },
            ),
      ],
    );
  }

  String _assetLabel(String assetPath) {
    if (isUploadedImageAssetPath(assetPath)) {
      return uploadedImageAssetLabel(assetPath);
    }
    final fileName = assetPath.split('/').last;
    return fileName;
  }

  Future<void> _openPixGridWidthModal(
    BuildContext context, {
    required double initialGridWidth,
  }) async {
    final controller = TextEditingController(
      text: _formatCellSize(initialGridWidth),
    );
    String? errorText;

    await showDialog<void>(
      context: context,
      barrierColor: Colors.transparent,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Material(
              color: Colors.transparent,
              child: Modal(
                title: 'Pix: Grid width',
                maxWidth: 420,
                onClose: () => Navigator.of(dialogContext).pop(),
                child: MenuColumn(
                  spacing: 8,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: controller,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: false,
                      ),
                      cursorColor: menuTextLight,
                      style: const TextStyle(
                        color: menuTextLight,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter grid line width (e.g. 0.25)',
                        hintStyle: const TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                        errorText: errorText,
                        filled: true,
                        fillColor: menuFillDark,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    PixelBorderButton(
                      label: 'Apply',
                      fillColor: menuFillPrimary,
                      textColor: menuTextDark,
                      minHeight: 40,
                      onPressed: () async {
                        final parsed = double.tryParse(controller.text.trim());
                        if (parsed == null || !parsed.isFinite || parsed <= 0) {
                          setModalState(() {
                            errorText = 'Enter a number greater than 0';
                          });
                          return;
                        }
                        await onPixGridLineWidthChanged(parsed);
                        if (!context.mounted) {
                          return;
                        }
                        Navigator.of(dialogContext).pop();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openPixResolutionModal(
    BuildContext context, {
    required double initialCellSize,
  }) async {
    final controller = TextEditingController(
      text: _formatCellSize(initialCellSize),
    );
    String? errorText;

    await showDialog<void>(
      context: context,
      barrierColor: Colors.transparent,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Material(
              color: Colors.transparent,
              child: Modal(
                title: 'Pix: Resolution',
                maxWidth: 420,
                onClose: () => Navigator.of(dialogContext).pop(),
                child: MenuColumn(
                  spacing: 8,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: controller,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: false,
                      ),
                      cursorColor: menuTextLight,
                      style: const TextStyle(
                        color: menuTextLight,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter fake pixel size (e.g. 16)',
                        hintStyle: const TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                        errorText: errorText,
                        filled: true,
                        fillColor: menuFillDark,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    PixelBorderButton(
                      label: 'Apply',
                      fillColor: menuFillPrimary,
                      textColor: menuTextDark,
                      minHeight: 40,
                      onPressed: () async {
                        final parsed = double.tryParse(controller.text.trim());
                        if (parsed == null || !parsed.isFinite || parsed <= 0) {
                          setModalState(() {
                            errorText = 'Enter a number greater than 0';
                          });
                          return;
                        }
                        await onPixResolutionChanged(parsed);
                        if (!context.mounted) {
                          return;
                        }
                        Navigator.of(dialogContext).pop();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatCellSize(double cellSize) {
    if (cellSize == cellSize.roundToDouble()) {
      return cellSize.toInt().toString();
    }
    return cellSize.toStringAsFixed(2);
  }

  Widget _buildPiTab(BuildContext context) {
    return const _PiPromptPanel();
  }
}

class _AssetOptionRow extends StatelessWidget {
  const _AssetOptionRow({
    required this.label,
    required this.selected,
    required this.canDelete,
    required this.onSelected,
    required this.onDelete,
  });

  final String label;
  final bool selected;
  final bool canDelete;
  final Future<void> Function() onSelected;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final button = PixelBorderButton(
      label: label,
      fillColor: selected ? menuFillPrimary : menuFillDark,
      textColor: selected ? menuTextDark : menuTextLight,
      minHeight: 36,
      onPressed: () async {
        await onSelected();
      },
    );

    if (!canDelete) {
      return button;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: button),
        const SizedBox(width: 6),
        _UploadedAssetDeleteButton(
          onPressed: () async {
            await onDelete();
          },
        ),
      ],
    );
  }
}

class _UploadedAssetDeleteButton extends StatelessWidget {
  const _UploadedAssetDeleteButton({
    required this.onPressed,
  });

  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Delete uploaded asset',
      child: SizedBox(
        width: 44,
        height: 36,
        child: Material(
          color: menuFillDark,
          child: InkWell(
            onTap: () async {
              await onPressed();
            },
            child: const Icon(
              Icons.delete_outline,
              color: Colors.white70,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}

class _PiPromptPanel extends StatefulWidget {
  const _PiPromptPanel();

  @override
  State<_PiPromptPanel> createState() => _PiPromptPanelState();
}

class _PiPromptPanelState extends State<_PiPromptPanel> {
  static const String _piApiUrl = String.fromEnvironment(
    "PI_API_URL",
    defaultValue: "http://localhost:8787",
  );
  static const String _piBridgeToken = String.fromEnvironment(
    "PI_BRIDGE_TOKEN",
    defaultValue: "",
  );

  final TextEditingController _controller = TextEditingController();
  bool _isSubmitting = false;
  String? _statusText;
  bool _statusIsError = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitPrompt() async {
    final message = _controller.text.trim();
    if (message.isEmpty || _isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _statusText = "Sending to Pi...";
      _statusIsError = false;
    });

    try {
      final headers = <String, String>{"content-type": "application/json"};
      if (_piBridgeToken.isNotEmpty) {
        headers["authorization"] = "Bearer $_piBridgeToken";
      }

      final response = await http.post(
        Uri.parse("$_piApiUrl/prompt"),
        headers: headers,
        body: jsonEncode({"message": message}),
      );

      if (!mounted) {
        return;
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        setState(() {
          _statusText = "Pi error ${response.statusCode}: ${response.body}";
          _statusIsError = true;
        });
        return;
      }

      setState(() {
        _controller.clear();
        _statusText = "Sent to Pi. Check the Pi service logs for progress.";
        _statusIsError = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _statusText = "Could not reach Pi at $_piApiUrl: $error";
        _statusIsError = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MenuColumn(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SettingsSectionHeader("Pi"),
        Text(
          "Prompts are sent to the configured Pi service.",
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        TextField(
          controller: _controller,
          minLines: 6,
          maxLines: 12,
          cursorColor: menuTextLight,
          style: const TextStyle(
            color: menuTextLight,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: "Tell Pi what code changes to make...",
            hintStyle: const TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
            filled: true,
            fillColor: menuFillDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(0),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        PixelBorderButton(
          label: _isSubmitting ? "Sending..." : "Submit to Pi",
          fillColor: menuFillPrimary,
          textColor: menuTextDark,
          minHeight: 40,
          onPressed: _isSubmitting ? null : _submitPrompt,
        ),
        if (_statusText != null)
          Text(
            _statusText!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _statusIsError ? Colors.redAccent : Colors.white70,
              fontSize: 12,
            ),
          ),
      ],
    );
  }
}

class _SettingsCheckboxRow extends StatelessWidget {
  const _SettingsCheckboxRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    final stateLabel = value ? "ON" : "OFF";
    return PixelBorderButton(
      label: "$label: $stateLabel",
      fillColor: menuFillDark,
      textColor: menuTextLight,
      minHeight: 36,
      onPressed: () => onChanged(!value),
    );
  }
}
