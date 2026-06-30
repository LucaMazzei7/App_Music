// lib/src/provider/playlist_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  // Este método sirve para crear una copia de la playlist
  // cambiando solo los datos que necesitemos.
  // Como nombre, imagePath, canciones, etc.
  PlaylistModel copyWith({
    String? id,
    String? nombre,
    String? imagePath,
    List<Map<String, String>>? canciones,
  }) {
    return PlaylistModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      imagePath: imagePath ?? this.imagePath,
      canciones: canciones ?? this.canciones,
    );
  }
}

class PlaylistProvider extends ChangeNotifier {
  List<PlaylistModel> _playlists = [];

  // Instancias de Firebase para conectarnos a la base de datos
  // y saber quién está logueado.
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<PlaylistModel> get playlists => _playlists;

  // Obtenemos el id del usuario actual de Firebase
  String? get _uid => _auth.currentUser?.uid;

  // Descargar las playlists cuando inicia la app
  Future<void> cargarPlaylists() async {
    if (_uid == null) return;

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
          id: doc.id,
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
      final docRef = await _db.collection('playlists').add({
        'userId': _uid,
        'nombre': nombre.trim(),
        'imagePath': imagePath,
        'canciones': [],
        'createdAt': FieldValue.serverTimestamp(),
      });

      final nuevaPlaylist = PlaylistModel(
        id: docRef.id,
        nombre: nombre.trim(),
        imagePath: imagePath,
        canciones: [],
      );

      _playlists.add(nuevaPlaylist);
      notifyListeners();

      return nuevaPlaylist;
    } catch (e) {
      print("❌ Error al crear playlist en Firebase: $e");

      return PlaylistModel(
        id: DateTime.now().toString(),
        nombre: nombre,
        canciones: [],
      );
    }
  }

  // Cambiar el nombre de una playlist
  Future<bool> cambiarNombrePlaylist({
    required String playlistId,
    required String nuevoNombre,
  }) async {
    final nombreLimpio = nuevoNombre.trim();

    // Si el nombre está vacío, no permitimos cambiarlo
    if (nombreLimpio.isEmpty) {
      return false;
    }

    // Buscamos la playlist en la lista local
    final index = _playlists.indexWhere((p) => p.id == playlistId);

    // Si no existe en la lista local, cortamos
    if (index == -1) {
      return false;
    }

    try {
      // Si hay usuario logueado, actualizamos Firebase
      if (_uid != null) {
        await _db.collection('playlists').doc(playlistId).update({
          'nombre': nombreLimpio,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Actualizamos la playlist local para que se vea el cambio en la app
      _playlists[index] = _playlists[index].copyWith(nombre: nombreLimpio);

      // CAMBIO DE SEGURIDAD ACÁ: Avisamos a las pantallas SOLO si el provider sigue activo
      if (hasListeners) {
        notifyListeners();
      }

      return true;
    } catch (e) {
      print("❌ Error al cambiar nombre de playlist: $e");
      return false;
    }
  }

  // Eliminar una playlist
  Future<void> eliminarPlaylist(String id) async {
    try {
      // Si hay usuario logueado, eliminamos también de Firebase
      if (_uid != null) {
        await _db.collection('playlists').doc(id).delete();
      }

      // Eliminamos de la lista local
      _playlists.removeWhere((p) => p.id == id);

      notifyListeners();
    } catch (e) {
      print("❌ Error al eliminar playlist en Firebase: $e");
    }
  }

  // Guardar canción en Firestore
  Future<bool> addCancionAPlaylist(
    String playlistId,
    Map<String, String> cancion,
  ) async {
    try {
      final index = _playlists.indexWhere((p) => p.id == playlistId);

      if (index == -1) return false;

      final yaExiste = _playlists[index].canciones.any(
        (c) => c['id'] == cancion['id'],
      );

      if (yaExiste) return true;

      if (_uid != null) {
        await _db.collection('playlists').doc(playlistId).update({
          'canciones': FieldValue.arrayUnion([cancion]),
        });
      }

      _playlists[index].canciones.add(cancion);

      notifyListeners();

      return true;
    } catch (e) {
      print("❌ Error al agregar canción a la playlist en Firebase: $e");
      return false;
    }
  }

  // Eliminar una canción de una playlist específica
  Future<bool> removeCancionDePlaylist(
    String playlistId,
    String cancionId,
  ) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);

    if (index == -1) return false;

    try {
      final cancionAEliminar = _playlists[index].canciones.firstWhere(
        (cancion) => cancion['id'] == cancionId,
      );

      if (_uid != null) {
        await _db.collection('playlists').doc(playlistId).update({
          'canciones': FieldValue.arrayRemove([cancionAEliminar]),
        });
      }

      _playlists[index].canciones.removeWhere(
        (cancion) => cancion['id'] == cancionId,
      );

      notifyListeners();

      return true;
    } catch (e) {
      print("❌ Error al eliminar canción de la playlist: $e");
      return false;
    }
  }

  // Actualizar portada de una playlist
  Future<bool> actualizarPortada(String playlistId, String? newPortada) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);

    if (index == -1) return false;

    try {
      if (_uid != null) {
        await _db.collection('playlists').doc(playlistId).update({
          'imagePath': newPortada,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      _playlists[index] = _playlists[index].copyWith(imagePath: newPortada);

      notifyListeners();

      return true;
    } catch (e) {
      print("❌ Error al actualizar portada: $e");
      return false;
    }
  }

  List<Map<String, String>> getCanciones(String playlistId) {
    final index = _playlists.indexWhere((p) => p.id == playlistId);

    if (index == -1) {
      return [];
    }

    return _playlists[index].canciones;
  }
}
