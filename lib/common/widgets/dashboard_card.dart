import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Gradient? gradient;
  final Border? border;
  final bool showShadow;
  final VoidCallback? onTap;

  const DashboardCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.gradient,
    this.border,
    this.showShadow = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final defaultPadding = const EdgeInsets.all(24.0);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        width: double.infinity,
        padding: padding ?? defaultPadding,
        decoration: BoxDecoration(
          color: color ?? Theme.of(context).cardColor,
          gradient: gradient,
          borderRadius: BorderRadius.circular(16.0),
          border: border,
          boxShadow: [
            if (showShadow && gradient == null)
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: child,
      ),
    );
  }
}