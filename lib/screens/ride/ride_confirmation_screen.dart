import 'dart:async';
import 'package:flutter/material.dart';

import 'ride_tracking_screen.dart';

class RideConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic>? bookingData;
  final Map<String, dynamic>? rideDetails;

  const RideConfirmationScreen({
    super.key,
    this.bookingData,
    this.rideDetails,
  });

  @override
  State<RideConfirmationScreen> createState() => _RideConfirmationScreenState();
}

class _RideConfirmationScreenState extends State<RideConfirmationScreen> {
  int _searchProgress = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final data = widget.rideDetails ?? widget.bookingData;

    _timer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (!mounted) return;
      if (_searchProgress < 100) {
        setState(() => _searchProgress += 25);
      } else {
        _timer?.cancel();
        // AUTO MATCH TO CAPTAIN SURESH VERMA
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RideTrackingScreen(
              tripData: data,
              rideDetails: data,
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080E1A),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 130,
                      height: 130,
                      child: CircularProgressIndicator(
                        value: _searchProgress / 100,
                        strokeWidth: 4,
                        color: const Color(0xFF00E676),
                        backgroundColor: Colors.white12,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: Color(0xFF131D31),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.radar, color: Color(0xFF00E676), size: 48),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                const Text("Connecting with Nearest EV Captain...", style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Text("Finding highest-rated Eco-Driver near MP Nagar Zone 1", style: TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: const Color(0x2600E676), borderRadius: BorderRadius.circular(20)),
                  child: const Text("⚡ Matched: Captain Suresh Verma (Tata Nexon EV)", style: TextStyle(color: Color(0xFF00E676), fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}