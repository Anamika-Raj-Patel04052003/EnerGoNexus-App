import 'package:flutter/material.dart';

import '../../screens/wallet/wallet_screen.dart';
import '../../services/energo_unified_service.dart';

class WalletSummaryCard extends StatelessWidget {
  const WalletSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final service = EnergoUnifiedService();

    return AnimatedBuilder(
      animation: service,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WalletScreen()),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF131D31),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF00E676).withOpacity(0.35)),
              gradient: const LinearGradient(
                colors: [Color(0xFF131D31), Color(0x1A00E676)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text("EnerGo Cash Balance", style: TextStyle(color: Colors.white54, fontSize: 11.5)),
                        SizedBox(width: 6),
                        Icon(Icons.stars, color: Color(0xFF00E676), size: 14),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "₹ ${service.walletBalance.toStringAsFixed(2)}",
                      style: const TextStyle(color: Color(0xFF00E676), fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    const Text("⚡ 5% Auto-Cashback on all Rides & Hubs", style: TextStyle(color: Color(0xFF00F0FF), fontSize: 10, fontWeight: FontWeight.w600)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E676),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add, color: Colors.black, size: 16),
                      SizedBox(width: 4),
                      Text("Add Money", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11.5)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}