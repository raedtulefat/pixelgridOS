import "package:flutter/material.dart";

import "package:game_shell/os.dart";
import "package:game_shell/menus/menu_overlay_types.dart";
import "package:game_shell/menus/menu_style.dart";
import "package:game_shell/settings/settings_controller.dart";
import "package:game_shell/ui/menu_column.dart";
import "package:game_shell/ui/pixel/pixel_border_button.dart";

enum _SettingsTab {
  config,
  debug,
  pi,
}

class SettingsMenu extends StatelessWidget {
  const SettingsMenu({
    required this.os,
    required this.developerMode,
    required this.debugEnabled,
    required this.showPrompt,
    required this.onSettingChanged,
    required this.runWithLoading,
    required this.onRequestClose,
  });

  final ShellOs os;
  final bool developerMode;
  final bool debugEnabled;
  final bool showPrompt;
  final void Function(SettingToggle, bool? value) onSettingChanged;
  final LoadingRunner runWithLoading;
  final VoidCallback onRequestClose;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _SettingsTab.values.length,
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              indicatorColor: menuFillPrimary,
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
                  icon: Icon(Icons.smart_toy),
                  text: "Pi",
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TabBarView(
              children: [
                SingleChildScrollView(
                  child: _SettingsMenuBody(
                    tab: _SettingsTab.config,
                    os: os,
                    developerMode: developerMode,
                    debugEnabled: debugEnabled,
                    showPrompt: showPrompt,
                    onSettingChanged: onSettingChanged,
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
                    onSettingChanged: onSettingChanged,
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
                    onSettingChanged: onSettingChanged,
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
    required this.onSettingChanged,
    required this.runWithLoading,
    required this.onRequestClose,
  });

  final _SettingsTab tab;
  final ShellOs os;
  final bool developerMode;
  final bool debugEnabled;
  final bool showPrompt;
  final void Function(SettingToggle, bool? value) onSettingChanged;
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
          _SettingsOption(
            label: "Tile grid",
            value: state.tileGrid,
            setting: SettingToggle.debugTileGrid,
          ),
        ];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: switch (tab) {
            _SettingsTab.config => _buildConfigTab(context, state),
            _SettingsTab.debug => _buildDebugTab(context, options),
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
