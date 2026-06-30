// lib/src/pages/home_page.dart
import 'dart:io';
//import 'package:app_music/src/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/menu_provider.dart';
import '../provider/playlist_provider.dart'; // Importamos el nuevo provider

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlaylistProvider>().cargarPlaylists();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos las playlists creadas
    final playlistProvider = context.watch<PlaylistProvider>();
    final listaPlaylists = playlistProvider.playlists;

    //al implementar el manu y la navigation page no devolvemos el scaffold, ni appbar pues ya lo creamos en navigation page y no hay que duplicarlos
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // COMPONENTE: AppBar
        AppBar(
          // IMPORTANTE: Mostramos la flecha de atrás nativa si no estamos en Home
          automaticallyImplyLeading: false,
          title: const Text(
            'Inicio',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_outlined, size: 40),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        const SizedBox(height: 25),
        _listaMenu(),
        const Divider(height: 1),
        _buildTituloPlaylists(),
        // Sección Inferior: Lista de Playlists que reacciona en tiempo real
        _buildSeccionPlaylists(listaPlaylists, playlistProvider),
      ],
    );
  }
  /*
  // COMPONENTE: AppBar lo borro pues ahora se crea solo en la navigation page
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout_outlined, size: 40),
          onPressed: () async {
            try {
              await AuthService().cerrarSesion();

              if (!mounted) return;

              Navigator.pushNamed(context, '/');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Sesion cerrada exitosamente')),
              );
            } catch (e) {
              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al cerrar sesión: $e')),
              );
            }
          },
        ),
      ],
      title: const Text(
        'Inicio',
        style: TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  */

  // COMPONENTE: Sub-Título de Playlists
  Widget _buildTituloPlaylists() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Text(
        'Mis Playlists Creadas',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  // COMPONENTE: Contenedor Expandido de Playlists
  Widget _buildSeccionPlaylists(
    List<PlaylistModel> listaPlaylists,
    PlaylistProvider playlistProvider,
  ) {
    return Expanded(
      //con expanded utilizo todo el espacio verticalmente
      child: listaPlaylists.isEmpty
          //si la lista esta vacia
          ? const Center(
              child: Text(
                'Aún no creaste ninguna playlist.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          //si no esta vacia, hay playlist creo un listview
          : ListView.separated(
              itemCount: listaPlaylists.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final playlist = listaPlaylists[index];
                return _buildPlaylistItem(playlist, playlistProvider);
              },
            ),
    );
  }

  Future<void> _mostrarDialogoCambiarNombre(
    PlaylistModel playlist,
    PlaylistProvider playlistProvider,
  ) async {
    final TextEditingController nombreController = TextEditingController(
      text: playlist.nombre,
    );

    final String? nuevoNombre = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cambiar nombre'),
          content: TextField(
            controller: nombreController,
            decoration: const InputDecoration(
              labelText: 'Nuevo nombre de la playlist',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, nombreController.text.trim());
                context.read<MenuProvider>().retroceder();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    nombreController.dispose();

    if (nuevoNombre == null || nuevoNombre.isEmpty) {
      return;
    }

    final ok = await playlistProvider.cambiarNombrePlaylist(
      playlistId: playlist.id,
      nuevoNombre: nuevoNombre,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Nombre cambiado correctamente' : 'No se pudo cambiar el nombre',
        ),
      ),
    );
  }

  // COMPONENTE: Celda ListTile de cada Playlist
  // COMPONENTE: Celda ListTile de cada Playlist
  Widget _buildPlaylistItem(
    PlaylistModel playlist,
    PlaylistProvider playlistProvider,
  ) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: playlist.imagePath != null
            ? Image.file(
                File(playlist.imagePath!),
                width: 45,
                height: 45,
                fit: BoxFit.cover,
              )
            : Container(
                width: 45,
                height: 45,
                color: Colors.grey[800],
                child: const Icon(Icons.music_note, color: Colors.white24),
              ),
      ),

      title: Text(playlist.nombre),

      subtitle: Text('${playlist.canciones.length} canciones'),

      // Acá ahora tenemos 2 botones:
      // editar nombre y eliminar playlist
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blueAccent),
            onPressed: () {
              _mostrarDialogoCambiarNombre(playlist, playlistProvider);
            },
          ),

          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () async {
              await playlistProvider.eliminarPlaylist(playlist.id);
            },
          ),
        ],
      ),

      onTap: () {
        context.read<MenuProvider>().abrirPlaylist(playlist.id);
      },
    );
  }

  Widget _listaMenu() {
    return Column(
      children: [
        ListTile(
          leading: Icon(
            Icons.add,
            color: Theme.of(context).colorScheme.primary,
          ), // El "+" con el verde de tu app
          title: const Text("Crear playlist"),
          trailing: const Icon(
            Icons.arrow_forward_ios_outlined,
            color: Color.fromARGB(255, 179, 24, 24),
            size: 16,
          ),
          onTap: () => Navigator.pushNamed(context, 'Playlist'),
        ),
        const Divider(height: 1),
        ListTile(
          leading: Icon(
            Icons.favorite,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: const Text("Favoritos"),
          trailing: const Icon(
            Icons.arrow_forward_ios_outlined,
            color: Color.fromARGB(255, 179, 24, 24),
            size: 16,
          ),
          onTap: () => context.read<MenuProvider>().abrirFavoritos(),
        ),
      ],
    );
  }

  /*
borro estas dos que crean las opciones del menu favoritos o crear playlist ya que como controlo las cosas con el menu provider y no leo el json para las opciones directamente
//hago menu provider.abrir favoritos o pushnamed a la ruta usando el routes.dart
  // LÓGICA ASÍNCRONA: Menú de Opciones
  Widget _listaMenu() {
    return FutureBuilder(
      future: menuProvider.cargarData(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        // 1. Si todavía está cargando, mostramos el indicador de progreso
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Si ya hay datos, mapeamos la lista de una directamente
        if (snapshot.hasData) {
          return Column(children: _listaItems(snapshot.data));
        }

        // Si falló por alguna razón, mostramos el error
        return Center(child: Text('Error al cargar el menú'));
      },
    );
  }
  
  // MAPEO: Elementos del Menú de Opciones
  List<Widget> _listaItems(List<dynamic> data) {
    return data.map((opt) {
      // Convertimos el texto a minúsculas una sola vez para analizarlo
      final textoItem = opt['texto'].toString().toLowerCase();

      // Evaluamos si es la opción de Favoritos o de Crear Playlist
      final esFavoritos = textoItem.contains('favoritos');
      final esCrearPlaylist = textoItem.contains(
        'crear playlist',
      ); // o la palabra clave que venga del JSON

      // Si es cualquiera de las dos, queremos que se alinee a la izquierda
      final alinearIzquierda = esFavoritos || esCrearPlaylist;

      return Column(
        children: [
          ListTile(
            // El corazón verde solo se lo dejamos a Favoritos como tenías antes
            leading: esFavoritos
                ? Icon(
                    Icons.favorite,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : esCrearPlaylist
                ? Icon(
                    Icons.add,
                    color: Theme.of(context).colorScheme.primary,
                  ) // El "+" con el verde de tu app
                : null,

            // CONDICIÓN ACTUALIZADA: Si es Favoritos o Crear Playlist va a la izquierda, sino al centro
            title: Text(
              opt['texto'],
              textAlign: alinearIzquierda ? TextAlign.start : TextAlign.center,
            ),

            trailing: const Icon(
              Icons.arrow_forward_ios_outlined,
              color: Color.fromARGB(255, 179, 24, 24),
              size: 16,
            ),
            onTap: () {
              Navigator.pushNamed(context, opt['ruta']);
            },
          ),
          const Divider(height: 1),
        ],
      );
    }).toList();
  }
}
*/
}
