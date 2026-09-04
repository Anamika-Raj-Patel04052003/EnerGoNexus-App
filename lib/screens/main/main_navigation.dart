import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../charging/charging_booking_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../ride/booking_screen.dart';
import '../wallet/wallet_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const BookingScreen(),
    const ChargingBookingScreen(),
    const WalletScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080E1A),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF10192B),
          border: Border(top: BorderSide(color: AppColors.primaryGreen.withValues(alpha: 0.25), width: 1.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: const Color(0xFF10192B),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primaryGreen,
          unselectedItemColor: Colors.white38,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.home, size: 22)),
              activeIcon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.home_filled, size: 24, color: AppColors.primaryGreen)),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.directions_car_outlined, size: 22)),
              activeIcon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.directions_car, size: 24, color: AppColors.primaryGreen)),
              label: "Rides",
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.ev_station_outlined, size: 22)),
              activeIcon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.ev_station, size: 24, color: AppColors.primaryGreen)),
              label: "Charging",
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.account_balance_wallet_outlined, size: 22)),
              activeIcon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.account_balance_wallet, size: 24, color: AppColors.primaryGreen)),
              label: "Wallet",
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.person_outline, size: 22)),
              activeIcon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.person, size: 24, color: AppColors.primaryGreen)),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}