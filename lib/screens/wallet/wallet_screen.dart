import 'package:flutter/material.dart';
import '../../services/energo_unified_service.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = EnergoUnifiedService();

    return ListenableBuilder(
      listenable: service,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF080E1A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0F172A),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text("ENERGO CASHBACK WALLET", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CASHBACK HERO BALANCE
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF0A2E1C), Color(0xFF0D5C3A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: const Color(0xFF00E676).withOpacity(0.25), blurRadius: 18, offset: const Offset(0, 6))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("AVAILABLE CASHBACK BALANCE", style: TextStyle(color: Colors.white70, fontSize: 11.5, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
                          Icon(Icons.stars, color: Color(0xFFFFD54F), size: 22),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text("₹ ${service.walletBalance.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      const Text("⚡ 100% Redeemable for Fast Charging, Smart Parking & EV Cab Rides.", style: TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const Text("Recent Cashback & Transactions", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),

                ...service.transactions.map((tx) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFF161F30), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white10)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: tx['type'] == 'CREDIT' ? const Color(0xFF00E676).withOpacity(0.2) : Colors.redAccent.withOpacity(0.2),
                            child: Icon(tx['type'] == 'CREDIT' ? Icons.arrow_downward : Icons.arrow_upward, color: tx['type'] == 'CREDIT' ? const Color(0xFF00E676) : Colors.redAccent, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tx['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                              Text("${tx['desc']} • ${tx['time']}", style: const TextStyle(color: Colors.white54, fontSize: 10.5)),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        "${tx['type'] == 'CREDIT' ? '+' : '-'}₹${(tx['amount'] as num).toStringAsFixed(2)}",
                        style: TextStyle(color: tx['type'] == 'CREDIT' ? const Color(0xFF00E676) : Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        );
      },
    );
  }
}