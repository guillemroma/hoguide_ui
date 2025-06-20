import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

import '../../../services/auth_service.dart';
import '../../../screens/signin_screen.dart';

import '../widgets/home_header.dart';
import '../widgets/daily_checkup_card.dart';
import '../widgets/streak_section.dart';
import '../widgets/locked_feature_card.dart';
import '../widgets/community_support_section.dart';
import '../widgets/patterns_card.dart';
import '../widgets/reminders_card.dart'; // IMPORTADO el nuevo widget
import '../view/patterns_screen.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- STATE MANAGEMENT ---
  bool _isLoading = true;
  String? _authToken;
  int _points = 0;
  int _questionnaireCount = 0;
  Greeting? _greeting; // NUEVO estado para el recordatorio
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // --- DATA FETCHING ---
  Future<void> _loadInitialData() async {
    final token = await AuthService.getToken();
    if (token == null) {
      _handleApiError({'requiresAuth': true}, 'No autenticado');
      return;
    }
    
    // Obtenemos todos los datos en paralelo para mejorar el rendimiento
    final results = await Future.wait([
      AuthService.getUserStats(),
      AuthService.getGreeting(token),
    ]);
    
    final userStatsResult = results[0] as Map<String, dynamic>;
    final greetingResult = results[1] as Greeting?;

    if (mounted) {
      setState(() {
        _authToken = token;
        _greeting = greetingResult; // Guardamos el recordatorio

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
    print('Navegar a la pantalla del cuestionario diario');
  }

  void _onNavigateToPatterns() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const PatternsScreen()),
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

          // AÑADIDO: Muestra la tarjeta de recordatorios solo si existe.
          if (_greeting != null) ...[
            RemindersCard(greeting: _greeting!),
            const SizedBox(height: 24.0),
          ],

          DailyCheckupCard(onFillForm: _onFillDailyForm),
          const SizedBox(height: 24.0),
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
