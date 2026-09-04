import 'dart:math';
import 'package:flutter/material.dart';

import '../../services/energo_unified_service.dart';
import '../../services/razorpay_service.dart';

class RideCompletedScreen extends StatefulWidget {
  const RideCompletedScreen({super.key});

  @override
  State<RideCompletedScreen> createState() => _RideCompletedScreenState();
}

class _RideCompletedScreenState extends State<RideCompletedScreen> {
  int _rating = 5;
  String _paymentMode = 'razorpay';
  bool _isPaid = false;
  String _txnId = "";

  void _payRideFare() async {
    final fare = EnergoUnifiedService().currentRideFare;

    if (_paymentMode == 'razorpay') {
      final res = await RazorpayPaymentService.openCheckout(
        context: context,
        amount: fare,
        purpose: "EnerGo EV Ride Settlement (Airport Drop)",
      );
      if (res != null && res['status'] == 'SUCCESS') {
        setState(() {
          _isPaid = true;
          _txnId = res['payment_id'] ?? "pay_rzp_98821";
        });
      }
    } else {
      EnergoUnifiedService().payWithWallet(fare, "EV Ride Settlement");
      setState(() {
        _isPaid = true;
        _txnId = "pay_wallet_${Random().nextInt(89999) + 10000}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = EnergoUnifiedService();

    return Scaffold(
      backgroundColor: const Color(0xFF080E1A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(color: Color(0x2600E676), shape: BoxShape.circle),
                child: const Icon(Icons.check_circle, color: Color(0xFF00E676), size: 48),
              ),
              const SizedBox(height: 12),
              const Text("You've Arrived at Raja Bhoj Airport!", style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
              const Text("Hope you enjoyed your eco-friendly EV ride", style: TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 20),

              // FARE SUMMARY & GST TAX INVOICE
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF131D31),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _isPaid ? const Color(0xFF00E676) : Colors.white12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Commercial GST Tax Slip", style: TextStyle(color: Colors.white54, fontSize: 11)),
                        Text(_isPaid ? "PAID 🟢" : "PAYMENT DUE 🔴", style: TextStyle(color: _isPaid ? const Color(0xFF00E676) : Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 11)),
                      ],
                    ),
                    const Divider(color: Colors.white12, height: 18),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Base Distance Tariff (8.2 km)", style: TextStyle(color: Colors.white70, fontSize: 12)),
                        Text("₹ 101.70", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("GST @ 18% (SAC 9964)", style: TextStyle(color: Colors.white70, fontSize: 12)),
                        Text("₹ 18.30", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(color: Colors.white12, height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Payable Fare", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        Text("₹ ${service.currentRideFare.toStringAsFixed(2)}", style: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 20)),
                      ],
                    ),
                    if (_isPaid) ...[
                      const SizedBox(height: 8),
                      Text("Txn Ref: $_txnId • 5% Cashback Credited", style: const TextStyle(color: Color(0xFF00F0FF), fontSize: 10.5, fontWeight: FontWeight.bold)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // RATING CAPTAIN
              const Text("Rate Captain Suresh Verma", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return IconButton(
                    icon: Icon(Icons.star, color: i < _rating ? Colors.amber : Colors.white24, size: 30),
                    onPressed: () => setState(() => _rating = i + 1),
                  );
                }),
              ),
              const SizedBox(height: 20),

              // PAYMENT BUTTON OR RETURN HOME
              if (!_isPaid) ...[
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _paymentMode = 'razorpay'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _paymentMode == 'razorpay' ? const Color(0x33528FF0) : const Color(0xFF131D31),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _paymentMode == 'razorpay' ? const Color(0xFF528FF0) : Colors.white12),
                          ),
                          child: const Center(
                            child: Text("Razorpay UPI", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _paymentMode = 'wallet'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _paymentMode == 'wallet' ? const Color(0x3300E676) : const Color(0xFF131D31),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _paymentMode == 'wallet' ? const Color(0xFF00E676) : Colors.white12),
                          ),
                          child: const Center(
                            child: Text("Wallet (5% Back)", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: _payRideFare,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(color: const Color(0xFF00E676), borderRadius: BorderRadius.circular(12)),
                    child: const Center(
                      child: Text("Pay ₹ 120.00 & Get GST Slip", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                ),
              ] else ...[
                GestureDetector(
                  onTap: () {
                    service.updateRideStage(ActiveRideStage.headingToPickup); // Reset for next ride
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(color: const Color(0xFF00E676), borderRadius: BorderRadius.circular(12)),
                    child: const Center(
                      child: Text("Done & Back to Home", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}