import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/theme_provider.dart';

//version preliminar, hay que conectarlo con los permisos de usuario

class ThemeBackground extends StatelessWidget {
  final Widget child;

  const ThemeBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeModifierProvider>();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        image: themeProvider.backgroundImagePath != null
            ? DecorationImage(
                image: FileImage(File(themeProvider.backgroundImagePath!)),
                fit: BoxFit.cover,
                // Le da una opacidad oscura en modo noche para que no tape las letras
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha:0.65),
                  BlendMode.darken,
                ),
              )
            : null,
      ),
      child: child,
    );
  }
}