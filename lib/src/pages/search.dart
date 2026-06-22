// lib/src/pages/search.dart
import 'package:flutter/material.dart';
import '../mock_data.dart'; 
import 'package:provider/provider.dart'; 
import '../provider/favoritos_provider.dart';
import '../provider/playlist_provider.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  // Lista que va a cambiar dinámicamente cuando busquemos
  List<Map<String, String>> cancionesFiltradas = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Al principio mostramos todas las canciones como "recomendaciones"
    cancionesFiltradas = cancionesDePrueba;
  }

  void _filtrarCanciones(String query) {
    setState(() {
      if (query.isEmpty) {
        cancionesFiltradas = cancionesDePrueba;
      } else {
        cancionesFiltradas = cancionesDePrueba
            .where((cancion) =>
                cancion['title']!.toLowerCase().contains(query.toLowerCase()) ||
                cancion['artist']!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  // Función simulada para el menú de opciones (Favoritos / Playlist)
  void _mostrarOpciones(BuildContext context, Map<String, String> cancion) {
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
                            onTap: () {
                              // 1. Guardamos el resultado de la operación (true o false)
                              bool seAgrego = pProvider.addCancionAPlaylist(pl.id, cancion);
                              
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
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: const Text(
            'Buscar',
            style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              
              // Barra de entrada de texto
              TextField(
                controller: _searchController,
                onChanged: _filtrarCanciones,
                style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                decoration: InputDecoration(
                  hintText: '¿Qué querés escuchar?',
                  hintStyle: const TextStyle(color: Color.fromARGB(255, 113, 113, 113)),
                  prefixIcon: const Icon(Icons.search, color: Color.fromARGB(255, 113, 113, 113)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            _filtrarCanciones('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFF242424),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              Text(
                _searchController.text.isEmpty ? 'Recomendaciones' : 'Resultados',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 255, 255, 255)),
              ),
              const SizedBox(height: 12),
              
              // Lista de canciones filtradas
              Expanded(
                child: cancionesFiltradas.isEmpty
                    ? const Center(
                        child: Text('No encontramos canciones con ese nombre.', style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
                      )
                    : ListView.builder(
                        itemCount: cancionesFiltradas.length,
                        itemBuilder: (context, index) {
                          final cancion = cancionesFiltradas[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                cancion['image']!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey[800],
                                  child: const Icon(Icons.music_note, color: Colors.white24),
                                ),
                              ),
                            ),
                            title: Text(
                              cancion['title']!,
                              style: const TextStyle(fontWeight: FontWeight.w600, color: Color.fromARGB(255, 255, 255, 255)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(cancion['artist']!, style: const TextStyle(color: Colors.grey)),
                            trailing: IconButton(
                              icon: const Icon(Icons.more_vert, color: Colors.grey),
                              onPressed: () => _mostrarOpciones(context, cancion),
                            ),
                            onTap: () {
                              // Acá podrías mandar la canción al reproductor
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}