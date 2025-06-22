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
  final bool hasHabitsSection;

  const QuestionSectionScreen({
    super.key,
    required this.vertical,
    required this.payload,
    required this.hasHabitsSection,
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
  
  late final List<String> sections;

  @override
  void initState() {
    super.initState();
    sections = [
      'sueño',
      'ejercicio',
      'nutricion',
      'bienestar_emocional'
    ];
    if (widget.hasHabitsSection) {
      sections.add('user_question');
    }
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    final result = await AuthService.getQuestions(widget.vertical);
    if (mounted) {
      setState(() {
        if (result['success']) {
          _questions = result['data'];
          _initializeAnswers(); 
        } else {
          _errorMessage = result['message'];
        }
        _isLoading = false;
      });
    }
  }

  void _initializeAnswers() {
    for (var question in _questions) {
      switch (question.answerType) {
        case 'duration':
          _answers[question.id] = _TimeDuration(0, 0);
          break;
        case 'slider':
          _answers[question.id] = 0.0;
          break;
        case 'text_form_field':
          _answers[question.id] = '';
          break;
        case 'checkbox':
          _answers[question.id] = <String>{};
          break;
        // NOVEDAD: Se añade el caso para inicializar las respuestas de tipo 'switch'
        case 'switch':
          _answers[question.id] = false; // Por defecto, el interruptor está apagado
          break;
        default:
          break;
      }
    }
  }

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

  // NOVEDAD: Nuevo método para manejar el cambio de estado del interruptor
  void _handleSwitchChange(int questionId, bool value) {
    setState(() {
      _answers[questionId] = value;
    });
  }

  void _onNext() async {
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
      // NOVEDAD: Se añade la lógica para formatear la respuesta booleana del switch a String
      } else if (answerValue is bool) {
        content = [answerValue.toString()]; // Convierte true a "true" y false a "false"
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
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => QuestionSectionScreen(
            vertical: nextSection,
            payload: updatedPayload,
            hasHabitsSection: widget.hasHabitsSection,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cuestionario: ${widget.vertical.toUpperCase()}'),
        actions: [
          if (sections.indexOf(widget.vertical) == sections.length - 1)
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
    // NOVEDAD: Se añade la condición para el nuevo tipo de pregunta 'switch'
    } else if (question.answerType == 'switch') {
      questionInput = _buildSwitchQuestion(question);
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

  Widget _buildDurationPicker(Question question) {
    final theme = Theme.of(context);
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

  Widget _buildSliderQuestion(Question question) {
    final currentValue = _answers[question.id] as double;
    return Row(
      children: [
        Expanded(
          child: Slider(
            value: currentValue,
            min: 0,
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

  // NOVEDAD: Se añade el widget que construye el interruptor.
  // Usamos CupertinoSwitch por su estética limpia, similar a la del picker de duración.
  Widget _buildSwitchQuestion(Question question) {
    final currentValue = _answers[question.id] as bool;
    return Align(
      alignment: Alignment.centerLeft,
      child: CupertinoSwitch(
        value: currentValue,
        onChanged: (value) => _handleSwitchChange(question.id, value),
      ),
    );
  }

  Widget _buildNextButton() {
    final currentIndex = sections.indexOf(widget.vertical);
    final totalSections = sections.length;
    final isLastSection = currentIndex == totalSections - 1;
    final progressText = '${currentIndex + 1}/$totalSections';

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
                  isLastSection ? 'Finalizar cuestionario' : 'Siguiente ($progressText)',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }
}