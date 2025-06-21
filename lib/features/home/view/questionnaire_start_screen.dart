import 'package:flutter/material.dart';

class QuestionnaireStartScreen extends StatefulWidget {
  const QuestionnaireStartScreen({super.key});

  @override
  State<QuestionnaireStartScreen> createState() =>
      _QuestionnaireStartScreenState();
}

class _QuestionnaireStartScreenState extends State<QuestionnaireStartScreen> {
  bool? _isForToday;

  void _onStartButtonPressed() {
    if (_isForToday == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona una opción.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    // Lógica para navegar a la siguiente pantalla del cuestionario
    print('Cuestionario iniciado para: ${_isForToday! ? "Hoy" : "Ayer"}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuestionario Diario'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                '¿Las respuestas que vas a dar son sobre hoy o sobre ayer?',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Esto nos ayuda a contextualizar tus datos con precisión.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _buildChoiceButton(
                context: context,
                label: 'Hoy',
                icon: Icons.wb_sunny_outlined,
                isSelected: _isForToday == true,
                onTap: () {
                  setState(() {
                    _isForToday = true;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildChoiceButton(
                context: context,
                label: 'Ayer',
                icon: Icons.nights_stay_outlined,
                isSelected: _isForToday == false,
                onTap: () {
                  setState(() {
                    _isForToday = false;
                  });
                },
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _onStartButtonPressed,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                child: const Text('Empezar Cuestionario'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor.withOpacity(0.1)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? theme.primaryColor : theme.dividerColor,
            width: isSelected ? 2.0 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected
                    ? theme.primaryColor
                    : theme.colorScheme.onSurface.withOpacity(0.7)),
            const SizedBox(width: 16),
            Text(
              label,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (isSelected)
              CircleAvatar(
                radius: 12,
                backgroundColor: theme.primaryColor,
                child: const Icon(Icons.check, size: 16, color: Colors.white),
              )
            else
              const CircleAvatar(
                radius: 12,
                backgroundColor: Colors.transparent,
              ),
          ],
        ),
      ),
    );
  }
}