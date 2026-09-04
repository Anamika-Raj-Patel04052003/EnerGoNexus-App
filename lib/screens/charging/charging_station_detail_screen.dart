import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import 'charging_booking_screen.dart';

class ChargingStationDetailScreen extends StatelessWidget {
  final dynamic stationId;
  final Map<String, dynamic>? station;

  const ChargingStationDetailScreen({
    super.key,
    this.stationId,
    this.station,
  });

  Map<String, dynamic> get _activeStation => station ?? {
    'id': stationId?.toString() ?? 'CS-230071',
    'name': 'EnerGo Central SuperHub',
    'station_name': 'EnerGo Central SuperHub',
    'city': 'Bhopal',
    'address': 'Plot 14, Zone 1, MP Nagar',
    'price_per_kwh': 18.50,
  };

  @override
  Widget build(BuildContext context) {
    final name = _activeStation['name'] ?? _activeStation['station_name'] ?? 'EnerGo Central SuperHub';
    final city = _activeStation['city'] ?? 'Bhopal';
    final address = _activeStation['address'] ?? 'Plot 14, MP Nagar';
    final tariff = (_activeStation['price_per_kwh'] as num?)?.toDouble() ?? 18.50;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(LucideIcons.arrowLeft)),
        title: const Text("Station Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Station Hero Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.primaryGreen.withValues(alpha: 0.15), shape: BoxShape.circle),
                      child: const Icon(LucideIcons.zap, color: AppColors.primaryGreen, size: 28),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.primaryGreen.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                      child: Text("₹ $tariff / kWh", style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text("📍 $city • $address", style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Amenities Matrix
          const Text("Available Amenities at SuperHub", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildAmenityChip("⚡ 120kW Fast DC Ports", AppColors.primaryGreen),
              _buildAmenityChip("🅿️ Smart Sensor Parking", const Color(0xFF00F0FF)),
              _buildAmenityChip("🛏️ 24x7 AC Rest Lounges", const Color(0xFFA855F7)),
              _buildAmenityChip("☕ Cafeteria & WiFi Desks", const Color(0xFFFFB703)),
              _buildAmenityChip("🔋 BESS Grid Energy Reserve", AppColors.primaryGreen),
            ],
          ),
          const SizedBox(height: 28),

          // Book Slot Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChargingBookingScreen(station: _activeStation)),
                );
              },
              icon: const Icon(LucideIcons.plugZap, size: 20),
              label: const Text("Select Live Port & Book Charging", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.w600)),
    );
  }
}