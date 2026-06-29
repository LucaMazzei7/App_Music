

import 'package:flutter/material.dart';
import 'src/app.dart';
import 'package:provider/provider.dart';
// Importamos tus dos providers centralizados
import 'src/provider/favoritos_provider.dart';
import 'src/provider/playlist_provider.dart';
import 'src/provider/menu_provider.dart';
import 'src/provider/reproducir_playlist.dart';
import 'src/provider/theme_provider.dart';

void main() {
  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => PlaylistProvider()),
        ChangeNotifierProvider(create: (_) => FavoritosProvider()),
        ChangeNotifierProvider(create: (_) => ReproductorProvider()),
        ChangeNotifierProvider(create: (_) => ThemeModifierProvider())
      ],
      child: const MyApp(),));
}