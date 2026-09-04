import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import 'driver_active_ride_screen.dart';

class IncomingRideScreen extends StatefulWidget {
  final Map<String, dynamic> trip;
  const IncomingRideScreen({super.key, required this.trip});

  @override
  State<IncomingRideScreen> createState() => _IncomingRideScreenState();
}

class _IncomingRideScreenState extends State<IncomingRideScreen> {
  int _secondsRemaining = 30;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0 && mounted) {
        setState(() => _secondsRemaining--);
      } else {
        _countdownTimer?.cancel();
        if (mounted) Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _acceptRide() {
    _countdownTimer?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DriverActiveRideScreen(trip: widget.trip),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = _secondsRemaining / 30.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Circular Timer Ring
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 6,
                      backgroundColor: Colors.white10,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                    ),
                  ),
                  Text(
                    "$_secondsRemaining s",
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text("NEW RIDE REQUEST!", style: TextStyle(color: AppColors.primaryGreen, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const Text("High-Demand Trip from MP Nagar Zone 1", style: TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 24),

              // Ride Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.4)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.2),
                              child: const Icon(LucideIcons.user, color: AppColors.primaryGreen),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.trip['passenger_name'] ?? 'Rohan Sharma', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                                const Text("⭐ 4.8 Passenger Rating", style: TextStyle(color: Colors.amber, fontSize: 11)),
                              ],
                            ),
                          ],
                        ),
                        Text("₹ ${widget.trip['fare']}", style: const TextStyle(color: AppColors.primaryGreen, fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(color: Colors.white12, height: 26),

                    _routeItem(LucideIcons.circleDot, AppColors.primaryGreen, "Pickup: ${widget.trip['pickup']}"),
                    const SizedBox(height: 12),
                    _routeItem(LucideIcons.mapPin, const Color(0xFF00F0FF), "Drop: ${widget.trip['dropoff']}"),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        _countdownTimer?.cancel();
                        Navigator.pop(context);
                      },
                      child: const Text("Decline"),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _acceptRide,
                      icon: const Icon(LucideIcons.checkCheck, size: 20),
                      label: const Text("ACCEPT RIDE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _routeItem(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12.5))),
      ],
    );
  }
}