import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../wallet/wallet_screen.dart';
import '../ride/booking_screen.dart';



class MainNavigation extends StatefulWidget {


  const MainNavigation({super.key});



  @override
  State<MainNavigation> createState() =>
      _MainNavigationState();


}





class _MainNavigationState extends State<MainNavigation> {



  int currentIndex = 0;




 final List<Widget> screens = [


  const HomeScreen(),


  const BookingScreen(),


  const WalletScreen(),


  const ProfileScreen(),


];







  @override
  Widget build(BuildContext context){



    return Scaffold(



      body:



      screens[currentIndex],






      bottomNavigationBar:



      Container(



        decoration:



        BoxDecoration(



          color:

          Colors.black.withOpacity(0.75),



          borderRadius:

          const BorderRadius.vertical(



            top:

            Radius.circular(25),



          ),



        ),




        child:



        BottomNavigationBar(



          backgroundColor:

          Colors.transparent,



          type:

          BottomNavigationBarType.fixed,



          currentIndex:

          currentIndex,



          onTap:(index){



            setState((){



              currentIndex = index;



            });



          },





          selectedItemColor:

          AppColors.primaryGreen,



          unselectedItemColor:

          Colors.white54,






          items:[





            const BottomNavigationBarItem(



              icon:

              Icon(Icons.home),



              label:"Home",



            ),





            const BottomNavigationBarItem(



              icon:

              Icon(Icons.directions_car),



              label:"Ride",



            ),





            const BottomNavigationBarItem(



              icon:

              Icon(Icons.wallet),



              label:"Wallet",



            ),





            const BottomNavigationBarItem(



              icon:

              Icon(Icons.person),



              label:"Profile",



            ),



          ],



        ),



      ),



    );



  }



}