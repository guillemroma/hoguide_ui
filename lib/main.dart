import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // IMPORTADO para control de orientación
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/signin_screen.dart';

void main() async {
  // Asegura que los bindings de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();
  
  // AÑADIDO: Bloquea la orientación de la app a solo vertical.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Inicialización para formato de fechas en español
  await initializeDateFormatting('es', null);
  
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
      ],

      title: 'Hoguide',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        textTheme: GoogleFonts.quicksandTextTheme(
          Theme.of(context).textTheme,
        ),
        scaffoldBackgroundColor: const Color(0xFFF3F4F6),
        primaryColor: const Color(0xFF667EEA),
        cardColor: Colors.white,
        dividerColor: const Color(0xFFE5E7EB),
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF667EEA),
          onPrimary: Colors.white,
          secondary: const Color(0xFF764BA2),
          onSecondary: Colors.white,
          surface: Colors.white,
          onSurface: const Color(0xFF1F2937),
          background: const Color(0xFFF3F4F6),
          onBackground: const Color(0xFF1F2937),
          error: Colors.red,
          onError: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        textTheme: GoogleFonts.quicksandTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          bodyColor: const Color(0xFFE5E7EB),
          displayColor: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFF111827),
        primaryColor: const Color(0xFF667EEA),
        cardColor: const Color(0xFF1F2937),
        dividerColor: const Color(0xFF374151),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF667EEA),
          onPrimary: Colors.white,
          secondary: const Color(0xFF764BA2),
          onSecondary: Colors.white,
          surface: const Color(0xFF1F2937),
          onSurface: const Color(0xFFE5E7EB),
          background: const Color(0xFF111827),
          onBackground: const Color(0xFFE5E7EB),
          error: Colors.red,
          onError: Colors.white,
        ),
      ),
      themeMode: ThemeMode.dark,
      home: const SignInScreen(),
    );
  }
}
