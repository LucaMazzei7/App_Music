// lib/src/pages/search.dart
import 'package:flutter/material.dart';
import '../mock_data.dart'; 
import '../provider/ver_playlist_provider.dart';
import '../widgets/opciones_cancion.dart';
import 'package:provider/provider.dart';

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
                            //row para que se alineen los dos al trailing porque sino tenes que poner una sola cosa
                            trailing: Row(
                              //es importante aca que usemos el mainaxissize porque sino el row va querer ocupar todo el espacio entonces esto siempre lo debemos poner si es dentro de un listile
                              mainAxisSize: MainAxisSize.min,
                              children: [

                                Text(
                                  cancion['duration']!,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),

                                const SizedBox(width: 4),

                                //con este boton lo que hago es llamar al widget donde me despliega el menu con las opciones de agregarla a favoritos o a las playlist creadas (esta en otro archivo)
                                IconButton(
                                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                                  onPressed: () => OpcionesCancion.mostrarOpciones( context, cancion,),
                                )
                              ]
                            ),
                            onTap: () {
                              // Acá podrías mandar la canción al reproductor
                              context.read<ReproductorProvider>().reproducir(
                                id: cancion['id']!,
                                titulo: cancion['title']!,
                                artista: cancion['artist']!,
                                imagen: cancion['image']!,
                              );
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