import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:game_shell/os.dart';
import 'package:game_shell/menus/menu_overlay.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Flame.device.fullScreen();

  final os = ShellOs();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        if (child == null) {
          return const SizedBox.shrink();
        }
        return MediaQuery.withNoTextScaling(child: child);
      },
      home: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Listener(
              onPointerSignal: (event) => os.handlePointerSignal(event),
              onPointerDown: os.handlePointerDown,
              onPointerMove: os.handlePointerMove,
              onPointerUp: os.handlePointerUp,
              onPointerCancel: os.handlePointerCancel,
              child: GameWidget(game: os),
            ),
            MenuOverlay(os: os),
          ],
        ),
      ),
    ),
  );
}
