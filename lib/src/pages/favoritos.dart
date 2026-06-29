// lib/src/pages/favoritos.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importante para escuchar el provider
import '../provider/favoritos_provider.dart';
import '../provider/menu_provider.dart';
import '../widgets/opciones_cancion.dart';
import '../provider/reproducir_playlist.dart';

class Favoritos extends StatelessWidget {
  const Favoritos({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos la lista de favoritos del Provider. 
    // Al usar "watch", Flutter sabe que si la lista cambia, esta pantalla se redibuja sola.
    final favoritosProvider = context.watch<FavoritosProvider>();
    final listaFavoritos = favoritosProvider.favoritos;

    return SafeArea(
      child: Column( 
        children: [
          AppBar(
            title: const Text('Tus Favoritos', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            // Agregamos la flecha manual conectada al MenuProvider
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.read<MenuProvider>().retroceder(),
            ),
          ),
          Expanded(
            child: listaFavoritos.isEmpty
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Todavía no tenés canciones favoritas',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              )
              : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView.builder(
                  itemCount: listaFavoritos.length,
                  itemBuilder: (context, index) {
                    final cancion = listaFavoritos[index];
                    return Card(
                      color: const Color(0xFF1E1E1E),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            cancion['image']!,
                            width: 45,
                            height: 45,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(cancion['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(cancion['artist']!, style: const TextStyle(color: Colors.grey)),
                        trailing: IconButton(
                          icon: const Icon(Icons.more_vert, color: Colors.grey),
                          onPressed: () => OpcionesCancion.mostrarOpciones(context:context, cancion:cancion, origen: 'favoritos'),
                        ),
                        onTap: () {
                          context.read<ReproductorProvider>().reproducir(
                            id: cancion['id']!,
                            titulo: cancion['title']!,
                            artista: cancion['artist']!,
                            imagen: cancion['image']!,
                );
                        },
                      )
                    );
                  },
                ),
              ),
          ),
        ]
      ),
    );
  }
  /*
  // Menú de opciones exclusivo de la pantalla de favoritos
  void _mostrarOpcionesFavoritos(BuildContext context, Map<String, String> cancion, FavoritosProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF282828),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.playlist_add, color: Colors.white),
                title: const Text('Agregar a una Playlist'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Añadida a Playlist (Simulado)')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                title: const Text('Eliminar de Favoritos', style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  Navigator.pop(context);
                  // Eliminamos usando el ID de la canción
                  provider.eliminarDeFavoritos(cancion['id']!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('"${cancion['title']}" eliminada de Favoritos')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
  */
}