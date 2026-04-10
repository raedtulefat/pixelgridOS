import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// A custom painter that draws an outline around the non-transparent pixels of an image.
///
/// This painter works by drawing the provided [image] multiple times, slightly offset
/// in various directions and colored with the [outlineColor]. This creates a silhouette
/// effect. Finally, it draws the original image on top.
class ActorOutlinePainter extends CustomPainter {
  /// The image to draw and outline.
  final ui.Image image;

  /// The width of the outline.
  final double outlineWidth;

  /// The color of the outline.
  final Color outlineColor;

  /// Creates a painter that outlines an image.
  const ActorOutlinePainter({
    required this.image,
    this.outlineWidth = 2.0,
    this.outlineColor = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint outlinePaint = Paint()
      ..colorFilter = ColorFilter.mode(outlineColor, BlendMode.srcIn);

    // This list of offsets will determine the directions in which the image is drawn
    // to create the outline. It includes horizontal, vertical, and diagonal offsets
    // to create a solid 2px border.
    final List<Offset> offsets = [
      // Cardinals
      Offset(-outlineWidth, 0), // Left
      Offset(outlineWidth, 0), // Right
      Offset(0, -outlineWidth), // Top
      Offset(0, outlineWidth), // Bottom
      // Diagonals
      Offset(-outlineWidth, -outlineWidth), // Top-Left
      Offset(outlineWidth, -outlineWidth), // Top-Right
      Offset(-outlineWidth, outlineWidth), // Bottom-Left
      Offset(outlineWidth, outlineWidth), // Bottom-Right
    ];

    // Draw the image shifted in each direction to create the outline.
    for (final offset in offsets) {
      canvas.drawImage(image, offset, outlinePaint);
    }

    // Draw the original image on top of the outlines.
    canvas.drawImage(image, Offset.zero, Paint());
  }

  @override
  bool shouldRepaint(covariant ActorOutlinePainter oldDelegate) {
    return image != oldDelegate.image ||
        outlineWidth != oldDelegate.outlineWidth ||
        outlineColor != oldDelegate.outlineColor;
  }
}
