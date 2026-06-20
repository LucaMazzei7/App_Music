
import 'package:flutter/material.dart';

import 'routes/routes.dart';
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music App',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: getApplicationRoutes(),
      theme: ThemeData(
      
        colorScheme: .fromSeed(seedColor: const Color.fromARGB(255, 100, 165, 25)),
      ),
      
    );
  }
}