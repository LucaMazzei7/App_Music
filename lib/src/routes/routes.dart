import 'package:flutter/material.dart';
import '../pages/search.dart';
import '../pages/home_page.dart';
import '../pages/favoritos.dart';
import '../pages/iniciar_sesion.dart';
import '../pages/playlist.dart';
import '../pages/navigation_page.dart';
import '../pages/agregar_canciones.dart';

// Función que retorna el mapa de rutas configurado
Map<String, WidgetBuilder> getApplicationRoutes() {
  return <String, WidgetBuilder>{
    // La ruta raíz '/' ahora pasa a ser la NavigationPage
    '/': (BuildContext context) => const NavigationPage(),
    
    // Mantenemos las rutas a las páginas individuales para acceso directo
    'Login':     (BuildContext context) => const InicioSesion(title: 'Iniciar sesión'),
    'Home':      (BuildContext context) => const HomePage(title: 'Pagina de inicio'),
    'Search':    (BuildContext context) => const Search(),
    'Playlist':  (BuildContext context) => const Playlist(), 
    'Favoritos': (BuildContext context) => const Favoritos(),
    'Canciones': (BuildContext context) => AgregarCanciones(nombrePlaylist: '', onGuardar: (List<Map<String, String>> p1) {  },), // Ruta adicional para la sección de canciones
  };
}