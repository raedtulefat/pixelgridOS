import 'package:flutter/material.dart';

const Color pixelBorderColor = Color(0xFF5B5F68);
const Color pixelCornerColor = Color(0xFF8A7354);
const double _pixelBorderThickness = 4;
const double _pixelCornerSize = 8;

class PixelBorderPainter extends CustomPainter {
  const PixelBorderPainter({
    required this.borderColor,
    required this.cornerColor,
    required this.fillColor,
  });

  final Color borderColor;
  final Color cornerColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    final framePaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _pixelBorderThickness;
    final cornerPaint = Paint()
      ..color = cornerColor
      ..style = PaintingStyle.fill;
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final frameRect = Rect.fromLTWH(
      _pixelBorderThickness / 2,
      _pixelBorderThickness / 2,
      size.width - _pixelBorderThickness,
      size.height - _pixelBorderThickness,
    );
    canvas.drawRect(frameRect, framePaint);

    final fillRect = Rect.fromLTWH(
      _pixelBorderThickness,
      _pixelBorderThickness,
      size.width - _pixelBorderThickness * 2,
      size.height - _pixelBorderThickness * 2,
    );
    canvas.drawRect(fillRect, fillPaint);

    // Corner blocks sit atop the border for a chunky pixel feel.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, _pixelCornerSize, _pixelCornerSize),
      cornerPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width - _pixelCornerSize,
        0,
        _pixelCornerSize,
        _pixelCornerSize,
      ),
      cornerPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        size.height - _pixelCornerSize,
        _pixelCornerSize,
        _pixelCornerSize,
      ),
      cornerPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width - _pixelCornerSize,
        size.height - _pixelCornerSize,
        _pixelCornerSize,
        _pixelCornerSize,
      ),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant PixelBorderPainter oldDelegate) {
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.cornerColor != cornerColor ||
        oldDelegate.fillColor != fillColor;
  }
}
