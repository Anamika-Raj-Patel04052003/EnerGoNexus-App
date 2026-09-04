import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../services/energo_unified_service.dart';
import '../../services/razorpay_service.dart';

class AddMoneyScreen extends StatefulWidget {
  const AddMoneyScreen({super.key});

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  final _service = EnergoUnifiedService();
  final _amountCtrl = TextEditingController(text: "1000");
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _service.init().then((_) => setState(() {}));
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  void _proceedRazorpayTopUp() async {
    final amt = double.tryParse(_amountCtrl.text.trim()) ?? 0.0;
    if (amt <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid amount"), backgroundColor: Colors.amber),
      );
      return;
    }

    setState(() => _isProcessing = true);

    // Open Razorpay Checkout Modal (Key: rzp_test_TVtsHQczSWr0rr)
    final res = await RazorpayPaymentService.openCheckout(
      context: context,
      amount: amt,
      purpose: "EnerGo Wallet Recharge Top-Up",
    );

    setState(() => _isProcessing = false);

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
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.amber.withValues(alpha: 0.6), width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.15), shape: BoxShape.circle),
                child: const Icon(LucideIcons.gift, color: Colors.amber, size: 44),
              ),
              const SizedBox(height: 16),
              const Text(
                "🎉 5% CASHBACK CARD UNLOCKED!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),
              Text(
                "+ ₹ ${cashback.toInt()} Instant Reward",
                style: const TextStyle(color: AppColors.primaryGreen, fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                "5% Cashback voucher has been credited directly to your EnerGo Wallet balance!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context, true);
                  },
                  child: const Text("Claim & Done", style: TextStyle(fontWeight: FontWeight.bold)),
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(LucideIcons.arrowLeft),
        ),
        title: const Text("Add Money to Wallet", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Current Balance Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Current Wallet Balance", style: TextStyle(color: Colors.white54, fontSize: 13)),
                const SizedBox(height: 6),
                Text(
                  "₹ ${_service.walletBalance.toStringAsFixed(2)}",
                  style: const TextStyle(color: AppColors.primaryGreen, fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "🎁 5% Cashback Reward Card Active on All Recharge Top-Ups",
                    style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Amount Input
          const Text("Enter Top-Up Amount", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          TextField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              prefixText: "₹ ",
              prefixStyle: const TextStyle(color: AppColors.primaryGreen, fontSize: 20, fontWeight: FontWeight.bold),
              filled: true,
              fillColor: AppColors.card,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 14),

          // Quick Selection Chips
          Row(
            children: [500, 1000, 2000, 5000].map((amt) {
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _amountCtrl.text = amt.toString()),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Center(
                      child: Text(
                        "+₹$amt",
                        style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),

          // Pay via Razorpay Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF528FF0),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _isProcessing ? null : _proceedRazorpayTopUp,
              icon: _isProcessing ? const SizedBox.shrink() : const Icon(LucideIcons.creditCard, size: 18),
              label: _isProcessing
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : const Text("Pay via Razorpay & Unlock 5% Cashback", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}