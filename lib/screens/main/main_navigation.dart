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
  // ACTIVE RIDE DATA
  // ==========================================================

  Map<String,dynamic>? activeRide;

  // ==========================================================
  // SCREENS
  // ==========================================================

late List<Widget> screens;

  // ==========================================================
  // INITIALIZATION
  // ==========================================================

  @override
  void initState() {
    super.initState();

   screens = [

    HomeScreen(
      activeRide: activeRide,
    ),

    const BookingScreen(),

    const WalletScreen(),

    const ProfileScreen(),

  ];


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

        await checkActiveRide();

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
// CHECK ACTIVE RIDE
// ==========================================================

Future<void> checkActiveRide() async {

  try {

    final passengerId =
        await ApiService.getPassengerId();


    if(passengerId == null){
      print("PASSENGER ID NOT FOUND");
      return;
    }


    final response =
        await ApiService.getPassengerRides(
          passengerId,
        );


    if(response["status"] != true){
      print(
        "ACTIVE RIDE CHECK FAILED"
      );
      return;
    }


    final rides =
        response["rides"];


    if(rides is! List){
      return;
    }


    for(final ride in rides){

      if(
        ride["ride_status"] == "Pending" ||
        ride["ride_status"] == "Accepted" ||
        ride["ride_status"] == "Driver Arrived" ||
        ride["ride_status"] == "Started"
      ){

        setState((){

          activeRide =
              Map<String,dynamic>.from(ride);

              screens[0] = HomeScreen(
    activeRide: activeRide,
  );

        });


        print(
          "ACTIVE RIDE FOUND: ${ride["id"]}"
        );


        return;
      }

    }


    print(
      "NO ACTIVE RIDE"
    );


  }
  catch(e){

    print(
      "CHECK ACTIVE RIDE ERROR: $e"
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