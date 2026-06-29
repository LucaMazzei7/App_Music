//import 'dart:convert';
//import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';


/*class MenuProvider {
  //Se genera una lista dinámica y se inicializa como una lista vacía
  List<dynamic> opciones = [];

  //Se define el constructor
  MenuProvider();

  //El método cargarData es un Future que permite devolver el listado de rutas una vez que se ha leído del archivo JSON
  //El Future va a retornar cuando esté disponible, la información en una lista dinámica
  Future<List<dynamic>> cargarData() async {
    final resp = await rootBundle.loadString('data/menu_opts.json');
    Map dataMap = json.decode(resp);
    // ignore: avoid_print
    print(dataMap['rutas']);
    opciones = dataMap['rutas'];

    return opciones;
  }
}

//Se crea la instancia del MenuProvider
final menuProvider =  MenuProvider();
*/

//el provider puede mostrar cualquier pantalla
//con este menu provider vamos hacer que la navigation page controle a todas las demas abriendolas desde el menu provider
//lo que hice fue colocar en el enum todas las paginas que necesito que tengan el reproductor y la barra de navigacion y las llamo desde aca entonces 
enum AppPage {
  home,
  search,
  favoritos,
  playlist,
  personalizar
}

class MenuProvider extends ChangeNotifier {
  AppPage paginaActual = AppPage.home;

  String? playlistId;
  // Historial interno para manejar el botón de atrás y que no me lleve siempre al inicio de sesion
  final List<AppPage> _historial = [AppPage.home];

  void _cambiarPagina(AppPage pagina) {
    if (paginaActual == pagina) return;
    
    paginaActual = pagina;
    _historial.add(pagina); // Guardamos el paso en el historial
    notifyListeners();
  }

  void abrirHome() {
    _historial.clear(); // Si vuelve a Home, limpiamos para no acumular bucles
    _historial.add(AppPage.home);
    paginaActual = AppPage.home;
    notifyListeners();
  }

  void abrirSearch() {
    _cambiarPagina(AppPage.search);
  }

  void abrirFavoritos() {
    _cambiarPagina(AppPage.favoritos);
  }

  void abrirPlaylist(String id) {
    playlistId = id;
    _cambiarPagina(AppPage.playlist);
  }

  void abrirPersonalizar () {
    _cambiarPagina(AppPage.personalizar);
  }

  String getPlaylistId () {
    return playlistId!;
  }

  // simula elhacer para atras 
  bool retroceder() {
    if (_historial.length > 1) {
      _historial.removeLast(); // Quitamos la pantalla actual
      paginaActual = _historial.last; // La anterior pasa a ser la actual
      notifyListeners();
      return false; // Bloquea el pop nativo de Flutter (no se va al Login)
    }
    return true; // Si solo queda el Home, permite salir de la app o desloguear
  }
}