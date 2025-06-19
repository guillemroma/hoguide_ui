import 'package:flutter/material.dart';
import '../features/home/view/home_screen.dart';
import 'signup_screen.dart'; // Sigue siendo necesario para la navegación a registro
import '../services/auth_service.dart'; // Asumiendo que esta es la ruta correcta

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true; // Para controlar la visibilidad de la contraseña
  bool _isLoading = false; // Estado para el indicador de carga

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    // Validación básica de campos vacíos
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa tu correo y contraseña.')),
      );
      return;
    }

    // Activar el indicador de carga
    setState(() {
      _isLoading = true;
    });

    try {
      final String email = _emailController.text;
      final String password = _passwordController.text;

      // Llama al método de login de AuthService
      final Map<String, dynamic> result = await AuthService.login(email, password);

      // Desactivar el indicador de carga
      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Inicio de sesión exitoso!')),
        );
        // Redirige a HomeScreen y reemplaza la ruta actual
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Credenciales incorrectas. Inténtalo de nuevo.')),
        );
      }
    } catch (e) {
      // Desactivar el indicador de carga en caso de error inesperado
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocurrió un error inesperado durante el inicio de sesión: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0), // p-6 sm:p-8 y mx-auto
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centra verticalmente el contenido
          crossAxisAlignment: CrossAxisAlignment.stretch, // Estira los elementos al ancho
          children: [
            // Espacio superior para centrar mejor el contenido en pantallas más grandes
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),

            // Título Principal
            Text(
              '¡Bienvenido de nuevo!',
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    // Los colores se gestionan con el tema, pero podemos forzar aquí si es necesario
                    color: Theme.of(context).colorScheme.onBackground, // text-gray-800 dark:text-white
                  ),
              textAlign: TextAlign.center, // Centra el texto
            ),
            const SizedBox(height: 8.0),
            // Subtítulo
            Text(
              'Introduce tus credenciales para acceder a tu cuenta.',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6), // text-gray-500 dark:text-gray-400
                  ),
              textAlign: TextAlign.center, // Centra el texto
            ),
            const SizedBox(height: 48.0), // Espacio después del subtítulo (md:mt-10)

            // Contenedor de campos de entrada (similar a las tarjetas de home_screen)
            Container(
              padding: const EdgeInsets.all(24.0), // p-6 sm:p-8
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor, // bg-white dark:bg-gray-800
                borderRadius: BorderRadius.circular(16.0), // rounded-2xl (16px)
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.08), // shadow-md
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Campo de Correo Electrónico
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Correo Electrónico',
                      hintText: 'ejemplo@dominio.com',
                      prefixIcon: Icon(Icons.email_outlined, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
                      ),
                      labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                      hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
                    ),
                    style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
                  ),
                  const SizedBox(height: 24.0), // Espacio entre campos

                  // Campo de Contraseña
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscureText,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      hintText: '**********',
                      prefixIcon: Icon(Icons.lock_outline, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
                      ),
                      labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                      hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
                    ),
                    style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0), // Espacio antes del enlace de "Olvidaste..."

            // "¿Olvidaste tu contraseña?"
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  print('Olvidé mi contraseña');
                  // Aquí navegarías a la pantalla de recuperación de contraseña
                },
                child: Text(
                  '¿Olvidaste tu contraseña?',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Colors.indigo.shade500,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 32.0), // Espacio antes del botón principal

            // Botón "Iniciar Sesión"
            ElevatedButton(
              onPressed: _isLoading ? null : _signIn, // Deshabilitar el botón mientras carga
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary, // Color primario del tema
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999.0),
                ),
                elevation: 4.0, // Sombra para que se destaque
                textStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0, // Un poco más grande para botón principal
                    ),
                minimumSize: const Size(double.infinity, 56), // w-full y altura mínima
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white) // Indicador de carga
                  : const Text('Iniciar Sesión'),
            ),
            const SizedBox(height: 32.0), // Espacio antes del pie de página

            // "¿No tienes una cuenta? Regístrate"
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '¿No tienes una cuenta? ',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                      ),
                ),
                InkWell(
                  onTap: () {
                    print('Navegar a pantalla de registro');
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SignUpScreen())); // <--- ¡Añade esto!
                  },
                  child: Text(
                    'Regístrate',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Colors.indigo.shade500,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                  ),
                ),
              ],
            ),
             // Espacio inferior para evitar que el teclado oculte el contenido
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 24.0 : 0),
          ],
        ),
      ),
    );
  }
}