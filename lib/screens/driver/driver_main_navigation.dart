import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

import 'driver_dashboard_screen.dart';
import 'driver_ride_requests_screen.dart';
import 'driver_history_screen.dart';
import 'driver_profile_screen.dart';
import 'driver_earnings_screen.dart';

class DriverMainNavigation extends StatefulWidget {

  const DriverMainNavigation({
    super.key,
  });


  @override
  State<DriverMainNavigation> createState() =>
      _DriverMainNavigationState();

}



class _DriverMainNavigationState
    extends State<DriverMainNavigation> {


  int currentIndex = 0;


  final List<Widget> screens = [


   const DriverDashboardScreen(),

  const DriverRideRequestsScreen(),

  const DriverHistoryScreen(),

  const DriverProfileScreen(),



  ];



  @override
  Widget build(BuildContext context){


    return Scaffold(


      backgroundColor:
      AppColors.background,


      body:

      IndexedStack(

        index: currentIndex,

        children: screens,

      ),



      bottomNavigationBar:


      Container(


        decoration:

        BoxDecoration(


          color:

          Colors.black.withOpacity(.85),


          borderRadius:

          const BorderRadius.vertical(

            top: Radius.circular(25),

          ),


        ),



        child:


        BottomNavigationBar(


          currentIndex:
          currentIndex,


          backgroundColor:
          Colors.transparent,


          elevation:0,


          type:
          BottomNavigationBarType.fixed,



          selectedItemColor:
          AppColors.primaryGreen,



          unselectedItemColor:
          Colors.white54,



          onTap:(index){


            setState((){


              currentIndex=index;

            });
          },

          items:[
            const BottomNavigationBarItem(

              icon:
              Icon(Icons.dashboard_outlined),

              label:"Dashboard",

            ),
            const BottomNavigationBarItem(

              icon:
              Icon(Icons.local_taxi_outlined),

              label:"Requests",

            ),
            const BottomNavigationBarItem(

              icon:
              Icon(Icons.account_balance_wallet),

              label:"Earnings",

            ),

            const BottomNavigationBarItem(

              icon:
              Icon(Icons.person_outline),

              label:"Profile",

            ),
          ],
        ),
      ),
    );
  }
}
