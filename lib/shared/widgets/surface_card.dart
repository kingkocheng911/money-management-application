import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class SurfaceCard extends StatelessWidget {
  final Widget child;
  final double? radius;
  final EdgeInsetsGeometry? padding;

  const SurfaceCard({
    super.key,
    required this.child,
    this.radius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: AppTheme.surface(isDark, radius: radius ?? AppTheme.r2XL),
      child: child,
    );
  }
}
