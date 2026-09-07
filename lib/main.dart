import 'package:flutter/material.dart';

import 'screens/auth/driver_login_screen.dart';
import 'screens/auth/role_selection_screen.dart';
import 'screens/charging/charging_booking_screen.dart';
import 'screens/driver/driver_active_ride_screen.dart';
import 'screens/driver/driver_main_navigation.dart';
import 'screens/facility/cafe_table_screen.dart';
import 'screens/facility/facility_booking_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/parking/parking_booking_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/ride/booking_screen.dart';
import 'screens/ride/ride_tracking_screen.dart';
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
      routes: {
        '/': (context) => const RoleSelectionScreen(),
        '/home': (context) => const HomeScreen(),
        '/driver-login': (context) => const DriverLoginScreen(),
        '/driver': (context) => const DriverActiveRideScreen(),
        '/driver-nav': (context) => const DriverMainNavigation(),
        '/charging': (context) => const ChargingBookingScreen(),
        '/parking': (context) => const ParkingBookingScreen(),
        '/booking': (context) => const BookingScreen(),
        '/tracking': (context) => const RideTrackingScreen(),
        '/facility': (context) => const FacilityBookingScreen(),
        '/cafe': (context) => const CafeTableScreen(),
        '/wallet': (context) => const WalletScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
      onGenerateRoute: (settings) {
        final routeName = settings.name ?? '/';

        if (routeName.contains('driver')) {
          if (routeName.contains('login')) {
            return MaterialPageRoute(builder: (_) => const DriverLoginScreen(), settings: settings);
          }
          return MaterialPageRoute(builder: (_) => const DriverActiveRideScreen(), settings: settings);
        }
        if (routeName.contains('home') || routeName.contains('passenger')) {
          return MaterialPageRoute(builder: (_) => const HomeScreen(), settings: settings);
        }
        if (routeName.contains('booking')) {
          return MaterialPageRoute(builder: (_) => const BookingScreen(), settings: settings);
        }
        if (routeName.contains('tracking')) {
          return MaterialPageRoute(builder: (_) => const RideTrackingScreen(), settings: settings);
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

        return MaterialPageRoute(builder: (_) => const RoleSelectionScreen(), settings: settings);
      },
    );
  }
}