import 'package:flutter/material.dart';

class InicioSesion extends StatefulWidget {
  const InicioSesion({super.key,required this.title});
  final String title;
  @override
  State<InicioSesion> createState() => IniciarSesion();
  


}


class IniciarSesion extends State<InicioSesion> {
  String _nombre = '';
  String _email = '';
  final TextEditingController _IniciarSesion = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _IniciarSesion.text = 'Valor inicial del input';
    _IniciarSesion.addListener(() {
    print('El valor del input es: ${_IniciarSesion.text}');
    });
  }

  // Destrucción obligatoria para liberar memoria RAM
  @override
  void dispose() {
    _IniciarSesion.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Iniciar sesion')),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        children: [
          _crearInput(),
          Divider(),
          _crearEmail(),
          Divider(),
          _crearPassword(),
          Divider(),
          _crearPersona(),
          Divider(),
          _crearBoton(),
        ],
      ),
    );
  }
Widget _crearInput() {
    return TextField(
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        iconColor:  const Color.fromARGB(255, 100, 165, 25),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        hintText: 'Nombre de la persona',
        labelText: 'Nombre',
        helperText: 'Solo nombre',
        suffixIcon: Icon(Icons.accessibility),
        icon: Icon(Icons.account_circle),
      ),
      onChanged: (valor) {
        setState(() {
          _nombre = valor;
        });
      },
    );
  }

  //Widget para generar un inputs para email
  Widget _crearEmail() {
    return TextField(
      //keyboardType permite que en el teclado del dispositivo móvil se encuentre accesible el arroba (@) con el fin de escribir las direcciones de correo con mayor facilidad
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        iconColor:  const Color.fromARGB(255, 100, 165, 25),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        hintText: 'Email',
        labelText: 'Email',
        suffixIcon: Icon(Icons.alternate_email),
        icon: Icon(Icons.email),
      ),
      onChanged: (valor) {
        setState(() {
          _email = valor;
        });
      },
    );
  }

  //Widget para generar un inputs para password
  Widget _crearPassword() {
    return TextField(
      //obscureText permite ocultar los caracteres que se ingresan en un input reemplazandolos por asteriscos
      obscureText: true,
      decoration: InputDecoration(
        iconColor:  const Color.fromARGB(255, 100, 165, 25),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        hintText: 'Password',
        labelText: 'Password',
        suffixIcon: Icon(Icons.remove_red_eye),
        icon: Icon(Icons.lock),
      ),
      onChanged: (valor) {
        setState(() {});
      },
    );
  }

  Widget _crearPersona() {
    return ListTile(  title: Text('Nombre es: $_nombre'),
      subtitle: Text('Email: $_email'),
    );
  }
  Widget _crearBoton() {
    return ElevatedButton(
    onPressed: () {
      Navigator.pushNamed(context, 'home');
    },
    child: const Text('Iniciar sesión'),
  );
}
}