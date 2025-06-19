import 'package:flutter/material.dart';
import '../../../common/widgets/dashboard_card.dart';

class StreakSection extends StatelessWidget {
  final bool isLoading;
  final int questionnaireCount;

  const StreakSection({
    super.key,
    required this.isLoading,
    required this.questionnaireCount,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Row(
        children: [
          Icon(Icons.local_fire_department, size: 40.0, color: Colors.amber.shade500),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Racha actual',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                ),
                isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(
                        '$questionnaireCount cuestionarios completados',
                        style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}