import 'package:flutter/material.dart';
import '../../../common/widgets/dashboard_card.dart';
import 'dart:convert';
import './question_section_screen.dart';
import '../../../services/auth_service.dart'; // NOVEDAD: Importamos el servicio

// Usamos un enum para gestionar la selección de forma clara y segura.
enum DateOption { today, yesterday }

class DateSelectionScreen extends StatefulWidget {
  const DateSelectionScreen({super.key});

  @override
  State<DateSelectionScreen> createState() => _DateSelectionScreenState();
}

class _DateSelectionScreenState extends State<DateSelectionScreen> {
  DateOption? _selectedOption;

  // NOVEDAD: Estado para controlar la carga y si existe la sección de hábitos
  bool _isLoading = true;
  bool _hasHabitsSection = false;

  @override
  void initState() {
    super.initState();
    // NOVEDAD: Al iniciar la pantalla, comprobamos las secciones
    _checkHabits();
  }

  Future<void> _checkHabits() async {
    final hasHabits = await AuthService.checkHabitsSection();
    if (mounted) {
      setState(() {
        _hasHabitsSection = hasHabits;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuestionario Diario'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      // NOVEDAD: Mostramos un indicador de carga mientras comprobamos las secciones
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¿A qué día corresponden tus respuestas?',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                      'Elige una opción para continuar.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                    ),
                  const SizedBox(height: 32),
                  _buildOptionCard(
                    title: 'Hoy',
                    subtitle: 'Registrar mis métricas del día de hoy.',
                    option: DateOption.today,
                  ),
                  const SizedBox(height: 16),
                  _buildOptionCard(
                    title: 'Ayer',
                    subtitle: 'Registrar las métricas correspondientes a ayer.',
                    option: DateOption.yesterday,
                  ),
                  const Spacer(),
                  _buildNextButton(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  /// Un widget que construye una tarjeta de opción.
  /// Reutiliza DashboardCard para mantener la consistencia del UI.
  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required DateOption option,
  }) {
    final bool isSelected = _selectedOption == option;
    final theme = Theme.of(context);

    return DashboardCard(
      onTap: () {
        setState(() {
          _selectedOption = option;
        });
      },
      border: isSelected
          ? Border.all(color: theme.primaryColor, width: 2)
          : Border.all(color: theme.dividerColor),
      color: isSelected ? theme.primaryColor.withOpacity(0.05) : theme.cardColor,
      showShadow: false,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                     color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  )
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          if (isSelected)
            Icon(Icons.check_circle, color: theme.primaryColor)
          else
            Icon(Icons.radio_button_unchecked_rounded, color: theme.dividerColor),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        // NOVEDAD: El botón está deshabilitado si se está cargando o no hay opción seleccionada
        onPressed: _isLoading || _selectedOption == null
            ? null
            : () {
                final bool fromToday = _selectedOption == DateOption.today;
                final Map<String, dynamic> initialPayload = {
                  'from_today': fromToday,
                  'answers': [], // La lista de respuestas empieza vacía
                };

                print('--- Payload al salir de DateSelectionScreen ---');
                JsonEncoder encoder = const JsonEncoder.withIndent('  ');
                print(encoder.convert(initialPayload));

                // NOVEDAD: Navegamos pasando el flag 'hasHabitsSection' y sin 'progress'
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => QuestionSectionScreen(
                      vertical: 'sueño', // La primera sección siempre es 'sueño'
                      payload: initialPayload,
                      hasHabitsSection: _hasHabitsSection, // Pasamos el resultado del check
                    ),
                  ),
                );
              },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        // NOVEDAD: El texto del botón ahora es fijo y claro.
        child: const Text(
          'Empezar cuestionario',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}