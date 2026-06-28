// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import '/src/services/auth_service.dart';

class RegistroSesion extends StatefulWidget {
  const RegistroSesion({super.key, required this.title});
  final String title;
  @override
  State<RegistroSesion> createState() => RegistrarSesion();
}

class RegistrarSesion extends State<RegistroSesion> {
  final TextEditingController usuario = TextEditingController();
  final TextEditingController correo = TextEditingController();
  final TextEditingController contra = TextEditingController();
  final TextEditingController fechaNac = TextEditingController();
  final TextEditingController generoController = TextEditingController();
  String _fecha = '';
  final List<String> opcionesGenero = ['Masculino', 'Femenino', 'Otro'];
  String? generoSeleccionado;
  final TextEditingController _iniciarSesion = TextEditingController();
  DateTime? fechaNacimientoSeleccionada;
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
          'Registrar Usuario',
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
          _crearUsuario(),
          Divider(),
          _crearEmail(),
          Divider(),
          _crearPassword(),
          Divider(),
          _crearFecha(),
          Divider(),
          _crearGenero(),
          const SizedBox(height: 25),
          _registrarsesion(),
        ],
      ),
    );
  }

  Widget _crearUsuario() {
    return TextField(
      controller: usuario,
      //keyboardType permite que en el teclado del dispositivo móvil se encuentre accesible el arroba (@) con el fin de escribir las direcciones de correo con mayor facilidad
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        iconColor: Theme.of(context).colorScheme.primary,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        hintText: 'Usuario',
        labelText: 'Usuario',
        suffixIcon: Icon(Icons.person),
        icon: Icon(Icons.person),
      ),
    );
  }

  Widget _crearGenero() {
    return DropdownMenu<String>(
      controller: generoController,
      width: MediaQuery.of(context).size.width - 40,
      label: const Text('Género'),
      leadingIcon: const Icon(Icons.person_outline),
      initialSelection: generoSeleccionado,
      onSelected: (String? valor) {
        setState(() {
          generoSeleccionado = valor;
        });
      },
      dropdownMenuEntries: opcionesGenero.map((String valor) {
        return DropdownMenuEntry<String>(value: valor, label: valor);
      }).toList(),
    );
  }

  //Widget para generar un inputs para email
  Widget _crearEmail() {
    return TextField(
      controller: correo,
      //keyboardType permite que en el teclado del dispositivo móvil se encuentre accesible el arroba (@) con el fin de escribir las direcciones de correo con mayor facilidad
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
      controller: contra,
      //obscureText permite ocultar los caracteres que se ingresan en un input reemplazandolos por asteriscos
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

  Widget _registrarsesion() {
    return ElevatedButton(
      onPressed: () async {
        //Navigator.pushNamed(context, 'Login');
        await _guardarUsuario();
      },
      child: const Text('Registrarse', style: TextStyle(fontSize: 20)),
    );
  }

  Widget _crearFecha() {
    return TextField(
      // Bloqueamos la selección y el portapapeles para obligar al usuario a usar el calendario
      enableInteractiveSelection: false,
      controller: fechaNac, // Enlazamos el controlador al input
      decoration: InputDecoration(
        iconColor: Theme.of(context).colorScheme.primary,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        hintText: 'Fecha de nacimiento',
        labelText: 'Fecha de nacimiento',
        suffixIcon: Icon(Icons.perm_contact_calendar),
        icon: const Icon(Icons.calendar_today),
      ),
      // onTap intercepta el toque físico sobre el componente
      onTap: () {
        // Arquitectura estricta: Le quitamos el foco a la caja de texto para
        // evitar que el teclado virtual del sistema operativo se despliegue en pantalla.
        FocusScope.of(context).requestFocus(FocusNode());
        // Invocamos el método asíncrono
        _selectDate(context);
      },
    );
  }

  // Método asíncrono para renderizar el calendario modal
  void _selectDate(BuildContext context) async {
    // La ejecución se pausa (await) hasta que el usuario elija una fecha o cancele el modal
    DateTime? calendario = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Punto de partida
      firstDate: DateTime(1950), // Límite inferior
      lastDate: DateTime.now(), // Límite superior
    );

    // Si el usuario no presionó "Cancelar" fuera del cuadro
    if (calendario != null) {
      setState(() {
        fechaNacimientoSeleccionada = calendario;
        final dia = calendario.day.toString().padLeft(2, '0');
        final mes = calendario.month.toString().padLeft(2, '0');
        final anio = calendario.year.toString();

        _fecha = '$dia/$mes/$anio';
        fechaNac.text = _fecha;
      });
    }
  }

  Future<void> _guardarUsuario() async {
    if (usuario.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresá un nombre de usuario')),
      );
      return;
    }
    if (correo.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresá un correo electrónico')),
      );
      return;
    }
    if (contra.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ingresá una contraseña')));
      return;
    }
    if (fechaNacimientoSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccioná una fecha de nacimiento')),
      );
      return;
    }
    if (generoSeleccionado == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Seleccioná un género')));
      return;
    }
    try {
      await AuthService().registrarUsuario(
        nombre: usuario.text,
        email: correo.text,
        password: contra.text,
        genero: generoSeleccionado!,
        fechaNacimiento: fechaNacimientoSeleccionada!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario registrado correctamente')),
      );
      Navigator.pushNamed(context, 'IniciarSesion');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al registrar: $e')));

      print('ERROR AL REGISTRAR: $e');
    }
  }
}
