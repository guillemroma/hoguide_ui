import 'package:flutter/material.dart'; // <-- ¡IMPORTANTE! Añade esta línea

// Widget reutilizable para las tarjetas del dashboard
class DashboardCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color; // Para poder sobreescribir el color
  final Gradient? gradient; // Para la tarjeta principal

  const DashboardCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24.0),
    this.color,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).cardColor,
        gradient: gradient,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          // No aplicamos sombra si la tarjeta tiene un degradado
          if (gradient == null)
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: child,
    );
  }
}
