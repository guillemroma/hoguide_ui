import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _launchWhatsApp() async {
    final Uri url = Uri.parse('https://chat.whatsapp.com/D26ArgmVNovFF1DgJT1bVp');
    if (!await launchUrl(url)) {
      throw Exception('No se pudo abrir $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('EEEE, d \'de\' MMMM', 'es').format(now);
    final String capitalizedDate = formattedDate.replaceRange(0, 1, formattedDate[0].toUpperCase());

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // (HEADER) Cabecera rediseñada, más compacta y personal.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 24.0,
                      backgroundColor: Color(0xFF764BA2),
                      child: Text(
                        'A',
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bienvenid@',
                          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          capitalizedDate,
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(999.0),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.string(
                        '''<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2L15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2z"></path></svg>''',
                        colorFilter: ColorFilter.mode(Colors.amber.shade400, BlendMode.srcIn),
                        width: 20, height: 20,
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        '125',
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24.0),

            // Tarjeta principal con degradado, usando el `DashboardCard`
            DashboardCard(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¿Listo para tu chequeo diario?',
                          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Gana 2 Hopoints y acércate a tus metas. Solo te tomará 2 minutos.',
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                color: Colors.indigo.shade200,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24.0),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.indigo.shade600,
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    child: const Text('Rellenar'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),

            // Módulo de Análisis (Bloqueado), usando DottedBorder + DashboardCard
            DottedBorder(
              borderType: BorderType.RRect,
              radius: const Radius.circular(16.0),
              padding: EdgeInsets.zero,
              strokeWidth: 2.0,
              color: Theme.of(context).dividerColor,
              dashPattern: const [8, 4],
              child: DashboardCard(
                color: Theme.of(context).cardColor.withOpacity(0.5),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.lock_outline, size: 32.0, color: Colors.indigo.shade400),
                          const SizedBox(width: 20.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Análisis y Plan de Mejora',
                                  style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  'Desbloquea tu plan personalizado para alcanzar tus metas.',
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    ElevatedButton(
                      onPressed: null,
                      child: const Text('Ver Plan'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24.0),

            // Módulos de Racha y Otros Servicios
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: DashboardCard(
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
                                    ),
                              ),
                              Text(
                                '14 días',
                                style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24.0),
                Expanded(
                  child: DashboardCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Otros Servicios', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4.0),
                        Text('Analíticas, tests y más.', style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                        const SizedBox(height: 12.0),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(onPressed: () {}, child: const Text('Explorar')),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24.0),

            // Módulo de Registros Anteriores
            DashboardCard(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Registros Anteriores', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16.0),
                  _buildRegistroItem(context, date: 'Jueves, 13 de Junio', isCompleted: true),
                  const Divider(height: 24),
                  _buildRegistroItem(context, date: 'Miércoles, 12 de Junio', isPending: true),
                  const Divider(height: 24),
                  _buildRegistroItem(context, date: 'Martes, 11 de Junio', isCompleted: true),
                ],
              ),
            ),
            const SizedBox(height: 24.0),

            // Módulos de Comunidad y Apoyo rediseñados
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: DashboardCard(
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
                          onPressed: _launchWhatsApp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Unirse al grupo'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24.0),
                Expanded(
                  child: DashboardCard(
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
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Ser mecenas')),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // MÉTODO MODIFICADO PARA EL ÚLTIMO REQUERIMIENTO
  Widget _buildRegistroItem(BuildContext context, {required String date, bool isCompleted = false, bool isPending = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(date, style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w600)),
        if (isCompleted)
          ElevatedButton(
            onPressed: () {
              // Acción para ver el registro completado, si se desea en el futuro.
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade100,
              foregroundColor: Colors.green.shade800,
              elevation: 0,
            ),
            child: const Text('Completado'),
          ),
        if (isPending)
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade100,
              foregroundColor: Colors.red.shade800,
              elevation: 0,
            ),
            child: const Text('Rellenar ahora'),
          ),
      ],
    );
  }
}

class DashboardCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Gradient? gradient;
  final Border? border;

  const DashboardCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.gradient,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final defaultPadding = const EdgeInsets.all(24.0);
    return Container(
      width: double.infinity,
      padding: padding ?? defaultPadding,
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).cardColor,
        gradient: gradient,
        borderRadius: BorderRadius.circular(16.0),
        border: border,
        boxShadow: [
          if (gradient == null)
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: child,
    );
  }
}