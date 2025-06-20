import 'package:flutter/material.dart';
import '../../../common/widgets/dashboard_card.dart';
import '../../../services/auth_service.dart';

class RemindersCard extends StatelessWidget {
  final Greeting greeting;

  const RemindersCard({
    super.key,
    required this.greeting,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      color: Colors.pink.shade50.withOpacity(0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icono a la izquierda
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.pink.withOpacity(0.1),
                child: Icon(
                  Icons.favorite_border,
                  color: Colors.pink.shade400,
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
                      'Recordatorios',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Un día como hoy, estuviste agradecido por...',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          Text(
            greeting.content,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              greeting.date,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
