import 'dart:async';
import 'package:flutter/material.dart';

import '../../services/energo_unified_service.dart';
import 'ride_dispatch_screen.dart';
import 'vehicle_approval_screen.dart';

class SubAdminDashboardScreen extends StatefulWidget {
  const SubAdminDashboardScreen({super.key});

  @override
  State<SubAdminDashboardScreen> createState() => _SubAdminDashboardScreenState();
}

class _SubAdminDashboardScreenState extends State<SubAdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  String _getTimeRemaining(DateTime? until) {
    if (until == null) return "Available (Free)";
    final diff = until.difference(DateTime.now());
    if (diff.isNegative) return "Available (Free)";
    final mins = diff.inMinutes;
    final secs = diff.inSeconds % 60;
    return "Booked (${mins}m ${secs}s left)";
  }

  @override
  Widget build(BuildContext context) {
    final service = EnerGoUnifiedService();

    return AnimatedBuilder(
      animation: service,
      builder: (context, child) {
        final currentStation = service.stations[0]; // MP Nagar SuperHub
        final ports = currentStation['ports'] as List;
        final parking = currentStation['parking'] as List;
        final beds = currentStation['beds'] as List;
        final tables = currentStation['tables'] as List;

        return Scaffold(
          backgroundColor: const Color(0xFF080E1A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF10192B),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pushReplacementNamed(context, '/role-selection'),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Sub-Admin Live Station Deck", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                Text(currentStation['name'] as String, style: const TextStyle(color: Color(0xFFFFB703), fontSize: 11)),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.verified_user, color: Color(0xFF00F0FF)),
                tooltip: "Driver KYC Approvals",
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VehicleApprovalScreen())),
              ),
              IconButton(
                icon: const Icon(Icons.radar, color: Color(0xFF00E676)),
                tooltip: "Live Ride Dispatch",
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RideDispatchScreen())),
              ),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // STATION STATS HERO
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131D31),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFFFB703).withOpacity(0.4)),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF131D31), Color(0x26FFB703)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Operator: Manoj Tiwari (Badge: OP-8821)", style: TextStyle(color: Colors.white70, fontSize: 11.5)),
                          Text("🟢 Grid 415V Normal", style: TextStyle(color: Color(0xFF00E676), fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Station Revenue Today", style: TextStyle(color: Colors.white54, fontSize: 11)),
                              Text("₹ 27,380.00", style: TextStyle(color: Color(0xFF00E676), fontSize: 22, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("Energy Dispensed", style: TextStyle(color: Colors.white54, fontSize: 11)),
                              Text("1,480 kWh", style: TextStyle(color: Color(0xFF00F0FF), fontSize: 20, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // 4 AMENITY TABS
                Container(
                  decoration: BoxDecoration(color: const Color(0xFF131D31), borderRadius: BorderRadius.circular(12)),
                  child: TabBar(
                    controller: _tabCtrl,
                    indicatorColor: const Color(0xFFFFB703),
                    labelColor: const Color(0xFFFFB703),
                    unselectedLabelColor: Colors.white54,
                    labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    tabs: const [
                      Tab(icon: Icon(Icons.bolt, size: 18), text: "Ports"),
                      Tab(icon: Icon(Icons.local_parking, size: 18), text: "Parking"),
                      Tab(icon: Icon(Icons.bed, size: 18), text: "Snooze Beds"),
                      Tab(icon: Icon(Icons.local_cafe, size: 18), text: "Cafe Tables"),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                SizedBox(
                  height: 320,
                  child: TabBarView(
                    controller: _tabCtrl,
                    children: [
                      // TAB 1: EV PORTS
                      ListView.builder(
                        itemCount: ports.length,
                        itemBuilder: (context, i) {
                          final p = ports[i] as Map<String, dynamic>;
                          final isOcc = p['isOccupied'] as bool;
                          final col = isOcc ? Colors.redAccent : const Color(0xFF00E676);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: const Color(0xFF131D31), borderRadius: BorderRadius.circular(12), border: Border.all(color: col.withOpacity(0.35))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.bolt, color: col, size: 20),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("${p['id']} (${p['power']})", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.5)),
                                        Text(isOcc ? "${p['bookedBy']}" : "Vacant & Ready", style: const TextStyle(color: Colors.white54, fontSize: 10)),
                                      ],
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: col.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                                  child: Text(isOcc ? _getTimeRemaining(p['bookedUntil']) : "🟢 FREE", style: TextStyle(color: col, fontSize: 9.5, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      // TAB 2: PARKING BAYS
                      ListView.builder(
                        itemCount: parking.length,
                        itemBuilder: (context, i) {
                          final b = parking[i] as Map<String, dynamic>;
                          final isOcc = b['isOccupied'] as bool;
                          final col = isOcc ? Colors.redAccent : const Color(0xFF00F0FF);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: const Color(0xFF131D31), borderRadius: BorderRadius.circular(12), border: Border.all(color: col.withOpacity(0.35))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.local_parking, color: col, size: 20),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("${b['id']} (${b['name']})", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.5)),
                                        Text(isOcc ? "Vehicle Plate: ${b['plate']}" : "Vacant Bay", style: const TextStyle(color: Colors.white54, fontSize: 10)),
                                      ],
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: col.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                                  child: Text(isOcc ? _getTimeRemaining(b['bookedUntil']) : "🟢 FREE", style: TextStyle(color: col, fontSize: 9.5, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      // TAB 3: REST SNOOZE BEDS
                      ListView.builder(
                        itemCount: beds.length,
                        itemBuilder: (context, i) {
                          final bed = beds[i] as Map<String, dynamic>;
                          final isOcc = bed['isOccupied'] as bool;
                          final col = isOcc ? Colors.redAccent : const Color(0xFFA855F7);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: const Color(0xFF131D31), borderRadius: BorderRadius.circular(12), border: Border.all(color: col.withOpacity(0.35))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.bed, color: col, size: 20),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("${bed['id']} (${bed['name']})", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.5)),
                                        Text(isOcc ? "Occupant: ${bed['occupant']}" : "Sanitized & Vacant", style: const TextStyle(color: Colors.white54, fontSize: 10)),
                                      ],
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: col.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                                  child: Text(isOcc ? _getTimeRemaining(bed['bookedUntil']) : "🟢 FREE", style: TextStyle(color: col, fontSize: 9.5, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      // TAB 4: CAFE & WORK TABLES
                      ListView.builder(
                        itemCount: tables.length,
                        itemBuilder: (context, i) {
                          final t = tables[i] as Map<String, dynamic>;
                          final isOcc = t['isOccupied'] as bool;
                          final col = isOcc ? Colors.redAccent : const Color(0xFFFFB703);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: const Color(0xFF131D31), borderRadius: BorderRadius.circular(12), border: Border.all(color: col.withOpacity(0.35))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.local_cafe, color: col, size: 20),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("${t['id']} (${t['name']})", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.5)),
                                        Text(isOcc ? "Guest: ${t['guest']}" : "Vacant Desk", style: const TextStyle(color: Colors.white54, fontSize: 10)),
                                      ],
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: col.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                                  child: Text(isOcc ? _getTimeRemaining(t['bookedUntil']) : "🟢 FREE", style: TextStyle(color: col, fontSize: 9.5, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}