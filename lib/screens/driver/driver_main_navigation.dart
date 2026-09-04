import 'package:flutter/material.dart';

import 'driver_dashboard_screen.dart';
import 'driver_earnings_screen.dart';
import 'driver_history_screen.dart';
import 'driver_profile_screen.dart';
import 'driver_vehicle_screen.dart';

class DriverMainNavigation extends StatefulWidget {
  const DriverMainNavigation({super.key});

  @override
  State<DriverMainNavigation> createState() => _DriverMainNavigationState();
}

class _DriverMainNavigationState extends State<DriverMainNavigation> {
  int _currentTab = 0;

  final List<Widget> _driverScreens = [
    const DriverDashboardScreen(),
    const DriverEarningsScreen(),
    const DriverHistoryScreen(),
    const DriverVehicleScreen(),
    const DriverProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080E1A),
      body: IndexedStack(
        index: _currentTab,
        children: _driverScreens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF10192B),
          border: Border(top: BorderSide(color: const Color(0xFF00F0FF).withOpacity(0.35), width: 1.2)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 16, offset: const Offset(0, -4)),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentTab,
          onTap: (index) => setState(() => _currentTab = index),
          backgroundColor: const Color(0xFF10192B),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF00F0FF),
          unselectedItemColor: Colors.white38,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.speed_outlined),
              activeIcon: Icon(Icons.speed, color: Color(0xFF00F0FF)),
              label: "Duty",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet, color: Color(0xFF00F0FF)),
              label: "Earnings",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history, color: Color(0xFF00F0FF)),
              label: "Trips",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.electric_car_outlined),
              activeIcon: Icon(Icons.electric_car, color: Color(0xFF00F0FF)),
              label: "EV Telemetry",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person, color: Color(0xFF00F0FF)),
              label: "Captain",
            ),
          ],
        ),
      ),
    );
  }
}