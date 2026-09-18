import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/auth/universal_auth_portal.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const EnerGoNexusApp());
}

class EnerGoNexusApp extends StatelessWidget {
  const EnerGoNexusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EnerGo Nexus Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0E17),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E5FF),
          secondary: Color(0xFF10B981),
          surface: Color(0xFF131B2E),
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      // App open hote hi sabse pehle ye Universal Login/Register Portal khulega
      home: const UniversalAuthPortal(),
    );
  }
} 