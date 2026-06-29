import 'package:flutter/material.dart';
import '../mock_data.dart';
import '../provider/playlist_provider.dart';
import 'package:provider/provider.dart';
class AgregarCanciones extends StatefulWidget {
  final String nombrePlaylist;
  final String? portada;
  final Function(List<Map<String, String>>) onGuardar;

  const AgregarCanciones({
    super.key,
    required this.nombrePlaylist,
    this.portada,
    required this.onGuardar,
  });

  @override
  State<AgregarCanciones> createState() => _AgregarCancionesState();
}

class _AgregarCancionesState extends State<AgregarCanciones> {
  //canciones que el usuario va agregar a la playlist
  List<Map<String, String>> cancionesSeleccionadas = [];
  
  //Lista local para guardar las canciones que el usuario sí puede agregar (que no estan ya en la playlist)
  List<Map<String, String>> cancionesFiltradas = [];
  
  //canciones que da como resultado la barra de busqueda
  List<Map<String, String>> cancionesMostradas = [];

  //Para limpiar el texto si es necesario
  final TextEditingController _searchController = TextEditingController();

  late String playlistId;
  late String nombrePlaylist;
  late String estado;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    playlistId = args['id'] as String;
    nombrePlaylist = args['nombre'] as String;
    estado=args['estado'] as String; 

    //Obtenemos las canciones que ya están en esta playlist desde el Provider
    final provider = context.read<PlaylistProvider>();
    //todas las canciones que tiene ya la playlist
    final cancionesActuales = provider.getCanciones(playlistId);

    // Filtramos: Solo dejamos las canciones de prueba cuyo 'id' o 'title' NO esté en la playlist
    cancionesFiltradas = cancionesDePrueba.where((cancionPrueba) {
      return !cancionesActuales.any((actual) => actual['title'] == cancionPrueba['title']);
    }).toList();

    //Al inicio, mostramos todas las que pasaron el filtro de la playlist
    cancionesMostradas = List.from(cancionesFiltradas);
  }

  // NUEVO: Función para filtrar según lo que escriba el usuario
  void _filtrarBusqueda(String query) {
    setState(() {
      if (query.isEmpty) {
        cancionesMostradas = List.from(cancionesFiltradas);
      } else {
        cancionesMostradas = cancionesFiltradas.where((cancion) {
          final titulo = (cancion['title'] ?? '').toLowerCase();
          final artista = (cancion['artist'] ?? '').toLowerCase();
          final input = query.toLowerCase();
          
          return titulo.contains(input) || artista.contains(input);
        }).toList();
      }
    });
  }

 void toggleCancion(Map<String, String> cancion) {
  final yaSeleccionada = cancionesSeleccionadas.contains(cancion);
  
  setState(() {
    if (yaSeleccionada) {
      cancionesSeleccionadas.remove(cancion);
    } else {
      cancionesSeleccionadas.add(cancion);
    }
  });
  

  if (yaSeleccionada) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: Text(
          '"${cancion['title']}" se eliminó de la playlist',
        ),
      ),
    );
  }  else {
  ScaffoldMessenger.of(context)
  ..hideCurrentSnackBar()
  ..showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      content: Row(
        children: [
          Expanded(
            child: Text(
              'Agregaste "${cancion['title']}" a la playlist',
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Color.fromARGB(255, 222, 6, 6)),
            onPressed: () {
              setState(() {
                cancionesSeleccionadas.remove(cancion);
              });

              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    duration: const Duration(seconds: 3),
                    content: Text(
                      '"${cancion['title']}" se eliminó de la playlist',
                    ),
                  ),
                );
            },
          ),
        ],
      ),
    ),
  );
}}

  bool estaSeleccionada(Map<String, String> cancion) {
    return cancionesSeleccionadas.contains(cancion);
  }

  void finalizar() {
    final provider = context.read<PlaylistProvider>();
    for (final cancion in cancionesSeleccionadas) {
      provider.addCancionAPlaylist(
        playlistId,
        cancion,
      );
    }
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    if (estado=='crear_play'){
      Navigator.pop(context);
    }
    Navigator.pop(context);
  }

  // NUEVO: Limpieza del controlador al destruir el widget
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Agregar canciones a la Playlist: $nombrePlaylist"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: finalizar,
          )
        ],
      ),

      // NUEVO: Cambiamos el body a un Column para meter el buscador arriba
      body: Column(
        children: [
          // NUEVO: El campo de texto para buscar
          Padding(
            padding: const EdgeInsets.all(12.0),
            key: const ValueKey('search_bar_padding'),
            child: 
            // Barra de entrada de texto
              TextField(
                controller: _searchController,
                onChanged: _filtrarBusqueda,
                style: const TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
                decoration: InputDecoration(
                  hintText: '¿Qué querés escuchar?',
                  hintStyle: const TextStyle(
                    color: Color.fromARGB(255, 113, 113, 113),
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color.fromARGB(255, 113, 113, 113),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            _filtrarBusqueda('');
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
          ),
          
          // El ListView ahora debe ir dentro de un Expanded para no romper el layout
          Expanded(
            child: cancionesMostradas.isEmpty
                ? const Center(child: Text("No se encontraron canciones"))
                : ListView.builder(
                    itemCount: cancionesMostradas.length,
                    itemBuilder: (context, index) {
                      final cancion = cancionesMostradas[index];

                      return ListTile(
                        leading: (cancion['image'] == null || cancion['image']!.isEmpty)
                            ? Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey[800],
                                child: const Icon(Icons.music_note, color: Colors.white24),
                              )
                            : Image.network(
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
                        title: Text(cancion['title'] ?? 'Sin título'),
                        subtitle: Text(cancion['artist'] ?? 'Sin artista'),
                        trailing: IconButton(
                          icon: Icon(
                            estaSeleccionada(cancion)
                                ? Icons.check_circle
                                : Icons.add_circle_outline,
                          ),
                          onPressed: () => toggleCancion(cancion),
                        ),
                      );      
                    },
                  ),
          ),
        ],
      ),
    );
  }
}