import 'package:flutter/material.dart';

class Inicio extends StatefulWidget {
  const Inicio({super.key, required this.title});
  final String title;
  @override
  State<Inicio> createState() => Iniciar();
}

class Iniciar extends State<Inicio> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/image/bienvenido.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _crearInicio(),
              const SizedBox(height: 15),
              _crearRegistro(),
              const SizedBox(height: 135),
            ],
          ),
        ),
      ),
    );
  }

  Widget _crearRegistro() {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, 'Registro');
      },
      child: const Text('Registrarse', style: TextStyle(fontSize: 34)),
    );
  }

  Widget _crearInicio() {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, 'IniciarSesion');
      },
      child: const Text('Iniciar Sesion', style: TextStyle(fontSize: 34)),
    );
  }
}
