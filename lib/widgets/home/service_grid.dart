import 'package:flutter/material.dart';

import '../../screens/charging/charging_booking_screen.dart';
import '../../screens/facility/cafe_table_screen.dart';
import '../../screens/facility/facility_booking_screen.dart';
import '../../screens/parking/parking_booking_screen.dart';

class ServiceGrid extends StatelessWidget {
  const ServiceGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTile(
                context,
                title: "EV Charging",
                subtitle: "120kW Fast DC",
                icon: Icons.ev_station,
                color: const Color(0xFF00E676),
                screen: const ChargingBookingScreen(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTile(
                context,
                title: "Smart Parking",
                subtitle: "IoT Sensor Bays",
                icon: Icons.local_parking,
                color: const Color(0xFF00F0FF),
                screen: const ParkingBookingScreen(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildTile(
                context,
                title: "Rest Lounges",
                subtitle: "24x7 AC Pods",
                icon: Icons.bed,
                color: const Color(0xFFA855F7),
                screen: const FacilityBookingScreen(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTile(
                context,
                title: "Cafe & Work",
                subtitle: "Desks & 5G WiFi",
                icon: Icons.local_cafe,
                color: const Color(0xFFFFB703),
                screen: const CafeTableScreen(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget screen,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF131D31),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color, width: 1.2),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}