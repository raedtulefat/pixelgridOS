import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:pixelgrid/pixelgrid.dart';
import 'package:pixelgrid/pixelgrid/control_center/control_center_overlay.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Flame.device.fullScreen();

  final pixelGrid = PixelGrid();

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
              behavior: HitTestBehavior.opaque,
              onPointerSignal: (event) => pixelGrid.handlePointerSignal(event),
              onPointerDown: pixelGrid.handlePointerDown,
              onPointerMove: pixelGrid.handlePointerMove,
              onPointerUp: pixelGrid.handlePointerUp,
              onPointerCancel: pixelGrid.handlePointerCancel,
              child: GameWidget(game: pixelGrid),
            ),
            ControlCenterOverlay(pixelGrid: pixelGrid),
          ],
        ),
      ),
    ),
  );
}
