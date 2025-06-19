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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- STATE MANAGEMENT SIMPLIFICADO ---
  bool _isLoading = true;
  String? _authToken;
  int _points = 0;
  int _questionnaireCount = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // --- DATA FETCHING ---
  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final token = await AuthService.getToken();
    if (token == null) {
      _handleApiError({'requiresAuth': true}, 'No autenticado');
      return;
    }

    final userStatsResult = await AuthService.getUserStats();
    
    if (mounted) {
      _processUserStats(userStatsResult);
      setState(() {
        _authToken = token;
        _isLoading = false;
      });
    }
  }

  void _processUserStats(Map<String, dynamic> result) {
    if (result['success']) {
      final data = result['data'];
      setState(() {
        _points = data['points'] ?? 0;
        _questionnaireCount = data['questionnaire_count'] ?? 0;
      });
    } else {
      _handleApiError(result, 'Error al cargar estadísticas del usuario');
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? defaultMessage)),
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Muestra un loader general mientras se obtiene el token y los datos iniciales
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HomeHeader(
                  isLoading: _isLoading,
                  points: _points,
                ),
                const SizedBox(height: 24.0),
                DailyCheckupCard(onFillForm: _onFillDailyForm),
                const SizedBox(height: 24.0),
                StreakSection(
                  isLoading: _isLoading,
                  questionnaireCount: _questionnaireCount,
                ),
                const SizedBox(height: 24.0),
                // La llamada al widget es ahora increíblemente limpia.
                // Nos aseguramos de que el token no sea nulo antes de construirlo.
                if (_authToken != null)
                  LockedFeatureCard(
                    userPoints: _points,
                    authToken: _authToken!, 
                  ),
                const SizedBox(height: 24.0),
                CommunitySupportSection(
                  onJoinWhatsApp: () => _launchURL('https://chat.whatsapp.com/D26ArgmVNovFF1DgJT1bVp'),
                  onSupportProject: () => _launchURL('https://patreon.com/user?u=64960324'),
                ),
              ],
            ),
        ),
    );
  }
}