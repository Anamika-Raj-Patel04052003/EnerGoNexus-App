import 'package:flutter/material.dart';

import 'screens/auth/driver_login_screen.dart';
import 'screens/auth/role_selection_screen.dart';
import 'screens/charging/charging_booking_screen.dart';
import 'screens/driver/driver_main_navigation.dart';
import 'screens/facility/cafe_table_screen.dart';
import 'screens/facility/facility_booking_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/parking/parking_booking_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/ride/booking_screen.dart';
import 'screens/wallet/wallet_screen.dart';
import 'services/energo_unified_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnergoUnifiedService().init();
  runApp(const EnerGoNexusApp());
}

class EnerGoNexusApp extends StatelessWidget {
  const EnerGoNexusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EnerGo Nexus EV SuperApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF080E1A),
        primaryColor: const Color(0xFF00E676),
      ),
      onGenerateRoute: (settings) {
        final routeName = settings.name ?? '/';

        // 1. EXACT DRIVER APP MATCH
        if (routeName.contains('driver')) {
          if (routeName.contains('login')) {
            return MaterialPageRoute(builder: (_) => const DriverLoginScreen(), settings: settings);
          }
          return MaterialPageRoute(builder: (_) => const DriverMainNavigation(), settings: settings);
        }

        // 2. EXACT PASSENGER APP MATCH
        if (routeName.contains('home') || routeName.contains('passenger')) {
          return MaterialPageRoute(builder: (_) => const HomeScreen(), settings: settings);
        }
        if (routeName.contains('booking')) {
          return MaterialPageRoute(builder: (_) => const BookingScreen(), settings: settings);
        }
        if (routeName.contains('charging')) {
          return MaterialPageRoute(builder: (_) => const ChargingBookingScreen(), settings: settings);
        }
        if (routeName.contains('parking')) {
          return MaterialPageRoute(builder: (_) => const ParkingBookingScreen(), settings: settings);
        }
        if (routeName.contains('facility')) {
          return MaterialPageRoute(builder: (_) => const FacilityBookingScreen(), settings: settings);
        }
        if (routeName.contains('cafe')) {
          return MaterialPageRoute(builder: (_) => const CafeTableScreen(), settings: settings);
        }
        if (routeName.contains('wallet')) {
          return MaterialPageRoute(builder: (_) => const WalletScreen(), settings: settings);
        }
        if (routeName.contains('profile')) {
          return MaterialPageRoute(builder: (_) => const ProfileScreen(), settings: settings);
        }

        // 3. DEFAULT: ROLE SELECTION GATEWAY
        return MaterialPageRoute(builder: (_) => const RoleSelectionScreen(), settings: settings);
      },
    );
  }
}