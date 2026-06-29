// lib/src/provider/playlist_provider.dart
import 'package:flutter/material.dart';

class PlaylistModel {
  final String id;
  final String nombre;
  final String? imagePath; // Ruta del archivo de la galería
  final List<Map<String, String>> canciones;

  PlaylistModel({
    required this.id,
    required this.nombre,
    this.imagePath,
    required this.canciones,
  });
}

class PlaylistProvider extends ChangeNotifier {
  final List<PlaylistModel> _playlists = [];

  List<PlaylistModel> get playlists => _playlists;

  // Crear una nueva playlist
  PlaylistModel crearPlaylist(String nombre, String? imagePath) {
    final nuevaPlaylist = PlaylistModel(
      id: DateTime.now().toString(), // ID único temporal
      nombre: nombre, 
      imagePath: imagePath,
      canciones: [],
    );
    _playlists.add(nuevaPlaylist);
    notifyListeners();
     return nuevaPlaylist;
  }

  // Eliminar una playlist
  void eliminarPlaylist(String id) {
    _playlists.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  bool addCancionAPlaylist(String playlistId, Map<String, String> cancion) {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
  
    if (index != -1) {
      // Verificamos si la canción YA EXISTE en esa playlist específica
      bool yaExiste = _playlists[index].canciones.any((c) => c['id'] == cancion['id']);
    
      if (yaExiste) {
        return false; // No la agrega y retorna false
      } else {
        _playlists[index].canciones.add(cancion);
        notifyListeners(); // Notifica el cambio a la Home
        return true; // Retorna true porque se agregó con éxito
      }
    }
    return false;
  }

  // Eliminar una canción de una playlist específica
  void removeCancionDePlaylist(String playlistId, String cancionId) {
    //buscamos el índice de la playlist
    final index = _playlists.indexWhere((p) => p.id == playlistId);

    if (index != -1) {
      //removemos la canción que coincida con el id provisto
      _playlists[index].canciones.removeWhere((cancion) => cancion['id'] == cancionId);
      
      //notificamos a todos los widgets para que se redibujen (y desaparezca la canción de la pantalla)
      notifyListeners();
    }
  }

  void actualizarPortada (String playlistId, String? newPortada) {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      _playlists[index] = PlaylistModel(
        id: _playlists[index].id, 
        nombre: _playlists[index].nombre, 
        canciones: _playlists[index].canciones, 
        imagePath: newPortada);
    }
  }

  List<Map<String, String>> getCanciones (String playlistId) {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    return _playlists[index].canciones;
  }

}