// lib/src/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'routes/routes.dart';
import 'provider/theme_provider.dart';



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider te permite meter todos los "cerebros" que necesite la app en una lista
    return MaterialApp(
        title: 'Music App',
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: getApplicationRoutes(),
        theme: ThemeModifierProvider().currentTheme,
        localizationsDelegates: const [
          // Delegados
          GlobalMaterialLocalizations
              .delegate, // Traduce componentes Material (ej. Calendarios)
          GlobalWidgetsLocalizations
              .delegate, // Traduce la dirección del texto (ej. de Izq a Der)
          GlobalCupertinoLocalizations
              .delegate, // Traduce componentes estilo iOS
        ],
        // Definimos los idiomas soportados por nuestra aplicación
        supportedLocales: const [Locale('en', 'US'), Locale('es', 'ES')],
      );
  }
}
