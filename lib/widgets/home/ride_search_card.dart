import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_colors.dart';



class RideSearchCard extends StatelessWidget {


  final VoidCallback onTap;


  const RideSearchCard({

    super.key,

    required this.onTap,

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

              .withOpacity(0.18),


        ),



        boxShadow: [


          BoxShadow(

            color:

            Colors.black

                .withOpacity(0.25),


            blurRadius: 20,


            offset:

            const Offset(0,8),


          ),


        ],


      ),





      child: Column(


        crossAxisAlignment:

        CrossAxisAlignment.start,



        children: [




          const Text(


            "Where do you want to go?",



            style: TextStyle(


              color:

              Colors.white,



              fontSize:20,



              fontWeight:

              FontWeight.bold,


            ),



          ),





          const SizedBox(height:20),





          // PICKUP


          locationTile(


            icon:

            LucideIcons.navigation,


            title:

            "Current Location",


            subtitle:

            "Your pickup point",


          ),




          const SizedBox(height:12),





          // DESTINATION


          locationTile(


            icon:

            LucideIcons.mapPin,


            title:

            "Search Destination",


            subtitle:

            "Where do you want to go?",


          ),




          const SizedBox(height:22),





          // BOOK BUTTON


          SizedBox(


            width:

            double.infinity,



            height:

            52,



            child:

            ElevatedButton(



              onPressed:

              onTap,



              style:

              ElevatedButton.styleFrom(



                backgroundColor:

                AppColors.primaryGreen,



                foregroundColor:

                Colors.black,



                elevation:

                0,



                shape:

                RoundedRectangleBorder(



                  borderRadius:

                  BorderRadius.circular(18),


                ),



              ),




              child:

              const Row(



                mainAxisAlignment:

                MainAxisAlignment.center,



                children: [



                  Icon(

                    LucideIcons.car,

                    size:20,

                  ),



                  SizedBox(width:8),



                  Text(



                    "BOOK RIDE",



                    style:

                    TextStyle(



                      fontWeight:

                      FontWeight.bold,



                      fontSize:15,


                    ),



                  ),



                ],



              ),



            ),



          ),



        ],


      ),


    );


  }






  Widget locationTile({

    required IconData icon,

    required String title,

    required String subtitle,

  }){


    return Container(


      padding:

      const EdgeInsets.all(15),



      decoration:

      BoxDecoration(



        color:

        Colors.black

            .withOpacity(0.25),



        borderRadius:

        BorderRadius.circular(18),



      ),




      child:

      Row(



        children: [



          Container(


            height:42,

            width:42,



            decoration:

            BoxDecoration(


              color:

              AppColors.primaryGreen

                  .withOpacity(0.15),



              borderRadius:

              BorderRadius.circular(14),



            ),




            child:

            Icon(


              icon,


              color:

              AppColors.primaryGreen,


              size:20,


            ),



          ),




          const SizedBox(width:14),





          Column(


            crossAxisAlignment:

            CrossAxisAlignment.start,



            children: [



              Text(


                title,



                style:

                const TextStyle(


                  color:

                  Colors.white,



                  fontSize:15,



                  fontWeight:

                  FontWeight.w600,


                ),



              ),




              const SizedBox(height:4),




              Text(


                subtitle,



                style:

                const TextStyle(


                  color:

                  Colors.white54,



                  fontSize:12,


                ),



              ),



            ],



          ),



        ],



      ),



    );


  }



}