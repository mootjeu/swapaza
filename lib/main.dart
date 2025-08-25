import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart'; // Zorg dat dit bestand bestaat

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 📡 Supabase initialisatie met jouw projectgegevens
    await Supabase.initialize(
      url: 'https://cpmqavmffgzoetjeiypu.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNwbXFhdm1mZmd6b2V0amVpeXB1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYwNTY4NzAsImV4cCI6MjA3MTYzMjg3MH0._OJbEWeWnyZCIBA9T7OG_bOeVY8PoKJcI01s9aPgn4s',
    );
    print('✅ Supabase succesvol geïnitialiseerd');
  } catch (e) {
    print('❌ Fout bij Supabase-initialisatie: $e');
  }

  // 🎨 Statusbar stijl instellen
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const SwapazaApp());
}

class SwapazaApp extends StatelessWidget {
  const SwapazaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Swapaza',
      theme: ThemeData.light(),
      home: const LoginPage(), // Startscherm van je app
    );
  }
}
