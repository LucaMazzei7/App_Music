import 'package:flutter/material.dart';

class ReproductorProvider extends ChangeNotifier {

  String? cancionActualId;
  String? tituloActual;
  String? artistaActual;
  String? imagenActual;

  bool reproduciendo = false;

  void reproducir({
    required String id,
    required String titulo,
    required String artista,
    required String imagen,
  }) {

    cancionActualId = id;
    tituloActual = titulo;
    artistaActual = artista;
    imagenActual = imagen;

    reproduciendo = true;
    notifyListeners();
  }

  void reanudar() {
    reproduciendo = true;
    notifyListeners();
  }

  void pausar() {
    reproduciendo = false;
    notifyListeners();
  }
}