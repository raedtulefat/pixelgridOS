import 'dart:ui';

import 'package:flame/components.dart';

void renderOutlinedSprite({
  required Canvas canvas,
  required Sprite sprite,
  required Vector2 position,
  required Vector2 size,
  required Color outlineColor,
  double outlineWidth = 2.0,
  Paint? spritePaint,
}) {
  if (outlineWidth <= 0) {
    sprite.render(
      canvas,
      position: position,
      size: size,
      overridePaint: spritePaint,
    );
    return;
  }

  final outlinePaint = Paint()
    ..colorFilter = ColorFilter.mode(outlineColor, BlendMode.srcIn);
  if (spritePaint != null) {
    outlinePaint
      ..isAntiAlias = spritePaint.isAntiAlias
      ..filterQuality = spritePaint.filterQuality;
  }

  final offsets = <Offset>[
    Offset(-outlineWidth, -outlineWidth),
    Offset(0, -outlineWidth),
    Offset(outlineWidth, -outlineWidth),
    Offset(-outlineWidth, 0),
    Offset(outlineWidth, 0),
    Offset(-outlineWidth, outlineWidth),
    Offset(0, outlineWidth),
    Offset(outlineWidth, outlineWidth),
  ];

  for (final offset in offsets) {
    sprite.render(
      canvas,
      position: Vector2(position.x + offset.dx, position.y + offset.dy),
      size: size,
      overridePaint: outlinePaint,
    );
  }

  sprite.render(
    canvas,
    position: position,
    size: size,
    overridePaint: spritePaint,
  );
}
