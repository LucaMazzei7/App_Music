// lib/src/provider/playlist_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  
  // Instancias de Firebase para conectarnos a la base de datos y saber quién está logueado
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<PlaylistModel> get playlists => _playlists;

  // Obtenemos el ID del usuario actual de Firebase
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

  // 2. ACTUALIZADA: Crear una nueva playlist en la nube
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

  // 3. ACTUALIZADA: Eliminar una playlist
  Future<void> eliminarPlaylist(String id) async {
    try {
      await _db.collection('playlists').doc(id).delete(); // Borra de la nube
      _playlists.removeWhere((p) => p.id == id); // Borra de la pantalla
      notifyListeners();
    } catch (e) {
      print("❌ Error al eliminar playlist en Firebase: $e");
    }
  }

  // 4. ACTUALIZADA: Modificar este método dentro de PlaylistProvider para subir canciones
  Future<bool> addCancionAPlaylist(String playlistId, Map<String, String> cancion) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    
    if (index != -1) {
      // Verificamos si la canción YA EXISTE en esa playlist específica
      bool yaExiste = _playlists[index].canciones.any((c) => c['id'] == cancion['id']);
      
      if (yaExiste) {
        return false; // No la agrega y retorna false
      } else {
        try {
          // Usamos arrayUnion para agregar solo esta canción al arreglo de Firebase
          await _db.collection('playlists').doc(playlistId).update({
            'canciones': FieldValue.arrayUnion([cancion])
          });

          _playlists[index].canciones.add(cancion);
          notifyListeners(); // Notifica el cambio a la Home
          return true; // Retorna true porque se agregó con éxito
        } catch (e) {
          print("❌ Error al agregar canción en Firebase: $e");
          return false;
        }
      }
    }
    return false;
  }
}