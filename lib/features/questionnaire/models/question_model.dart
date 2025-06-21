class Question {
  final int id;
  final String content;
  final String vertical;
  final String answerType;
  final List<String> options;

  Question({
    required this.id,
    required this.content,
    required this.vertical,
    required this.answerType,
    required this.options,
  });

  // Factory constructor para crear una instancia de Question desde un JSON.
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? 0,
      content: json['content'] ?? 'Contenido no disponible',
      vertical: json['vertical'] ?? '',
      answerType: json['answer_type'] ?? 'text',
      // Nos aseguramos de que las opciones sean siempre una lista de strings.
      options: List<String>.from(json['options'] ?? []),
    );
  }
}