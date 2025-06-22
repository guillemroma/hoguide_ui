// lib/features/home/widgets/patterns_card.dart

import 'package:flutter/material.dart';
import '../../../common/widgets/dashboard_card.dart';

class PatternsCard extends StatelessWidget {
  final VoidCallback onTap;

  const PatternsCard({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // La acción de onTap ya se está aplicando a la tarjeta entera, lo cual es perfecto.
    return DashboardCard(
      onTap: onTap,
      child: Row(
        children: [
          // Icono a la izquierda
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.purple.withOpacity(0.1),
            child: Icon(
              Icons.auto_awesome_mosaic_outlined,
              color: Colors.purple.shade600,
              size: 28,
            ),
          ),
          const SizedBox(width: 16.0),
          // Título y subtítulo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Patrones',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Analiza tus patrones de comportamiento.',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16.0),
          // Botón de icono de flecha
          Container(
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              // AJUSTE: Cambiamos onTap por null para que el botón no sea interactivo.
              onPressed: null,
              icon: Icon(Icons.arrow_forward, color: Colors.purple.shade700),
              tooltip: 'Ver Patrones',
            ),
          ),
        ],
      ),
    );
  }
}