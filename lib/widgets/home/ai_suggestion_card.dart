import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../screens/charging/charging_booking_screen.dart';
import '../../screens/facility/facility_booking_screen.dart';

class AiSuggestionCard extends StatelessWidget {
  const AiSuggestionCard({super.key});

  void _openAiDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(LucideIcons.bot, color: Color(0xFF00F0FF), size: 24),
                SizedBox(width: 10),
                Text("EnerGo AI Assistant", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const Divider(color: Colors.white12, height: 20),
            _aiTile("⚡ Bhopal Central has 4 vacant 120kW Fast DC Ports.", () {
              Navigator.pop(ctx);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ChargingBookingScreen()));
            }),
            const SizedBox(height: 8),
            _aiTile("🛏️ Rest Pod #A1 is clean & available for power nap (₹80/hr).", () {
              Navigator.pop(ctx);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const FacilityBookingScreen()));
            }),
            const SizedBox(height: 8),
            _aiTile("🎁 5% Cashback is active on all wallet recharges today.", null),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.black),
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Close", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _aiTile(String text, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            const Icon(LucideIcons.sparkles, color: AppColors.primaryGreen, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 11.5))),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openAiDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF00F0FF).withValues(alpha: 0.3)),
        ),
        child: const Row(
          children: [
            Icon(LucideIcons.bot, color: Color(0xFF00F0FF), size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("AI Mobility Assistant", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  Text("Tap to check free charging ports, rest beds & traffic", style: TextStyle(color: Colors.white54, fontSize: 10)),
                ],
              ),
            ),
            Icon(LucideIcons.arrowRight, color: Color(0xFF00F0FF), size: 16),
          ],
        ),
      ),
    );
  }
}