import 'package:flutter/material.dart';

import 'driver_documents_screen.dart';
import 'driver_earnings_screen.dart';

class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10192B),
        elevation: 0,
        title: const Text("Captain Profile & Badges", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 1. CAPTAIN AVATAR & BIO
            Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF00E676), width: 2.5)),
                child: const CircleAvatar(
                  radius: 38,
                  backgroundColor: Color(0xFF131D31),
                  child: Icon(Icons.person, color: Color(0xFF00E676), size: 44),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text("Suresh Verma", style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 2),
            const Center(
              child: Text("⭐ 4.9 (342 Reviews) • Super Captain Partner", style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const Center(
              child: Text("Member since Mar 2024 • Bhopal Fleet Zone", style: TextStyle(color: Colors.white54, fontSize: 10.5)),
            ),
            const SizedBox(height: 20),

            // 2. ECO-HERO & PERFORMANCE STATS
            Container(
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
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text("CO2 Saved", style: TextStyle(color: Colors.white54, fontSize: 11)),
                      SizedBox(height: 2),
                      Text("🌿 1,240 kg", style: TextStyle(color: Color(0xFF00E676), fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    children: [
                      Text("Acceptance", style: TextStyle(color: Colors.white54, fontSize: 11)),
                      SizedBox(height: 2),
                      Text("99.2%", style: TextStyle(color: Color(0xFF00F0FF), fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    children: [
                      Text("Cancellation", style: TextStyle(color: Colors.white54, fontSize: 11)),
                      SizedBox(height: 2),
                      Text("0.4%", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. EARNED HONORS & BADGES
            const Text("Earned Captain Badges", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(child: _badgePill("🌟 Super Captain", "100+ 5-Star Trips", const Color(0xFF00E676))),
                const SizedBox(width: 8),
                Expanded(child: _badgePill("⚡ EV Master", "Eco Fleet Pro", const Color(0xFF00F0FF))),
                const SizedBox(width: 8),
                Expanded(child: _badgePill("🛡️ Safety Star", "Zero Incidents", Colors.amber)),
              ],
            ),
            const SizedBox(height: 20),

            // 4. ACTION TILES
            ListTile(
              tileColor: const Color(0xFF131D31),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              leading: const Icon(Icons.verified_user, color: Color(0xFF00E676)),
              title: const Text("View Verified KYC Documents", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              subtitle: const Text("DL, RC, Aadhaar, Insurance & Police Check", style: TextStyle(color: Colors.white54, fontSize: 10.5)),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 14),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DriverDocumentsScreen())),
            ),
            const SizedBox(height: 10),

            ListTile(
              tileColor: const Color(0xFF131D31),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              leading: const Icon(Icons.account_balance, color: Color(0xFF00F0FF)),
              title: const Text("Bank Account & Instant Payouts", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              subtitle: const Text("HDFC Bank A/c **4891 • 1-Click IMPS", style: TextStyle(color: Colors.white54, fontSize: 10.5)),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 14),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DriverEarningsScreen())),
            ),
            const SizedBox(height: 10),

            ListTile(
              tileColor: const Color(0xFF131D31),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text("Switch Role / Sign Out", style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold)),
              onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/role-selection', (r) => false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badgePill(String title, String subtitle, Color col) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: col.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: col.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: col, fontWeight: FontWeight.bold, fontSize: 11)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 8.5)),
        ],
      ),
    );
  }
}