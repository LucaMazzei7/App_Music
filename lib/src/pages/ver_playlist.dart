
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/playlist_provider.dart';
import 'dart:io';
import '../provider/ver_playlist_provider.dart';
import 'miniplayer.dart';
import '../widgets/opciones_cancion.dart';

class VerPlaylist extends StatelessWidget {
  const VerPlaylist({super.key});

  @override
  Widget build(BuildContext context) {
    //modalroute obtiene informacion de la ruta actual, con esto recibimos los argumentos
    final String playlistId = ModalRoute.of(context)!.settings.arguments as String;
    final playlistProvider = context.watch<PlaylistProvider>();
    final playlist = playlistProvider.playlists.firstWhere( (p) => p.id == playlistId );

    return Scaffold(
      appBar: AppBar(),

      body: ListView(
        children: [
          const SizedBox(height: 20,),

          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 187, 49, 49),
                Colors.black,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            ),
          
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: playlist.imagePath != null
                  //si la tiene cargamos desde el almacenamiento
                  ? Image.file(File(playlist.imagePath!), width: 130, height: 130, fit: BoxFit.cover)
                  //si no tiene imagen ponemos este container por default
                  : Container(
                    width: 130,
                    height: 130,
                    color: Colors.grey[800],
                    child: const Icon(Icons.music_note, color: Colors.white24),
                  ),
                ),
              ]
            )
          ),

          const SizedBox(height: 16),

          Stack(
            alignment: Alignment.center,
            children: [

              Positioned(
                left: 0,
                child: IconButton(
                  onPressed: (){}, 
                  tooltip: 'Descargar',
                  icon: const Icon(Icons.download)
                )
              ),

              Column(
                children: [
                  Text(
                    playlist.nombre,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    '${playlist.canciones.length} canciones',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),

              Positioned(
                right: 0,
                child: IconButton(
                  tooltip: 'Agregar canción',
                  icon: const Icon(Icons.add_circle),
                  iconSize: 42,
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () {
                    // agregar canciones
                    Navigator.pushNamed(context, 'Canciones', arguments: {'id': playlist.id, 'nombre': playlist.nombre, 'estado': 'ver_playlist'});
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(), 
          //aca tenemos un listview dentro de otro listview
          ListView.builder(
            //le decimos basdicamente al listview "No ocupes todo el espacio posible. Calculá tu altura según la cantidad de elementos que tenés."
            shrinkWrap: true,
            //como son dos listview cada uno es scrolleable entonces para no tener dos scrolleos medios raros le ponemos que no permita scrollear la lista de canciones
            physics: const NeverScrollableScrollPhysics(),
            itemCount: playlist.canciones.length,
            itemBuilder: (context, index) {
              final cancion = playlist.canciones[index];
              return ListTile(
                
leading: (cancion['image'] == null || cancion['image']!.isEmpty)
    ? Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(Icons.music_note, color: Colors.white24),
      )
    : Image.network(
        cancion['image']!,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 60,
          height: 60,
          color: Colors.grey[800],
          child: const Icon(Icons.broken_image, color: Colors.white24),
        ),
      ),
                title: Text(
                  cancion['title']!,
                  softWrap: true,
                  overflow: TextOverflow.visible, 
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(cancion['artist']!),
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

                    IconButton(
                              icon: const Icon(Icons.more_vert, color: Colors.grey),
                              onPressed: () => OpcionesCancion.mostrarOpciones( context, cancion,),
                            ),

                    /*PopupMenuButton<String>(
                      tooltip: 'Opciones',
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        if (value == 'agregar') {
                          // Agregar a playlist
                        }

                        if (value == 'eliminar') {
                          // Eliminar de playlist
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'agregar',
                          child: Text('Agregar a playlist'),
                        ),
                        const PopupMenuItem(
                          value: 'eliminar',
                          child: Text('Eliminar'),
                        ),
                      ],
                    ),*/
                  ],
                ),
                onTap: () {
                   context.read<ReproductorProvider>().reproducir(
                    id: cancion['id']!,
                    titulo: cancion['title']!,
                    artista: cancion['artist']!,
                    imagen: cancion['image']!,
                    url: cancion['url'] ?? '',
                  );
                }
              );
            },
          ),
//    ]
      
    ]), 
        bottomNavigationBar: const MiniPlayer(),  
    );
  }
}
