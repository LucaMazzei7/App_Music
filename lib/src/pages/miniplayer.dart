// widgets/mini_player.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/reproducir_playlist.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final reproductor =
        context.watch<ReproductorProvider>();

    if (reproductor.cancionActualId == null) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
        border: Border(
          top: BorderSide(color: Colors.white10),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),

          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              reproductor.imagenActual!,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reproductor.tituloActual!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  reproductor.artistaActual!,
                  style: const TextStyle(color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          IconButton(
            icon: Icon(
              reproductor.reproduciendo ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () {
              if (reproductor.reproduciendo) {
                reproductor.pausar();
              } else {
                reproductor.reanudar();
              }
            },
          ),
        ],
      ),
    );
  }
}