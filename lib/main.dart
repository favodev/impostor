import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_theme.dart';
import 'ui/screens/screens.dart';

/// Punto de entrada de la aplicación Impostor (Who is the Spy?)
///
/// Arquitectura:
/// - State Management: Riverpod para máxima eficiencia y testabilidad
/// - UI: Material Design 3 con tema Cyberpunk/Noir
/// - Principios: Clean Code + SOLID
///
/// Estructura de carpetas:
/// lib/
/// ├── core/
/// │   ├── models/      - Modelos de datos inmutables
/// │   ├── providers/   - Providers de Riverpod y lógica de negocio
/// │   └── theme/       - Tema y estilos de la aplicación
/// └── ui/
///     ├── screens/     - Pantallas principales
///     └── widgets/     - Widgets reutilizables
void main() {
  // Asegurar inicialización de bindings
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar GoogleFonts para NO hacer peticiones HTTP
  // Usa fuentes cacheadas o del sistema, mejorando rendimiento offline
  GoogleFonts.config.allowRuntimeFetching = false;

  // Configurar orientación preferida (portrait para mejor UX en pass-the-device)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configurar estilo de barra de sistema para tema oscuro
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.backgroundDark,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    // ProviderScope es requerido para que Riverpod funcione
    const ProviderScope(child: ImpostorApp()),
  );
}

/// Widget raíz de la aplicación
///
/// Implementa el tema Material 3 oscuro con acentos neón
/// y configura la navegación principal
class ImpostorApp extends StatelessWidget {
  const ImpostorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Impostor - Who is the Spy?',
      debugShowCheckedModeBanner: false,

      // Aplicar tema Cyberpunk/Noir
      theme: AppTheme.darkTheme,

      // Pantalla inicial: Configuración del juego
      home: const SetupScreen(),
    );
  }
}
