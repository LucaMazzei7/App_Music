import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import '../provider/favoritos_provider.dart';
import '../provider/playlist_provider.dart';

class OpcionesCancion {
  // Función simulada para el menú de opciones (Search / Playlist)
  // Pasamos el origen ('search', 'favoritos'
  //si estoy en search no me puede salir la opcion eliminar y si estoy en favoritos no me puede salir la opcion de agregar a favortios
  // Si se borra de una playlist, pasamos también su playlistId

  static void mostrarOpciones({
    required BuildContext context, 
    required Map<String, String> cancion,
    required String origen,
    String? playlistId,
  }) {
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

              //muestra info de la cancion
              ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                      cancion['image']!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 40, 
                          height: 40,
                          color: Colors.grey[800],
                          child: const Icon(Icons.music_note, color: Colors.white24),
                        );
                      },
                    ),
                  ),
                title: Text(cancion['title']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 255, 255, 255))),
                subtitle: Text(cancion['artist']!, style: const TextStyle(color: Colors.grey)),
              ),
              const Divider(color: Colors.white10),


              //opcion de agregar a favoritos

              // 1. CONDICIÓN: Si vengo de favoritos, NO muestro esta opción
              if (origen != 'favoritos')
                ListTile(
                  leading: Icon(
                    Provider.of<FavoritosProvider>(context, listen: false).esFavorito(cancion['id']!)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color:Theme.of(context).colorScheme.primary,
                  ),
                title: const Text('Añadir a Favoritos',style: TextStyle(color: Colors.grey)),
                onTap: () {
                  Navigator.pop(context);
                  Provider.of<FavoritosProvider>(context, listen: false).agregarAFavoritos(cancion);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('"${cancion['title']}" añadida a Favoritos')),
                  );
                },
              ),


              //opcion de agregar a otra playlist
              ListTile(
                leading: const Icon(Icons.playlist_add, color: Colors.white),
                title: const Text('Añadir a una Playlist', style: TextStyle(color: Colors.grey)),
                onTap: () {
                  Navigator.pop(context); // Cierra el primer menú
                  
                  final pProvider = Provider.of<PlaylistProvider>(context, listen: false);
                  
                  if (pProvider.playlists.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Primero debés crear una playlist en la Home.')),
                    );
                    return;
                  }

                  // Mostramos un sub-menú con todas las playlists creadas
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: const Color(0xFF282828),
                    builder: (context) {
                      return ListView.builder(
                        itemCount: pProvider.playlists.length,
                        itemBuilder: (context, i) {
                          final pl = pProvider.playlists[i];
                          return ListTile(
                            title: Text(pl.nombre),
                            leading: Icon(Icons.music_note, color: Theme.of(context).colorScheme.primary),
                            onTap: () async {
                              // 1. Guardamos el resultado de la operación (true o false)
                              bool seAgrego = await pProvider.addCancionAPlaylist(pl.id, cancion);
                              if (!context.mounted) return;
                              Navigator.pop(context); // Cierra el sub-menú

                              if (seAgrego) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Añadida a "${pl.nombre}"'),
                                    backgroundColor: const Color.fromARGB(255, 237, 221, 184), // fondo cremita de éxito
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('"${cancion['title']}" ya está añadida a esta playlist'),
                                    backgroundColor: Colors.amber[800], // fondo naranja de advertencia
                                  ),
                                );
                              }
                            },
                          );
                        },
                      );
                    },
                  );
                }
              ),


              //opcion de eliminar

              // 2. CONDICIÓN: Si vengo de 'search', NO muestro la opción de eliminar. 
              // Si vengo de cualquier otro lado, se muestra dinámicamente.
              if (origen != 'search')
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  title: Text(
                    origen == 'favoritos' ? 'Eliminar de Favoritos' : 'Eliminar de esta Playlist',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    
                    if (origen == 'favoritos') {
                      Provider.of<FavoritosProvider>(context, listen: false).eliminarDeFavoritos(cancion['id']!); 
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('"${cancion['title']}" eliminada de Favoritos')),
                      );
                    } else if (playlistId != null) {
                      // Llamada al provider para remover de la playlist actual
                      // NOTA: Asegúrate de tener este método implementado en tu PlaylistProvider
                      Provider.of<PlaylistProvider>(context, listen: false)
                          .removeCancionDePlaylist(playlistId, cancion['id']!);
                          
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('"${cancion['title']}" eliminada de la playlist')),
                      );
                    }
                },
              )
            ]
          )
        );
      }
    );
  }
}