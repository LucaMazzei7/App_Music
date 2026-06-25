// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class InicioSesion extends StatefulWidget {
  const InicioSesion({super.key, required this.title});
  final String title;
  @override
  State<InicioSesion> createState() => IniciarSesion();
}

class IniciarSesion extends State<InicioSesion> {
  List<dynamic> usuarios=[];
  final TextEditingController correoController = TextEditingController();
  final TextEditingController contraController = TextEditingController();
  final TextEditingController _iniciarSesion = TextEditingController();

  @override
  void initState() {
    super.initState();
    _iniciarSesion.text = 'Valor inicial del input';
    _iniciarSesion.addListener(() {
      print('El valor del input es: ${_iniciarSesion.text}');
    });
  }

  // Destrucción obligatoria para liberar memoria RAM
  @override
  void dispose() {
    _iniciarSesion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Iniciar Sesion',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
        children: [
          const SizedBox(height: 25),
          _crearEmail(),
          Divider(),
          _crearPassword(),
          const SizedBox(height: 25),
          _iniciarsesion(),
        ],
      ),
    );
  }

  //Widget para generar un inputs para email
  Widget _crearEmail() {
    return TextField(
      controller: correoController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        iconColor: Theme.of(context).colorScheme.primary,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        hintText: 'Correo electrónico',
        labelText: 'Correo electrónico',
        suffixIcon: Icon(Icons.alternate_email),
        icon: Icon(Icons.email),
      ),
    );
  }

  //Widget para generar un inputs para password
  Widget _crearPassword() {
    return TextField(
      controller: contraController,
      obscureText: true,
      decoration: InputDecoration(
        iconColor: Theme.of(context).colorScheme.primary,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        hintText: 'Constraseña',
        labelText: 'Contraseña',
        suffixIcon: Icon(Icons.lock_open),
        icon: Icon(Icons.lock),
      ),
      onChanged: (valor) {
        setState(() {});
      },
    );
  }

  Widget _iniciarsesion() {
    return ElevatedButton(
      onPressed: () {
        _verificar();
      },
      child: const Text('Iniciar Sesion', style: TextStyle(fontSize: 24)),
    );
  }

  Future<List<dynamic>>  cargarUsuario() async {

  final resp = await rootBundle.loadString('data/usuarios.json');
  Map<String,dynamic> dataMap = json.decode(resp);
  usuarios = dataMap['usuario'];
  return usuarios;
}

  void _verificar(){
    cargarUsuario();
    int i=0;
    bool verifica=true;
    while ((i<usuarios.length) & verifica){
      if ((correoController.text==usuarios[i]["correo"]) & (contraController.text==usuarios[i]["contraseña"])){
        print(usuarios[i]["correo"]);
        print(usuarios[i]["correo"]);
        verifica=false;
      }
      i++;
    }
    if (verifica){
      print("no existis");
    }else{
      Navigator.pushNamed(context, 'Navigator');
    }
  }
}
