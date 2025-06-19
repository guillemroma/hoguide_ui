import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../common/widgets/dashboard_card.dart';

class CommunitySupportSection extends StatelessWidget {
  final VoidCallback onJoinWhatsApp;
  final VoidCallback onSupportProject;

  const CommunitySupportSection({
    super.key,
    required this.onJoinWhatsApp,
    required this.onSupportProject,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardCard(
          color: const Color(0xFFE6F8F0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.green,
                child: SvgPicture.string(
                  '''<svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" viewBox="0 0 24 24" fill="white"><path d="M.057 24l1.687-6.163c-1.041-1.804-1.588-3.849-1.587-5.946.003-6.556 5.338-11.891 11.893-11.891 3.181.001 6.167 1.24 8.413 3.488 2.245 2.248 3.481 5.236 3.48 8.414-.003 6.557-5.338 11.892-11.894 11.892-1.99-.001-3.951-.5-5.688-1.448l-6.305 1.654zm6.597-3.807c1.676.995 3.276 1.591 5.392 1.592 5.448 0 9.886-4.434 9.889-9.885.002-5.462-4.415-9.89-9.881-9.892-5.452 0-9.887 4.434-9.889 9.884-.001 2.225.651 4.315 1.731 6.086l-1.096 4.022 4.13-1.082z"/></svg>''',
                ),
              ),
              const SizedBox(height: 12.0),
              Text(
                'Únete a la Comunidad',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: onJoinWhatsApp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Unirse al grupo'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24.0),
        DashboardCard(
          color: const Color(0xFFFFF0F0),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: Colors.red,
                child: Icon(Icons.favorite, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 12.0),
              Text(
                'Apoya el Proyecto',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                  onPressed: onSupportProject,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Ser mecenas')),
            ],
          ),
        ),
      ],
    );
  }
}