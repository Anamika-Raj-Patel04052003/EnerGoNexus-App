import 'package:flutter/material.dart';

import 'screens/auth/supreme_admin_login_screen.dart';
import 'screens/auth/supreme_admin_register_screen.dart';
import 'screens/auth/admin_login_screen.dart';
import 'screens/auth/admin_register_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/super_admin/super_admin_dashboard.dart'; // ✅ Clean Single Import

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EnerGoNexusAdminApp());
}

class EnerGoNexusAdminApp extends StatelessWidget {
  const EnerGoNexusAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EnerGoNexus Admin Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),
      home: const SupremeAdminLoginScreen(),
      routes: {
        '/supreme-admin/login': (context) => const SupremeAdminLoginScreen(),
        '/supreme-admin/register': (context) => const SupremeAdminRegisterScreen(),
        '/supreme-admin/dashboard': (context) => const SuperAdminDashboard(),
        '/admin/login': (context) => const AdminLoginScreen(),
        '/admin/register': (context) => const AdminRegisterScreen(),
        '/admin/dashboard': (context) => const AdminDashboard(),
      },
    );
  }
}