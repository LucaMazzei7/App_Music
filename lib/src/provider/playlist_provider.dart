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
  void crearPlaylist(String nombre, String? imagePath) {
    final nuevaPlaylist = PlaylistModel(
      id: DateTime.now().toString(), // ID único temporal
      nombre: nombre,
      imagePath: imagePath,
      canciones: [],
    );
    _playlists.add(nuevaPlaylist);
    notifyListeners();
  }

  // Eliminar una playlist
  void eliminarPlaylist(String id) {
    _playlists.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  // Modificá este método dentro de PlaylistProvider:
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
}