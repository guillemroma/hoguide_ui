// reminders_card.dart (MODIFICADO)

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
    // Los cambios están aquí, en el widget DashboardCard.
    return DashboardCard(
      // 1. Hacemos el fondo del card transparente.
      color: Colors.transparent,
      // 2. Quitamos la sombra para que se integre perfectamente.
      showShadow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // CAMBIOS PARA COINCIDIR CON LA CAPTURA
              CircleAvatar(
                radius: 28,
                // 1. Se ajusta el color de fondo a un púrpura oscuro
                backgroundColor: const Color(0xFF44394E),
                child: Icon(
                  // 2. Se cambia el ícono a un corazón relleno
                  Icons.favorite,
                  // 3. Se ajusta el color del ícono a un púrpura más claro
                  color: Colors.purple.shade200,
                  size: 28,
                ),
              ),
              const SizedBox(width: 8.0),
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
                  .titleMedium,
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
    );
  }
}