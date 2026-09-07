import 'package:flutter/material.dart';
import 'driver_login_screen.dart';
import 'broker_login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  void _showAdminPortModal(BuildContext context, String title, String roleBadge) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161F30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFF00E5FF))),
        title: Row(
          children: [
            const Icon(Icons.shield, color: Color(0xFF00E5FF), size: 22),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Role: $roleBadge", style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 10),
            const Text(
              "Station Sub-Admin & Supreme Admin HQ enterprise terminals run securely on Enterprise Admin Port 8081 (http://localhost:8081).",
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5FF), foregroundColor: Colors.black),
            onPressed: () => Navigator.pop(ctx),
            child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.bolt, color: Color(0xFF00E5FF), size: 24),
            SizedBox(width: 8),
            Text("EnerGo Nexus Ecosystem", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF162544), Color(0xFF0F172A)]),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.electric_bolt, color: Color(0xFF00E5FF), size: 36),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Select Operating Portal", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("MNC-Grade Smart EV Mobility & 4 Mega SuperHubs Grid", style: TextStyle(color: Colors.white60, fontSize: 11)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildRoleCard(
              title: "Passenger SuperApp Portal",
              sub: "Book EV Rides, Reserve SuperHub Fast DC Ports & Snooze Pods, 5% Cashback",
              icon: Icons.person_pin_circle,
              color: const Color(0xFF00E5FF),
              badge: "PUBLIC RIDER",
              onTap: () => Navigator.pushNamed(context, '/home'),
            ),

            _buildRoleCard(
              title: "Driver Cockpit (Solo & Fleet)",
              sub: "Live GPS Radar, 15s Ride Accept, EV Telemetry, SuperHub Pass, Daily Wages",
              icon: Icons.local_taxi,
              color: const Color(0xFF10B981),
              badge: "EV DRIVER",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (ctx) => const DriverLoginScreen()),
                );
              },
            ),

            _buildRoleCard(
              title: "Fleet Broker Enterprise ERP",
              sub: "Manage 10-500+ EVs, Add Driver/Vehicle KYC, Central Vault, 1-Tap Payroll",
              icon: Icons.business_center,
              color: const Color(0xFFFFD54F),
              badge: "FLEET BROKER",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (ctx) => const BrokerLoginScreen()),
                );
              },
            ),

            _buildRoleCard(
              title: "Station Sub-Admin Terminal",
              sub: "Local SuperHub Control: 8 DC Chargers, Ultrasonic Parking Bay Barriers, Snooze Pods",
              icon: Icons.hub,
              color: const Color(0xFFEC4899),
              badge: "STATION SUB-ADMIN",
              onTap: () => _showAdminPortModal(context, "Station Sub-Admin Terminal", "Port 8081 Sub-Admin Access"),
            ),

            _buildRoleCard(
              title: "Supreme Admin Master HQ",
              sub: "Master City Grid Load (1.84 MW), Global Dispatch Radar, 1-Click KYC Approvals",
              icon: Icons.shield,
              color: const Color(0xFF38BDF8),
              badge: "SUPREME ROOT ACCESS",
              onTap: () => _showAdminPortModal(context, "Supreme Admin Master HQ", "Port 8081 Master HQ Access"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String sub,
    required IconData icon,
    required Color color,
    required String badge,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF161F30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
              child: Text(badge, style: TextStyle(color: color, fontSize: 8.5, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(sub, style: const TextStyle(color: Colors.white60, fontSize: 11)),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 14),
      ),
    );
  }
}