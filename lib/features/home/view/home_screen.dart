import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:confetti/confetti.dart'; // Importamos el paquete de confeti

import '../../../services/auth_service.dart';
import '../../../screens/signin_screen.dart';

import '../widgets/home_header.dart';
import '../widgets/daily_checkup_card.dart';
import '../widgets/streak_section.dart';
import '../widgets/locked_feature_card.dart';
import '../widgets/community_support_section.dart';
import '../widgets/patterns_card.dart';
import '../widgets/reminders_card.dart';
import '../view/patterns_screen.dart'; 
import '../../questionnaire/view/date_selection_screen.dart'; // Importamos la pantalla del cuestionario
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatefulWidget {
  // Añadimos el parámetro para saber si mostrar el diálogo
  final bool showSuccessDialog;

  const HomeScreen({
    super.key,
    this.showSuccessDialog = false, // Valor por defecto es no mostrarlo
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- STATE MANAGEMENT ---
  bool _isLoading = true;
  String? _authToken;
  int _points = 0;
  int _questionnaireCount = 0;
  Greeting? _greeting;
  String? _errorMessage;

  // Controlador para la animación de confeti
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    // Inicializamos el controlador
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));

    _loadInitialData();

    // Si se nos indica desde el constructor, mostramos el diálogo de éxito
    if (widget.showSuccessDialog) {
      // Usamos un delay para asegurar que la pantalla está completamente construida
      // antes de mostrar un diálogo sobre ella.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showQuestionnaireSuccessDialog();
      });
    }
  }

  @override
  void dispose() {
    // Es muy importante liberar los recursos del controlador para evitar fugas de memoria
    _confettiController.dispose();
    super.dispose();
  }
  
  // --- DATA FETCHING ---
  Future<void> _loadInitialData() async {
    final token = await AuthService.getToken();
    if (token == null) {
      _handleApiError({'requiresAuth': true}, 'No autenticado');
      return;
    }
    
    final results = await Future.wait([
      AuthService.getUserStats(),
      AuthService.getGreeting(token),
    ]);
    
    final userStatsResult = results[0] as Map<String, dynamic>;
    final greetingResult = results[1] as Greeting?;

    if (mounted) {
      setState(() {
        _authToken = token;
        _greeting = greetingResult;

        if (userStatsResult['success']) {
          final data = userStatsResult['data'];
          _points = data?['points'] ?? 0;
          _questionnaireCount = data?['questionnaire_count'] ?? 0;
          _errorMessage = null;
        } else {
          _handleApiError(userStatsResult, 'Error al cargar estadísticas del usuario');
          _errorMessage = userStatsResult['message'] ?? 'Error desconocido';
        }
        
        _isLoading = false;
      });
    }
  }
  
  // --- UI ACTIONS & HELPERS ---
  void _handleApiError(Map<String, dynamic> result, String defaultMessage) {
    if (result['requiresAuth'] == true) {
      AuthService.logout().then((_) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const SignInScreen()),
            (Route<dynamic> route) => false,
          );
        }
      });
    } else if (mounted) {
      print("Error de API: ${result['message'] ?? defaultMessage}");
    }
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo abrir $urlString')));
    }
  }
  
  void _onFillDailyForm() {
    // Navegamos a la primera pantalla del cuestionario
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const DateSelectionScreen()),
    );
  }

  void _onNavigateToPatterns() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const PatternsScreen()),
    );
  }

  void _showQuestionnaireSuccessDialog() {
    _confettiController.play();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                        tooltip: 'Cerrar',
                      ),
                    ),
                    // AJUSTE (4): Reemplazamos Icon por SvgPicture
                    SvgPicture.string(
                      '''<svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2L15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2z"></path></svg>''',
                      colorFilter: ColorFilter.mode(Colors.amber.shade400, BlendMode.srcIn),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '¡Felicidades!',
                      style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Has ganado 2 Hopoints por completar tu cuestionario diario.',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    // AJUSTE (3): Botón "Genial" eliminado
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Ocurrió un error',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                     _isLoading = true;
                     _errorMessage = null;
                  });
                  _loadInitialData();
                },
                child: const Text('Reintentar'),
              )
            ],
          ),
        ),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeHeader(
            isLoading: false,
            points: _points,
          ),
          const SizedBox(height: 24.0),
          DailyCheckupCard(onFillForm: _onFillDailyForm),
          const SizedBox(height: 24.0),
          if (_greeting != null) ...[
            RemindersCard(greeting: _greeting!),
            const SizedBox(height: 24.0),
          ],
          StreakSection(
            isLoading: false,
            questionnaireCount: _questionnaireCount,
          ),
          const SizedBox(height: 24.0),
          if (_authToken != null)
            LockedFeatureCard(
              userPoints: _points,
              authToken: _authToken!,
            ),
          const SizedBox(height: 24.0),
          PatternsCard(onTap: _onNavigateToPatterns),
          const SizedBox(height: 24.0),
          CommunitySupportSection(
            onJoinWhatsApp: () => _launchURL('https://chat.whatsapp.com/D26ArgmVNovFF1DgJT1bVp'),
            onSupportProject: () => _launchURL('https://patreon.com/user?u=64960324'),
          ),
        ],
      ),
    );
  }
}