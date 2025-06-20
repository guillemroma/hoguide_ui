import 'package:flutter/material.dart';

import '../../../common/widgets/dashboard_card.dart';
import '../../../services/auth_service.dart';

class PatternsScreen extends StatefulWidget {
  const PatternsScreen({super.key});

  @override
  State<PatternsScreen> createState() => _PatternsScreenState();
}

class _PatternsScreenState extends State<PatternsScreen> {
  late Future<List<Trend>> _trendsFuture;

  @override
  void initState() {
    super.initState();
    _trendsFuture = _fetchTrends();
  }

  Future<List<Trend>> _fetchTrends() async {
    final token = await AuthService.getToken();
    if (token != null) {
      return AuthService.getTrends(token);
    } else {
      // Lanza un error si el usuario no está autenticado
      throw Exception('Usuario no autenticado');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patrones'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: FutureBuilder<List<Trend>>(
        future: _trendsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
                child: Text('Error al cargar los patrones.'));
          }

          final trends = snapshot.data;
          if (trends == null || trends.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 64, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
                    const SizedBox(height: 16),
                    Text(
                      'Aún no se han detectado patrones.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            );
          }

          // Si hay datos, muestra la lista
          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: trends.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final trend = trends[index];
              return DashboardCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.insights, color: Colors.purple.shade300, size: 28),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            trend.name,
                            style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Detectado el: ${trend.reportDate}',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                    ),
                    const Divider(height: 24),
                    Text(
                      trend.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
