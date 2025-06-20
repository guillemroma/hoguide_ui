import 'package:flutter/material.dart';
import '../../../common/widgets/dashboard_card.dart';

class DailyCheckupCard extends StatelessWidget {
  final VoidCallback onFillForm;

  const DailyCheckupCard({
    super.key, 
    required this.onFillForm
  });

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      gradient: const LinearGradient(
        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila que contiene el título principal y el nuevo botón de icono.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '¿Listo para rellenar tu cuestionario diario?',
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
              ),
              const SizedBox(width: 16),
              // El nuevo botón de icono circular.
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: onFillForm,
                  icon: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                  ),
                  tooltip: 'Rellenar cuestionario',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Text(
            'Gana 2 Hopoints y acércate a tus metas. Solo te tomará 2 minutos.',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
          ),
        ],
      ),
    );
  }
}
