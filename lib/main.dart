import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';

void main() {
  runApp(
    const EnerGoNexusApp(),
  );
}


class EnerGoNexusApp extends StatelessWidget {

  const EnerGoNexusApp({super.key});


  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner:false,

      title:"EnerGoNexus",

      theme:AppTheme.darkTheme,


    home: const SplashScreen(),

    );

  }

}