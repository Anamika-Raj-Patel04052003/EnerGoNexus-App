import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../config/payment_config.dart';

class RazorpayPaymentService {
  static Future<Map<String, dynamic>?> openCheckout({
    required BuildContext context,
    required double amount,
    required String purpose,
    String? userEmail,
    String? userPhone,
  }) async {
    return await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _RazorpayCheckoutModal(
        amount: amount,
        purpose: purpose,
        userEmail: userEmail ?? "passenger@energonexus.com",
        userPhone: userPhone ?? "+91 98765 43210",
      ),
    );
  }
}

class _RazorpayCheckoutModal extends StatefulWidget {
  final double amount;
  final String purpose;
  final String userEmail;
  final String userPhone;

  const _RazorpayCheckoutModal({
    required this.amount,
    required this.purpose,
    required this.userEmail,
    required this.userPhone,
  });

  @override
  State<_RazorpayCheckoutModal> createState() => _RazorpayCheckoutModalState();
}

class _RazorpayCheckoutModalState extends State<_RazorpayCheckoutModal> {
  String _selectedMethod = "upi";
  bool _isProcessing = false;

  static const Color bgPrimary = Color(0xFF060B14);
  static const Color bgInput = Color(0xFF1E293B);
  static const Color accentCyan = Color(0xFF00F0FF);
  static const Color accentGreen = Color(0xFF00E676);
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);

  void _completePayment(bool success) async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;
    if (success) {
      final paymentId = "pay_${Random().nextInt(89999999) + 10000000}";
      Navigator.pop(context, {
        'status': 'SUCCESS',
        'payment_id': paymentId,
        'amount': widget.amount,
        'razorpay_key': PaymentConfig.razorpayKeyId,
      });
    } else {
      Navigator.pop(context, {'status': 'FAILED'});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Razorpay Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF02042B),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF528FF0)),
                    ),
                    child: const Text(
                      "Razorpay",
                      style: TextStyle(
                        color: Color(0xFF528FF0),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text("TEST MODE", style: TextStyle(color: Colors.amber, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              Text(
                "₹ ${widget.amount.toStringAsFixed(2)}",
                style: const TextStyle(color: accentGreen, fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(widget.purpose, style: const TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
          Text("Key: ${PaymentConfig.razorpayKeyId} • Encrypted 256-bit", style: const TextStyle(color: textSecondary, fontSize: 10.5)),
          const Divider(color: bgInput, height: 24),

          // Payment Options
          const Text("Select Payment Instrument:", style: TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          _buildPaymentTile("UPI (GPay / PhonePe / Paytm / BHIM)", "upi", LucideIcons.smartphone, accentCyan),
          _buildPaymentTile("Debit / Credit Card (Visa / Mastercard)", "card", LucideIcons.creditCard, accentGreen),
          _buildPaymentTile("Netbanking (All Major Indian Banks)", "netbanking", LucideIcons.building2, const Color(0xFFA855F7)),

          const SizedBox(height: 20),

          // Pay Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF528FF0),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isProcessing ? null : () => _completePayment(true),
              child: _isProcessing
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.lock, size: 16),
                        const SizedBox(width: 8),
                        Text("Pay ₹ ${widget.amount.toStringAsFixed(2)} via Razorpay", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTile(String title, String value, IconData icon, Color color) {
    final isSelected = _selectedMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : bgPrimary,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? color : bgInput, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? color : textSecondary, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected ? color : textPrimary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected) Icon(LucideIcons.check, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}