import 'dart:async';
import 'package:flutter/material.dart';

import '../../services/energo_unified_service.dart';
import 'ride_tracking_screen.dart';

class RideConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic>? rideDetails;
  final Map<String, dynamic>? bookingData;
  final Map<String, dynamic>? tripData;

  const RideConfirmationScreen({
    super.key,
    this.rideDetails,
    this.bookingData,
    this.tripData,
  });

  @override
  State<RideConfirmationScreen> createState() => _RideConfirmationScreenState();
}

class _RideConfirmationScreenState extends State<RideConfirmationScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  Timer? _matchTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();

    // TRIGGER PASSENGER RIDE REQUEST TO DRIVERS
    EnergoUnifiedService().passengerBookRide();

    final payload = widget.rideDetails ?? widget.bookingData ?? widget.tripData ?? {};

    // 3-SECOND RADAR MATCH TO CAPTAIN SURESH VERMA
    _matchTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RideTrackingScreen(
            tripData: payload,
            rideDetails: payload,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _matchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080E1A),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 140 + (_pulseController.value * 30),
                    height: 140 + (_pulseController.value * 30),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF00E676).withOpacity(0.15 - (_pulseController.value * 0.1)),
                      border: Border.all(color: const Color(0xFF00E676).withOpacity(1.0 - _pulseController.value), width: 2),
                    ),
                    child: const Center(
                      child: Icon(Icons.electric_car, color: Color(0xFF00E676), size: 48),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              const Text("Connecting to Nearest EV Captain...", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text("Searching in MP Nagar Zone 1 (Radius 2 km)", style: TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF131D31),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF00E676).withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt, color: Color(0xFF00E676), size: 16),
                    SizedBox(width: 6),
                    Text("100% Guaranteed EV Fleet Match", style: TextStyle(color: Color(0xFF00E676), fontSize: 11, fontWeight: FontWeight.bold)),
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