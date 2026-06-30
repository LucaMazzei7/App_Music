// lib/src/provider/playlist_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_core/firebase_core.dart';
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
  List<PlaylistModel> _playlists = [];
 //instancias de firebase para conectarnos a la bdd y saber quien esta logeado
 final FirebaseFirestore _db= FirebaseFirestore.instance;
 final FirebaseAuth _auth=FirebaseAuth.instance;

  List<PlaylistModel> get playlists => _playlists;
//obtenemos el id del usuario actual de firebase
String? get _uid => _auth.currentUser?.uid;

 // 1. NUEVA FUNCIÓN: Descargar las playlists cuando inicia la app
  Future<void> cargarPlaylists() async {
    if (_uid == null) return; // Si no hay usuario, no cargamos nada

    try {
      final snapshot = await _db
          .collection('playlists')
          .where('userId', isEqualTo: _uid)
          .get();

      _playlists = snapshot.docs.map((doc) {
        final data = doc.data();
        
        final List<dynamic> cancionesRaw = data['canciones'] ?? [];
        List<Map<String, String>> cancionesFormateadas = cancionesRaw.map((c) {
          return Map<String, String>.from(c as Map);
        }).toList();

        return PlaylistModel(
          id: doc.id, // El ID ahora es el documento real de Firestore
          nombre: data['nombre'] ?? 'Sin nombre',
          imagePath: data['imagePath'],
          canciones: cancionesFormateadas,
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      print("❌ Error al cargar las playlists de Firebase: $e");
    }
  }


  // Crear una nueva playlist
  Future<PlaylistModel> crearPlaylist(String nombre, String? imagePath) async {
    // Si por alguna razón no hay sesión, creamos una local temporal para que no explote
    if (_uid == null) {
      final temporal = PlaylistModel(
        id: DateTime.now().toString(),
        nombre: nombre,
        imagePath: imagePath,
        canciones: [],
      );
      _playlists.add(temporal);
      notifyListeners();
      return temporal;
    }

    try {
      // Guardamos en Firebase
      final docRef = await _db.collection('playlists').add({
        'userId': _uid,
        'nombre': nombre,
        'imagePath': imagePath,
        'canciones': [], 
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Creamos el modelo con el ID que nos devolvió Firebase
      final nuevaPlaylist = PlaylistModel(
        id: docRef.id, 
        nombre: nombre,
        imagePath: imagePath,
        canciones: [],
      );

      _playlists.add(nuevaPlaylist);
      notifyListeners();
      return nuevaPlaylist;
    } catch (e) {
      print("❌ Error al crear playlist en Firebase: $e");
      // Retornamos temporal en caso de error para no trabar la UI
      return PlaylistModel(id: DateTime.now().toString(), nombre: nombre, canciones: []);
    }
  }


  // Eliminar una playlist
  void eliminarPlaylist(String id) {
    _playlists.removeWhere((p) => p.id == id);
    notifyListeners();
  }
// 3. NUEVA FUNCIÓN (Indispensable para AgregarCanciones): Guardar canción en Firestore
  Future<bool> addCancionAPlaylist(String playlistId, Map<String, String> cancion) async {
    try {
      // 1. Buscamos la playlist localmente en la lista del Provider
      final index = _playlists.indexWhere((p) => p.id == playlistId);
      if (index == -1) return false;

      // Evitamos duplicados locales rápido
      final yaExiste = _playlists[index].canciones.any((c) => c['id'] == cancion['id']);
      if (yaExiste) return true;

      // 2. Si hay sesión iniciada, impactamos en Firebase usando la sintaxis nueva (.doc y .update)
      if (_uid != null) {
        await _db.collection('playlists').doc(playlistId).update({
          'canciones': FieldValue.arrayUnion([cancion])
        });
      }

      // 3. Actualizamos el estado local para reflejar el cambio en la UI sin recargar
      _playlists[index].canciones.add(cancion);
      notifyListeners();
      return true;
    } catch (e) {
      print("❌ Error al agregar canción a la playlist en Firebase: $e");
      return false;
    }
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