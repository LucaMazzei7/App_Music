import 'package:flutter/material.dart';
import '../provider/menu_provider.dart';

class Home_page extends StatefulWidget {
  const Home_page({super.key, required this.title});

  final String title;

  @override
  State<Home_page> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Home_page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Opciones')),
      body: _lista(),
    );
  }

  Widget _lista() {
    return FutureBuilder(
      future: menuProvider.cargarData(),
      initialData: const [],
      //retorna un widget builder que va a permitir dibujar un elemento en pantalla
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasData) {
          List<dynamic> data = snapshot.data;
          return ListView.separated(
            itemCount: data.length,
            itemBuilder: (context, index) {
              return _listaItems(data)[index];
            },
            separatorBuilder: (context, index) {
              return Divider();
            },
          );
        } else {
          return Text('Error: ${snapshot.error}');
        }
      },
    );
  }

  List<Widget> _listaItems(List<dynamic> data) {
    //Recorremos cada uno de los elementos de la lista, armando los ListTile
    return data
        .map(
          (opt) => ListTile(
            title: Text(opt['texto'], textAlign: TextAlign.center),
            trailing: Icon(
              Icons.arrow_forward_ios_outlined,
              color: Colors.blue,
            ),
            onTap: () {
              Navigator.pushNamed(context, opt['ruta']);
            },
          ),
        )
        .toList();
  }
}
