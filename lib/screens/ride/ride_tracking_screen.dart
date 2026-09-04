import 'package:flutter/material.dart';

import '../../services/energo_unified_service.dart';
import 'ride_completed_screen.dart';

class RideTrackingScreen extends StatefulWidget {
  final Map<String, dynamic>? rideDetails;
  final Map<String, dynamic>? tripData;

  const RideTrackingScreen({
    super.key,
    this.rideDetails,
    this.tripData,
  });

  @override
  State<RideTrackingScreen> createState() => _RideTrackingScreenState();
}

class _RideTrackingScreenState extends State<RideTrackingScreen> {
  @override
  Widget build(BuildContext context) {
    final service = EnergoUnifiedService();

    return AnimatedBuilder(
      animation: service,
      builder: (context, child) {
        final stage = service.currentRideStage;

        // AUTO-NAVIGATE TO PAYMENT IF DESTINATION REACHED
        if (stage == ActiveRideStage.reachedDestination || stage == ActiveRideStage.completed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const RideCompletedScreen()),
            );
          });
        }

        String statusHeader = "Captain is on the way (ETA: 3 Mins)";
        Color statusColor = const Color(0xFF00F0FF);

        if (stage == ActiveRideStage.driverArrived) {
          statusHeader = "🟢 Captain Suresh Arrived at Pickup Spot!";
          statusColor = const Color(0xFF00E676);
        } else if (stage == ActiveRideStage.inTransit) {
          statusHeader = "🚀 Ride Started! Heading to Airport";
          statusColor = const Color(0xFF00E676);
        }

        return Scaffold(
          backgroundColor: const Color(0xFF080E1A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF10192B),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
            ),
            title: const Text("Live GPS Trip Tracking", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          body: Column(
            children: [
              // 1. LIVE GPS MAP SIMULATION
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

                    // STATUS BANNER AT TOP
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF080E1A).withOpacity(0.92),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: statusColor, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.near_me, color: statusColor, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(statusHeader, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12.5)),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // MOVING CAR ICON
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF080E1A),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF00E676), width: 2),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFF00E676).withOpacity(0.4), blurRadius: 20, spreadRadius: 4),
                          ],
                        ),
                        child: const Icon(Icons.electric_car, color: Color(0xFF00E676), size: 36),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. PASSENGER BOTTOM COCKPIT (NO DRIVER BUTTONS!)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF131D31),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // DRIVER & VEHICLE INFO
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 24,
                              backgroundColor: Color(0x3300E676),
                              child: Icon(Icons.person, color: Color(0xFF00E676), size: 28),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(service.driverName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                                    const SizedBox(width: 6),
                                    const Text("⭐ 4.9", style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Text("⚡ ${service.vehicleName} • ${service.vehiclePlate}", style: const TextStyle(color: Color(0xFF00F0FF), fontSize: 11, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text("Estimated Fare", style: TextStyle(color: Colors.white54, fontSize: 10)),
                            Text("₹ ${service.currentRideFare.toInt()}", style: const TextStyle(color: Color(0xFF00E676), fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white12, height: 22),

                    // PASSENGER 4-DIGIT SECURITY PIN BADGE
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0x2600E676),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF00E676), width: 1.2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("YOUR SECURITY PIN FOR DRIVER", style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                              SizedBox(height: 2),
                              Text("Share with Suresh Verma to start ride", style: TextStyle(color: Colors.white54, fontSize: 10)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(color: const Color(0xFF00E676), borderRadius: BorderRadius.circular(10)),
                            child: Text(
                              service.ridePin,
                              style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ROUTE
                    Text("📍 Pickup: ${service.pickupLocation}", style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    Text("🏁 Drop: ${service.dropLocation}", style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    const SizedBox(height: 16),

                    // PASSENGER ACTIONS (CALL / CHAT / SOS)
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(color: const Color(0xFF080E1A), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white24)),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.phone, color: Color(0xFF00F0FF), size: 16),
                                SizedBox(width: 6),
                                Text("Call Captain", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(color: const Color(0xFF080E1A), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white24)),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat, color: Color(0xFF00E676), size: 16),
                                SizedBox(width: 6),
                                Text("Chat", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.redAccent)),
                          child: const Icon(Icons.shield, color: Colors.redAccent, size: 20),
                        ),
                      ],
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