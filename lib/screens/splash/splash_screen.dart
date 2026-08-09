import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/animated_ev_background.dart';
import '../../services/auth_service.dart';
import '../home/home_screen.dart';
import '../auth/login_screen.dart';


class SplashScreen extends StatefulWidget {

  const SplashScreen({super.key});


  @override
  State<SplashScreen> createState() => _SplashScreenState();

}



class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {


  late AnimationController logoController;

  late Animation<double> logoAnimation;



  @override
  void initState() {

    super.initState();


    logoController = AnimationController(

      vsync: this,

      duration: const Duration(seconds:2),

    )..repeat(reverse:true);



    logoAnimation = Tween<double>(

      begin:0.95,

      end:1.08,


    ).animate(

      CurvedAnimation(

        parent:logoController,

        curve:Curves.easeInOut,

      ),

    );



    // Splash Duration

   Timer(

  const Duration(seconds:3),

  () async {


    bool loggedIn =

    await AuthService.isLoggedIn();



    if(loggedIn){



      Navigator.pushReplacement(

        context,

        MaterialPageRoute(

          builder:(context)=>

          const HomeScreen(),

        ),

      );



    }

    else{



      Navigator.pushReplacement(

        context,

        MaterialPageRoute(

          builder:(context)=>

          const LoginScreen(),

        ),

      );


    }



  },

);


  }





  @override
  void dispose(){

    logoController.dispose();

    super.dispose();

  }






  @override
  Widget build(BuildContext context){


    return Scaffold(

      body:

      AnimatedEVBackground(

        child:

        Center(

          child:

          Column(

            mainAxisAlignment:
            MainAxisAlignment.center,


            children:[



              ScaleTransition(

                scale:logoAnimation,


                child:

                Container(

                  padding:
                  const EdgeInsets.all(10),


                  decoration:

                  BoxDecoration(

                    shape:

                    BoxShape.circle,


                    boxShadow:[


                      BoxShadow(

                        color:

                        AppColors.primaryGreen
                            .withOpacity(0.35),


                        blurRadius:50,


                        spreadRadius:12,


                      )

                    ],


                  ),



                  child:

                  Image.asset(

                    "assets/images/logoEnergo.png",

                    height:190,

                  ),


                ),

              ),





              const SizedBox(height:10),





              const Text(

                "EnerGo",


                style:

                TextStyle(

                  color:

                  AppColors.primaryGreen,


                  fontSize:46,


                  fontWeight:

                  FontWeight.bold,


                  letterSpacing:1.5,

                ),

              ),





              const SizedBox(height:8),





              const Text(

                "Smart EV Mobility Platform",


                style:

                TextStyle(

                  color:

                  Colors.white70,


                  fontSize:16,

                ),

              ),



            ],


          ),

        ),

      ),

    );


  }


}