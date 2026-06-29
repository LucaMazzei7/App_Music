import 'package:flutter/material.dart';
//import '../pages/search.dart';
//import '../pages/home_page.dart';
import '../pages/iniciar_sesion.dart';
import '../pages/crear_playlist.dart';
import '../pages/navigation_page.dart';
//import '../pages/ver_playlist.dart';
import '../pages/agregar_canciones.dart';
import '../pages/registrarse.dart';

// Función que retorna el mapa de rutas configurado
Map<String, WidgetBuilder> getApplicationRoutes() {
  return <String, WidgetBuilder>{
    // La ruta raíz '/' ahora pasa a ser la NavigationPage
    'IniciarSesion': (BuildContext context) =>
        const InicioSesion(title: 'Iniciar sesión'),
    'Registro': (BuildContext context) => const RegistroSesion(title: 'Inicio'),

    '/': (BuildContext context) => const InicioSesion(title: 'Iniciar sesión'),

    // Mantenemos las rutas a las páginas individuales para acceso directo
    'Login': (BuildContext context) =>
        const InicioSesion(title: 'Iniciar sesión'),
    //'Home': (BuildContext context) => const HomePage(title: 'Pagina de inicio'),
    //'Search': (BuildContext context) => const Search(),
    'Playlist': (BuildContext context) => const Playlist(),
    //'Favoritos': (BuildContext context) => const Favoritos(),
    'Navigator': (BuildContext context) => const NavigationPage(),
    //'ver_playlist': (BuildContext context) => const VerPlaylist(),
    'Canciones': (BuildContext context) =>
        AgregarCanciones(nombrePlaylist: '', onGuardar: (_) {}),
  };
}
