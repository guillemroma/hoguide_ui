import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_service.dart';
import 'signin_screen.dart'; // Importa la SignInScreen

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _launchWhatsApp() async {
    final Uri url = Uri.parse('https://chat.whatsapp.com/D26ArgmVNovFF1DgJT1bVp');
    if (!await launchUrl(url)) {
      throw Exception('No se pudo abrir $url');
    }
  }

  // Se mantiene como referencia, aunque Otros Servicios se haya eliminado de la UI principal
  void _onOtherServicesTap() {
    print('Otros Servicios clickeado!');
  }

  void _onActionItemsTap() {
    print('Action Items clickeado!');
  }

  // Nueva función para lanzar la URL de Patreon
  Future<void> _launchPatreon() async {
    final Uri url = Uri.parse('https://patreon.com/user?u=64960324');
    if (!await launchUrl(url)) {
      throw Exception('No se pudo abrir $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _HomeScreenHeader(),
            const SizedBox(height: 24.0),

            const _DailyChechupCard(),
            const SizedBox(height: 24.0),

            const _StreakAndServicesSection(),
            const SizedBox(height: 24.0),

            _LockedFeatureCard(
                onTap: _onActionItemsTap),
            const SizedBox(height: 24.0),

            // Pasa la nueva función _launchPatreon
            _CommunityAndSupportSection(
                onJoinWhatsApp: _launchWhatsApp,
                onSupportProject: _launchPatreon), // Pasa la función de launch Patreon
          ],
        ),
      ),
    );
  }
}

// --- Widgets Reutilizables ---

class DashboardCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Gradient? gradient;
  final Border? border;
  final bool showShadow;
  final VoidCallback? onTap;

  const DashboardCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.gradient,
    this.border,
    this.showShadow = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final defaultPadding = const EdgeInsets.all(24.0);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        width: double.infinity,
        padding: padding ?? defaultPadding,
        decoration: BoxDecoration(
          color: color ?? Theme.of(context).cardColor,
          gradient: gradient,
          borderRadius: BorderRadius.circular(16.0),
          border: border,
          boxShadow: [
            if (showShadow && gradient == null)
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class _HomeScreenHeader extends StatefulWidget {
  const _HomeScreenHeader({super.key});

  @override
  State<_HomeScreenHeader> createState() => _HomeScreenHeaderState();
}

class _HomeScreenHeaderState extends State<_HomeScreenHeader> {
  int _points = 0;
  bool _isLoadingPoints = true;

  @override
  void initState() {
    super.initState();
    _loadUserStats();
  }

  Future<void> _loadUserStats() async {
    setState(() {
      _isLoadingPoints = true;
    });
    final result = await AuthService.getUserStats();
    if (mounted) {
      if (result['success']) {
        setState(() {
          _points = result['data']['points'] ?? 0;
          _isLoadingPoints = false;
        });
      } else {
        print('Error cargando puntos: ${result['message']}');
        setState(() {
          _isLoadingPoints = false;
        });
        if (result['requiresAuth'] == true) {
          await AuthService.logout();
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const SignInScreen()),
              (Route<dynamic> route) => false,
            );
          }
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al cargar puntos: ${result['message']}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('EEEE, d \'de\' MMMM', 'es').format(now);
    final String capitalizedDate = formattedDate.replaceRange(0, 1, formattedDate[0].toUpperCase());

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
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
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 8.0),
              _isLoadingPoints
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2)
                    )
                  : Text(
                      '$_points',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                    ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DailyChechupCard extends StatelessWidget {
  const _DailyChechupCard();

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
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.indigo.shade600,
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                textStyle: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontSize: 18,
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

class _LockedFeatureCard extends StatelessWidget {
  final VoidCallback? onTap;
  const _LockedFeatureCard({this.onTap});

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      borderType: BorderType.RRect,
      radius: const Radius.circular(16.0),
      padding: EdgeInsets.zero,
      strokeWidth: 2.0,
      color: Theme.of(context).dividerColor,
      dashPattern: const [8, 4],
      child: DashboardCard(
        color: Theme.of(context).cardColor.withOpacity(0.5),
        showShadow: false,
        onTap: onTap,
        child: Row(
          children: [
            Icon(Icons.lock_outline, size: 32.0, color: Colors.indigo.shade400),
            const SizedBox(width: 20.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Action Items',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Consigue 14 Hopoints y desbloquea tu plan personalizado para alcanzar tus metas.',
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
    );
  }
}

class _StreakAndServicesSection extends StatefulWidget {
  // onOtherServicesTap ya no es necesario aquí si la tarjeta "Otros Servicios" se elimina
  const _StreakAndServicesSection({super.key}); // Se elimina el parámetro

  @override
  State<_StreakAndServicesSection> createState() => _StreakAndServicesSectionState();
}

class _StreakAndServicesSectionState extends State<_StreakAndServicesSection> {
  int _questionnaireCount = 0;
  bool _isLoadingStreak = true;

  @override
  void initState() {
    super.initState();
    _loadUserStats();
  }

  Future<void> _loadUserStats() async {
    setState(() {
      _isLoadingStreak = true;
    });
    final result = await AuthService.getUserStats();
    if (mounted) {
      if (result['success']) {
        setState(() {
          _questionnaireCount = result['data']['questionnaire_count'] ?? 0;
          _isLoadingStreak = false;
        });
      } else {
        print('Error cargando racha: ${result['message']}');
        setState(() {
          _isLoadingStreak = false;
        });
        if (result['requiresAuth'] == true) {
          await AuthService.logout();
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const SignInScreen()),
              (Route<dynamic> route) => false,
            );
          }
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al cargar racha: ${result['message']}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardCard(
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
                    _isLoadingStreak
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2)
                          )
                        : Text(
                            '$_questionnaireCount cuestionarios completados',
                            style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // ELIMINADO: Ya no hay el segundo DashboardCard para "Otros Servicios" aquí.
        // Por lo tanto, el SizedBox de 24.0 que lo separaba también se elimina implícitamente
      ],
    );
  }
}

class _CommunityAndSupportSection extends StatelessWidget {
  final VoidCallback onJoinWhatsApp;
  final VoidCallback onSupportProject; // Nuevo parámetro para la acción del botón "Ser mecenas"

  const _CommunityAndSupportSection({
    super.key,
    required this.onJoinWhatsApp,
    required this.onSupportProject, // Requerir la nueva función
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
                  onPressed: onSupportProject, // Asignar la función pasada por parámetro
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