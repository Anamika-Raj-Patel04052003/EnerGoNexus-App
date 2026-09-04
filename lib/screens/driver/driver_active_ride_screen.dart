import 'package:flutter/material.dart';

import '../../services/energo_unified_service.dart';

class DriverActiveRideScreen extends StatefulWidget {
  const DriverActiveRideScreen({super.key});

  @override
  State<DriverActiveRideScreen> createState() => _DriverActiveRideScreenState();
}

class _DriverActiveRideScreenState extends State<DriverActiveRideScreen> {
  final _pinCtrl = TextEditingController();

  void _markArrived() {
    EnergoUnifiedService().updateRideStage(ActiveRideStage.driverArrived);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("📍 Marked Arrived! Passenger has been notified."), backgroundColor: Color(0xFF00E676)),
    );
  }

  void _verifyPinAndStartTrip() {
    final service = EnergoUnifiedService();
    if (_pinCtrl.text.trim() == service.ridePin) {
      service.updateRideStage(ActiveRideStage.inTransit);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🚀 PIN Verified (7842)! Trip Started to Airport."), backgroundColor: Color(0xFF00E676)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Invalid PIN. Please ask passenger for 4-digit PIN (7842)."), backgroundColor: Colors.redAccent),
      );
    }
  }

  void _endTripAndShowSettlement() {
    final service = EnergoUnifiedService();
    service.updateRideStage(ActiveRideStage.reachedDestination);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131D31),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFF00E676), width: 1.5)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF00E676), size: 28),
            SizedBox(width: 8),
            Text("Trip Completed & Fare", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text("Total Fare Collected", style: TextStyle(color: Colors.white54, fontSize: 11)),
            const SizedBox(height: 2),
            const Text("₹ 120.00", style: TextStyle(color: Color(0xFF00E676), fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // DYNAMIC RAZORPAY / ENERGO QR CODE FOR OFFLINE SCAN
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Image.network(
                'https://api.qrserver.com/v1/create-qr-code/?size=140x140&data=upi://pay?pa=energo@hdfcbank&pn=EnerGoCaptain&am=120.00&cu=INR',
                width: 120,
                height: 120,
              ),
            ),
            const SizedBox(height: 10),
            const Text("Passenger can scan QR or pay via App", style: TextStyle(color: Colors.white54, fontSize: 10.5)),
            const Divider(color: Colors.white12, height: 20),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Captain Shift Total:", style: TextStyle(color: Colors.white70, fontSize: 11)),
                Text("₹ 2,570.00", style: TextStyle(color: Color(0xFF00F0FF), fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E676), foregroundColor: Colors.black),
            onPressed: () {
              Navigator.pop(ctx);
              service.updateRideStage(ActiveRideStage.completed);
              Navigator.pushReplacementNamed(context, '/driver');
            },
            child: const Text("Next Ride (Duty Online)", style: TextStyle(fontWeight: FontWeight.bold)),
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
        final stage = service.currentRideStage;

        return Scaffold(
          backgroundColor: const Color(0xFF080E1A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF10192B),
            elevation: 0,
            title: const Text("Captain On-Duty Trip Console", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          body: Column(
            children: [
              // 1. LIVE TURN-BY-TURN HUD
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10192B),
                        image: DecorationImage(
                          image: NetworkImage('https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&w=1200&q=80'),
                          fit: BoxFit.cover,
                          opacity: 0.22,
                        ),
                      ),
                    ),

                    // TOP TURN-BY-TURN BOX
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF080E1A).withOpacity(0.92),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF00E676)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.turn_right, color: Color(0xFF00E676), size: 28),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    stage == ActiveRideStage.headingToPickup
                                        ? "In 300m Turn Right to Zone 1 Pickup"
                                        : "Take VIP Road towards Airport (8.2 km)",
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.5),
                                  ),
                                  const Text("Speed: 42 km/h • Battery: 78% (290 km Range)", style: TextStyle(color: Color(0xFF00F0FF), fontSize: 10)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. DRIVER CONSOLE CONTROLS
              Container(
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                  color: Color(0xFF131D31),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Passenger: ${service.passengerName}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                            Text("📍 ${service.pickupLocation} ➔ ${service.dropLocation}", style: const TextStyle(color: Colors.white54, fontSize: 10.5)),
                          ],
                        ),
                        Text("₹ ${service.currentRideFare.toInt()}", style: const TextStyle(color: Color(0xFF00E676), fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(color: Colors.white12, height: 20),

                    // STAGE 1: HEADING TO PICKUP ➔ CLICK ARRIVED
                    if (stage == ActiveRideStage.headingToPickup)
                      GestureDetector(
                        onTap: _markArrived,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(color: const Color(0xFF00F0FF), borderRadius: BorderRadius.circular(12)),
                          child: const Center(
                            child: Text("📍 Mark Arrived at Pickup Spot", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                        ),
                      ),

                    // STAGE 2: DRIVER ARRIVED ➔ ENTER 4-DIGIT PIN (7842)
                    if (stage == ActiveRideStage.driverArrived) ...[
                      const Text("Ask Passenger for 4-Digit Security PIN:", style: TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _pinCtrl,
                              keyboardType: TextInputType.number,
                              maxLength: 4,
                              style: const TextStyle(color: Color(0xFF00E676), fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 8),
                              decoration: InputDecoration(
                                hintText: "7842",
                                hintStyle: const TextStyle(color: Colors.white24),
                                counterText: "",
                                filled: true,
                                fillColor: const Color(0xFF080E1A),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF00E676))),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E676), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14)),
                            onPressed: _verifyPinAndStartTrip,
                            child: const Text("Start Ride 🚀", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],

                    // STAGE 3: IN TRANSIT ➔ REACHED DESTINATION BUTTON
                    if (stage == ActiveRideStage.inTransit)
                      GestureDetector(
                        onTap: _endTripAndShowSettlement,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(12)),
                          child: const Center(
                            child: Text("🏁 End Trip & Collect ₹120 Fare", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}