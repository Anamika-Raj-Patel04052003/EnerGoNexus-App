import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../auth/role_selection_screen.dart';
import '../driver/driver_main_navigation.dart';
import '../main/main_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnim = Tween<double>(begin: 0.8, end: 1.05).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeIn),
    );

    _ctrl.forward();

    // Navigate smoothly after 2 seconds
    Timer(const Duration(milliseconds: 2200), _checkAuthAndNavigate);
  }

  void _checkAuthAndNavigate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final role = prefs.getString('user_role');

      if (!mounted) return;

      if (role == 'driver') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DriverMainNavigation()),
        );
      } else if (role == 'passenger') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigation()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
        );
      }
    } catch (_) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
      );
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Glowing EnerGo Logo / Icon
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryGreen, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withValues(alpha: 0.4),
                        blurRadius: 30,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/home/logoEnergo.png',
                    height: 80,
                    errorBuilder: (_, __, ___) => const Icon(
                      LucideIcons.zap,
                      color: AppColors.primaryGreen,
                      size: 60,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                const Text(
                  "EnerGoNexus",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Unified EV SuperHub & Fleet Network",
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 40),

                // Modern Loading Ring
                const SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}