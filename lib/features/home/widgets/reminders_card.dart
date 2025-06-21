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
    // UI-UPDATE: Se envuelve la tarjeta en un Container para crear el borde degradado.
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Colors.amber,
            Colors.pink,
            Colors.purple,
          ],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
      padding: const EdgeInsets.all(1.5), // El grosor del borde
      child: DashboardCard(
        // Se elimina el color explícito para usar el del tema.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // UI-UPDATE: Icono actualizado a una estrella.
                CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.pink.withOpacity(0.1),
                    child: Icon(
                    Icons.favorite_border,
                    color: Colors.pink.shade400,
                    size: 28,
                    ),
                ),
                const SizedBox(width: 8.0),
                // UI-UPDATE: Título actualizado.
                Text(
                  'Recordatorios',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Un día como hoy, estuviste agardecid@ por...',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
            ),
            const Divider(height: 32),
            Center(
              child: Text(
                '"${greeting.content}"',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontStyle: FontStyle.italic),
              ),
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
      ),
    );
  }
}
