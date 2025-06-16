import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _baseUrl = 'https://hoguide-737872d9cf3e.herokuapp.com/api/v1/auth';

  // Método para el inicio de sesión
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final Uri url = Uri.parse(_baseUrl); // Tu endpoint de login/register es el mismo _baseUrl
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
        // Éxito: La API devolvió un estado 200 (OK)
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final String token = responseBody['token'];

        if (token != null && token.isNotEmpty) {
          await _saveToken(token); // Guarda el token
          return {'success': true, 'token': token, 'message': 'Inicio de sesión exitoso'};
        } else {
          return {'success': false, 'message': 'Respuesta inválida de la API: token no encontrado'};
        }
      } else if (response.statusCode == 401) {
        // Error de autenticación: La API devolvió un estado 401 (Unauthorized)
        final Map<String, dynamic> errorBody = jsonDecode(response.body);
        final String errorMessage = errorBody['error'] ?? 'Credenciales inválidas';
        return {'success': false, 'message': errorMessage};
      } else {
        // Otros errores del servidor
        print('Error de servidor (${response.statusCode}): ${response.body}');
        return {'success': false, 'message': 'Error en el servidor. Código: ${response.statusCode}'};
      }
    } on http.ClientException catch (e) {
      // Errores de red (ej. sin conexión a internet)
      print('Error de red durante el login: $e');
      return {'success': false, 'message': 'Error de conexión. Revisa tu internet.'};
    } catch (e) {
      // Otros errores inesperados
      print('Error inesperado durante el login: $e');
      return {'success': false, 'message': 'Ocurrió un error inesperado.'};
    }
  }

  // Método para el registro (usará el mismo endpoint si tu API lo permite)
  // Nota: Si tu API tiene un endpoint de registro diferente (ej. /api/v1/register),
  // deberás cambiar la URL aquí. Dado que el ejemplo usa el mismo /auth para ambos, lo mantendremos.
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

      // ¡Cambio aquí! Se espera un 201 Created para el registro exitoso.
      if (response.statusCode == 201) {
        // Éxito: La API devolvió un estado 201 (Created)
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final String token = responseBody['token'];

        if (token != null && token.isNotEmpty) {
          await _saveToken(token); // Guarda el token
          return {'success': true, 'token': token, 'message': 'Registro exitoso'};
        } else {
          return {'success': false, 'message': 'Respuesta inválida de la API: token no encontrado tras registro'};
        }
      } else if (response.statusCode == 400 || response.statusCode == 409) {
        // Errores comunes de registro: 400 Bad Request, 409 Conflict (si el usuario ya existe)
        final Map<String, dynamic> errorBody = jsonDecode(response.body);
        final String errorMessage = errorBody['error'] ?? 'Error de registro';
        return {'success': false, 'message': errorMessage};
      } else {
        // Otros errores del servidor
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

  // Método privado para guardar el token en SharedPreferences
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
    print('Token guardado: $token');
  }

  // Método para obtener el token desde SharedPreferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    print('Token recuperado: $token');
    return token;
  }

  // Método para eliminar el token (cerrar sesión)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    print('Token eliminado (sesión cerrada)');
  }
}