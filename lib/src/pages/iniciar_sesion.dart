// ignore_for_file: avoid_print
/*
Para crear el efecto visual de un difuminado de colores segun la paleta de colores elegida vamos a usar 
una combinación de Stack, un LinearGradient ambiental de fondo, y el widget BackdropFilter para generar el desenfoque suave.

Además, usaremos el algoritmo de luminancia que ya tenemos implementado en ThemeModifierProvider. Separaremos los colores de forma automática: los 
tonos base se van al fondo difuminado, y el color de acento más contrastante (el que no forma la parte de atrás) se inyectará en los bordes de los 
inputs y los botones primarios para darles impacto visual.
*/
import 'package:flutter/material.dart';
import 'dart:ui'; // Obligatorio para usar ImageFilter (el difuminado)
import 'package:provider/provider.dart';
import '../provider/theme_provider.dart';
import '../services/auth_service.dart';
class InicioSesion extends StatefulWidget {
  const InicioSesion({super.key, required this.title});
  final String title;
  @override
  State<InicioSesion> createState() => IniciarSesion();
}

class IniciarSesion extends State<InicioSesion> {
  List <dynamic> usuarios=[];
  final TextEditingController correoController= TextEditingController();
  final TextEditingController contraController= TextEditingController();
  final TextEditingController _iniciarSesion = TextEditingController();
  @override
  void initState() {
    super.initState();
    _iniciarSesion.text = 'valor inicial del input'; // Inicializamos vacío para un login real
    _iniciarSesion.addListener(() {
      print('el valor del input es: ${_iniciarSesion.text}');
    });
  }

  @override
  void dispose() {
    _iniciarSesion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Tomamos la paleta de colores activa de tu ThemeProvider
    final themeProvider = context.watch<ThemeModifierProvider>();
    final colores = themeProvider.currentPalette.colors;

    // Aseguramos tener al menos dos colores para el degradado de fondo
    final colorFondo1 = colores.first;
    final colorFondo2 = colores.length > 2 ? colores[1] : colores.last;
    
    // El color de acento (el que resalta y no se pierde en el fondo)
    final colorAcento = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: Stack(
        children: [
          // Capa 1: El degradado dinámico de fondo (Base ambiental)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colorFondo1, colorFondo2, Colors.black],
              ),
            ),
          ),

          // Capa 2: Contenido con el contenedor efecto vidrio (Glassmorphism) de image_f49d43.jpg
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    // Aquí controlamos qué tan difuminado se ve el degradado de atrás
                    filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                    child: Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: themeProvider.isDarkMode ? 0.06 : 0.4),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Welcome',
                            style: TextStyle(
                              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 30),
                          _crearEmail(colorAcento),
                          const SizedBox(height: 20),
                          _crearPassword(colorAcento),
                          const SizedBox(height: 35),
                          _iniciarsesion(colorAcento),
                          const SizedBox(height: 16),
                          _crearRegistro(colorAcento),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Inputs con bordes estilizados usando el color de acento
  Widget _crearEmail(Color activeColor) {
    return TextField(
      controller: correoController,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.black12,
        prefixIcon: Icon(Icons.email, color: activeColor.withValues(alpha: 0.8)),
        suffixIcon: const Icon(Icons.alternate_email, color: Colors.white30),
        hintText: 'Correo electrónico',
        hintStyle: const TextStyle(color: Colors.white38),
        labelText: 'Correo electrónico',
        labelStyle: const TextStyle(color: Colors.white70),
        // Bordes inactivos sutiles
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        // Borde resaltado con el color que no forma la parte de atrás
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(color: activeColor, width: 2),
        ),
      ),
    );
  }

  Widget _crearPassword(Color activeColor) {
    return TextField(
      controller: contraController,
      obscureText: true,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.black12,
        prefixIcon: Icon(Icons.password, color: activeColor.withValues(alpha: 0.8)),
        suffixIcon: const Icon(Icons.lock_open, color: Colors.white30),
        hintText: 'Contraseña',
        hintStyle: const TextStyle(color: Colors.white38),
        labelText: 'Contraseña',
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(color: activeColor, width: 2),
        ),
      ),
    );
  }

  // Botón principal (Estilo píldora como el de la captura)
  Widget _iniciarsesion(Color activeColor) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: activeColor, // Toma el color destacado limpio
        minimumSize: const Size(double.infinity, 50),
        shape: const StadiumBorder(),
        elevation: 4,
      ),
      onPressed: () async {

        if (correoController.text.isNotEmpty && contraController.text.isNotEmpty) {
    // Mostramos un indicador de carga estético sobre el vidrio si deseas
    final exito = await AuthService().iniciarSesion(
      correo: correoController.text.trim(),
      contrasena: contraController.text.trim(),
    );

    if (exito) {
      if (mounted) Navigator.pushNamed(context, 'Navigator');
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario o contraseña erróneo')),
        );
      }
    }
  }
      },
      child: Text(
        'LOGIN', 
        style: TextStyle(
          fontSize: 16, 
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          color: activeColor.computeLuminance() > 0.5 ? Colors.black : Colors.white
        )
      ),
    );
  }

  // Botón secundario minimalista sin fondo sólido
  Widget _crearRegistro(Color activeColor) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        shape: const StadiumBorder(),
        side: BorderSide(color: activeColor, width: 1.5), // Borde de acento
      ),
      onPressed: () {
        Navigator.pushNamed(context, 'Registro');
      },
      child: const Text(
        'Sign Up', 
        style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600)
      ),
    );
  }
}
  /*
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
          const SizedBox(height: 25),
          _crearRegistro()
        ],
      ),
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

   Widget _crearRegistro() {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, 'Registro');
      },
      child: const Text('Registrarse', style: TextStyle(fontSize: 34)),
    );
  }

  Widget _iniciarsesion() {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, 'Navigator');
      },
      child: const Text('Iniciar Sesion', style: TextStyle(fontSize: 24)),
    );
  }
}
*/