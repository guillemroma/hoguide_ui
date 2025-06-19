import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// MEJOR PRÁCTICA: Mueve la clase ActionItem a su propio archivo (ej: lib/models/action_item.dart)
// para que el servicio no dependa de un widget. Luego actualiza esta ruta de importación.
import '../features/home/widgets/locked_feature_card.dart';

class AuthService {
  static const String _authBaseUrl = 'https://hoguide-737872d9cf3e.herokuapp.com/api/v1/auth';
  static const String _apiBaseUrl = 'https://hoguide-737872d9cf3e.herokuapp.com/api/v1/hoguide';

  // --- MÉTODOS DE AUTENTICACIÓN (LOGIN, REGISTER, LOGOUT) ---

  static Future<Map<String, dynamic>> login(String email, String password) async {
    // CORRECCIÓN: Usando la URL base para el login, como indicaste.
    final Uri url = Uri.parse(_authBaseUrl); 
    print('Intentando LOGIN con: $email');

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
        return {'success': false, 'message': 'Respuesta inválida de la API: token no encontrado'};
      } else if (response.statusCode == 401) {
        final Map<String, dynamic> errorBody = jsonDecode(response.body);
        return {'success': false, 'message': errorBody['error'] ?? 'Credenciales inválidas'};
      } else {
        return {'success': false, 'message': 'Error en el servidor. Código: ${response.statusCode}'};
      }
    } catch (e) {
      print('Error inesperado durante el login: $e');
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
    print('Intentando REGISTER con: $email');

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
        return {'success': false, 'message': 'Respuesta inválida: token no encontrado tras registro'};
      } else {
        final Map<String, dynamic> errorBody = jsonDecode(response.body);
        return {'success': false, 'message': errorBody['error'] ?? 'Error de registro'};
      }
    } catch (e) {
      print('Error inesperado durante el registro: $e');
      return {'success': false, 'message': 'Ocurrió un error inesperado durante el registro.'};
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    print('Token eliminado (sesión cerrada)');
  }

  // --- MANEJO DE TOKEN (INTERNO) ---

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
    print('Token guardado.');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  // --- MÉTODOS DE API RELACIONADOS CON DATOS DEL USUARIO ---

  static Future<Map<String, dynamic>> getUserStats() async {
    final String? token = await getToken();
    if (token == null) return {'success': false, 'message': 'No autenticado', 'requiresAuth': true};

    final Uri url = Uri.parse('$_apiBaseUrl/user_stats');
    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {
          'success': false,
          'message': 'Error obteniendo stats: ${response.statusCode}',
          'requiresAuth': response.statusCode == 401
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Excepción al obtener stats: $e'};
    }
  }

  /// Inicia la generación de un Action Item en el backend.
  static Future<bool> generateActionItem(String token) async {
    final Uri url = Uri.parse('$_apiBaseUrl/action_items');
    print('Iniciando generación de Action Item en: $url');
    try {
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode({}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Excepción al generar Action Item: $e');
      return false;
    }
  }

  /// Obtiene y parsea el primer Action Item de la lista desde la API.
  static Future<ActionItem?> fetchFirstActionItem(String token) async {
    final uri = Uri.parse('$_apiBaseUrl/action_items');
    final headers = {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'};
    print("Obteniendo Action Items con token desde: $uri");

    try {
      final response = await http.get(uri, headers: headers);
      print('[API RESPONSE BODY] status: ${response.statusCode}, body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic decodedBody = json.decode(response.body);
        if (decodedBody is List && decodedBody.isNotEmpty) {
          final itemData = decodedBody[0] as Map<String, dynamic>;
          return ActionItem.fromJson(itemData);
        }
      }
      return null;
    } catch (e) {
      print("Excepción catastrófica en fetchFirstActionItem: $e");
      return null;
    }
  }
}