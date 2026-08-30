import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'driver_vehicle_screen.dart';
import 'driver_documents_screen.dart';
import 'driver_earnings_screen.dart';

class DriverProfileScreen extends StatelessWidget {


  const DriverProfileScreen({
    super.key,
  });



  @override
  Widget build(BuildContext context){


    return Scaffold(


      backgroundColor:
      AppColors.background,



      appBar:

      AppBar(

        backgroundColor:
        Colors.transparent,

        elevation:0,

        title:

        const Text(

          "Driver Profile",

          style:

          TextStyle(

            fontWeight:
            FontWeight.bold,

          ),

        ),

      ),




      body:


      SingleChildScrollView(


        padding:

        const EdgeInsets.all(20),



        child:

        Column(


          children:[



            // PROFILE HEADER

            Container(


              width:
              double.infinity,


              padding:

              const EdgeInsets.all(25),



              decoration:

              BoxDecoration(


                color:

                AppColors.card,


                borderRadius:

                BorderRadius.circular(25),



              ),



              child:

              Column(


                children:[



                  CircleAvatar(


                    radius:45,


                    backgroundColor:

                    AppColors.primaryGreen
                        .withOpacity(.2),



                    child:

                    const Icon(

                      Icons.person,

                      size:50,

                      color:

                      AppColors.primaryGreen,

                    ),

                  ),




                  const SizedBox(height:15),




                  const Text(

                    "EnerGo Driver",

                    style:

                    TextStyle(

                      fontSize:24,

                      fontWeight:
                      FontWeight.bold,

                    ),

                  ),



                  const SizedBox(height:8),




                  Row(

                    mainAxisAlignment:
                    MainAxisAlignment.center,

                    children:[


                      const Icon(

                        Icons.star,

                        color:
                        Colors.amber,

                        size:18,

                      ),


                      const SizedBox(width:5),


                      const Text(

                        "4.8 Rating",

                        style:

                        TextStyle(

                          color:
                          Colors.white70,

                        ),

                      ),


                    ],

                  )



                ],

              ),


            ),





            const SizedBox(height:25),





            profileCard(

              icon: Icons.phone,

              title:"Mobile Number",

              value:"9876543210",

            ),



           profileCard(

  icon: Icons.directions_car,

  title:"Vehicle",

  value:"Electric Auto",

  onTap:(){

    Navigator.push(

      context,

      MaterialPageRoute(

        builder:(context)=>

        const DriverVehicleScreen(),

      ),

    );

  },

),



            profileCard(

              icon: Icons.confirmation_number,

              title:"Vehicle Number",

              value:"MP04 AB1234",

            ),


profileCard(

  icon: Icons.badge,

  title:"Documents",

  value:"Verified",

  onTap:(){

    Navigator.push(

      context,

      MaterialPageRoute(

        builder:(context)=>

        const DriverDocumentsScreen(),

      ),

    );

  },

),


profileCard(

  icon: Icons.account_balance_wallet,

  title:"Earnings",

  value:"View Income History",

  onTap:(){

    Navigator.push(

      context,

      MaterialPageRoute(

        builder:(context)=>

        const DriverEarningsScreen(),

      ),

    );

  },

),

            const SizedBox(height:30),





            SizedBox(


              width:
              double.infinity,


              height:50,


              child:

              ElevatedButton(


                onPressed:(){


                  // logout later


                },


                style:

                ElevatedButton.styleFrom(


                  backgroundColor:
                  Colors.redAccent,


                  foregroundColor:
                  Colors.white,



                  shape:

                  RoundedRectangleBorder(

                    borderRadius:
                    BorderRadius.circular(18),

                  ),

                ),



                child:

                const Text(

                  "LOGOUT",

                  style:

                  TextStyle(

                    fontWeight:
                    FontWeight.bold,

                  ),

                ),


              ),


            )



          ],

        ),


      ),


    );


  }

Widget profileCard({

    required IconData icon,

    required String title,

    required String value,

    VoidCallback? onTap,

  }){


    return GestureDetector(

  onTap: onTap,

  child: Container(


      margin:

      const EdgeInsets.only(bottom:15),



      padding:

      const EdgeInsets.all(18),



      decoration:

      BoxDecoration(


        color:

        AppColors.card,


        borderRadius:

        BorderRadius.circular(20),



      ),



      child:

      Row(


        children:[



          Container(


            padding:

            const EdgeInsets.all(12),



            decoration:

            BoxDecoration(


              color:

              AppColors.primaryGreen
                  .withOpacity(.15),



              borderRadius:

              BorderRadius.circular(15),


            ),



            child:

            Icon(

              icon,

              color:

              AppColors.primaryGreen,

            ),


          ),





          const SizedBox(width:15),




          Column(


            crossAxisAlignment:
            CrossAxisAlignment.start,


            children:[



              Text(

                title,

                style:

                const TextStyle(

                  color:
                  Colors.white54,

                  fontSize:13,

                ),

              ),




              const SizedBox(height:5),




              Text(

                value,

                style:

                const TextStyle(

                  fontSize:17,

                  fontWeight:
                  FontWeight.bold,

                ),

              ),



            ],

          )


        ],

      ),


    ),
);

  }



}