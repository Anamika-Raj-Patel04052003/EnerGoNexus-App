import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_colors.dart';

class PaymentReceiptScreen extends StatelessWidget {
  final Map<String, dynamic> invoiceData;

  const PaymentReceiptScreen({
    super.key,
    required this.invoiceData,
  });

  @override
  Widget build(BuildContext context) {
    final invId = invoiceData['invoice_id'] ?? 'INV-EV-90412';
    final station = invoiceData['station_name'] ?? 'EnerGo SuperHub Central';
    final vehicle = invoiceData['vehicle_name'] ?? 'Tata Nexon EV Max';
    final plate = invoiceData['vehicle_plate'] ?? 'MP 04 EV 8891';
    final port = invoiceData['port_name'] ?? 'Port #1 (CCS2 Fast DC 120kW)';
    final energy = invoiceData['energy_kwh'] ?? '32.5';
    final tariff = invoiceData['tariff_rate'] ?? '18.50';
    final base = invoiceData['base_amount'] ?? '601.25';
    final gst = invoiceData['gst_amount'] ?? '108.22';
    final total = invoiceData['total_amount'] ?? '709.47';
    final mode = invoiceData['payment_mode'] ?? 'RAZORPAY';
    final txn = invoiceData['transaction_id'] ?? 'pay_98234112';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Digital Tax Invoice & Slip", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Receipt Card
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Invoice Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "EnerGoNexus EV",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          Text(
                            "GSTIN: 23AABCE1234F1Z5 • $invId",
                            style: const TextStyle(color: Colors.white54, fontSize: 11),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppColors.primaryGreen.withValues(alpha: 0.15), shape: BoxShape.circle),
                        child: const Icon(LucideIcons.checkCheck, color: AppColors.primaryGreen, size: 24),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white12, height: 28),

                  // Slip Line Items
                  _buildReceiptRow("SuperHub Station", station),
                  _buildReceiptRow("Vehicle Model", "$vehicle ($plate)"),
                  _buildReceiptRow("Charging Port", port),
                  _buildReceiptRow("Energy Dispensed", "$energy kWh"),
                  _buildReceiptRow("Base Tariff Rate", "₹ $tariff / kWh"),
                  _buildReceiptRow("Subtotal", "₹ $base"),
                  _buildReceiptRow("GST (18% Green Energy)", "₹ $gst"),
                  const Divider(color: Colors.white12, height: 24),

                  // Total Highlight
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total Amount Paid", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      Text("₹ $total", style: const TextStyle(color: AppColors.primaryGreen, fontSize: 22, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildReceiptRow("Payment Mode", mode),
                  _buildReceiptRow("Transaction Ref", txn),
                  const Divider(color: Colors.white12, height: 24),

                  // QR Code Verification
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                          child: const Icon(LucideIcons.qrCode, color: Colors.black, size: 68),
                        ),
                        const SizedBox(height: 8),
                        const Text("Scan QR at Charging Bay or Exit Gate", style: TextStyle(color: Colors.white54, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryGreen,
                      side: const BorderSide(color: AppColors.primaryGreen),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Tax Invoice Slip Downloaded to Gallery / Storage!"), backgroundColor: AppColors.primaryGreen),
                      );
                    },
                    icon: const Icon(LucideIcons.download, size: 18),
                    label: const Text("Download Slip", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(LucideIcons.home, size: 18),
                    label: const Text("Return Home", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }
}