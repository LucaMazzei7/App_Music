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
  List<Map<String, String>> cancionesSeleccionadas = [];
  late String playlistId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    playlistId =
        ModalRoute.of(context)!.settings.arguments as String;
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
    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Agregar canciones a la Playlist: ${widget.nombrePlaylist}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: finalizar,
          )
        ],
      ),
      body: ListView.builder(
  itemCount: cancionesDePrueba.length,
  itemBuilder: (context, index) {
    final cancion = cancionesDePrueba[index];

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
    onPressed: () {
      toggleCancion(cancion);
    },
  ),
);      
  },
),
    );
  }
}