import 'dart:math';
import 'package:flutter/material.dart';

class DriverEarningsScreen extends StatefulWidget {
  const DriverEarningsScreen({super.key});

  @override
  State<DriverEarningsScreen> createState() => _DriverEarningsScreenState();
}

class _DriverEarningsScreenState extends State<DriverEarningsScreen> {
  double _balance = 2450.0;
  bool _isTransferring = false;

  final List<Map<String, dynamic>> _recentPayouts = [
    {'id': 'IMPS-984210', 'amount': 4200.0, 'date': 'Yesterday, 10:30 PM', 'status': 'SETTLED 🟢', 'bank': 'HDFC Bank **4891'},
    {'id': 'IMPS-983192', 'amount': 3850.0, 'date': '01 Sep, 09:15 PM', 'status': 'SETTLED 🟢', 'bank': 'HDFC Bank **4891'},
    {'id': 'IMPS-981044', 'amount': 5100.0, 'date': '30 Aug, 11:45 PM', 'status': 'SETTLED 🟢', 'bank': 'HDFC Bank **4891'},
  ];

  void _instantBankTransfer() async {
    if (_balance <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No balance available to transfer."), backgroundColor: Colors.amber),
      );
      return;
    }

    setState(() => _isTransferring = true);
    await Future.delayed(const Duration(milliseconds: 900));

    final txnId = "IMPS-${Random().nextInt(899999) + 100000}";
    final transferredAmount = _balance;

    setState(() {
      _balance = 0.0;
      _isTransferring = false;
      _recentPayouts.insert(0, {
        'id': txnId,
        'amount': transferredAmount,
        'date': 'Just Now',
        'status': 'SETTLED 🟢',
        'bank': 'HDFC Bank **4891',
      });
    });

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131D31),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: Color(0xFF00E676), width: 1.5)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF00E676), size: 28),
            SizedBox(width: 8),
            Text("Instant Payout Success!", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Ref No: $txnId", style: const TextStyle(color: Colors.white54, fontSize: 11)),
            const Divider(color: Colors.white12, height: 16),
            Text("Amount: ₹ ${transferredAmount.toStringAsFixed(2)}", style: const TextStyle(color: Color(0xFF00E676), fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text("Credited to: HDFC Bank A/c **4891", style: TextStyle(color: Color(0xFF00F0FF), fontSize: 12)),
            const SizedBox(height: 4),
            const Text("Mode: 24x7 Real-Time IMPS Payout", style: TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Done", style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10192B),
        elevation: 0,
        title: const Text("Earnings & Instant Payouts", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 1. WITHDRAWABLE BALANCE CARD
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
                  const Text("Withdrawable Driver Balance", style: TextStyle(color: Colors.white54, fontSize: 11.5)),
                  const SizedBox(height: 4),
                  Text("₹ ${_balance.toStringAsFixed(2)}", style: const TextStyle(color: Color(0xFF00E676), fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text("Linked: HDFC Bank A/c **4891 (IFSC: HDFC0001234)", style: TextStyle(color: Color(0xFF00F0FF), fontSize: 11)),
                  const SizedBox(height: 16),

                  GestureDetector(
                    onTap: _isTransferring ? null : _instantBankTransfer,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _balance > 0 ? const Color(0xFF00E676) : Colors.white12,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.account_balance, color: _balance > 0 ? Colors.black : Colors.white38, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            _isTransferring ? "Processing IMPS..." : "1-Click Instant Bank Transfer",
                            style: TextStyle(color: _balance > 0 ? Colors.black : Colors.white38, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. DAILY QUEST INCENTIVE
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0x26FFB703),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFB703)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("⚡ Daily Eco-Hero Quest", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      Text("₹ 300.00 Bonus", style: TextStyle(color: Color(0xFFFFB703), fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text("Complete 10 rides today. You've completed 8/10 rides!", style: TextStyle(color: Colors.white70, fontSize: 11)),
                  SizedBox(height: 8),
                  LinearProgressIndicator(value: 0.8, backgroundColor: Colors.white12, color: Color(0xFFFFB703)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. WEEKLY EARNINGS LEDGER
            const Text("Weekly Earnings Breakdown", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFF131D31), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
              child: Column(
                children: [
                  _breakdownRow("Gross Ride Fares (142 Trips)", "₹ 16,400.00", Colors.white),
                  _breakdownRow("Passenger Tips Earned (100% Yours)", "+₹ 850.00", Colors.amber),
                  _breakdownRow("Green Quest Bonuses", "+₹ 600.00", const Color(0xFF00E676)),
                  _breakdownRow("Platform Tech Commission (10%)", "-₹ 1,640.00", Colors.redAccent),
                  const Divider(color: Colors.white12, height: 18),
                  _breakdownRow("Net Driver Weekly Take-Home", "₹ 16,210.00", const Color(0xFF00E676), isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 4. RECENT BANK PAYOUTS
            const Text("Recent Bank Settlements", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 10),

            ..._recentPayouts.map((p) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFF131D31), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p['id'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.5)),
                      Text("${p['date']} • ${p['bank']}", style: const TextStyle(color: Colors.white54, fontSize: 10)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("₹ ${(p['amount'] as num).toInt()}", style: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(p['status'] as String, style: const TextStyle(color: Color(0xFF00E676), fontSize: 9.5, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _breakdownRow(String title, String value, Color col, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(color: col, fontSize: isBold ? 14.5 : 12, fontWeight: isBold ? FontWeight.bold : FontWeight.w600)),
        ],
      ),
    );
  }
}