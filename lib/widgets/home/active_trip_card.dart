import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_colors.dart';



class ActiveTripCard extends StatelessWidget {


  final String status;

  final String driverName;

  final String eta;

  final VoidCallback? onTrackRide;



  const ActiveTripCard({

    super.key,

    required this.status,

    this.driverName = "Your Driver",

    this.eta = "5 min",

    this.onTrackRide,

  });



  @override
  Widget build(BuildContext context) {


    return Container(


      padding:

      const EdgeInsets.all(22),



      decoration: BoxDecoration(



        color:

        AppColors.card,



        borderRadius:

        BorderRadius.circular(28),



        border: Border.all(


          color:

          AppColors.primaryGreen

              .withOpacity(0.25),


        ),



      ),





      child: Column(


        crossAxisAlignment:

        CrossAxisAlignment.start,



        children: [



          // Header


          Row(



            mainAxisAlignment:

            MainAxisAlignment.spaceBetween,



            children: [



              const Text(


                "Current Ride",



                style:

                TextStyle(



                  color:

                  Colors.white70,



                  fontSize:14,


                ),



              ),





              Container(


                padding:

                const EdgeInsets.symmetric(

                  horizontal:10,

                  vertical:6,

                ),



                decoration:

                BoxDecoration(



                  color:

                  AppColors.primaryGreen

                      .withOpacity(0.15),



                  borderRadius:

                  BorderRadius.circular(20),



                ),




                child:

                Row(



                  children: [



                    const Icon(


                      LucideIcons.clock,


                      color:

                      AppColors.primaryGreen,


                      size:14,


                    ),



                    const SizedBox(width:5),



                    Text(


                      eta,


                      style:

                      const TextStyle(



                        color:

                        AppColors.primaryGreen,



                        fontSize:12,


                        fontWeight:

                        FontWeight.bold,


                      ),



                    ),



                  ],



                ),



              ),



            ],



          ),




          const SizedBox(height:20),






          // Driver Information


          Row(



            children: [



              Container(


                height:52,

                width:52,



                decoration:

                BoxDecoration(



                  color:

                  AppColors.primaryGreen

                      .withOpacity(0.15),



                  borderRadius:

                  BorderRadius.circular(18),



                ),



                child:

                const Icon(



                  LucideIcons.car,



                  color:

                  AppColors.primaryGreen,



                  size:26,


                ),



              ),





              const SizedBox(width:15),





              Column(



                crossAxisAlignment:

                CrossAxisAlignment.start,



                children: [



                  Text(



                    driverName,



                    style:

                    const TextStyle(



                      color:

                      Colors.white,



                      fontSize:17,



                      fontWeight:

                      FontWeight.bold,


                    ),



                  ),




                  const SizedBox(height:5),




                  Text(



                    status,



                    style:

                    const TextStyle(



                      color:

                      Colors.white54,



                      fontSize:13,


                    ),



                  ),



                ],



              )



            ],



          ),





          const SizedBox(height:22),





          // Track Button


          SizedBox(


            width:

            double.infinity,



            height:

            48,



            child:

            ElevatedButton.icon(



              onPressed:

              onTrackRide,



              icon:

              const Icon(


                LucideIcons.navigation,


                size:18,


              ),



              label:

              const Text(



                "TRACK RIDE",



                style:

                TextStyle(



                  fontWeight:

                  FontWeight.bold,


                ),



              ),




              style:

              ElevatedButton.styleFrom(



                backgroundColor:

                AppColors.primaryGreen,



                foregroundColor:

                Colors.black,



                elevation:0,



                shape:

                RoundedRectangleBorder(



                  borderRadius:

                  BorderRadius.circular(18),



                ),



              ),



            ),



          )



        ],



      ),



    );


  }


}