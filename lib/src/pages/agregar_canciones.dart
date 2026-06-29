import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; 
import '../mock_data.dart';
import '../provider/playlist_provider.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AgregarCanciones extends StatefulWidget {
  final String nombrePlaylist;
  final String? portada;
  final Function(List<Map<String, String>>) onGuardar;

  const AgregarCanciones({
    super.key,
    required this.nombrePlaylist,
    this.portada,
    required this.onGuardar,
  });

  @override
  State<AgregarCanciones> createState() => _AgregarCancionesState();
}

class _AgregarCancionesState extends State<AgregarCanciones> {
  List<Map<String, String>> cancionesSeleccionadas = [];
  
  //Para guardar temporalmente en la UI las canciones locales que vayas subiendo
  List<Map<String, String>> cancionesLocales = []; 

  late String playlistId;
  late String nombrePlaylist;
  late String estado;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    playlistId = args['id'] as String;
    nombrePlaylist = args['nombre'] as String;
    estado = args['estado'] as String;
  }

// 3. NUEVA FUNCIÓN: Para abrir el explorador y cargar la canción
Future<void> _subirArchivoLocal() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav'],
      withData: true, // Necesario para la web
    );

    if (result != null) {
      String? filePath = result.files.single.path;
      String fileName = result.files.single.name;
      String duracionFormateada = '3:30'; // <-- DATO FALSO POR DEFECTO PARA SALVAR LA WEB
      String urlFinal = ''; 

      final player = AudioPlayer();

      try {
        // Intentamos cargar el audio para sacar la duración real
        if (filePath != null && !kIsWeb) {
          urlFinal = filePath;
          await player.setAudioSource(AudioSource.file(filePath));
          
          final duration = player.duration;
          if (duration != null && duration.inSeconds > 0) {
            String minutos = duration.inMinutes.toString();
            String segundos = (duration.inSeconds % 60).toString().padLeft(2, '0');
            duracionFormateada = '$minutos:$segundos';
          }
        } else if (kIsWeb) {
          // En web es muy inestable leer metadatos locales, 
          // saltamos directamente a usar el valor por defecto para no trabar la app.
          urlFinal = 'archivo_local_web'; 
        }
      } catch (e) {
        print("Ignorando error de lectura: $e");
      } finally {
        await player.dispose(); 
      }

      Map<String, String> nuevaCancion = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': fileName.replaceAll('.mp3', '').replaceAll('.wav', ''),
        'artist': 'Archivo Local',
        'url': urlFinal, 
        'image': '',
        'duration': duracionFormateada, 
        'album': 'Desconocido',
      };

      setState(() {
        cancionesLocales.add(nuevaCancion);
        cancionesSeleccionadas.add(nuevaCancion);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Archivo "$fileName" listo')),
        );
      }
    }
  }

  void toggleCancion(Map<String, String> cancion) {
    final yaSeleccionada = cancionesSeleccionadas.contains(cancion);

    setState(() {
      if (yaSeleccionada) {
        cancionesSeleccionadas.remove(cancion);
      } else {
        cancionesSeleccionadas.add(cancion);
      }
    });

    if (yaSeleccionada) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          content: Text('"${cancion['title']}" se eliminó de la playlist'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            content: Row(
              children: [
                Expanded(
                  child: Text('Agregaste "${cancion['title']}" a la playlist'),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Color.fromARGB(255, 222, 6, 6)),
                  onPressed: () {
                    setState(() {
                      cancionesSeleccionadas.remove(cancion);
                    });
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          duration: const Duration(seconds: 3),
                          content: Text('"${cancion['title']}" se eliminó de la playlist'),
                        ),
                      );
                  },
                ),
              ],
            ),
          ),
        );
    }
  }

  bool estaSeleccionada(Map<String, String> cancion) {
    return cancionesSeleccionadas.contains(cancion);
  }

  void finalizar() {
    final provider = context.read<PlaylistProvider>();

    for (final cancion in cancionesSeleccionadas) {
      provider.addCancionAPlaylist(
        playlistId,
        cancion,
      );
    }
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    if (estado == 'crear_play') {
      Navigator.pop(context);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // 4. COMBINAMOS LAS LISTAS: Mostramos las que subes localmente + las de prueba
    final listaCompleta = [...cancionesLocales, ...cancionesDePrueba];

    return Scaffold(
      appBar: AppBar(
        title: Text("Agregar a: $nombrePlaylist"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: finalizar,
          )
        ],
      ),
      // 5. MODIFICAMOS EL BODY: Usamos un Column para poner el botón arriba y la lista abajo
      body: Column(
        children: [
          // --- BOTÓN DE SUBIR ARCHIVO ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _subirArchivoLocal,
              icon: const Icon(Icons.upload_file),
              label: const Text('Subir canción desde el dispositivo'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50), // Botón ancho
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          
          // --- LISTA DE CANCIONES ---
          Expanded(
            child: ListView.builder(
              itemCount: listaCompleta.length,
              itemBuilder: (context, index) {
                final cancion = listaCompleta[index];

                return ListTile(
                  leading: (cancion['image'] == null || cancion['image']!.isEmpty)
                      ? Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey[800],
                          child: const Icon(Icons.music_note, color: Colors.white24),
                        )
                      : Image.network(
                          cancion['image']!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey[800],
                            child: const Icon(Icons.music_note, color: Colors.white24),
                          ),
                        ),
                  title: Text(cancion['title'] ?? 'Sin título'),
                  subtitle: Text(cancion['artist'] ?? 'Sin artista'),
                  trailing: IconButton(
                    icon: Icon(
                      estaSeleccionada(cancion)
                          ? Icons.check_circle
                          : Icons.add_circle_outline,
                      color: estaSeleccionada(cancion) ? Colors.green : null,
                    ),
                    onPressed: () {
                      toggleCancion(cancion);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}