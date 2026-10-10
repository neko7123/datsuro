import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class GlassCard extends StatelessWidget {
  const GlassCard(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(16)});
  final Widget child;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xF726342B)
                : Colors.white.withValues(alpha: .94),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: Colors.white.withValues(alpha: .72), width: 1),
            boxShadow: [
              BoxShadow(
                  color: forest.withValues(alpha: .035),
                  blurRadius: 16,
                  offset: const Offset(0, 5))
            ],
          ),
          child: Material(color: Colors.transparent, child: child),
        ),
      );
}
