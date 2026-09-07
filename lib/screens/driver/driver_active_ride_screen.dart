import 'package:flutter/material.dart';
import '../../services/energo_unified_service.dart';

class DriverActiveRideScreen extends StatefulWidget {
  const DriverActiveRideScreen({super.key});

  @override
  State<DriverActiveRideScreen> createState() => _DriverActiveRideScreenState();
}

class _DriverActiveRideScreenState extends State<DriverActiveRideScreen> {
  final _pinController = TextEditingController();

  void _verifyPinAndStartTrip() {
    final service = EnergoUnifiedService();
    if (_pinController.text == service.ridePin) {
      service.updateRideStage(ActiveRideStage.inTransit);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🟢 PIN Verified! Trip In Progress."), backgroundColor: Color(0xFF10B981)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Invalid OTP/PIN from passenger!"), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = EnergoUnifiedService();

    return ListenableBuilder(
      listenable: service,
      builder: (context, _) {
        final isBrokerDriver = service.currentDriverType == DriverType.brokerFleetDriver;

        return Scaffold(
          backgroundColor: const Color(0xFF0A0E17),
          appBar: AppBar(
            backgroundColor: const Color(0xFF111827),
            title: Text(
              isBrokerDriver ? "🏢 Broker Fleet Cockpit" : "🚕 Solo Driver Cockpit",
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isBrokerDriver ? const Color(0xFF10B981).withOpacity(0.2) : const Color(0xFF00E5FF).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isBrokerDriver ? const Color(0xFF10B981) : const Color(0xFF00E5FF)),
                ),
                child: Center(
                  child: Text(
                    isBrokerDriver ? "FLEET EV" : "SOLO EV",
                    style: TextStyle(color: isBrokerDriver ? const Color(0xFF10B981) : const Color(0xFF00E5FF), fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // DRIVER INFO HERO CARD
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161F30),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(service.driverName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 4),
                          Text(isBrokerDriver ? "Broker: ${service.brokerCompanyName}" : "Self-Owned: ${service.vehiclePlate}", style: const TextStyle(color: Colors.white60, fontSize: 12)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(isBrokerDriver ? "Accrued Salary" : "Wallet Balance", style: const TextStyle(color: Colors.white54, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text(
                            isBrokerDriver ? "₹${service.brokerDriverAccruedSalary.toStringAsFixed(2)}" : "₹${service.soloDriverWallet.toStringAsFixed(2)}",
                            style: const TextStyle(color: Color(0xFFFFD54F), fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // TRIP STATUS DETAILS
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161F30),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Ride ID: ${service.currentRideId}", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                          Text("Fare: ₹${service.rideFare}", style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.my_location, color: Color(0xFF10B981), size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text(service.pickupLocation, style: const TextStyle(color: Colors.white, fontSize: 13))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.redAccent, size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text(service.dropLocation, style: const TextStyle(color: Colors.white, fontSize: 13))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // STAGE 1: ENTER PIN TO START RIDE
                if (service.rideStage == ActiveRideStage.searching || service.rideStage == ActiveRideStage.driverAssigned || service.rideStage == ActiveRideStage.headingToPickup || service.rideStage == ActiveRideStage.driverArrived) ...[
                  const Text("Verify Passenger PIN to Start Trip", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: "ENTER PIN",
                      hintStyle: const TextStyle(color: Colors.white24, fontSize: 14, letterSpacing: 1),
                      filled: true,
                      fillColor: const Color(0xFF161F30),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF00E5FF))),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
                      onPressed: _verifyPinAndStartTrip,
                      child: const Text("Verify PIN & Start Trip", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                ],

                // STAGE 2: IN TRANSIT
                if (service.rideStage == ActiveRideStage.inTransit) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.15), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF10B981))),
                    child: const Row(
                      children: [
                        Icon(Icons.navigation_rounded, color: Color(0xFF10B981), size: 36),
                        SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Trip in Progress...", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              Text("Driving towards destination SuperHub.", style: TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                      onPressed: () => service.updateRideStage(ActiveRideStage.reachedDestination),
                      child: const Text("End Trip at Destination", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                ],

                // STAGE 3: PAYMENT COLLECTION (DIFFERENT FOR BOTH!)
                if (service.rideStage == ActiveRideStage.reachedDestination || service.rideStage == ActiveRideStage.completed) ...[
                  const Text("Payment Settlement", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  if (isBrokerDriver) ...[
                    // BROKER DRIVER: SHOW BROKER CORPORATE QR & NO CASH BANNER
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161F30),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF00E5FF)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                            child: const Text("⚠️ STRICTLY NO CASH • BROKER FLEET POLICY", style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.qr_code_2_rounded, size: 140, color: Colors.black),
                          ),
                          const SizedBox(height: 12),
                          Text("Scan Broker QR: ${service.brokerCorporateUpi}", style: const TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 6),
                          const Text("100% Fare settles to Broker Vault.\nDriver receives shift salary from broker.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 11)),
                        ],
                      ),
                    ),
                  ] else ...[
                    // SOLO DRIVER: CASH COLLECTION ALLOWED + PERSONAL QR
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161F30),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF10B981)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                            child: const Text("🟢 CASH OR PERSONAL UPI ACCEPTED", style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.qr_code_rounded, size: 140, color: Colors.black),
                          ),
                          const SizedBox(height: 12),
                          Text("Driver UPI: ${service.soloPersonalUpi}", style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 6),
                          const Text("Directly credited to your Personal Wallet (minus 10% platform fee).", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
                      onPressed: () {
                        service.completeRideAndRouteFare();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isBrokerDriver ? "✅ Fare credited to Broker Vault! Salary wage logged." : "✅ ₹108 Net added to Solo Wallet!"),
                            backgroundColor: const Color(0xFF10B981),
                          ),
                        );
                      },
                      child: const Text("Confirm Payment & Close Ride", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}