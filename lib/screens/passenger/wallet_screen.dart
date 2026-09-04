import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../services/energo_unified_service.dart';
import '../../services/razorpay_service.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _service = EnergoUnifiedService();
  final _amountCtrl = TextEditingController(text: "1000");

  static const Color bgPrimary = Color(0xFF060B14);
  static const Color bgCard = Color(0xFF0F172A);
  static const Color bgCardHover = Color(0xFF1E293B);
  static const Color accentCyan = Color(0xFF00F0FF);
  static const Color accentGreen = Color(0xFF00E676);
  static const Color accentPurple = Color(0xFFA855F7);
  static const Color accentYellow = Color(0xFFFFB703);
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);

  @override
  void initState() {
    super.initState();
    _service.init().then((_) => setState(() {}));
  }

  void _addMoneyWithRazorpay() async {
    final amt = double.tryParse(_amountCtrl.text.trim()) ?? 500.0;
    if (amt <= 0) return;

    // Open Razorpay Checkout Modal
    final res = await RazorpayPaymentService.openCheckout(
      context: context,
      amount: amt,
      purpose: "EnerGo Wallet Balance Recharge",
    );

    if (res != null && res['status'] == 'SUCCESS') {
      await _service.addMoneyToWallet(amt, context: context);
      setState(() {});

      if (!mounted) return;
      _showCashbackRewardModal(amt * 0.05);
    }
  }

  void _showCashbackRewardModal(double cashback) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: accentYellow.withValues(alpha: 0.6), width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: accentYellow.withValues(alpha: 0.15), shape: BoxShape.circle),
                child: const Icon(LucideIcons.gift, color: accentYellow, size: 44),
              ),
              const SizedBox(height: 16),
              const Text("🎉 5% CASHBACK CARD UNLOCKED!", textAlign: TextAlign.center, style: TextStyle(color: accentYellow, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              const SizedBox(height: 8),
              Text(
                "+ ₹ ${cashback.toInt()} Instant Cashback",
                style: const TextStyle(color: accentGreen, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text("5% reward has been directly added to your EnerGo Wallet balance!", textAlign: TextAlign.center, style: TextStyle(color: textSecondary, fontSize: 12)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentGreen,
                    foregroundColor: bgPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Claim & Continue", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgPrimary,
      appBar: AppBar(
        backgroundColor: bgCard,
        title: const Text("EnerGo Wallet & Rewards", style: TextStyle(color: textPrimary, fontSize: 17, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // Balance Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: bgCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accentGreen.withValues(alpha: 0.4)),
              gradient: LinearGradient(colors: [bgCard, accentGreen.withValues(alpha: 0.08)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Available Wallet Balance", style: TextStyle(color: textSecondary, fontSize: 13)),
                const SizedBox(height: 6),
                Text("₹ ${_service.walletBalance.toStringAsFixed(2)}", style: const TextStyle(color: accentGreen, fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: accentYellow.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                  child: const Text("🎁 5% Cashback Reward Card Active on All Top-Ups", style: TextStyle(color: accentYellow, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Add Money Input
          const Text("Top Up Wallet via Razorpay", style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          TextField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              prefixText: "₹ ",
              prefixStyle: const TextStyle(color: accentGreen, fontSize: 18, fontWeight: FontWeight.bold),
              filled: true,
              fillColor: bgCard,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: bgCardHover)),
            ),
          ),
          const SizedBox(height: 12),

          // Quick Selection Pills
          Row(
            children: [500, 1000, 2000, 5000].map((v) {
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _amountCtrl.text = v.toString()),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(8), border: Border.all(color: bgCardHover)),
                    child: Center(child: Text("+₹$v", style: const TextStyle(color: accentCyan, fontWeight: FontWeight.bold, fontSize: 12))),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: accentGreen, foregroundColor: bgPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: _addMoneyWithRazorpay,
              icon: const Icon(LucideIcons.plusCircle, size: 18),
              label: const Text("Add Money & Unlock 5% Cashback", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 28),

          // Transactions
          const Text("Recent Transactions & Rewards", style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          ..._service.walletTransactions.map((tx) {
            final isCredit = tx['type'] == 'credit' || tx['type'] == 'cashback';
            final isCashback = tx['type'] == 'cashback';
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: bgCardHover)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: (isCashback ? accentYellow : isCredit ? accentGreen : accentCyan).withValues(alpha: 0.15), shape: BoxShape.circle),
                        child: Icon(isCashback ? LucideIcons.gift : isCredit ? LucideIcons.arrowDownLeft : LucideIcons.arrowUpRight, color: isCashback ? accentYellow : isCredit ? accentGreen : accentCyan, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tx['title'], style: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(tx['date'], style: const TextStyle(color: textSecondary, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                  Text(tx['amount'], style: TextStyle(color: isCredit ? accentGreen : textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}