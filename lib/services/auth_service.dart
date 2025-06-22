import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../features/questionnaire/models/question_model.dart';

// --- MODELS --- (Sin cambios)
class ActionItem {
  final String title;
  final String description;
  final int currentCount;
  final int totalCount;

  ActionItem({
    required this.title,
    required this.description,
    this.currentCount = 0,
    this.totalCount = 0,
  });

  factory ActionItem.fromJson(Map<String, dynamic> json) {
    return ActionItem(
      title: json['title'] ?? 'Título no disponible',
      description: json['description'] ?? '',
      currentCount: json['current_count'] ?? 0,
      totalCount: json['total_count'] ?? 0,
    );
  }
}

class Trend {
  final int id;
  final String name;
  final String description;
  final String reportDate;

  Trend({
    required this.id,
    required this.name,
    required this.description,
    required this.reportDate,
  });

  factory Trend.fromJson(Map<String, dynamic> json) {
    return Trend(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Sin nombre',
      description: json['description'] ?? 'Sin descripción',
      reportDate: json['report_date'] ?? 'Fecha no disponible',
    );
  }
}

class Greeting {
  final String content;
  final String date;

  Greeting({
    required this.content,
    required this.date,
  });

  factory Greeting.fromJson(Map<String, dynamic> json) {
    return Greeting(
      content: json['content'] ?? 'No hay contenido',
      date: json['date'] ?? 'Fecha no disponible',
    );
  }
}


// --- SERVICE ---


class AuthService {
  static const String _authBaseUrl = 'https://hoguide-737872d9cf3e.herokuapp.com/api/v1/auth';
  static const String _apiBaseUrl = 'https://hoguide-737872d9cf3e.herokuapp.com/api/v1/hoguide';

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final Uri url = Uri.parse(_authBaseUrl);
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final String? token = responseBody['token'];
        if (token != null && token.isNotEmpty) {
          await _saveToken(token);
          return {'success': true, 'token': token, 'message': 'Inicio de sesión exitoso'};
        }
      }
      return {'success': false, 'message': 'Error de autenticación'};
    } catch (e) {
      return {'success': false, 'message': 'Ocurrió un error inesperado.'};
    }
  }

  static Future<Map<String, dynamic>> register(
    String email,
    String password,
    String gender,
    int height,
    String birthday,
  ) async {
    final Uri url = Uri.parse('$_authBaseUrl/sign_up');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'gender': gender,
          'height': height,
          'birthday': birthday,
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final String? token = responseBody['token'];
        if (token != null && token.isNotEmpty) {
          await _saveToken(token);
          return {'success': true, 'token': token, 'message': 'Registro exitoso'};
        }
        return {'success': false, 'message': 'Token no encontrado tras el registro'};
      } else {
        final Map<String, dynamic> errorBody = jsonDecode(response.body);
        return {'success': false, 'message': errorBody['error'] ?? 'Error de registro'};
      }
    } catch (e) {
      print('Error inesperado durante el registro: $e');
      return {'success': false, 'message': 'Ocurrió un error inesperado.'};
    }
  }

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }
  
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
  }

  static Future<Map<String, dynamic>> getUserStats() async {
    final String? token = await getToken();
    if (token == null) return {'success': false, 'message': 'No autenticado', 'requiresAuth': true};
    final Uri url = Uri.parse('$_apiBaseUrl/user_stats');
    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      return {'success': false, 'message': 'Error obteniendo stats: ${response.statusCode}', 'requiresAuth': response.statusCode == 401};
    } catch (e) {
      return {'success': false, 'message': 'Excepción al obtener stats: $e'};
    }
  }

  static Future<bool> generateActionItem(String token) async {
    final Uri url = Uri.parse('$_apiBaseUrl/action_items');
    try {
      final response = await http.post(url, headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'}, body: jsonEncode({}));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  static Future<ActionItem?> fetchFirstActionItem(String token) async {
    final uri = Uri.parse('$_apiBaseUrl/action_items');
    final headers = {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'};
    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedBody = json.decode(response.body);
        if (decodedBody.containsKey('action_item') && decodedBody['action_item'] != null) {
          final dynamic itemValue = decodedBody['action_item'];
          if (itemValue is Map<String, dynamic>) return ActionItem.fromJson(itemValue);
          if (itemValue is String && itemValue == 'in_progress') return ActionItem(title: 'En progreso', description: 'in_progress');
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<Trend>> getTrends(String token) async {
    final Uri url = Uri.parse('$_apiBaseUrl/trends');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedBody = jsonDecode(response.body);
        final dynamic trendsData = decodedBody['trends'];
        if (trendsData is List) {
          return trendsData.map((dynamic item) => Trend.fromJson(item as Map<String, dynamic>)).toList();
        }
        return [];
      } else {
        return [];
      }
    } catch (e) {
      print('Excepción al obtener trends: $e');
      return [];
    }
  }

  static Future<Greeting?> getGreeting(String token) async {
    final Uri url = Uri.parse('$_apiBaseUrl/greetings');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedBody = jsonDecode(response.body);
        if (decodedBody.containsKey('greeting') && decodedBody['greeting'] != null) {
          return Greeting.fromJson(decodedBody['greeting'] as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      print('Excepción al obtener greeting: $e');
      return null;
    }
  }

 // --- QUESTIONNAIRE ---

  static Future<bool> checkHabitsSection() async {
    final String? token = await getToken();
    if (token == null) return false;
    final Uri url = Uri.parse('$_apiBaseUrl/questions?vertical=user_question');
    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedBody = jsonDecode(response.body);
        if (decodedBody.containsKey('user_questions') &&
            decodedBody['user_questions'] is List &&
            (decodedBody['user_questions'] as List).isNotEmpty) {
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Excepción al comprobar la sección de hábitos: $e');
      return false;
    }
  }

  // NOVEDAD: Se modifica este método para manejar diferentes claves de respuesta
  static Future<Map<String, dynamic>> getQuestions(String vertical) async {
    final String? token = await getToken();
    if (token == null) return {'success': false, 'message': 'No autenticado', 'requiresAuth': true};

    final Uri url = Uri.parse('$_apiBaseUrl/questions?vertical=$vertical');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedBody = jsonDecode(response.body);
        
        // ---- INICIO DE LA MODIFICACIÓN ----
        // Lógica para seleccionar la clave correcta según la vertical
        List<dynamic> questionData;
        if (vertical == 'user_question') {
          // Para la sección de hábitos, usamos la clave "user_questions"
          questionData = decodedBody['user_questions'] ?? [];
        } else {
          // Para todas las demás secciones, usamos "general_questions"
          questionData = decodedBody['general_questions'] ?? [];
        }
        // ---- FIN DE LA MODIFICACIÓN ----

        final List<Question> questions = questionData.map((data) => Question.fromJson(data as Map<String, dynamic>)).toList();
        return {'success': true, 'data': questions};
      } else {
        return {'success': false, 'message': 'Error obteniendo preguntas: ${response.statusCode}', 'requiresAuth': response.statusCode == 401};
      }
    } catch (e) {
      print('Excepción al obtener preguntas: $e');
      return {'success': false, 'message': 'Excepción al obtener preguntas: $e'};
    }
  }

  static Future<Map<String, dynamic>> postAnswers(Map<String, dynamic> payload) async {
    final String? token = await getToken();
    if (token == null) return {'success': false, 'message': 'No autenticado', 'requiresAuth': true};

    final Uri url = Uri.parse('$_apiBaseUrl/answers');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['error'] ?? 'Error desconocido al enviar las respuestas.';
        return {'success': false, 'message': errorMessage, 'requiresAuth': response.statusCode == 401};
      }
    } catch (e) {
      print('Excepción al enviar respuestas: $e');
      return {'success': false, 'message': 'Ocurrió un error inesperado. Revisa tu conexión.'};
    }
  }

  static Future<bool> checkQuestionnaireAvailability() async {
    final String? token = await getToken();
    if (token == null) return false;
    final Uri url = Uri.parse('$_apiBaseUrl/questionnaire');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print('Excepción al comprobar la disponibilidad del cuestionario: $e');
      return false;
    }
  }
}