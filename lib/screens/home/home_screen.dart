import 'package:flutter/material.dart';

import '../../widgets/home/ai_suggestion_card.dart';
import '../../widgets/home/service_grid.dart';
import '../../widgets/home/wallet_summary_card.dart';
import '../charging/charging_booking_screen.dart';
import '../profile/profile_screen.dart';
import '../ride/booking_screen.dart';
import '../wallet/wallet_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomeDashboard(context),
      const BookingScreen(),
      const ChargingBookingScreen(),
      const WalletScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF080E1A),
      body: Stack(
        children: [
          // 1. SCROLLABLE CONTENT (PADDING AT BOTTOM SO IT DOES NOT OVERLAP FOOTER)
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 70),
              child: IndexedStack(
                index: _currentTab,
                children: pages,
              ),
            ),
          ),

          // 2. 🌟 100% FIXED FLOATING 5-TAB FOOTER BAR
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 70,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF10192B),
                border: Border(
                  top: BorderSide(color: const Color(0xFF00E676).withOpacity(0.4), width: 1.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.9),
                    blurRadius: 20,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTabItem(0, Icons.home_outlined, Icons.home, "Home"),
                  _buildTabItem(1, Icons.directions_car_outlined, Icons.directions_car, "Rides"),
                  _buildTabItem(2, Icons.ev_station_outlined, Icons.ev_station, "Charging"),
                  _buildTabItem(3, Icons.account_balance_wallet_outlined, Icons.account_balance_wallet, "Wallet"),
                  _buildTabItem(4, Icons.person_outline, Icons.person, "Profile"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentTab == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _currentTab = index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? const Color(0xFF00E676) : Colors.white38,
              size: isSelected ? 24 : 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF00E676) : Colors.white38,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeDashboard(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        children: [
          // VIP PASSENGER HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF00E676), width: 2),
                    ),
                    child: const CircleAvatar(
                      radius: 20,
                      backgroundColor: Color(0xFF131D31),
                      child: Icon(Icons.person, color: Color(0xFF00E676), size: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text("Anamika Choudhary", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                          SizedBox(width: 6),
                          Text("⭐ 4.9", style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Text("📍 Bhopal SuperHub Zone • 🌿 142 kg CO2 Saved", style: TextStyle(color: Color(0xFF00E676), fontSize: 10.5, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
              Container(
                decoration: const BoxDecoration(color: Color(0xFF131D31), shape: BoxShape.circle),
                child: IconButton(
                  icon: const Icon(Icons.notifications_none, color: Colors.white, size: 20),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("🔔 5% Cashback Credited on your recent booking!"), backgroundColor: Color(0xFF00E676)),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // WHERE TO GO SEARCH BAR
          GestureDetector(
            onTap: () => setState(() => _currentTab = 1), // Direct open Rides Tab
            child: Container(
              padding: const EdgeInsets.all(14),
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
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Color(0x2600E676), shape: BoxShape.circle),
                    child: const Icon(Icons.near_me, color: Color(0xFF00E676), size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Where do you want to go?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
                        Text("Book EV Bike, Auto, Pink Cab, Comfort or Cargo", style: TextStyle(color: Colors.white54, fontSize: 10.5)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Color(0xFF00E676), shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_forward, color: Colors.black, size: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          // 5% CASHBACK LOYALTY CARD
          const WalletSummaryCard(),
          const SizedBox(height: 20),

          // SUPERHUB 4-IN-1 GRID
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("SuperHub Amenities & Services", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              Text("⚡ All Live", style: TextStyle(color: Color(0xFF00E676), fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          const ServiceGrid(),
          const SizedBox(height: 20),

          // AI MOBILITY ASSISTANT
          const AiSuggestionCard(),
          const SizedBox(height: 20),

          // FEATURED SUPERHUB CARD (DIRECT TO CHARGING TAB)
          GestureDetector(
            onTap: () => setState(() => _currentTab = 2),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF131D31),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: Color(0x2600E676), shape: BoxShape.circle),
                    child: const Icon(Icons.ev_station, color: Color(0xFF00E676), size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("EnerGo Central SuperHub", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
                        Text("📍 MP Nagar • 4 Free Ports (120kW Fast DC)", style: TextStyle(color: Colors.white54, fontSize: 10.5)),
                        Text("⚡ ₹18.50/kWh • 🛏️ Rest Beds • 🅿️ Parking Active", style: TextStyle(color: Color(0xFF00E676), fontSize: 10.5, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 14),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}