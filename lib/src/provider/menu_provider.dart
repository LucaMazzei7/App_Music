import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

//Se genera de manera privada la clase
class _MenuProvider {
  //Se genera una lista dinámica y se inicializa como una lista vacía
  List<dynamic> opciones = [];

  //Se define el constructor
  _MenuProvider();

  //El método cargarData es un Future que permite devolver el listado de rutas una vez que se ha leído del archivo JSON
  //El Future va a retornar cuando esté disponible, la información en una lista dinámica
  Future<List<dynamic>> cargarData() async {
    final resp = await rootBundle.loadString('data/menu_opts.json');
    Map dataMap = json.decode(resp);
    // ignore: avoid_print
    print(dataMap['rutas']);
    opciones = dataMap['rutas'];

    return opciones;
  }
}

//Se crea la instancia del MenuProvider
final menuProvider =  _MenuProvider();
