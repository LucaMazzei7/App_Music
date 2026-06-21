// lib/src/provider/favoritos_provider.dart
import 'package:flutter/material.dart';

class FavoritosProvider extends ChangeNotifier {
  // Lista privada donde guardaremos los mapas de las canciones favoritas
  final List<Map<String, String>> _favoritos = [];

  // Getter para leer los favoritos desde las páginas
  List<Map<String, String>> get favoritos => _favoritos;

  // Función para saber si una canción ya es favorita (para cambiar el ícono en el Search)
  bool esFavorito(String id) {
    return _favoritos.any((cancion) => cancion['id'] == id);
  }

  // Agregar canción a favoritos
  void agregarAFavoritos(Map<String, String> cancion) {
    if (!esFavorito(cancion['id']!)) {
      _favoritos.add(cancion);
      notifyListeners(); // Esto redibuja las pantallas que estén escuchando
    }
  }

  // Eliminar canción de favoritos por ID
  void eliminarDeFavoritos(String id) {
    _favoritos.removeWhere((cancion) => cancion['id'] == id);
    notifyListeners(); // Esto actualiza la lista visual al instante
  }
}