import 'package:flutter/material.dart';
import 'package:pixelgrid/ui/pixel/pixel_border_painter.dart';

class Modal extends StatelessWidget {
  const Modal({
    required this.title,
    required this.child,
    required this.onClose,
    this.maxWidth = 520,
  });

  final String title;
  final Widget child;
  final VoidCallback onClose;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onClose,
            child: Container(
              color: Colors.black54,
            ),
          ),
        ),
        SafeArea(
          minimum: const EdgeInsets.only(top: 8),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxHeight = constraints.maxHeight * 0.6;
              return Align(
                alignment: const Alignment(0, -0.12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: maxWidth,
                      maxHeight: maxHeight,
                    ),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {},
                      child: CustomPaint(
                        painter: const PixelBorderPainter(
                          borderColor: pixelBorderColor,
                          cornerColor: pixelCornerColor,
                          fillColor: Color(0xFF111111),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Flexible(child: child),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
