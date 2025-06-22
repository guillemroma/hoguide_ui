import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../models/question_model.dart';
import 'package:flutter/cupertino.dart';
import '../../../features/home/view/home_screen.dart';


class _TimeDuration {
  int hours;
  int minutes;
  _TimeDuration(this.hours, this.minutes);
}

class QuestionSectionScreen extends StatefulWidget {
  final String vertical;
  final Map<String, dynamic> payload;
  final String progress;

  const QuestionSectionScreen({
    super.key,
    required this.vertical,
    required this.payload,
    required this.progress,
  });

  @override
  State<QuestionSectionScreen> createState() => _QuestionSectionScreenState();
}

class _QuestionSectionScreenState extends State<QuestionSectionScreen> {
  bool _isSubmitting = false;
  bool _isLoading = true;
  List<Question> _questions = [];
  String? _errorMessage;
  final Map<int, dynamic> _answers = {};
  
  final List<String> sections = const ['sueño', 'ejercicio', 'nutricion', 'bienestar_emocional'];

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    final result = await AuthService.getQuestions(widget.vertical);
    if (mounted) {
      setState(() {
        if (result['success']) {
          _questions = result['data'];
          // NOVEDAD: Inicializamos las respuestas con valores por defecto
          _initializeAnswers(); 
        } else {
          _errorMessage = result['message'];
        }
        _isLoading = false;
      });
    }
  }

  // NOVEDAD: Este método pre-carga el mapa de respuestas
  void _initializeAnswers() {
    for (var question in _questions) {
      switch (question.answerType) {
        case 'duration':
          // El rodillo empezará en 0 horas y 0 minutos
          _answers[question.id] = _TimeDuration(0, 0);
          break;
        case 'slider':
          // El slider empezará en 0.0
          _answers[question.id] = 0.0;
          break;
        case 'text_form_field':
          _answers[question.id] = '';
          break;
        case 'checkbox':
          _answers[question.id] = <String>{};
          break;
        default:
          // Para otros tipos, no asignamos valor por defecto
          break;
      }
    }
  }

  // --- MÉTODOS PARA MANEJAR RESPUESTAS (sin cambios) ---

  void _handleSliderChange(int questionId, double value) {
    setState(() { _answers[questionId] = value; });
  }

  void _handleCheckboxChange(int questionId, bool? isSelected, String option) {
    setState(() {
      final currentAnswers = _answers.putIfAbsent(questionId, () => <String>{});
      if (isSelected == true) { currentAnswers.add(option); } 
      else { currentAnswers.remove(option); }
    });
  }
  
  void _handleRadioChange(int questionId, String? value) {
    setState(() {
      if(value != null) { _answers[questionId] = {value}; }
    });
  }
  
  void _handleDurationChange(int questionId, {int? hours, int? minutes}) {
    setState(() {
      final currentValue = _answers[questionId] as _TimeDuration;
      if (hours != null) { currentValue.hours = hours; }
      if (minutes != null) { currentValue.minutes = minutes; }
    });
  }

  void _handleTextChange(int questionId, String value) {
    setState(() { _answers[questionId] = value; });
  }

  // --- LÓGICA DE NAVEGACIÓN Y ENVÍO FINAL (sin cambios) ---
  
  void _onNext() async {
    // ... (Este método no necesita cambios)
    final currentIndex = sections.indexOf(widget.vertical);
    final isLastSection = currentIndex == sections.length - 1;

    final List<Map<String, dynamic>> formattedAnswers = [];
    _answers.forEach((questionId, answerValue) {
      List<String> content = [];
      if (answerValue is double) {
        content = [answerValue.toStringAsFixed(1)];
      } else if (answerValue is Set<String>) {
        content = answerValue.toList();
      } else if (answerValue is _TimeDuration) {
        final double totalHours = answerValue.hours + (answerValue.minutes / 60.0);
        content = [totalHours.toStringAsFixed(2)];
      } else if (answerValue is String && answerValue.isNotEmpty) {
        content = [answerValue];
      }
      
      if (content.isNotEmpty) {
        formattedAnswers.add({ 'question_id': questionId, 'content': content });
      }
    });
    
    final sectionPayload = { 'vertical': widget.vertical, 'answers': formattedAnswers };
    final updatedPayload = Map<String, dynamic>.from(widget.payload);
    (updatedPayload['answers'] as List).add(sectionPayload);
    
    print('--- Payload al salir de ${widget.vertical.toUpperCase()} ---');
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    print(encoder.convert(updatedPayload));

    if (!isLastSection) {
      final nextSection = sections[currentIndex + 1];
      final nextProgress = '${currentIndex + 3}/5';
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => QuestionSectionScreen(
            vertical: nextSection,
            payload: updatedPayload,
            progress: nextProgress,
          ),
        ),
      );
    } else {
      setState(() { _isSubmitting = true; });
      final result = await AuthService.postAnswers(updatedPayload);
      if (!mounted) return;
      setState(() { _isSubmitting = false; });
      if (result['success']) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen(showSuccessDialog: true)),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Error al enviar. Inténtalo de nuevo.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- WIDGETS DE UI ---

  // ... (build, _buildBody, _buildQuestionWidget y otros no necesitan cambios)
  @override
  Widget build(BuildContext context) {
    final isLastSection = sections.indexOf(widget.vertical) == sections.length - 1;
    return Scaffold(
      appBar: AppBar(
        title: Text('Cuestionario: ${widget.vertical.toUpperCase()}'),
        actions: [
          if (isLastSection)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              tooltip: 'Salir del cuestionario',
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) { return const Center(child: CircularProgressIndicator()); }
    if (_errorMessage != null) { return Center(child: Text('Error: $_errorMessage')); }
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(24.0),
            itemCount: _questions.length,
            itemBuilder: (context, index) {
              final question = _questions[index];
              return _buildQuestionWidget(question);
            },
          ),
        ),
        _buildNextButton(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildQuestionWidget(Question question) {
    Widget questionInput;
    if (question.answerType == 'text_form_field') {
      questionInput = _buildTextFieldQuestion(question);
    } else if (question.answerType == 'duration') {
      questionInput = _buildDurationPicker(question);
    } else if (question.answerType == 'slider') {
      questionInput = _buildSliderQuestion(question);
    } else if (question.answerType == 'checkbox') {
      if (question.content.contains('(puedes marcar varias opciones)')) {
        questionInput = _buildCheckboxQuestion(question);
      } else {
        questionInput = _buildRadioQuestion(question);
      }
    } else {
      questionInput = Text('Tipo de pregunta no soportado: ${question.answerType}');
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question.content, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          questionInput,
        ],
      ),
    );
  }

  Widget _buildTextFieldQuestion(Question question) {
    return TextFormField(
      initialValue: _answers[question.id] as String?,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Escribe tu respuesta...',
      ),
      onChanged: (value) => _handleTextChange(question.id, value),
      maxLines: 3,
    );
  }

  // AJUSTE: El rodillo ahora lee el valor inicial del mapa _answers
  Widget _buildDurationPicker(Question question) {
    final theme = Theme.of(context);
    // Ya no usamos putIfAbsent, el valor está garantizado
    final currentValue = _answers[question.id] as _TimeDuration;

    final hoursController = FixedExtentScrollController(initialItem: currentValue.hours);
    final minutesController = FixedExtentScrollController(initialItem: currentValue.minutes);

    return SizedBox(
      height: 160,
      child: Row(
        children: [
          Expanded( child: CupertinoPicker( scrollController: hoursController, itemExtent: 40, onSelectedItemChanged: (index) { _handleDurationChange(question.id, hours: index); }, children: List.generate(25, (index) { return Center( child: Text( '$index horas', style: TextStyle( fontSize: 20, color: theme.textTheme.bodyLarge?.color, ), ), ); }), ), ),
          Expanded( child: CupertinoPicker( scrollController: minutesController, itemExtent: 40, onSelectedItemChanged: (index) { _handleDurationChange(question.id, minutes: index); }, children: List.generate(60, (index) { final minuteText = index.toString().padLeft(2, '0'); return Center( child: Text( '$minuteText min', style: TextStyle( fontSize: 20, color: theme.textTheme.bodyLarge?.color, ), ), ); }), ), ),
        ],
      ),
    );
  }

  // AJUSTE: El slider ahora empieza en 0 y lee el valor del mapa _answers
  Widget _buildSliderQuestion(Question question) {
    // El valor está garantizado, ya no necesitamos un valor por defecto aquí
    final currentValue = _answers[question.id] as double;
    return Row(
      children: [
        Expanded(
          child: Slider(
            value: currentValue,
            min: 0, // El slider ahora empieza en 0
            max: 10,
            divisions: 10,
            label: currentValue.toStringAsFixed(1),
            onChanged: (value) => _handleSliderChange(question.id, value),
          ),
        ),
        Text(currentValue.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildCheckboxQuestion(Question question) {
    final currentSelections = _answers[question.id] as Set<String>;
    return Column(
      children: question.options.map((option) {
        return CheckboxListTile( title: Text(option), value: currentSelections.contains(option), onChanged: (isSelected) => _handleCheckboxChange(question.id, isSelected, option), controlAffinity: ListTileControlAffinity.leading, contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }

  Widget _buildRadioQuestion(Question question) {
    final currentSelection = (_answers[question.id] as Set<String>?)?.firstOrNull;
    return Column(
      children: question.options.map((option) {
        return RadioListTile<String>( title: Text(option), value: option, groupValue: currentSelection, onChanged: (value) => _handleRadioChange(question.id, value), controlAffinity: ListTileControlAffinity.leading, contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }

  Widget _buildNextButton() {
    final isLastSection = sections.indexOf(widget.vertical) == sections.length - 1;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _onNext,
          style: ElevatedButton.styleFrom( padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), backgroundColor: isLastSection ? Colors.black87 : null, foregroundColor: isLastSection ? Colors.white : null,
          ),
          child: _isSubmitting
              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white))
              : Text(
                  isLastSection ? 'Finalizar cuestionario' : 'Siguiente (${widget.progress})',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }
}