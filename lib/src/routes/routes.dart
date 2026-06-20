import 'package:flutter/material.dart';
import '../pages/playlist.dart';
import '../pages/home_page.dart';
import '../pages/song.dart';
import '../pages/iniciar_sesion.dart';

// Función pura que retorna el mapa de rutas configurado
Map<String, WidgetBuilder> getApplicationRoutes() {
  return <String, WidgetBuilder>{
    '/':      (BuildContext context) => const InicioSesion(title: 'Iniciar sesión',),
    'home':   (BuildContext context) => const Home_page(title: 'Pagina de inicio',),
    'playlist':  (BuildContext context) => const Playlist(),
    'song': (BuildContext context) => const Songs(),
  };
}
