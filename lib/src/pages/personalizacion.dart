import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/theme_provider.dart';
import '../provider/menu_provider.dart';

class Personalizacion extends StatelessWidget {
  const Personalizacion({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeModifierProvider>();

    return ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          AppBar(title: const Text('Personalizar', style: TextStyle(fontWeight: FontWeight.normal)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            // Agregamos la flecha manual conectada al MenuProvider
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.read<MenuProvider>().retroceder(),
            ),
          ),
          // SECCIÓN 1: MODO CLARO / OSCURO
          const SizedBox(height: 20),
          SwitchListTile(
            title: const Text('Modo Oscuro'),
            value: themeProvider.isDarkMode,
            activeThumbColor: Theme.of(context).colorScheme.primary,
            onChanged: (val) => themeProvider.toggleTheme(val),
          ),
          const Divider(),
          
          const Text('Paletas de Colores', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          // Renderizador de tus paletas estructuradas como las fotos
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: themeProvider.allPalettes.length,
            itemBuilder: (context, index) {
              final palette = themeProvider.allPalettes[index];
              final esActiva = themeProvider.currentPalette == palette;

              return GestureDetector(
                onTap: () => themeProvider.selectPalette(palette),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: esActiva ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2) : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(palette.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Row(
                        children: palette.colors.map((color) {
                          return Expanded(
                            child: Container(
                              height: 35,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          );
                        }).toList(),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Botón para que el usuario ensamble su propia paleta
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
            icon: const Icon(Icons.color_lens),
            label: const Text('Crear Paleta Propia (Max 5)'),
            onPressed: () => _mostrarCreadorDePaletas(context, themeProvider),
          ),
        ],
      );
  }

  // Cuadro de diálogo interactivo para generar la paleta
  void _mostrarCreadorDePaletas(BuildContext context, ThemeModifierProvider provider) {
    final List<Color> coloresElegidos = [
      Colors.blue, Colors.purple, Colors.teal // Colores base sugeridos de partida
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF282828),
        title: const Text('Nueva Paleta', style: TextStyle(color: Colors.white)),
        content: const Text('Aquí integrarías un ColorPicker (como flutter_colorpicker) para añadir hasta 5 muestras.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              provider.addUserPalette('Mi Paleta ${provider.allPalettes.length}', coloresElegidos);
              Navigator.pop(context);
            },
            child: Text('Guardar', style: TextStyle(color: provider.currentPalette.colors.first)),
          )
        ],
      ),
    );
  }
}