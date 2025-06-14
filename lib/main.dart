import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Importa google_fonts
import 'screens/home_screen.dart'; // Importa tu pantalla principal
import 'package:intl/date_symbol_data_local.dart'; 

void main() async { // Cambia a void main() async
  WidgetsFlutterBinding.ensureInitialized(); // Asegura que los bindings de Flutter estén inicializados
  await initializeDateFormatting('es', null); // Inicializa los datos de fecha para español
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hoguide',
      debugShowCheckedModeBanner: false, // Oculta la cinta de "DEBUG"
      theme: ThemeData(
        // Configuración para el modo claro
        brightness: Brightness.light,
        // Usamos la fuente Inter para todo el tema de texto
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme, // Mantiene los estilos de texto predeterminados de Flutter
        ),
        // Colores base para el modo claro
        scaffoldBackgroundColor: const Color(0xFFF3F4F6), // body background-color: #f3f4f6
        primaryColor: const Color(0xFF667EEA), // Color principal para algunos widgets (opcional, ajusta según necesidad)
        cardColor: Colors.white, // Color de fondo para Cards/Contenedores (bg-white)
        dividerColor: const Color(0xFFE5E7EB), // Color para divisores (border-gray-200)

        // Definimos un ColorScheme para una gestión de color más robusta
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF667EEA), // Indigo principal
          onPrimary: Colors.white,
          secondary: const Color(0xFF764BA2), // Púrpura secundario (para degradado)
          onSecondary: Colors.white,
          surface: Colors.white, // Para superficies como Cards
          onSurface: const Color(0xFF1F2937), // text-gray-900 (oscuro)
          background: const Color(0xFFF3F4F6), // body background-color
          onBackground: const Color(0xFF1F2937),
          error: Colors.red,
          onError: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        // Configuración para el modo oscuro
        brightness: Brightness.dark,
        // Usamos la fuente Inter también para el tema oscuro
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          bodyColor: const Color(0xFFE5E7EB), // text-gray-100 para el cuerpo
          displayColor: Colors.white, // text-white para encabezados
        ),
        // Colores base para el modo oscuro
        scaffoldBackgroundColor: const Color(0xFF111827), // dark body background-color: #111827
        primaryColor: const Color(0xFF667EEA), // Puede ser el mismo o ajustarse
        cardColor: const Color(0xFF1F2937), // dark bg-gray-800
        dividerColor: const Color(0xFF374151), // dark border-gray-700

        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF667EEA),
          onPrimary: Colors.white,
          secondary: const Color(0xFF764BA2),
          onSecondary: Colors.white,
          surface: const Color(0xFF1F2937), // dark bg-gray-800
          onSurface: const Color(0xFFE5E7EB), // dark text-gray-100
          background: const Color(0xFF111827),
          onBackground: const Color(0xFFE5E7EB),
          error: Colors.red,
          onError: Colors.white,
        ),
      ),
      themeMode: ThemeMode.dark, // Usa el tema del sistema (claro/oscuro)
      home: const HomeScreen(), // Aquí irá tu pantalla principal
    );
  }
}