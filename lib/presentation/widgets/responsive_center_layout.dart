import 'package:flutter/material.dart';

class ResponsiveCenterLayout extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveCenterLayout({
    super.key,
    required this.child,
    this.maxWidth = 800.0, // Lebar maksimal untuk konten web
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}