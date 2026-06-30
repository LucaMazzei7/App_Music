import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ReproductorProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();

  String? cancionActualId;
  String? tituloActual;
  String? artistaActual;
  String? imagenActual;

  bool reproduciendo = false;

  ReproductorProvider() {
    // Escuchamos el estado del reproductor real (para las canciones subidas)
    _audioPlayer.playerStateStream.listen((state) {
      // Solo actualizamos si realmente hay un audio cargado
      if (_audioPlayer.audioSource != null) {
        reproduciendo = state.playing;
        notifyListeners();

        // Si la canción termina, la frena y vuelve al inicio
        if (state.processingState == ProcessingState.completed) {
          reproduciendo = false;
          _audioPlayer.stop();
          _audioPlayer.seek(Duration.zero);
          notifyListeners();
        }
      }
    });
  }

  // Al poner "String? url", hacemos que no sea obligatorio pasarla
  Future<void> reproducir({
    required String id,
    required String titulo,
    required String artista,
    required String imagen,
    String? url, 
  }) async {
    cancionActualId = id;
    tituloActual = titulo;
    artistaActual = artista;
    imagenActual = imagen;
    
    // Asumimos que empieza a reproducir para actualizar la UI rápido
    reproduciendo = true; 
    notifyListeners();

    try {
      // Si la URL es nula o vacía (tus canciones de prueba)
      if (url == null || url.isEmpty || url == 'archivo_local_web') {
        print("Canción de prueba sin archivo real. Simulando Play...");
        // Frenamos cualquier audio real que estuviera sonando antes
        await _audioPlayer.stop(); 
        return;
      }

      // Si es un archivo local real
      if (!kIsWeb) {
        await _audioPlayer.setAudioSource(AudioSource.file(url));
        _audioPlayer.play();
      }
    } catch (e) {
      print("Error al intentar reproducir el audio: $e");
    }
  }

  void reanudar() {
    reproduciendo = true;
    notifyListeners();
    // Si hay un audio real cargado, le damos play
    if (_audioPlayer.audioSource != null) {
      _audioPlayer.play();
    }
  }

  void pausar() {
    reproduciendo = false;
    notifyListeners();
    // Si hay un audio real cargado, lo pausamos
    if (_audioPlayer.audioSource != null) {
      _audioPlayer.pause();
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}