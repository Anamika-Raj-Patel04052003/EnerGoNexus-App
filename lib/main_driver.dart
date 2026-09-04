import 'package:flutter/material.dart';

import 'screens/driver/driver_main_navigation.dart';
import 'services/energo_unified_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnergoUnifiedService().init();
  runApp(const EnerGoDriverApp());
}

class EnerGoDriverApp extends StatelessWidget {
  const EnerGoDriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EnerGo Captain Driver App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF080E1A),
        primaryColor: const Color(0xFF00F0FF),
      ),
      // 100% DIRECT DRIVER CAPTAIN COCKPIT
      home: const DriverMainNavigation(),
    );
  }
}