import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/menu_provider.dart';

class MiBottomBar extends StatelessWidget {
  const MiBottomBar({super.key});

  int? _getIndex(AppPage page) {
  switch (page) {
    case AppPage.home:
      return 0;
    case AppPage.search:
      return 1;
    case AppPage.personalizar:
      return 2;
    default:
      return null; // nada seleccionado
  }
}

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<MenuProvider>();
    
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        indicatorColor: const Color.fromARGB(0, 244, 232, 232),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            );
          }

          return const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          );
        }),
      ),
      child: NavigationBar(
        backgroundColor: const Color(0xFF181818),
        height: 65,
        selectedIndex: _getIndex(menu.paginaActual) ?? 0,

        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.read<MenuProvider>().abrirHome();
              break;

            case 1:
              context.read<MenuProvider>().abrirSearch();
              break;

            case 2:
            context.read<MenuProvider>().abrirPersonalizar();
              break;
          }
        },

        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: Icon(
              Icons.home,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: const Icon(Icons.search_outlined),
            selectedIcon: Icon(
              Icons.search,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: 'Buscar',
          ),
          NavigationDestination(
            icon: const Icon(Icons.person),
            selectedIcon: Icon(
              Icons.person,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: 'Personalizar',
          ),
        ],
      ),
    );
  }
}