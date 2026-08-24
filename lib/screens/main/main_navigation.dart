import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../services/api_service.dart';

import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../wallet/wallet_screen.dart';
import '../ride/booking_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({
    super.key,
  });

  @override
  State<MainNavigation> createState() =>
      _MainNavigationState();
}

class _MainNavigationState
    extends State<MainNavigation> {

  // ==========================================================
  // CURRENT TAB
  // ==========================================================

  int currentIndex = 0;

  // ==========================================================
  // SCREENS
  // ==========================================================

  final List<Widget> screens = [
    const HomeScreen(),
    const BookingScreen(),
    const WalletScreen(),
    const ProfileScreen(),
  ];

  // ==========================================================
  // INITIALIZATION
  // ==========================================================

  @override
  void initState() {
    super.initState();

    // Login ko touch nahi kar rahe.
    //
    // MainNavigation open hone ke baad passenger profile
    // check/create hoga.
    _preparePassengerProfile();
  }

  // ==========================================================
  // PREPARE PASSENGER PROFILE
  // ==========================================================

  Future<void> _preparePassengerProfile() async {
    try {
      print("========================================");
      print("       PASSENGER PROFILE CHECK");
      print("========================================");

      // --------------------------------------------------------
      // GET LOGGED-IN USER PROFILE
      // --------------------------------------------------------

      final profileResponse =
          await ApiService.getProfile();

      if (profileResponse["status"] != true) {
        print(
          "PROFILE ERROR: ${profileResponse["message"]}",
        );

        return;
      }

      // --------------------------------------------------------
      // GET USER
      // --------------------------------------------------------

      final user = profileResponse["user"];

      if (user == null || user is! Map) {
        print("USER DATA NOT FOUND");
        return;
      }

      final userId = user["id"];

      if (userId == null) {
        print("USER ID NOT FOUND");
        return;
      }

      final fullName =
          user["full_name"]?.toString() ?? "";

      final mobileNumber =
          user["mobile_number"]?.toString() ?? "";

      final email =
          user["email"]?.toString() ?? "";

      print("USER ID: $userId");
      print("USER NAME: $fullName");

      // --------------------------------------------------------
      // ENSURE PASSENGER PROFILE
      // --------------------------------------------------------

      final passengerResponse =
          await ApiService.ensurePassengerProfile(
        userId: userId,
        fullName: fullName,
        mobileNumber: mobileNumber,
        email: email,
      );

      // --------------------------------------------------------
      // SUCCESS
      // --------------------------------------------------------

      if (passengerResponse["status"] == true) {
        final passenger =
            passengerResponse["passenger"];

        if (passenger is Map &&
            passenger["id"] != null) {

          await ApiService.savePassengerId(
            passenger["id"],
          );

          print(
            "PASSENGER ID: ${passenger["id"]}",
          );
        }

        print(
          "PASSENGER PROFILE: READY",
        );

        print("========================================");

        return;
      }

      // --------------------------------------------------------
      // FAILED
      // --------------------------------------------------------

      print(
        "PASSENGER PROFILE ERROR: "
        "${passengerResponse["message"]}",
      );

      print("========================================");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            passengerResponse["message"] ??
                "Passenger profile could not be prepared",
          ),
        ),
      );
    } catch (e) {
      print(
        "PASSENGER PROFILE EXCEPTION: $e",
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Unable to prepare passenger profile",
          ),
        ),
      );
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],

      // ========================================================
      // BOTTOM NAVIGATION
      // ========================================================

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.75),

          borderRadius:
              const BorderRadius.vertical(
            top: Radius.circular(25),
          ),
        ),

        child: BottomNavigationBar(
          backgroundColor:
              Colors.transparent,

          type:
              BottomNavigationBarType.fixed,

          currentIndex:
              currentIndex,

          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },

          selectedItemColor:
              AppColors.primaryGreen,

          unselectedItemColor:
              Colors.white54,

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),

            BottomNavigationBarItem(
              icon:
                  Icon(Icons.directions_car),
              label: "Ride",
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.wallet),
              label: "Wallet",
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}