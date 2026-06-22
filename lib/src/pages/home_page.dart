// lib/src/pages/home_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/menu_provider.dart';
import '../provider/playlist_provider.dart'; // Importamos el nuevo provider

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    // Escuchamos las playlists creadas
    final playlistProvider = context.watch<PlaylistProvider>();
    final listaPlaylists = playlistProvider.playlists;

    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 25),
          _listaMenuOriginal(),
          const Divider(height: 1),
          _buildTituloPlaylists(),
          // Sección Inferior: Lista de Playlists que reacciona en tiempo real
          _buildSeccionPlaylists(listaPlaylists, playlistProvider),
        ],
      ),
    );
  }

  // COMPONENTE: AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Padding(
        padding: EdgeInsets.only(top: 30.0),
        child: Text(
          'Home',
          style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // COMPONENTE: Sub-Título de Playlists
  Widget _buildTituloPlaylists() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Text(
        'Mis Playlists Creadas',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  // COMPONENTE: Contenedor Expandido de Playlists
  Widget _buildSeccionPlaylists(List<dynamic> listaPlaylists, PlaylistProvider playlistProvider) {
    return Expanded(
      child: listaPlaylists.isEmpty
          ? const Center(
              child: Text('Aún no creaste ninguna playlist.', style: TextStyle(color: Colors.grey)),
            )
          : ListView.separated(
              itemCount: listaPlaylists.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final playlist = listaPlaylists[index];
                return _buildPlaylistItem(playlist, playlistProvider);
              },
            ),
    );
  }

  // COMPONENTE: Celda ListTile de cada Playlist
  Widget _buildPlaylistItem(dynamic playlist, PlaylistProvider playlistProvider) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: playlist.imagePath != null
            ? Image.file(File(playlist.imagePath!), width: 45, height: 45, fit: BoxFit.cover)
            : Container(
                width: 45,
                height: 45,
                color: Colors.grey[800],
                child: const Icon(Icons.music_note, color: Colors.white24),
              ),
      ),
      title: Text(playlist.nombre),
      subtitle: Text('${playlist.canciones.length} canciones'),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
        onPressed: () {
          playlistProvider.eliminarPlaylist(playlist.id);
        },
      ),
      onTap: () {
        // Lógica para abrir los detalles de la playlist más adelante
      },
    );
  }

  // LÓGICA ASÍNCRONA: Menú de Opciones
  Widget _listaMenuOriginal() {
    return FutureBuilder(
      future: menuProvider.cargarData(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        // 1. Si todavía está cargando, mostramos el indicador de progreso
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        // 2. Si ya hay datos, mapeamos la lista de una directamente
        if (snapshot.hasData) {
          return Column(children: _listaItems(snapshot.data));
        }
        
        // 3. Si falló por alguna razón, mostramos el error
        return Center(child: Text('Error al cargar el menú'));
      },
    );
  }


  // MAPEO: Elementos del Menú de Opciones
  List<Widget> _listaItems(List<dynamic> data) {
    return data.map((opt) {
      // Convertimos el texto a minúsculas una sola vez para analizarlo
      final textoItem = opt['texto'].toString().toLowerCase();

      // Evaluamos si es la opción de Favoritos o de Crear Playlist
      final esFavoritos = textoItem.contains('favoritos');
      final esCrearPlaylist = textoItem.contains('crear playlist'); // o la palabra clave que venga del JSON

      // Si es cualquiera de las dos, queremos que se alinee a la izquierda
      final alinearIzquierda = esFavoritos || esCrearPlaylist;

      return Column(
        children: [
          ListTile(
            // El corazón verde solo se lo dejamos a Favoritos como tenías antes
            leading: esFavoritos 
                ? Icon(Icons.favorite, color: Theme.of(context).colorScheme.primary) 
                : esCrearPlaylist
                    ? Icon(Icons.add, color: Theme.of(context).colorScheme.primary) // El "+" con el verde de tu app
                    : null,
            
            // CONDICIÓN ACTUALIZADA: Si es Favoritos o Crear Playlist va a la izquierda, sino al centro
            title: Text(
              opt['texto'], 
              textAlign: alinearIzquierda ? TextAlign.start : TextAlign.center,
            ),
            
            trailing: const Icon(
              Icons.arrow_forward_ios_outlined,
              color: Color.fromARGB(255, 179, 24, 24),
              size: 16,
            ),
            onTap: () {
              Navigator.pushNamed(context, opt['ruta']);
            },
          ),
          const Divider(height: 1),
        ],
      );
    }).toList();
  }
}