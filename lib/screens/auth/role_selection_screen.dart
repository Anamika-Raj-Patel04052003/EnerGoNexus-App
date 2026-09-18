import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'passenger_login_screen.dart';
import 'passenger_register_screen.dart';
import 'driver_login_screen.dart';
import 'driver_register_screen.dart';
import 'broker_login_screen.dart';
import 'broker_register_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  void _openAuth(BuildContext context, String role, bool isLogin) {
    Widget targetScreen;
    if (role == 'passenger') {
      targetScreen = isLogin ? const PassengerLoginScreen() : const PassengerRegisterScreen();
    } else if (role == 'driver') {
      targetScreen = isLogin ? const DriverLoginScreen() : const DriverRegisterScreen();
    } else {
      targetScreen = isLogin ? const BrokerLoginScreen() : const BrokerRegisterScreen();
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => targetScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // App Logo / Title
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E5FF).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.zap, size: 48, color: Color(0xFF00E5FF)),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'EnerGo Nexus',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const Center(
                child: Text(
                  'Select your profile to Login or Register',
                  style: TextStyle(color: Colors.white60, fontSize: 14),
                ),
              ),
              const SizedBox(height: 36),

              // Role Cards
              Expanded(
                child: ListView(
                  children: [
                    _buildRoleCard(
                      context,
                      title: 'Passenger / Commuter',
                      subtitle: 'Book rides, schedule shared shuttles & pay cashless',
                      icon: LucideIcons.user,
                      color: const Color(0xFF00E5FF),
                      onLogin: () => _openAuth(context, 'passenger', true),
                      onRegister: () => _openAuth(context, 'passenger', false),
                    ),
                    const SizedBox(height: 16),
                    _buildRoleCard(
                      context,
                      title: 'Pilot / Driver (Solo & Fleet)',
                      subtitle: 'Accept rides, OTP trip start & instant bank payouts',
                      icon: LucideIcons.car,
                      color: const Color(0xFF10B981),
                      onLogin: () => _openAuth(context, 'driver', true),
                      onRegister: () => _openAuth(context, 'driver', false),
                    ),
                    const SizedBox(height: 16),
                    _buildRoleCard(
                      context,
                      title: 'Fleet Broker / Partner',
                      subtitle: 'Manage multi-cab fleet, drivers & vault settlements',
                      icon: LucideIcons.building2,
                      color: const Color(0xFFF59E0B),
                      onLogin: () => _openAuth(context, 'broker', true),
                      onRegister: () => _openAuth(context, 'broker', false),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onLogin,
    required VoidCallback onRegister,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Login', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: onRegister,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: color),
                    foregroundColor: color,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Register', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}