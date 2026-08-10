import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_colors.dart';


class PremiumHeader extends StatelessWidget {

  final String name;
  final String location;


  const PremiumHeader({

    super.key,

    required this.name,

    this.location = "Bengaluru, India",

  });



  String getGreeting() {

    final hour = DateTime.now().hour;


    if (hour < 12) {

      return "Good Morning";

    } 
    
    else if (hour < 17) {

      return "Good Afternoon";

    } 
    
    else {

      return "Good Evening";

    }

  }



  @override
  Widget build(BuildContext context) {


    return Row(

      mainAxisAlignment:
      MainAxisAlignment.spaceBetween,


      crossAxisAlignment:
      CrossAxisAlignment.start,


      children: [



        // USER INFORMATION

        Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,


          children: [



            Text(

              "${getGreeting()} 👋",

              style: const TextStyle(

                color: Colors.white70,

                fontSize: 14,

                fontWeight:
                FontWeight.w500,

              ),

            ),



            const SizedBox(height: 6),



            Text(

              name.trim().isEmpty

                  ? "EnerGo User"

                  : name,


              style: const TextStyle(

                color: Colors.white,

                fontSize: 26,

                fontWeight:
                FontWeight.bold,

                letterSpacing: 0.3,

              ),

            ),



            const SizedBox(height: 10),



            // LOCATION CHIP

            Container(

              padding:

              const EdgeInsets.symmetric(

                horizontal: 12,

                vertical: 7,

              ),


              decoration: BoxDecoration(


                color: AppColors.card,


                borderRadius:

                BorderRadius.circular(20),



                border: Border.all(

                  color:

                  AppColors.primaryGreen

                      .withOpacity(0.25),

                ),


              ),



              child: Row(

                mainAxisSize:

                MainAxisSize.min,


                children: [



                  const Icon(

                    LucideIcons.mapPin,

                    size: 15,

                    color:

                    AppColors.primaryGreen,

                  ),



                  const SizedBox(width: 6),



                  Text(

                    location,


                    style: const TextStyle(

                      color:

                      Colors.white70,

                      fontSize: 12,

                    ),

                  ),


                ],

              ),

            ),


          ],

        ),





        // NOTIFICATION BUTTON


        Container(


          height: 48,

          width: 48,



          decoration: BoxDecoration(


            color:

            AppColors.card,



            shape:

            BoxShape.circle,



            border: Border.all(

              color:

              AppColors.primaryGreen

                  .withOpacity(0.35),

            ),



            boxShadow: [


              BoxShadow(

                color:

                AppColors.primaryGreen

                    .withOpacity(0.15),


                blurRadius: 18,

                spreadRadius: 2,

              ),

            ],



          ),



          child: const Icon(


            LucideIcons.bell,


            color:

            AppColors.primaryGreen,


            size: 22,


          ),



        ),



      ],

    );


  }

}