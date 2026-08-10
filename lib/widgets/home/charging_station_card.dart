import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_colors.dart';



class ChargingStationCard extends StatelessWidget {


  final String stationName;

  final String distance;

  final String ports;

  final String chargingType;

  final String price;

  final VoidCallback? onTap;



  const ChargingStationCard({

    super.key,

    this.stationName = "EnerGo Fast Charging Hub",

    this.distance = "2.5 km away",

    this.ports = "4 Ports Available",

    this.chargingType = "Fast Charging",

    this.price = "₹12 / unit",

    this.onTap,

  });



  @override
  Widget build(BuildContext context) {


    return InkWell(

      onTap: onTap,

      borderRadius:

      BorderRadius.circular(28),


      child: Container(


        width:

        double.infinity,



        padding:

        const EdgeInsets.all(20),



        decoration:

        BoxDecoration(


          color:

          AppColors.card,



          borderRadius:

          BorderRadius.circular(28),



          border: Border.all(

            color:

            AppColors.primaryGreen

                .withOpacity(0.25),

          ),



          boxShadow: [


            BoxShadow(

              color:

              AppColors.primaryGreen

                  .withOpacity(0.08),


              blurRadius:18,


              offset:

              const Offset(0,8),


            )

          ],


        ),





        child: Row(


          children: [



            // Station Icon


            Container(


              height:60,

              width:60,



              decoration:

              BoxDecoration(


                color:

                AppColors.primaryGreen

                    .withOpacity(0.15),



                borderRadius:

                BorderRadius.circular(20),



              ),



              child:

              const Icon(



                LucideIcons.battery,



                color:

                AppColors.primaryGreen,



                size:30,


              ),



            ),




            const SizedBox(width:16),





            Expanded(



              child:

              Column(



                crossAxisAlignment:

                CrossAxisAlignment.start,



                children: [



                  Text(


                    stationName,



                    maxLines:1,

                    overflow:

                    TextOverflow.ellipsis,



                    style:

                    const TextStyle(



                      color:

                      Colors.white,



                      fontSize:16,



                      fontWeight:

                      FontWeight.bold,


                    ),



                  ),





                  const SizedBox(height:8),





                  Row(



                    children: [



                      const Icon(


                        LucideIcons.mapPin,


                        size:14,


                        color:

                        AppColors.primaryGreen,


                      ),




                      const SizedBox(width:5),




                      Text(


                        distance,



                        style:

                        const TextStyle(



                          color:

                          Colors.white54,



                          fontSize:12,


                        ),



                      ),



                    ],



                  ),





                  const SizedBox(height:8),





                  Row(



                    children: [



                      const Icon(



                        LucideIcons.plug,



                        size:14,



                        color:

                        AppColors.primaryGreen,


                      ),




                      const SizedBox(width:5),




                      Text(



                        ports,



                        style:

                        const TextStyle(



                          color:

                          Colors.white70,



                          fontSize:12,


                        ),



                      ),



                    ],



                  ),



                ],



              ),



            ),





            Column(



              crossAxisAlignment:

              CrossAxisAlignment.end,



              children: [



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

                    BorderRadius.circular(15),



                  ),



                  child:

                  Text(



                    chargingType,



                    style:

                    const TextStyle(



                      color:

                      AppColors.primaryGreen,



                      fontSize:11,



                      fontWeight:

                      FontWeight.bold,


                    ),



                  ),



                ),





                const SizedBox(height:12),





                Text(



                  price,



                  style:

                  const TextStyle(



                    color:

                    Colors.white,



                    fontWeight:

                    FontWeight.bold,


                    fontSize:14,


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