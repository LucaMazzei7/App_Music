/* 
Este archivo controlará si la app está en modo claro/oscuro, qué paleta de 
colores secundaria (acentos) está activa y qué imagen de fondo se debe 
renderizar.
*/

/*Para que la app asigne cada color en el lugar correcto (botones, fondos, textos), implementaremos una función inteligente que ordene los colores recibidos basándose en su brillo/luminancia. De esta forma:
En Modo Claro, el color más claro se usará automáticamente como fondo principal, y los tonos más oscuros para textos y acentos.
En Modo Oscuro, invertimos la lógica: el color más oscuro va al fondo principal, el más claro/vibrante resalta los botones o textos primarios, y se calculan contrastes en tiempo real para evitar que una letra quede ilegible.
 */

import 'package:flutter/material.dart';

class CustomPalette {
  final String name;
  final List<Color> colors; // Máximo 5 colores

  CustomPalette({required this.name, required this.colors});
}

class ThemeModifierProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  String? _backgroundImagePath; // Ruta de la imagen de fondo elegida

  // Paletas por Defecto (Sacadas de tus imágenes)
  final List<CustomPalette> _defaultPalettes = [
    CustomPalette(
      name: 'Botanical',
      colors: [
        const Color(0xFFF7EFDA), // Parchment
        const Color(0xFFBADD7F), // Pistachio
        const Color(0xFFEFACA5), // Melon
        const Color(0xFF3E8440), // Fern Green
      ],
    ),
    CustomPalette(
      name: 'Powder Blush',
      colors: [
        const Color(0xFFF2FFE9), // Honeydew
        const Color(0xFFF2A4A5), // Powder Blush
        const Color(0xFFE5D4C5), // Almond Cream
        const Color(0xFF3078A4), // Rich Cerulean
        const Color(0xFF090087), // Navy
      ],
    ),
    CustomPalette(
      name: 'Tomato Jam',
      colors: [
        const Color(0xFFF6FFEA), // Honeydew
        const Color(0xFFFFDE96), // Soft Peach
        const Color(0xFFFA855A), // Coral Glow
        const Color(0xFFC9363B), // Tomato Jam
        const Color(0xFF62C4DA), // Sky Blue
      ],
    ),
  ];

  // Paletas personalizadas creadas por el usuario
  final List<CustomPalette> _userPalettes = [];

  // Paleta seleccionada actualmente (Arranca con Botanical)
  late CustomPalette _currentPalette;

  ThemeModifierProvider() {
    _currentPalette = _defaultPalettes[0];
  }

  // Getters
  bool get isDarkMode => _isDarkMode;
  String? get backgroundImagePath => _backgroundImagePath;
  List<CustomPalette> get allPalettes => [..._defaultPalettes, ..._userPalettes];
  CustomPalette get currentPalette => _currentPalette;

  // Cambiar Modo Claro/Oscuro
  void toggleTheme(bool darkMode) {
    _isDarkMode = darkMode;
    notifyListeners();
  }

  // Seleccionar una paleta
  void selectPalette(CustomPalette palette) {
    _currentPalette = palette;
    notifyListeners();
  }

  // Agregar una paleta propia (Máximo 5 colores)
  void addUserPalette(String name, List<Color> colors) {
    if (colors.length > 5) return;
    _userPalettes.add(CustomPalette(name: name, colors: colors));
    notifyListeners();
  }

  void setBackgroundImage(String? path) {
    _backgroundImagePath = path;
    notifyListeners();
  }

  //Recibe el color extraído por el ReproductorProvider
  // y genera una paleta equilibrada de 4 tonos armónicos basados en él.
  void actualizarColorSintonizado(Color? nuevoColor) {
    if (nuevoColor == null) return;

    // Generamos variaciones de brillo y opacidad para abastecer a tu algoritmo de luminancia
    final colorFondoSimulado = Color.alphaBlend(nuevoColor.withValues(alpha: 0.1), const Color(0xFF1F1F1F));
    final colorIntermedio1 = Color.alphaBlend(nuevoColor.withValues(alpha: 0.4), Colors.grey);
    final colorIntermedio2 = nuevoColor; 
    final colorResaltado = Color.alphaBlend(Colors.white.withValues(alpha: 0.3), nuevoColor);

    // Creamos la paleta dinámica instantánea
    _currentPalette = CustomPalette(
      name: 'Sintonía',
      colors: [
        colorFondoSimulado,
        colorIntermedio1,
        colorIntermedio2,
        colorResaltado,
      ],
    );

    // Avisamos a la UI para que haga la magia del cambio de color
    notifyListeners();
  }

  /// ALGORITMO: Distribuye los colores dinámicamente según el Brillo (Luminance)
  ThemeData get currentTheme {
    // Ordenamos una copia de los colores de la paleta de menor a mayor brillo
    List<Color> sortedColors = List.from(_currentPalette.colors);
    sortedColors.sort((a, b) => a.computeLuminance().compareTo(b.computeLuminance()));

    Color baseBackground;
    Color baseSurface;
    Color primaryAccent;
    Color textColor;

    if (_isDarkMode) {
      // MODO OSCURO:
      // Fondo: El color más oscuro de la paleta. Si es muy brillante, usamos un carbón base
      baseBackground = sortedColors.first.computeLuminance() < 0.15 
          ? sortedColors.first 
          : const Color(0xFF121212);
      
      baseSurface = Color.alphaBlend(Colors.white12, baseBackground);

      // Acento: Buscamos el color intermedio que sea más vivo/vibrante para los botones
      primaryAccent = sortedColors.length > 2 ? sortedColors[sortedColors.length - 2] : sortedColors.last;
      textColor = Colors.white;
    } else {
      // MODO CLARO:
      // Fondo: El color más claro de la paleta
      baseBackground = sortedColors.last.computeLuminance() > 0.85 
          ? sortedColors.last 
          : const Color(0xFFF5F5F5);
      
      baseSurface = Colors.white;

      // Acento: El color más oscuro/intenso de la paleta para que tenga buen contraste
      primaryAccent = sortedColors.first.computeLuminance() < 0.4 ? sortedColors.first : sortedColors[1];
      textColor = Colors.black87;
    }

    return ThemeData(
      brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryAccent,
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        primary: primaryAccent,
        surface: baseSurface,
      ),
      scaffoldBackgroundColor: baseBackground,
      // Aplicación automática a tipografías globales
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: textColor),
        bodyMedium: TextStyle(color: textColor.withValues(alpha: 0.7)),
        titleLarge: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      ),
    );
  }
}