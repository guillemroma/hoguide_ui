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
          Text(
            '¿Listo para rellenar tu cuestionario diario?',
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Gana 2 Hopoints y acércate a tus metas. Solo te tomará 2 minutos.',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
          ),
          const SizedBox(height: 24.0),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: onFillForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.indigo.shade600,
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                textStyle: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  color: Colors.indigo.shade600,
                  fontWeight: FontWeight.bold,
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Rellenar'),
            ),
          ),
        ],
      ),
    );
  }
}