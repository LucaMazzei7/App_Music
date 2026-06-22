// lib/src/pages/playlist.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/playlist_provider.dart';

class Playlist extends StatefulWidget {
  const Playlist({super.key});

  @override
  State<Playlist> createState() => _PlaylistState();
}

class _PlaylistState extends State<Playlist> {
  final TextEditingController _nameController = TextEditingController();
   // Crear la playlist al iniciar el estado

   @override
  @override
  Widget build(BuildContext context) {
    final playlistProvider = context.read<PlaylistProvider>();
    

    return Scaffold(
      appBar: AppBar(title: const Text('Crear Playlist')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Vista previa de la portada (Simulada y fija por ahora)
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo, size: 50, color: Colors.white54),
                  SizedBox(height: 8),
                  Text(
                    'Subir Portada', 
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Campo de texto para el nombre
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Nombre de la playlist',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF242424),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10), 
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Botón para guardar
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                if (_nameController.text.isNotEmpty) {
                  // Envia los datos al Provider (pasamos null en la ruta de imagen por ahora)
                 final nuevaPlaylist = playlistProvider.crearPlaylist(_nameController.text, null);
                  
                  // Limpia el campo de texto
                  _nameController.clear();
                  
                  // Notificación visual de éxito
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('¡Playlist creada con éxito!')),
                  );

                  // VOLVER AUTOMÁTICAMENTE A LA HOME_PAGE
                  Navigator.pushNamed(context, 'Canciones', arguments: nuevaPlaylist.id); // 
                }
              },
              child: const Text('Guardar Playlist', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}