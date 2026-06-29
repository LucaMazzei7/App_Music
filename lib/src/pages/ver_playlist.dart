
//ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/playlist_provider.dart';
import 'dart:io';
import '../provider/reproducir_playlist.dart';
import '../widgets/opciones_cancion.dart';
import '../provider/menu_provider.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';



class VerPlaylist extends StatefulWidget {
  final String playlistId;

  const VerPlaylist({super.key, required this.playlistId});
  @override
  State<VerPlaylist> createState() => _VerPlaylistState(); 
}

class _VerPlaylistState extends State<VerPlaylist> {
  String? _imagePath;
  Color _dominantColor = const Color.fromARGB(255, 94, 181, 89);
  final ImagePicker picker = ImagePicker();
  
  String? _lastProcessedPath;
  String _criterioOrden = 'recientes'; 
  bool _isPaletteLoading = false; // Bandera para evitar bucles asíncronos

  Future<void> seleccionarImagen(
    BuildContext context,
    PlaylistProvider playlistProvider,
    String playlistId, 
  ) async {
    // 1. Verificamos el estado actual en el sistema de forma silenciosa de los permisos
    final status = await Permission.photos.status;


    if (status.isGranted || status.isLimited) {
      // Si ya tiene acceso total o limitado, procedemos directo a abrir el hardware de la galería
      await _procesarSeleccionDeImagen( playlistProvider, playlistId);
    } else if (status.isPermanentlyDenied) {
      // Si el usuario seleccionó en el pasado "No seleccionar más" o lo bloqueó en ajustes
      if (context.mounted) {
        _mostrarDialogoDeAjustes();
      }
    } else {
      // Si es la primera vez, fue denegado de forma temporal (isDenied) o está en "Preguntar siempre"
      // Hacemos la solicitud formal nativa en este instante
      final nuevoStatus = await Permission.photos.request();
      
      if (nuevoStatus.isGranted || nuevoStatus.isLimited) {
        await _procesarSeleccionDeImagen(playlistProvider, playlistId);
      } else {
        // Si vuelve a denegar o pulsa "No seleccionar más" tras el cartel nativo
        if (context.mounted) {
          _mostrarDialogoDeAjustes();
        }
      }
    }
  }

  // Sub-método aislado para mantener limpio el flujo de selección y procesamiento de PaletteGenerator
  Future<void> _procesarSeleccionDeImagen(
    PlaylistProvider playlistProvider,
    String playlistId,
  ) async {
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return; // Si abrió la galería pero tiró para atrás sin elegir nada
      
      // Procesamiento de la paleta con la imagen confirmada
      final palette = await PaletteGenerator.fromImageProvider(
        FileImage(File(image.path)),
      );
      if (!mounted) return;
      setState(() {
        _imagePath = image.path;
        _dominantColor = palette.dominantColor?.color ?? const Color.fromARGB(255, 49, 187, 65);
      });
      
      playlistProvider.actualizarPortada(playlistId, image.path);
    } catch (e) {
      print("Error al abrir el selector de imágenes o procesar paleta: $e");
    }
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
          'Para poder cambiar la foto de portada de tu playlist, la aplicación necesita acceso a tus fotos. Por favor, habilítalo en los ajustes del sistema.',
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

  Future<void> _actualizarColorDesdePortada(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty || _lastProcessedPath == imagePath || _isPaletteLoading) return;
    
    _isPaletteLoading = true;
    try {
      ImageProvider imageProvider;
      if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
        imageProvider = NetworkImage(imagePath);
      } else {
        imageProvider = FileImage(File(imagePath));
      }
      
      final palette = await PaletteGenerator.fromImageProvider(imageProvider);
      
      if (!mounted) return;
      setState(() {
        _lastProcessedPath = imagePath; 
        _dominantColor = palette.dominantColor?.color ?? const Color.fromARGB(255, 49, 187, 60);
      });
    } catch (e) {
      print("Error al generar la paleta automática: $e");
    } finally {
      _isPaletteLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    //como cambie la forma de navegar para usar el menu provider ya no usamos modal
    //final String playlistId = ModalRoute.of(context)!.settings.arguments as String;
    
    // CORREGIDO: Accedemos al MenuProvider para obtener los argumentos actuales de navegación
    // 2. Usamos widget.playlistId para acceder al parámetro del constructor
    final String playlistId = widget.playlistId; 
    
    // Usamos watch para reaccionar si agregan o quitan canciones
    final playlistProvider = context.watch<PlaylistProvider>();
    
    final playlist = playlistProvider.playlists.firstWhere(
      (p) => p.id == playlistId,);
    final portada = _imagePath ?? playlist.imagePath;
    
    // Disparamos la paleta de forma segura en el siguiente frame para que no interrumpa el build actual
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _actualizarColorDesdePortada(portada);
    });

    // Lógica de ordenamiento
    List<Map<String, dynamic>> cancionesOrdenadas = List.from(playlist.canciones);
    if (_criterioOrden == 'nombre') {
      cancionesOrdenadas.sort((a, b) => (a['title'] ?? '').compareTo(b['title'] ?? ''));
    } else if (_criterioOrden == 'artista') {
      cancionesOrdenadas.sort((a, b) => (a['artist'] ?? '').compareTo(b['artist'] ?? ''));
    } else if (_criterioOrden == 'recientes') {
      cancionesOrdenadas = cancionesOrdenadas.reversed.toList();
    }
/*
Meter un ListView con shrinkWrap: true y NeverScrollableScrollPhysics dentro de otro ListView es un antipatrón común en Flutter. El problema es que obliga a calcular la altura de todas las canciones de la lista en memoria antes de poder dibujarlas, perdiendo por completo la optimización de reciclaje que hace eficiente a un ListView. Si tu playlist llega a tener 100 o 200 canciones, la app se va a empezar a trabar (laggear).
Para solucionar esto de forma profesional y eficiente, la herramienta perfecta en Flutter es CustomScrollView junto con Slivers.
Los Slivers te permiten mezclar en una sola lista componentes que se mueven a ritmos distintos: una cabecera que se encoge con efecto elástico (SliverAppBar), contenido estático (SliverToBoxAdapter) y una lista de canciones ultra eficiente que renderiza solo lo que se ve en pantalla (SliverList).
*/
// Usamos un Container por si en el futuro querés heredar un fondo o transparencia.
return Container(
  color: Colors.transparent, // Permite que se vea el fondo unificado de tu NavigationPage
  child:CustomScrollView(
    slivers: [
        // 1. APPBAR FLOTANTE Y COLAPSABLE CON DEGRADADO 
        SliverAppBar(
          expandedHeight: 280.0, // Altura de la cabecera extendida
          pinned: true,          // Deja la barra fija arriba al hacer scroll
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF121212), // Color de fondo final al colapsar
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.read<MenuProvider>().retroceder(),
          ),
          // Aquí creamos el fondo degradado y la portada
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true, // Centra el título en el AppBar colapsado
            //titlePadding: const EdgeInsets.only(bottom: 16), // Centra verticalmente el texto en la barra final

            // Este es el título que aparecerá en el AppBar al scrollear
            title: Text(
              playlist.nombre,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18, // Tamaño ideal para la barra superior compacta
                fontWeight: FontWeight.bold,
              ),
            ),
            
            // Este es el fondo que se desvanece
            background: Stack(
              clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [_dominantColor, Colors.black],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 80,
                    child: GestureDetector(
                      onTap: () => seleccionarImagen(context, playlistProvider, playlistId),
                      child: Container(
                        width: 190,
                        height: 190,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black54,
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            )
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: portada == null
                              ? Container(
                                  color: Colors.grey[850],
                                  child: const Center(
                                    child: Icon(Icons.add_a_photo, size: 60, color: Colors.white),
                                  ),
                                )
                              : (portada.startsWith('http://') || portada.startsWith('https://'))
                                  ? Image.network(portada, fit: BoxFit.cover)
                                  : Image.file(File(portada), fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ), 

        // 2. SECCIÓN DE TEXTOS Y BOTONES // Panel de acciones (Descargar, Ordenar, Contador, Añadir)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,               
                  children: [
                     Row(
                        children: [
                          //boton de descargar
                          IconButton(
                            tooltip: 'Descargar',
                            onPressed: () {},
                            icon: const Icon(Icons.download),
                          ),
                          //boton para ordenar
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.sort),
                            tooltip: 'Ordenar por',
                            onSelected: (String nuevoOrden) {
                              setState(() {
                                _criterioOrden = nuevoOrden;
                              });
                            },
                            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                PopupMenuItem<String>(
                                  value: 'recientes',
                                  child: Row(
                                    children: [
                                    Icon(Icons.access_time, color: _criterioOrden == 'recientes' ? Theme.of(context).colorScheme.primary : Colors.grey),
                                      const SizedBox(width: 10),
                                      const Text('Agregadas recientemente'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem<String>(
                                  value: 'nombre',
                                  child: Row(
                                    children: [
                                      Icon(Icons.title, color: _criterioOrden == 'nombre' ? Theme.of(context).colorScheme.primary : Colors.grey),
                                      const SizedBox(width: 10),
                                      const Text('Nombre de canción'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem<String>(
                                  value: 'artista',
                                  child: Row(
                                    children: [
                                      Icon(Icons.person, color: _criterioOrden == 'artista' ? Theme.of(context).colorScheme.primary : Colors.grey),
                                      const SizedBox(width: 10),                                        const Text('Artista'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],),
                          //texto de canciones
                          const SizedBox(height: 4),
                          Text(
                            '${playlist.canciones.length} canciones',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.grey, 
                              fontSize: 14, 
                              fontWeight: FontWeight.w400
                            ),
                          ),
                          // Botón de agregar canciones derecho (+)
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.add_circle),
                            iconSize: 45,
                            color: Theme.of(context).colorScheme.primary,
                            onPressed: () {
                              Navigator.pushNamed(context, 'Canciones', arguments: {
                                'id': playlist.id,
                                'nombre': playlist.nombre,
                                'estado': 'ver_playlist'
                              });
                            },
                          ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Colors.white10),
              ],
            ),
          ),
        ),

        // 3. LISTA DE CANCIONES ULTRA EFICIENTE (Reemplaza los dos ListViews)
        SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final cancion = cancionesOrdenadas[index];
                final String? imagePath = cancion['image'];
                
                Widget imagenLeading = const Icon(Icons.music_note, size: 40);
                if (imagePath != null && imagePath.isNotEmpty) {
                  if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
                    imagenLeading = Image.network(
                      imagePath, 
                      width: 50, 
                      height: 50, 
                      fit: BoxFit.cover,
                      cacheHeight: 100,
                      cacheWidth: 100,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const SizedBox(
                          width: 50, 
                          height: 50, 
                          child: Center(child: CircularProgressIndicator(strokeWidth: 2))
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 40),
                    );
                  } else if (File(imagePath).existsSync()) {
                    imagenLeading = Image.file(
                      File(imagePath),
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      cacheWidth: 100,
                      cacheHeight: 100,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.music_note, size: 40),
                    );
                  }
                }
                
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: imagenLeading,
                  ),
                  title: Text(
                    cancion['title'] ?? 'Sin título',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    cancion['artist'] ?? 'Artista desconocido',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      // Creamos un mapa nuevo transformando cada dynamic a String de forma segura
                      final Map<String, String> cancionString = cancion.map(
                      (key, value) => MapEntry(key, value?.toString() ?? ''),
                      );
                      OpcionesCancion.mostrarOpciones(
                        context: context,
                        cancion: cancionString,
                        origen: 'playlist',
                        playlistId: playlist.id,
                      );
                    },
                  ),
                  onTap: () {
                    context.read<ReproductorProvider>().reproducir(
                      id: cancion['id']!,
                      titulo: cancion['title']!,
                      artista: cancion['artist']!,
                      imagen: cancion['image']!,
                    );
                  },
                );
              },
              childCount: cancionesOrdenadas.length,
            ),
          ),
        ],
      ),
    );
  }
}