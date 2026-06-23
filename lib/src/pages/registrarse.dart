// ignore_for_file: avoid_print
import 'package:flutter/material.dart';

class RegistroSesion extends StatefulWidget {
  const RegistroSesion({super.key, required this.title});
  final String title;
  @override
  State<RegistroSesion> createState() => RegistrarSesion();
}

class RegistrarSesion extends State<RegistroSesion> {
  String _fecha = '';

  final TextEditingController _inputFieldController = TextEditingController();
  final List<String> opcionesGenero = ['Masculino', 'Femenino', 'Otro'];
  String _genero = 'Genero';
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
      width: MediaQuery.of(context).size.width - 40,
      label: const Text('Género'),
      leadingIcon: const Icon(Icons.person_outline),
      initialSelection: _genero,
      onSelected: (String? valor) {
        setState(() {
          _genero = valor!;
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
      onPressed: () {
        Navigator.pushNamed(context, '/');
      },
      child: const Text('Registrarse', style: TextStyle(fontSize: 20)),
    );
  }

  Widget _crearFecha() {
    return TextField(
      // Bloqueamos la selección y el portapapeles para obligar al usuario a usar el calendario
      enableInteractiveSelection: false,
      controller: _inputFieldController, // Enlazamos el controlador al input
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
        final dia = calendario.day.toString().padLeft(2, '0');
        final mes = calendario.month.toString().padLeft(2, '0');
        final anio = calendario.year.toString();

        _fecha = '$dia/$mes/$anio';
        _inputFieldController.text = _fecha;
      });
    }
  }
}
