// lib/src/pages/navigation_page.dart
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'search.dart';
import 'miniplayer.dart';

class NavigationPage extends StatefulWidget {
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
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.search_outlined),
                  selectedIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  label: 'Search',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
