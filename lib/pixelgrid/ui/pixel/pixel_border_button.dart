import 'package:flutter/material.dart';

import 'pixel_border_painter.dart';

class PixelBorderButton extends StatefulWidget {
  const PixelBorderButton({
    super.key,
    required this.label,
    required this.fillColor,
    required this.textColor,
    this.onPressed,
    this.minHeight = 48,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  final String label;
  final Color fillColor;
  final Color textColor;
  final VoidCallback? onPressed;
  final double minHeight;
  final EdgeInsets padding;

  @override
  State<PixelBorderButton> createState() => _PixelBorderButtonState();
}

class _PixelBorderButtonState extends State<PixelBorderButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final effectiveBorderOpacity = enabled ? 1.0 : 0.5;
    Color fill = widget.fillColor;
    if (!enabled) {
      fill = _desaturate(fill, 0.35);
    } else if (_pressed) {
      fill = _shiftLightness(fill, -0.08);
    } else if (_hovered) {
      fill = _shiftLightness(fill, 0.06);
    }
    final textColor = widget.textColor.withValues(
      alpha: enabled ? 1 : 0.6,
    );

    final child = CustomPaint(
      painter: PixelBorderPainter(
        borderColor: pixelBorderColor.withValues(
          alpha: effectiveBorderOpacity,
        ),
        cornerColor: pixelCornerColor.withValues(
          alpha: effectiveBorderOpacity,
        ),
        fillColor: fill,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: widget.minHeight),
        child: Padding(
          padding: widget.padding,
          child: Center(
            child: Text(
              widget.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ).copyWith(color: textColor),
            ),
          ),
        ),
      ),
    );

    if (!enabled) {
      return child;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() {
        _hovered = false;
        _pressed = false;
      }),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onPressed,
        child: child,
      ),
    );
  }
}

Color _shiftLightness(Color color, double delta) {
  final hsl = HSLColor.fromColor(color);
  final nextLightness = (hsl.lightness + delta).clamp(0.0, 1.0).toDouble();
  return hsl.withLightness(nextLightness).toColor();
}

Color _desaturate(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  final nextSaturation =
      (hsl.saturation * (1 - amount)).clamp(0.0, 1.0).toDouble();
  final nextLightness =
      (hsl.lightness + 0.05 * amount).clamp(0.0, 1.0).toDouble();
  return hsl
      .withSaturation(nextSaturation)
      .withLightness(nextLightness)
      .toColor();
}
