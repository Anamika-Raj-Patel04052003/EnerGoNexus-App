import 'dart:async';
import 'package:flutter/material.dart';

import '../charging/charging_booking_screen.dart';
import '../facility/cafe_table_screen.dart';
import '../facility/facility_booking_screen.dart';
import '../parking/parking_booking_screen.dart';
import 'driver_active_ride_screen.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  bool _isOnline = true;
  int _radarTimer = 30;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startIncomingRequestCountdown();
  }

  void _startIncomingRequestCountdown() {
    _countdownTimer?.cancel();
    _radarTimer = 30;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_radarTimer > 1) {
        setState(() => _radarTimer--);
      } else {
        setState(() => _radarTimer = 30);
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080E1A),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          children: [
            // 1. CAPTAIN COCKPIT HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF00E676), width: 2),
                      ),
                      child: const CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFF131D31),
                        child: Icon(Icons.person, color: Color(0xFF00E676), size: 24),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text("Suresh Verma", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                            SizedBox(width: 6),
                            Text("⭐ 4.9", style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Text("⚡ Tata Nexon EV Max • MP 04 EV 8891", style: TextStyle(color: Color(0xFF00F0FF), fontSize: 10.5, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => setState(() => _isOnline = !_isOnline),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _isOnline ? const Color(0x3300E676) : const Color(0x26FF5252),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _isOnline ? const Color(0xFF00E676) : Colors.redAccent, width: 1.2),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(color: _isOnline ? const Color(0xFF00E676) : Colors.redAccent, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isOnline ? "ON DUTY" : "OFF DUTY",
                          style: TextStyle(color: _isOnline ? const Color(0xFF00E676) : Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // 2. TODAY'S SHIFT METRICS HUD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF131D31),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF00E676).withOpacity(0.35), width: 1.2),
              ),
              child: const Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Today's Net Earning", style: TextStyle(color: Colors.white54, fontSize: 11)),
                          SizedBox(height: 2),
                          Text("₹ 2,450.00", style: TextStyle(color: Color(0xFF00E676), fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Icon(Icons.account_balance_wallet, color: Color(0xFF00E676), size: 28),
                    ],
                  ),
                  Divider(color: Colors.white12, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("8 Trips Done", style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold)),
                      Text("5h 20m Online", style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold)),
                      Text("78% (290 km)", style: TextStyle(color: Color(0xFF00E676), fontSize: 11.5, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. INCOMING RIDE REQUEST RADAR
            if (_isOnline) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF131D31),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF00F0FF), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.radar, color: Color(0xFF00F0FF), size: 18),
                            SizedBox(width: 8),
                            Text("Incoming Ride Match!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                          child: Text("⏱️ ${_radarTimer}s left", style: const TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white12, height: 18),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Passenger: Anamika Choudhary", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        Text("₹ 120.00", style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text("📍 Pickup: Zone 1, MP Nagar (1.2 km away)", style: TextStyle(color: Color(0xFF00F0FF), fontSize: 11)),
                    const Text("🏁 Drop: Raja Bhoj Airport, VIP Road", style: TextStyle(color: Colors.white70, fontSize: 11)),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Ride Passed to next nearest driver."), backgroundColor: Colors.redAccent),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              decoration: BoxDecoration(
                                color: const Color(0xFF080E1A),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: const Center(
                                child: Text("Reject / Pass", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const DriverActiveRideScreen()),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00E676),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(
                                child: Text("Accept Ride Request", style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 4. SUPERHUB AMENITIES GRID FOR DRIVERS
            const Text("SuperHub Driver Amenities & Booking", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.5)),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _driverHubTile(
                    title: "EV Charging",
                    subtitle: "120kW Fast DC",
                    icon: Icons.ev_station,
                    color: const Color(0xFF00E676),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChargingBookingScreen())),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _driverHubTile(
                    title: "Driver Parking",
                    subtitle: "Priority Sensor Bays",
                    icon: Icons.local_parking,
                    color: const Color(0xFF00F0FF),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ParkingBookingScreen())),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _driverHubTile(
                    title: "Rest Snooze Pods",
                    subtitle: "AC Nap Cabins",
                    icon: Icons.bed,
                    color: const Color(0xFFA855F7),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FacilityBookingScreen())),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _driverHubTile(
                    title: "Driver Cafe",
                    subtitle: "5G WiFi & Coffee",
                    icon: Icons.local_cafe,
                    color: const Color(0xFFFFB703),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CafeTableScreen())),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _driverHubTile({required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF131D31),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.35), width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.5)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 9.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}