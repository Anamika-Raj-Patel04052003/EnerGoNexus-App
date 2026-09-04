import 'package:flutter/material.dart';

class DriverHistoryScreen extends StatefulWidget {
  const DriverHistoryScreen({super.key});

  @override
  State<DriverHistoryScreen> createState() => _DriverHistoryScreenState();
}

class _DriverHistoryScreenState extends State<DriverHistoryScreen> {
  String _selectedFilter = "ALL";

  final List<Map<String, dynamic>> _history = [
    {
      'id': 'TRIP-9842',
      'passenger': 'Anamika Choudhary',
      'pickup': 'Zone 1, MP Nagar',
      'dropoff': 'Raja Bhoj Airport, VIP Road',
      'distance': '4.2 km (12 Mins)',
      'fare': 120.0,
      'tip': 50.0,
      'status': 'COMPLETED',
      'date': 'Today, 02:45 PM',
      'rating': 5,
      'mode': 'Razorpay Online',
    },
    {
      'id': 'TRIP-9839',
      'passenger': 'Rahul Sharma',
      'pickup': 'ISBT Bus Terminal',
      'dropoff': 'Bittan Market, Arera Colony',
      'distance': '6.8 km (18 Mins)',
      'fare': 180.0,
      'tip': 20.0,
      'status': 'COMPLETED',
      'date': 'Today, 11:20 AM',
      'rating': 5,
      'mode': 'EnerGo Wallet',
    },
    {
      'id': 'TRIP-9831',
      'passenger': 'Vikram Mehta',
      'pickup': 'New Market Commercial',
      'dropoff': 'Kolar Road Phase 1',
      'distance': '8.1 km (24 Mins)',
      'fare': 210.0,
      'tip': 0.0,
      'status': 'REJECTED',
      'date': 'Yesterday, 06:15 PM',
      'rating': null,
      'mode': 'Cash on Spot',
    },
    {
      'id': 'TRIP-9824',
      'passenger': 'Pooja Verma',
      'pickup': 'Shahpura Lake Promenade',
      'dropoff': 'Bhopal Junction Platform 1',
      'distance': '5.4 km (15 Mins)',
      'fare': 150.0,
      'tip': 30.0,
      'status': 'COMPLETED',
      'date': 'Yesterday, 02:10 PM',
      'rating': 5,
      'mode': 'Razorpay Online',
    },
  ];

  void _showTripReceiptDialog(Map<String, dynamic> trip) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131D31),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: Color(0xFF00E676), width: 1.5)),
        title: Row(
          children: [
            const Icon(Icons.receipt_long, color: Color(0xFF00E676), size: 26),
            const SizedBox(width: 8),
            Text("Trip Summary (${trip['id']})", style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Passenger: ${trip['passenger']}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            Text("${trip['date']} • ${trip['mode']}", style: const TextStyle(color: Colors.white54, fontSize: 10.5)),
            const Divider(color: Colors.white12, height: 16),
            Text("📍 Pickup: ${trip['pickup']}", style: const TextStyle(color: Colors.white70, fontSize: 11.5)),
            Text("🏁 Drop: ${trip['dropoff']}", style: const TextStyle(color: Color(0xFF00F0FF), fontSize: 11.5)),
            Text("Distance: ${trip['distance']}", style: const TextStyle(color: Colors.white54, fontSize: 11)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Base Ride Fare:", style: TextStyle(color: Colors.white70, fontSize: 12)),
                Text("₹ ${(trip['fare'] as num).toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
            if ((trip['tip'] as num) > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Passenger Tip (100% Yours):", style: TextStyle(color: Colors.amber, fontSize: 12)),
                  Text("+₹ ${(trip['tip'] as num).toStringAsFixed(2)}", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            const Divider(color: Colors.white12, height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Driver Settlement:", style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 13)),
                Text("₹ ${((trip['fare'] as num) + (trip['tip'] as num)).toStringAsFixed(2)}", style: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close", style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _history.where((t) {
      if (_selectedFilter == "COMPLETED") return t['status'] == "COMPLETED";
      if (_selectedFilter == "REJECTED") return t['status'] == "REJECTED";
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF080E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10192B),
        elevation: 0,
        title: const Text("Driver Ride History & Ledger", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // SUMMARY STATS
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
                      Text("Total Trips", style: TextStyle(color: Colors.white54, fontSize: 11)),
                      Text("145", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    children: [
                      Text("Completed", style: TextStyle(color: Colors.white54, fontSize: 11)),
                      Text("142 (98%)", style: TextStyle(color: Color(0xFF00E676), fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    children: [
                      Text("Rejected", style: TextStyle(color: Colors.white54, fontSize: 11)),
                      Text("3", style: TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // FILTER CHIPS
            Row(
              children: [
                _filterChip("All Trips (145)", "ALL"),
                const SizedBox(width: 8),
                _filterChip("Completed (142)", "COMPLETED"),
                const SizedBox(width: 8),
                _filterChip("Rejected (3)", "REJECTED"),
              ],
            ),
            const SizedBox(height: 16),

            // TRIP CARDS
            ...filteredList.map((trip) {
              final isComp = trip['status'] == 'COMPLETED';

              return GestureDetector(
                onTap: () => _showTripReceiptDialog(trip),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131D31),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isComp ? Colors.white10 : Colors.redAccent.withOpacity(0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(trip['id'] as String, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: (isComp ? const Color(0xFF00E676) : Colors.redAccent).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isComp ? "🟢 COMPLETED" : "🔴 REJECTED",
                              style: TextStyle(color: isComp ? const Color(0xFF00E676) : Colors.redAccent, fontSize: 9.5, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(trip['passenger'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
                          Text("₹ ${(trip['fare'] as num).toInt()}", style: TextStyle(color: isComp ? const Color(0xFF00E676) : Colors.white54, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text("📍 ${trip['pickup']} ➔ ${trip['dropoff']}", style: const TextStyle(color: Color(0xFF00F0FF), fontSize: 11)),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("${trip['date']} • ${trip['mode']}", style: const TextStyle(color: Colors.white38, fontSize: 10)),
                          if ((trip['tip'] as num) > 0)
                            Text("🎁 +₹${(trip['tip'] as num).toInt()} Tip", style: const TextStyle(color: Colors.amber, fontSize: 10.5, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final isSel = _selectedFilter == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSel ? const Color(0xFF00E676) : const Color(0xFF131D31),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSel ? const Color(0xFF00E676) : Colors.white12),
          ),
          child: Center(
            child: Text(label, style: TextStyle(color: isSel ? Colors.black : Colors.white70, fontSize: 11, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
          ),
        ),
      ),
    );
  }
}