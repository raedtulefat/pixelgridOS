import "package:flutter/material.dart";

import "package:game_shell/os.dart";
import "package:game_shell/menus/menu_overlay_types.dart";
import "package:game_shell/menus/menu_style.dart";
import "package:game_shell/settings/settings_controller.dart";
import "package:game_shell/ui/menu_column.dart";
import "package:game_shell/ui/modal.dart";
import "package:game_shell/ui/pixel/pixel_border_button.dart";

enum _SettingsTab {
  config,
  debug,
  pix,
  assets,
  pi,
}

class SettingsMenu extends StatelessWidget {
  const SettingsMenu({
    required this.os,
    required this.developerMode,
    required this.debugEnabled,
    required this.showPrompt,
    required this.logoAssetOptions,
    required this.selectedLogoAsset,
    required this.initialTabIndex,
    required this.onTabChanged,
    required this.onSettingChanged,
    required this.onPixResolutionChanged,
    required this.onPixShadesChanged,
    required this.onLogoAssetChanged,
    required this.runWithLoading,
    required this.onRequestClose,
  });

  static const int tabCount = 5;

  final ShellOs os;
  final bool developerMode;
  final bool debugEnabled;
  final bool showPrompt;
  final List<String> logoAssetOptions;
  final String? selectedLogoAsset;
  final int initialTabIndex;
  final Future<void> Function(int index) onTabChanged;
  final void Function(SettingToggle, bool? value) onSettingChanged;
  final Future<void> Function(double value) onPixResolutionChanged;
  final Future<void> Function(bool enabled) onPixShadesChanged;
  final Future<void> Function(String assetPath) onLogoAssetChanged;
  final LoadingRunner runWithLoading;
  final VoidCallback onRequestClose;

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
                  child: _SettingsMenuBody(
                    tab: _SettingsTab.config,
                    os: os,
                    developerMode: developerMode,
                    debugEnabled: debugEnabled,
                    showPrompt: showPrompt,
                    logoAssetOptions: logoAssetOptions,
                    selectedLogoAsset: selectedLogoAsset,
                    onSettingChanged: onSettingChanged,
                    onPixResolutionChanged: onPixResolutionChanged,
                    onPixShadesChanged: onPixShadesChanged,
                    onLogoAssetChanged: onLogoAssetChanged,
                    onRequestClose: onRequestClose,
                    runWithLoading: runWithLoading,
                  ),
                ),
                SingleChildScrollView(
                  child: _SettingsMenuBody(
                    tab: _SettingsTab.debug,
                    os: os,
                    developerMode: developerMode,
                    debugEnabled: debugEnabled,
                    showPrompt: showPrompt,
                    logoAssetOptions: logoAssetOptions,
                    selectedLogoAsset: selectedLogoAsset,
                    onSettingChanged: onSettingChanged,
                    onPixResolutionChanged: onPixResolutionChanged,
                    onPixShadesChanged: onPixShadesChanged,
                    onLogoAssetChanged: onLogoAssetChanged,
                    onRequestClose: onRequestClose,
                    runWithLoading: runWithLoading,
                  ),
                ),
                SingleChildScrollView(
                  child: _SettingsMenuBody(
                    tab: _SettingsTab.pix,
                    os: os,
                    developerMode: developerMode,
                    debugEnabled: debugEnabled,
                    showPrompt: showPrompt,
                    logoAssetOptions: logoAssetOptions,
                    selectedLogoAsset: selectedLogoAsset,
                    onSettingChanged: onSettingChanged,
                    onPixResolutionChanged: onPixResolutionChanged,
                    onPixShadesChanged: onPixShadesChanged,
                    onLogoAssetChanged: onLogoAssetChanged,
                    onRequestClose: onRequestClose,
                    runWithLoading: runWithLoading,
                  ),
                ),
                SingleChildScrollView(
                  child: _SettingsMenuBody(
                    tab: _SettingsTab.assets,
                    os: os,
                    developerMode: developerMode,
                    debugEnabled: debugEnabled,
                    showPrompt: showPrompt,
                    logoAssetOptions: logoAssetOptions,
                    selectedLogoAsset: selectedLogoAsset,
                    onSettingChanged: onSettingChanged,
                    onPixResolutionChanged: onPixResolutionChanged,
                    onPixShadesChanged: onPixShadesChanged,
                    onLogoAssetChanged: onLogoAssetChanged,
                    onRequestClose: onRequestClose,
                    runWithLoading: runWithLoading,
                  ),
                ),
                SingleChildScrollView(
                  child: _SettingsMenuBody(
                    tab: _SettingsTab.pi,
                    os: os,
                    developerMode: developerMode,
                    debugEnabled: debugEnabled,
                    showPrompt: showPrompt,
                    logoAssetOptions: logoAssetOptions,
                    selectedLogoAsset: selectedLogoAsset,
                    onSettingChanged: onSettingChanged,
                    onPixResolutionChanged: onPixResolutionChanged,
                    onPixShadesChanged: onPixShadesChanged,
                    onLogoAssetChanged: onLogoAssetChanged,
                    onRequestClose: onRequestClose,
                    runWithLoading: runWithLoading,
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

class _SettingsMenuBody extends StatelessWidget {
  const _SettingsMenuBody({
    required this.tab,
    required this.os,
    required this.developerMode,
    required this.debugEnabled,
    required this.showPrompt,
    required this.logoAssetOptions,
    required this.selectedLogoAsset,
    required this.onSettingChanged,
    required this.onPixResolutionChanged,
    required this.onPixShadesChanged,
    required this.onLogoAssetChanged,
    required this.runWithLoading,
    required this.onRequestClose,
  });

  final _SettingsTab tab;
  final ShellOs os;
  final bool developerMode;
  final bool debugEnabled;
  final bool showPrompt;
  final List<String> logoAssetOptions;
  final String? selectedLogoAsset;
  final void Function(SettingToggle, bool? value) onSettingChanged;
  final Future<void> Function(double value) onPixResolutionChanged;
  final Future<void> Function(bool enabled) onPixShadesChanged;
  final Future<void> Function(String assetPath) onLogoAssetChanged;
  final LoadingRunner runWithLoading;
  final VoidCallback onRequestClose;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DebugUiState>(
      valueListenable: os.debugUiListenable,
      builder: (context, state, _) {
        final options = <_SettingsOption>[
          _SettingsOption(
            label: "Debug info",
            value: state.infoText,
            setting: SettingToggle.debugInfoText,
          ),
          _SettingsOption(
            label: "Surface outline",
            value: state.surfaceOutline,
            setting: SettingToggle.debugSurfaceOutline,
          ),
        ];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: switch (tab) {
            _SettingsTab.config => _buildConfigTab(context, state),
            _SettingsTab.debug => _buildDebugTab(context, options),
            _SettingsTab.pix => _buildPixTab(context),
            _SettingsTab.assets => _buildAssetsTab(context),
            _SettingsTab.pi => _buildPiTab(context),
          },
        );
      },
    );
  }

  Widget _buildConfigTab(
    BuildContext context,
    DebugUiState state,
  ) {
    return MenuColumn(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SettingsSectionHeader("Configurations"),
        _SettingsCheckboxRow(
          label: "Shell logs",
          value: state.shellLogs,
          onChanged: (value) => onSettingChanged(
            SettingToggle.debugShellLogs,
            value,
          ),
        ),
      ],
    );
  }

  Widget _buildDebugTab(
    BuildContext context,
    List<_SettingsOption> options,
  ) {
    return MenuColumn(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SettingsSectionHeader("Debug settings"),
        _SettingsCheckboxRow(
          label: "Developer mode",
          value: developerMode,
          onChanged: (value) => onSettingChanged(
            SettingToggle.developerMode,
            value,
          ),
        ),
        _SettingsCheckboxRow(
          label: "QA focus",
          value: showPrompt,
          onChanged: (value) => onSettingChanged(
            SettingToggle.promptBanner,
            value,
          ),
        ),
        for (final option in options)
          _SettingsCheckboxRow(
            label: option.label,
            value: option.value,
            onChanged: (value) => onSettingChanged(option.setting, value),
          ),
        PixelBorderButton(
          label: "Refresh shell",
          fillColor: menuFillPrimary,
          textColor: menuTextDark,
          minHeight: 40,
          onPressed: () async {
            onRequestClose();
            await runWithLoading(
              () => os.refreshShell(),
            );
          },
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
          valueListenable: os.fakePixelsCellSizeListenable,
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
          valueListenable: os.fakePixelsShadedColorsListenable,
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
        PixelBorderButton(
          label: "Refresh",
          fillColor: menuFillPrimary,
          textColor: menuTextDark,
          minHeight: 36,
          onPressed: () async {
            onRequestClose();
            await runWithLoading(
              () => os.refreshShell(),
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
        const Text(
          "Logo",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (logoAssetOptions.isEmpty)
          const Text(
            "No logo options found in assets/ui/logo/",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54),
          )
        else
          for (final option in logoAssetOptions)
            PixelBorderButton(
              label: _assetLabel(option),
              fillColor:
                  option == selectedLogoAsset ? menuFillPrimary : menuFillDark,
              textColor:
                  option == selectedLogoAsset ? menuTextDark : menuTextLight,
              minHeight: 36,
              onPressed: () async {
                await onLogoAssetChanged(option);
              },
            ),
        PixelBorderButton(
          label: "Refresh",
          fillColor: menuFillPrimary,
          textColor: menuTextDark,
          minHeight: 36,
          onPressed: () async {
            onRequestClose();
            await runWithLoading(
              () => os.refreshShell(),
            );
          },
        ),
      ],
    );
  }

  String _assetLabel(String assetPath) {
    final fileName = assetPath.split('/').last;
    return fileName;
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
    final controller = TextEditingController();

    return MenuColumn(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SettingsSectionHeader("Pi"),
        // Copied shell UI shape from roguechoices kanban tab; intentionally no-op.
        TextField(
          controller: controller,
          minLines: 6,
          maxLines: 12,
          cursorColor: menuTextLight,
          style: const TextStyle(
            color: menuTextLight,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: "Type markdown...",
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
          label: "Submit",
          fillColor: menuFillPrimary,
          textColor: menuTextDark,
          minHeight: 40,
          onPressed: () {},
        ),
      ],
    );
  }
}

class _SettingsOption {
  const _SettingsOption({
    required this.label,
    required this.value,
    required this.setting,
  });

  final String label;
  final bool value;
  final SettingToggle setting;
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
