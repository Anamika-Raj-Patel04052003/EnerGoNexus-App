import 'dart:math';
import 'package:flutter/material.dart';

import '../../services/energo_unified_service.dart';
import '../../services/razorpay_service.dart';

class ParkingBookingScreen extends StatefulWidget {
  const ParkingBookingScreen({super.key});

  @override
  State<ParkingBookingScreen> createState() => _ParkingBookingScreenState();
}

class _ParkingBookingScreenState extends State<ParkingBookingScreen> {
  int _selectedHours = 2;
  String _vehiclePlate = "MP 04 EV 8891";
  String _paymentMode = 'razorpay';
  String? _bookedBayId;

  double get _totalAmount => _selectedHours * 40.0;

  void _bookParkingSlot(Map<String, dynamic> currentStation, Map<String, dynamic> bay) async {
    if (bay['isOccupied'] == true && bay['id'] != _bookedBayId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bay is Occupied. Please tap a GREEN Free Bay."), backgroundColor: Colors.redAccent),
      );
      return;
    }

    if (_paymentMode == 'razorpay') {
      final res = await RazorpayPaymentService.openCheckout(
        context: context,
        amount: _totalAmount,
        purpose: "Smart EV Parking (${bay['id']}) - $_selectedHours Hours",
      );
      if (res != null && res['status'] == 'SUCCESS') {
        _confirmParking(currentStation, bay, res['payment_id'] ?? "pay_rzp_99120");
      }
    } else {
      EnergoUnifiedService().payWithWallet(_totalAmount, "Smart Parking (${bay['id']})");
      _confirmParking(currentStation, bay, "pay_wallet_${Random().nextInt(89999) + 10000}");
    }
  }

  void _confirmParking(Map<String, dynamic> currentStation, Map<String, dynamic> bay, String txnId) {
    EnergoUnifiedService().bookAmenity(
      stationId: currentStation['id'] as String,
      category: 'parking',
      itemId: bay['id'] as String,
      durationMinutes: _selectedHours * 60,
      bookedBy: _vehiclePlate,
    );

    setState(() => _bookedBayId = bay['id'] as String);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131D31),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFF00F0FF), width: 1.5)),
        title: const Row(
          children: [
            Icon(Icons.local_parking, color: Color(0xFF00F0FF), size: 28),
            SizedBox(width: 8),
            Text("Barrier Gate Pass Issued", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Bay: ${bay['id']} • Duration: $_selectedHours Hours", style: const TextStyle(color: Color(0xFF00F0FF), fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Image.network(
                'https://api.qrserver.com/v1/create-qr-code/?size=130x130&data=GATE_PASS_${bay['id']}_$_vehiclePlate',
                width: 120,
                height: 120,
              ),
            ),
            const SizedBox(height: 8),
            const Text("Scan this QR at SuperHub Entry Boom Barrier", style: TextStyle(color: Colors.white54, fontSize: 10.5)),
            const SizedBox(height: 6),
            Text("Paid: ₹ ${_totalAmount.toStringAsFixed(2)} • Txn: $txnId", style: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 11.5)),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00F0FF), foregroundColor: Colors.black),
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Done", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = EnergoUnifiedService();

    return AnimatedBuilder(
      animation: service,
      builder: (context, child) {
        final currentStation = service.stations[0];
        final parkingBays = currentStation['parking'] as List;

        return Scaffold(
          backgroundColor: const Color(0xFF080E1A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF10192B),
            elevation: 0,
            leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
            title: const Text("Smart IoT Sensor EV Parking", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // HUB INFO
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131D31),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.35)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(currentStation['name'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
                          const Text("🅿️ Automated Barrier & 24x7 CCTV Security", style: TextStyle(color: Color(0xFF00F0FF), fontSize: 10.5, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const Text("₹ 40 / hr", style: TextStyle(color: Color(0xFF00E676), fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // VEHICLE PLATE
                const Text("1. Vehicle Registration Plate", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: "MP 04 EV 8891",
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: const Color(0xFF131D31),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  onChanged: (v) => _vehiclePlate = v,
                ),
                const SizedBox(height: 16),

                // PARKING DURATION
                const Text("2. Select Parking Duration (Hours)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: [1, 2, 4, 8].map((h) {
                    final isSel = _selectedHours == h;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedHours = h),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSel ? const Color(0xFF00F0FF) : const Color(0xFF131D31),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: isSel ? const Color(0xFF00F0FF) : Colors.white12),
                          ),
                          child: Center(
                            child: Text(
                              "$h hr${h > 1 ? 's' : ''}",
                              style: TextStyle(color: isSel ? Colors.black : Colors.white70, fontSize: 12, fontWeight: isSel ? FontWeight.bold : FontWeight.normal),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // LIVE BAYS MATRIX
                const Text("3. Tap a Sensor Bay to Book", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 10),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.6,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: parkingBays.length,
                  itemBuilder: (context, i) {
                    final b = parkingBays[i] as Map<String, dynamic>;
                    final isOcc = b['isOccupied'] as bool;
                    final col = isOcc ? Colors.redAccent : const Color(0xFF00F0FF);

                    return GestureDetector(
                      onTap: () => _bookParkingSlot(currentStation, b),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF131D31),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: col.withOpacity(0.4), width: 1.2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(Icons.local_parking, color: col, size: 20),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: col.withOpacity(0.18), borderRadius: BorderRadius.circular(6)),
                                  child: Text(isOcc ? "OCCUPIED 🔴" : "FREE 🟢", style: TextStyle(color: col, fontSize: 8.5, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(b['id'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                Text(isOcc ? "${b['plate']}" : "Tap to Book", style: const TextStyle(color: Colors.white54, fontSize: 9.5)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}