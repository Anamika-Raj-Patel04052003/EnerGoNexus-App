import 'package:flutter/material.dart';

class DriverVehicleScreen extends StatelessWidget {
  const DriverVehicleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10192B),
        elevation: 0,
        title: const Text("EV Vehicle Telemetry & Health", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 1. VEHICLE PROFILE CARD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF131D31),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.4)),
                gradient: const LinearGradient(
                  colors: [Color(0xFF131D31), Color(0x2600F0FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.electric_car, color: Color(0xFF00F0FF), size: 38),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Tata Nexon EV Max (Dark Edition)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.5)),
                        Text("Plate: MP 04 EV 8891 • 40.5 kWh LFP Pack", style: TextStyle(color: Colors.white54, fontSize: 11)),
                        SizedBox(height: 2),
                        Text("🟢 Commercial EV Fleet Permit Active", style: TextStyle(color: Color(0xFF00E676), fontSize: 10.5, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 2. LIVE DIAGNOSTIC METRICS
            const Text("Live Battery & Drive Telemetry", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(child: _sensorCard("Battery SoC", "78%", "290 km Range", Icons.battery_charging_full, const Color(0xFF00E676))),
                const SizedBox(width: 10),
                Expanded(child: _sensorCard("Battery Health", "98.5%", "Temp: 28°C Optimal", Icons.health_and_safety, const Color(0xFF00F0FF))),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _sensorCard("Tire Pressure", "34 PSI", "All 4 Wheels Equal", Icons.tire_repair, Colors.amber)),
                const SizedBox(width: 10),
                Expanded(child: _sensorCard("Fast DC Speed", "50 kW", "CCS-2 Fast DC Ready", Icons.bolt, const Color(0xFFA855F7))),
              ],
            ),
            const SizedBox(height: 20),

            // 3. POWERTRAIN HEALTH CARD
            const Text("Powertrain & Ingress Status", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFF131D31), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
              child: Column(
                children: [
                  _telemetryRow("Motor Output", "143 PS / 250 Nm Instant Torque", const Color(0xFF00F0FF)),
                  _telemetryRow("Regenerative Braking", "Level 3 (Max Eco Harvesting)", const Color(0xFF00E676)),
                  _telemetryRow("Battery Ingress Rating", "IP67 Waterproof & Dustproof", const Color(0xFF00E676)),
                  _telemetryRow("Brake Pad Wear", "12% Wear (Healthy)", Colors.white70),
                  _telemetryRow("Last SuperHub Inspection", "15 Aug 2026 (Passed 100%)", Colors.amber),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sensorCard(String title, String value, String subtitle, IconData icon, Color col) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF131D31),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: col.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: col, size: 22),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          Text(value, style: TextStyle(color: col, fontSize: 18, fontWeight: FontWeight.bold)),
          Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 9.5)),
        ],
      ),
    );
  }

  Widget _telemetryRow(String label, String value, Color col) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11.5)),
          Text(value, style: TextStyle(color: col, fontSize: 11.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}