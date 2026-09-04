import 'package:flutter/material.dart';

class RideDispatchScreen extends StatefulWidget {
  const RideDispatchScreen({super.key});

  @override
  State<RideDispatchScreen> createState() => _RideDispatchScreenState();
}

class _RideDispatchScreenState extends State<RideDispatchScreen> {
  final List<Map<String, dynamic>> _liveDispatches = [
    {
      'id': 'DISP-8842',
      'passenger': 'Anamika Choudhary (⭐ 4.9)',
      'driver': 'Suresh Verma (Tata Nexon EV Max)',
      'plate': 'MP 04 EV 8891',
      'pickup': 'Zone 1, MP Nagar',
      'drop': 'Raja Bhoj Airport, VIP Road',
      'fare': 120.0,
      'status': 'IN_TRANSIT 🔵',
      'speed': '42 km/h (ETA: 8m)',
    },
    {
      'id': 'DISP-8839',
      'passenger': 'Rahul Sharma (⭐ 4.8)',
      'driver': 'Rajesh Patel (MG ZS EV)',
      'plate': 'MP 04 ZS 2210',
      'pickup': 'ISBT Bus Terminal',
      'drop': 'Bittan Market, Arera Colony',
      'fare': 180.0,
      'status': 'ASSIGNED 🟡',
      'speed': 'At Pickup Spot',
    },
    {
      'id': 'DISP-8835',
      'passenger': 'Pooja Verma (⭐ 5.0)',
      'driver': 'Amitabh Roy (Mahindra Treo Auto)',
      'plate': 'MP 04 TR 5541',
      'pickup': 'Shahpura Lake Promenade',
      'drop': 'Bhopal Junction Platform 1',
      'fare': 150.0,
      'status': 'COMPLETED 🟢',
      'speed': 'Trip Settled (Paid)',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10192B),
        elevation: 0,
        title: const Text("Live Ride Dispatch Radar", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF131D31),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF00E676).withOpacity(0.35)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text("Active Dispatches", style: TextStyle(color: Colors.white54, fontSize: 11)),
                      Text("2 Live", style: TextStyle(color: Color(0xFF00E676), fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    children: [
                      Text("Completed Today", style: TextStyle(color: Colors.white54, fontSize: 11)),
                      Text("142 Rides", style: TextStyle(color: Color(0xFF00F0FF), fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    children: [
                      Text("Avg Response", style: TextStyle(color: Colors.white54, fontSize: 11)),
                      Text("1.8 Mins", style: TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            const Text("Live GPS Fleet Tracking", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 10),

            ..._liveDispatches.map((d) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF131D31),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(d['id'] as String, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                      Text(d['status'] as String, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text("👤 Passenger: ${d['passenger']}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  Text("🚖 Captain: ${d['driver']} (${d['plate']})", style: const TextStyle(color: Color(0xFF00F0FF), fontSize: 11.5)),
                  const SizedBox(height: 4),
                  Text("📍 ${d['pickup']} ➔ ${d['drop']}", style: const TextStyle(color: Colors.white70, fontSize: 11)),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Telemetry: ${d['speed']}", style: const TextStyle(color: Colors.amber, fontSize: 10.5, fontWeight: FontWeight.w600)),
                      Text("₹ ${(d['fare'] as num).toInt()}", style: const TextStyle(color: Color(0xFF00E676), fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}