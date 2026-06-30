// lib/src/pages/navigation_page.dart
import 'package:app_music/src/pages/personalizacion.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'search.dart';
import 'miniplayer.dart';
import 'favoritos.dart';
import 'ver_playlist.dart';
import '../widgets/bottom_bar.dart';
import '../provider/menu_provider.dart';
import 'package:provider/provider.dart';

/*class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _currentIndex = 0; // Arranca en la Home (índice 1)

  // Lista de tus páginas reales con los parámetros que necesitan
  final List<Widget> _paginas = [
    //const InicioSesion(title: 'Iniciar sesión'), // Índice 0
    const HomePage(title: 'Pagina de inicio'), // Índice 1
    const Search(), // Índice 2
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _paginas),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),

          NavigationBarTheme(
            data: NavigationBarThemeData(
              indicatorColor: Colors.transparent,
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  );
                }
                return const TextStyle(color: Colors.grey, fontSize: 12);
              }),
            ),
            child: NavigationBar(
              backgroundColor: const Color(0xFF181818),
              height: 65,
              selectedIndex: _currentIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              destinations: [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(
                    Icons.home,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  label: 'Inicio',
                ),
                NavigationDestination(
                  icon: Icon(Icons.search_outlined),
                  selectedIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  label: 'Buscar',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
*/

//con este navigation page lo que hacemos es siempre dejar fijo el reproductor y la pagina de abajo
//el body es un widget llamdo pantalla que va cambiando segun la pagina a la que queramos ir, en realidad no hay navegacion entre paginas sino que es una que cambia de body
//el codigo queda mas legible y limpio
//ademas no tenemos que estar haciendo navigator.push o pushnamed sino que lo controlamos con el menuprovider
//tampoco usamos las routes.dart para estas paginas, solo usamos ese archivo para paginas donde no se deba ver el miniplayer con la barra de navegacion, como el loggin o el crear playlist
//Al remover los Scaffold de las páginas hijas, el único color de fondo real de la app será el que configuraste en tu NavigationPage (ese Color(0xFF121212) oscuro). Esto es genial porque
// unifica toda la estética de tu reproductor de música de forma nativa sin configuraciones repetidas.
class NavigationPage extends StatelessWidget {
  const NavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<MenuProvider>();
   
    Widget pantalla;

    switch(menu.paginaActual){

      case AppPage.home:
        pantalla = const HomePage(title: 'home',);
        break;

      case AppPage.search:
        pantalla = const Search();
        break;

      case AppPage.favoritos:
        pantalla = const Favoritos();
        break;

      case AppPage.playlist: 
      pantalla = VerPlaylist( playlistId: menu.getPlaylistId());
          break;

      case AppPage.personalizar: 
      pantalla = Personalizacion();
          break;
    }

    // Usamos PopScope para capturar el botón "Atrás"
    return PopScope(
      canPop: menu.paginaActual == AppPage.home, // Solo permite salir si está en el Home
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        
        // Ejecutamos el retroceso de nuestro historial del provider
        menu.retroceder();
      },
      child: Scaffold(

      body: pantalla,

      bottomNavigationBar: const MiBottomBar(),

      bottomSheet: const MiniPlayer(),

    )
    );
  }
}