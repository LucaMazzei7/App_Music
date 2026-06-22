// lib/src/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Importamos tus dos providers centralizados
import 'provider/favoritos_provider.dart';
import 'provider/playlist_provider.dart';
import 'routes/routes.dart';
import 'provider/ver_playlist_provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider te permite meter todos los "cerebros" que necesite la app en una lista
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => FavoritosProvider()),
        ChangeNotifierProvider(create: (context) => PlaylistProvider()),
        ChangeNotifierProvider(create: (_) => ReproductorProvider(),),
      ],
      child: MaterialApp(
        title: 'Music App',
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: getApplicationRoutes(),
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF121212),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 165, 95, 25),
            primary: const Color.fromARGB(255, 185, 29, 29),
            secondary: const Color.fromARGB(255, 131, 16, 16),
            brightness: Brightness.dark,
          ),
        ),
      ),
    );
  }
}