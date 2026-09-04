import 'package:flutter/material.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080E1A),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: [
            // HEADER LOGO
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF131D31),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF00E676), width: 1.5),
                ),
                child: const Icon(Icons.bolt, color: Color(0xFF00E676), size: 36),
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text("EnerGo SuperApp Gateway", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 4),
            const Center(
              child: Text("Select your portal role to continue", style: TextStyle(color: Colors.white54, fontSize: 12)),
            ),
            const SizedBox(height: 28),

            // 1. PASSENGER PORTAL
            _roleCard(
              context,
              title: "Passenger / EV Commuter",
              subtitle: "Book EV Rides, DC Fast Charging, Parking & 5% Cashback",
              icon: Icons.person,
              badge: "PUBLIC",
              color: const Color(0xFF00E676),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
            const SizedBox(height: 14),

            // 2. DRIVER CAPTAIN PORTAL
            _roleCard(
              context,
              title: "EV Fleet Captain (Driver)",
              subtitle: "Live Radar Dispatch, Turn-by-Turn GPS, Earnings & Telemetry",
              icon: Icons.local_taxi,
              badge: "CAPTAIN",
              color: const Color(0xFF00F0FF),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/driver');
              },
            ),
            const SizedBox(height: 14),

            // 3. SUB-ADMIN HUB OPERATOR
            _roleCard(
              context,
              title: "SuperHub Station Sub-Admin",
              subtitle: "Manage Port Chargers, Barrier Gates, Snooze Pods & Local Tariffs",
              icon: Icons.admin_panel_settings,
              badge: "STATION OPERATOR",
              color: const Color(0xFFFFB703),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/sub-admin');
              },
            ),
            const SizedBox(height: 14),

            // 4. SUPREME ADMIN ENTERPRISE HQ
            _roleCard(
              context,
              title: "Super Admin Enterprise HQ",
              subtitle: "Fleet Governance, Dynamic Surge, GST Audit & Platform Analytics",
              icon: Icons.shield,
              badge: "ENTERPRISE",
              color: const Color(0xFFA855F7),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/super-admin');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String badge,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF131D31),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.4), width: 1.2),
          gradient: LinearGradient(
            colors: [const Color(0xFF131D31), color.withOpacity(0.12)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.18), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                        child: Text(badge, style: TextStyle(color: color, fontSize: 8.5, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 10.5)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 14),
          ],
        ),
      ),
    );
  }
}