import 'package:flutter/material.dart';
import 'login_page.dart'; // Zorg dat dit bestand bestaat

void main() {
  runApp(const SwapazaApp());
}

class SwapazaApp extends StatelessWidget {
  const SwapazaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swapaza',
      theme: ThemeData.light(),
      home: const LoginPage(),
    );
  }
}
