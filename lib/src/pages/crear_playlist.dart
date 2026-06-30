
// lib/src/pages/playlist.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../provider/playlist_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class Playlist extends StatefulWidget {
  const Playlist({super.key});

  @override
  State<Playlist> createState() => _PlaylistState();
}

class _PlaylistState extends State<Playlist> {
  final TextEditingController _nameController = TextEditingController();
  String? imagePath;
  final ImagePicker _picker = ImagePicker();

  // Abre de forma directa el hardware de selección
  Future<void> _ejecutarGaleriaOriginal() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        imagePath = image.path;
      });
    }
  }

  // Este es el método que ahora vinculas al onTap de la portada
  Future<void> _interceptadorDePermisos() async {
    final status = await Permission.photos.status;

    if (status.isGranted || status.isLimited) {
      // Si ya tiene el permiso total de antes, entra directo a la galería
      await _ejecutarGaleriaOriginal();
    } else  {
      if (mounted) _mostrarPreCartelPersonalizado();
    }
  }

  // el primer cartel que mostramos , no es necesario pero para mas placer
  void _mostrarPreCartelPersonalizado() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: const Color(0xFF282828),
        title: const Text(
          'Acceso a la Galería', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
        // Aquí pones exactamente el texto explicativo que quieras mostrar antes del nativo
        content: const Text(
          'App Music quiere acceder a la galería para que puedas elegir fotos de portada.\n\n¿Deseas permitir el acceso?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cierra tu cartel
              // Como seleccionó que NO, mostramos el cartel de advertencia que pediste
              _mostrarAvisoPermisoRequerido(); 
            },
            child: const Text('Nunca', style: TextStyle(color: Colors.redAccent)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () async {
              Navigator.of(context).pop(); // Cierra tu cartel
              
              // PASO 2: Ahora sí disparamos el cartel nativo del sistema operativo
              final status = await Permission.photos.request();
              
              if (status.isGranted || status.isLimited) {
                await _ejecutarGaleriaOriginal();
              } else {
                // Si en el nativo le da a rechazar/limitar, mostramos el aviso de ajustes
                if (mounted) _mostrarDialogoDeAjustes();
              }
            },
            child: const Text('Permitir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // CARTEL DE ADVERTENCIA (Si selecciona "Nunca" en tu pre-cartel)
  void _mostrarAvisoPermisoRequerido() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: const Color(0xFF282828),
        title: const Text('Acceso Necesario', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Se necesita el acceso a la galería para poder cargar imágenes personalizadas en tus playlists.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido', style: TextStyle(color: Colors.grey)),
          )
        ],
      ),
    );
  }

  // cartel que sale cuando le pones sin permisos, te dice que para poder subir la portada necesita que nos des permiso
  void _mostrarDialogoDeAjustes() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: const Color(0xFF282828),
        title: const Text(
          'Permiso Requerido', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
        content: const Text(
          'Para poder subir portadas personalizadas, la aplicación necesita acceso a la galería. Por favor, cambia la configuración en los ajustes.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cierra el cartel sin hacer nada
            },
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings(); // Abre los ajustes nativos de la app
            },
            child: const Text('Ir a Ajustes', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playlistProvider = context.read<PlaylistProvider>();
    

    return Scaffold(
      appBar: AppBar(title: const Text('Crear Playlist')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Portada playlist
            GestureDetector(
              // NUEVO: Dispara la validación
              onTap: _interceptadorDePermisos, 
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                  image: imagePath != null
                      ? DecorationImage(
                          image: FileImage(File(imagePath!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: imagePath == null
                    ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo, size: 50, color: Colors.white54),
                        SizedBox(height: 8),
                        Text(
                          'Subir Portada', 
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    )
                    : null, // Si hay foto, la decoración de fondo se encarga de mostrarla
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
              onPressed: () async {
                if (_nameController.text.isNotEmpty) {
                  // MODIFICADO: Ahora pasamos la variable `imagePath` real en lugar de null
                  final nuevaPlaylist = await playlistProvider.crearPlaylist(
                    _nameController.text.trim(), 
                    imagePath,
                  );
                  
                  _nameController.clear();
                  setState(() {
                    imagePath = null; // Reinicia la imagen tras guardar
                  });
                  if (mounted){
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(content: const Text('¡Playlist creada con éxito!'),
                     backgroundColor: Theme.of(context).colorScheme.surface ,),
                     
                  );
                  }                // Notificación visual de éxito
                  
                  if (!context.mounted) return;
                  // Enviar el ID y nombre de la nueva playlist a la página de canciones para agregar canciones
                  Navigator.pushNamed(context, 'Canciones', arguments: {'id': nuevaPlaylist.id, 'nombre': nuevaPlaylist.nombre,'estado':'crear_play'}); // 
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