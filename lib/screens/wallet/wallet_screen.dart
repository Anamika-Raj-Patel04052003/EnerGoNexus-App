import 'dart:math';
import 'package:flutter/material.dart';

import '../../services/energo_unified_service.dart';
import '../../services/razorpay_service.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _amountCtrl = TextEditingController(text: "500");
  String _selectedFilter = "ALL";
  bool _isProcessing = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  void _topUpViaRazorpay(double amount) async {
    setState(() => _isProcessing = true);

    final res = await RazorpayPaymentService.openCheckout(
      context: context,
      amount: amount,
      purpose: "EnerGo Wallet Credit Top-Up",
    );

    if (res != null && res['status'] == 'SUCCESS') {
      EnerGoUnifiedService().topUpWallet(amount, "Razorpay Online Top-Up (${res['payment_id'] ?? 'pay_rzp_topup'})");

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ ₹ ${amount.toInt()} added to EnerGo Wallet!"), backgroundColor: const Color(0xFF00E676)),
      );
    }
    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    final service = EnerGoUnifiedService();

    return AnimatedBuilder(
      animation: service,
      builder: (context, child) {
        final transactions = service.transactions;
        final filteredList = transactions.where((t) {
          if (_selectedFilter == "CREDIT") return t['type'] == "CREDIT";
          if (_selectedFilter == "DEBIT") return t['type'] == "DEBIT";
          return true;
        }).toList();

        return Scaffold(
          backgroundColor: const Color(0xFF080E1A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF10192B),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text("EnerGo Cash & 5% Cashback", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 1. WALLET BALANCE CARD
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131D31),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF00E676), width: 1.2),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF131D31), Color(0x2600E676)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Available EnerGo Credits", style: TextStyle(color: Colors.white54, fontSize: 11.5)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: const Color(0x2600E676), borderRadius: BorderRadius.circular(6)),
                            child: const Text("⚡ 5% Cashback Active", style: TextStyle(color: Color(0xFF00E676), fontSize: 9.5, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text("₹ ${service.walletBalance.toStringAsFixed(2)}", style: const TextStyle(color: Color(0xFF00E676), fontSize: 30, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("Total Lifetime Cashback Earned: ₹ ${(service.walletBalance * 0.28).toStringAsFixed(2)}", style: const TextStyle(color: Color(0xFF00F0FF), fontSize: 11)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 2. QUICK RECHARGE TILES
                const Text("Quick Add Money (Razorpay Gateway)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
                const SizedBox(height: 10),

                Row(
                  children: [200.0, 500.0, 1000.0, 2000.0].map((amt) {
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _topUpViaRazorpay(amt),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF131D31),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF00E676).withOpacity(0.4)),
                          ),
                          child: Center(
                            child: Text("+₹${amt.toInt()}", style: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // 3. CASHBACK PROMO CARD
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0x26FFB703),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFFB703)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.stars, color: Color(0xFFFFB703), size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("5% Auto-Cashback on All Services!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.5)),
                            Text("Rides, Fast Charging, Parking & Rest Lounges automatically credit 5% back into your wallet.", style: TextStyle(color: Colors.white70, fontSize: 10.5)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 4. TRANSACTION HISTORY
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Transaction Ledger", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    Row(
                      children: [
                        _filterTab("ALL"),
                        _filterTab("CREDIT"),
                        _filterTab("DEBIT"),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                ...filteredList.map((tx) {
                  final isCredit = tx['type'] == "CREDIT";
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131D31),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: (isCredit ? const Color(0xFF00E676) : Colors.redAccent).withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(isCredit ? Icons.arrow_downward : Icons.arrow_upward, color: isCredit ? const Color(0xFF00E676) : Colors.redAccent, size: 16),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(tx['title'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.5)),
                                Text("${tx['time']} • ${tx['id']}", style: const TextStyle(color: Colors.white38, fontSize: 9.5)),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          "${isCredit ? '+' : '-'}₹ ${(tx['amount'] as num).toInt()}",
                          style: TextStyle(color: isCredit ? const Color(0xFF00E676) : Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _filterTab(String label) {
    final isSel = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        margin: const EdgeInsets.only(left: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSel ? const Color(0xFF00E676) : const Color(0xFF131D31),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label, style: TextStyle(color: isSel ? Colors.black : Colors.white54, fontSize: 9.5, fontWeight: FontWeight.bold)),
      ),
    );
  }
}