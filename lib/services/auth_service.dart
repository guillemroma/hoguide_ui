import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _baseUrl = 'https://hoguide-737872d9cf3e.herokuapp.com/api/v1/auth';
  static const String _apiBaseUrl = 'https://hoguide-737872d9cf3e.herokuapp.com/api/v1/hoguide';

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final Uri url = Uri.parse(_baseUrl);
    print('Intentando LOGIN con: $email');

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final String? token = responseBody['token'];

        if (token != null && token.isNotEmpty) {
          await _saveToken(token);
          return {'success': true, 'token': token, 'message': 'Inicio de sesión exitoso'};
        } else {
          return {'success': false, 'message': 'Respuesta inválida de la API: token no encontrado'};
        }
      } else if (response.statusCode == 401) {
        final Map<String, dynamic> errorBody = jsonDecode(response.body);
        final String errorMessage = errorBody['error'] ?? 'Credenciales inválidas';
        return {'success': false, 'message': errorMessage};
      } else {
        print('Error de servidor (${response.statusCode}): ${response.body}');
        return {'success': false, 'message': 'Error en el servidor. Código: ${response.statusCode}'};
      }
    } on http.ClientException catch (e) {
      print('Error de red durante el login: $e');
      return {'success': false, 'message': 'Error de conexión. Revisa tu internet.'};
    } catch (e) {
      print('Error inesperado durante el login: $e');
      return {'success': false, 'message': 'Ocurrió un error inesperado.'};
    }
  }

  static Future<Map<String, dynamic>> register(String email, String password) async {
    final Uri url = Uri.parse('https://hoguide-737872d9cf3e.herokuapp.com/api/v1/auth/sign_up');
    print('Intentando REGISTER con: $email');

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final String? token = responseBody['token'];

        if (token != null && token.isNotEmpty) {
          await _saveToken(token);
          return {'success': true, 'token': token, 'message': 'Registro exitoso'};
        } else {
          return {'success': false, 'message': 'Respuesta inválida de la API: token no encontrado tras registro'};
        }
      } else if (response.statusCode == 400 || response.statusCode == 409) {
        final Map<String, dynamic> errorBody = jsonDecode(response.body);
        final String errorMessage = errorBody['error'] ?? 'Error de registro';
        return {'success': false, 'message': errorMessage};
      } else {
        print('Error de servidor durante el registro (${response.statusCode}): ${response.body}');
        return {'success': false, 'message': 'Error en el servidor durante el registro. Código: ${response.statusCode}'};
      }
    } on http.ClientException catch (e) {
      print('Error de red durante el registro: $e');
      return {'success': false, 'message': 'Error de conexión. Revisa tu internet.'};
    } catch (e) {
      print('Error inesperado durante el registro: $e');
      return {'success': false, 'message': 'Ocurrió un error inesperado durante el registro.'};
    }
  }

  static Future<Map<String, dynamic>> getUserStats() async {
    final String? token = await getToken();
    if (token == null) {
      return {'success': false, 'message': 'No se encontró el token de autenticación.', 'requiresAuth': true};
    }

    final Uri url = Uri.parse('$_apiBaseUrl/user_stats');
    print('Intentando obtener estadísticas de usuario desde: $url');

    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        return {'success': true, 'data': responseBody};
      } else if (response.statusCode == 401) {
        await logout(); // Limpiar el token antiguo al detectar 401
        return {'success': false, 'message': 'No autorizado. Por favor, inicia sesión de nuevo.', 'requiresAuth': true}; //
      } else {
        print('Error de servidor al obtener user_stats (${response.statusCode}): ${response.body}');
        return {'success': false, 'message': 'Error al obtener estadísticas. Código: ${response.statusCode}'};
      }
    } on http.ClientException catch (e) {
      print('Error de red al obtener user_stats: $e');
      return {'success': false, 'message': 'Error de conexión al obtener estadísticas. Revisa tu internet.'};
    } catch (e) {
      print('Error inesperado al obtener user_stats: $e');
      return {'success': false, 'message': 'Ocurrió un error inesperado al obtener estadísticas.'};
    }
  }

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
    print('Token guardado: $token');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    print('Token recuperado: $token');
    return token;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    print('Token eliminado (sesión cerrada)');
  }
}