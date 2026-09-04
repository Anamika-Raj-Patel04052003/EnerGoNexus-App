import 'package:flutter/material.dart';

import '../wallet/wallet_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10192B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("My Profile & Eco-Impact", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 1. VIP AVATAR & BIO
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
              child: Text("Anamika Choudhary", style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 2),
            const Center(
              child: Text("⭐ 4.9 (54 Rides) • Platinum VIP Member", style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const Center(
              child: Text("+91 98765 12345 • Bhopal SuperHub Zone", style: TextStyle(color: Colors.white54, fontSize: 10.5)),
            ),
            const SizedBox(height: 20),

            // 2. ECO HERO SUSTAINABILITY METRICS
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
                      Text("🌿 142 kg", style: TextStyle(color: Color(0xFF00E676), fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    children: [
                      Text("Clean KM", style: TextStyle(color: Colors.white54, fontSize: 11)),
                      SizedBox(height: 2),
                      Text("⚡ 890 km", style: TextStyle(color: Color(0xFF00F0FF), fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    children: [
                      Text("Cashback", style: TextStyle(color: Colors.white54, fontSize: 11)),
                      SizedBox(height: 2),
                      Text("₹ 420.00", style: TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. PLATINUM VIP TIER CARD
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0x2600F0FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF00F0FF)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.workspace_premium, color: Color(0xFF00F0FF), size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Platinum Green Tier Active", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        Text("5% Auto-Cashback on Rides & SuperHubs + Priority Airport Pickup.", style: TextStyle(color: Colors.white70, fontSize: 10.5)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 4. ACTION TILES
            ListTile(
              tileColor: const Color(0xFF131D31),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              leading: const Icon(Icons.account_balance_wallet, color: Color(0xFF00E676)),
              title: const Text("EnerGo Wallet & Cashback", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              subtitle: const Text("View balance, top-up & transaction ledger", style: TextStyle(color: Colors.white54, fontSize: 10.5)),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 14),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen())),
            ),
            const SizedBox(height: 10),

            ListTile(
              tileColor: const Color(0xFF131D31),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              leading: const Icon(Icons.shield, color: Colors.redAccent),
              title: const Text("Safety & Emergency SOS", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              subtitle: const Text("24x7 Helpline • 112 Police Alert Integration", style: TextStyle(color: Colors.white54, fontSize: 10.5)),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 14),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("🛡️ Safety Guard Active • 112 Police Helpline Connected"), backgroundColor: Colors.redAccent),
                );
              },
            ),
            const SizedBox(height: 10),

            ListTile(
              tileColor: const Color(0xFF131D31),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              leading: const Icon(Icons.swap_horiz, color: Color(0xFF00F0FF)),
              title: const Text("Switch Role (Driver / Sub-Admin / Super Admin)", style: TextStyle(color: Color(0xFF00F0FF), fontSize: 13, fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 14),
              onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/role-selection', (r) => false),
            ),
          ],
        ),
      ),
    );
  }
}