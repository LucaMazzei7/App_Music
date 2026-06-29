import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import '../provider/favoritos_provider.dart';
import '../provider/playlist_provider.dart';

class OpcionesCancion {

// Función simulada para el menú de opciones (Favoritos / Playlist)
  static void mostrarOpciones(BuildContext context, Map<String, String> cancion) {
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
              ListTile(
                leading: Icon(
                  Provider.of<FavoritosProvider>(context, listen: false).esFavorito(cancion['id']!)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color:Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Añadir a Favoritos'),
                onTap: () {
                  Navigator.pop(context);
                  
                  // LLAMADA REAL AL PROVIDER:
                  Provider.of<FavoritosProvider>(context, listen: false).agregarAFavoritos(cancion);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('"${cancion['title']}" añadida a Favoritos')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.playlist_add, color: Colors.white),
                title: const Text('Añadir a una Playlist'),
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
                            // 1. Convertimos este onTap en async
                            onTap: () async {
                              // 2. Le clavamos el await para esperar la respuesta de Firebase
                              bool seAgrego = await pProvider.addCancionAPlaylist(pl.id, cancion);
                              
                              if (!context.mounted) return;
                              Navigator.pop(context); // Cierra el sub-menú

                              if (seAgrego) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Añadida a "${pl.nombre}"'),
                                    backgroundColor: const Color.fromARGB(255, 46, 125, 50), // Cambié a verde sutil para que combine con éxito
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('"${cancion['title']}" ya está añadida a esta playlist'),
                                    backgroundColor: Colors.amber[800], 
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
              )
            ]
          )
        );
      }
    );
  }
}