import 'package:flutter/material.dart';

class RideCompletedScreen extends StatefulWidget {
  final double fare;
  final String pickup;
  final String? drop;
  final String? dropoff;
  final String? destination;
  final String driverName;
  final String vehicleNumber;
  final String? rideId;

  const RideCompletedScreen({
    super.key,
    required this.fare,
    required this.pickup,
    this.drop,
    this.dropoff,
    this.destination,
    this.driverName = "Rahul Sharma",
    this.vehicleNumber = "DL 01 EV 4891",
    this.rideId,
  });

  @override
  State<RideCompletedScreen> createState() => _RideCompletedScreenState();
}

class _RideCompletedScreenState extends State<RideCompletedScreen> {
  @override
  Widget build(BuildContext context) {
    final effectiveDrop = widget.dropoff ?? widget.destination ?? widget.drop ?? "EnerGo Central SuperHub";
    final double cashback = widget.fare * 0.05;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.15), shape: BoxShape.circle),
                child: const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 72),
              ),
              const SizedBox(height: 20),
              const Text("Ride Completed Successfully!", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Total Paid: ₹${widget.fare.toStringAsFixed(2)}", style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // 5% CASHBACK
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(color: Colors.amber.withOpacity(0.15), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.amber)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stars, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Text("₹${cashback.toStringAsFixed(2)} (5% Cashback) Credited!", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // DRIVER & VEHICLE
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFF161F30), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.driverName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(widget.vehicleNumber, style: const TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ROUTE
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFF161F30), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
                child: Column(
                  children: [
                    Row(children: [const Icon(Icons.my_location, color: Color(0xFF10B981), size: 16), const SizedBox(width: 8), Expanded(child: Text(widget.pickup, style: const TextStyle(color: Colors.white70, fontSize: 12)))]),
                    const Divider(color: Colors.white12, height: 16),
                    Row(children: [const Icon(Icons.location_on, color: Colors.redAccent, size: 16), const SizedBox(width: 8), Expanded(child: Text(effectiveDrop, style: const TextStyle(color: Colors.white70, fontSize: 12)))]),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5FF), foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false),
                  child: const Text("Back to Home", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}