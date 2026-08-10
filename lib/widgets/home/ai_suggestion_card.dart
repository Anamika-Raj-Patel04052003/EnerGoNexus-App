import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_colors.dart';



class AISuggestionCard extends StatelessWidget {


  final String title;

  final String message;

  final VoidCallback? onTap;



  const AISuggestionCard({

    super.key,

    this.title = "AI Smart Suggestion",

    this.message =
    "Optimized route available. Save battery and time.",

    this.onTap,

  });



  @override
  Widget build(BuildContext context) {


    return InkWell(

      onTap: onTap,

      borderRadius:

      BorderRadius.circular(28),


      child: Container(


        padding:

        const EdgeInsets.all(22),



        decoration: BoxDecoration(



          gradient: LinearGradient(



            colors: [


              AppColors.darkGreen

                  .withOpacity(0.45),



              AppColors.card,



            ],



            begin:

            Alignment.topLeft,



            end:

            Alignment.bottomRight,



          ),



          borderRadius:

          BorderRadius.circular(28),



          border: Border.all(



            color:

            AppColors.primaryGreen

                .withOpacity(0.35),



          ),



        ),





        child: Row(


          children: [




            // AI ICON


            Container(


              height:55,

              width:55,



              decoration:

              BoxDecoration(



                color:

                AppColors.primaryGreen

                    .withOpacity(0.18),



                borderRadius:

                BorderRadius.circular(18),



              ),




              child:

              const Icon(



                LucideIcons.sparkles,



                color:

                AppColors.primaryGreen,



                size:28,


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



                    title,



                    style:

                    const TextStyle(



                      color:

                      Colors.white,



                      fontSize:17,



                      fontWeight:

                      FontWeight.bold,


                    ),



                  ),




                  const SizedBox(height:7),





                  Text(



                    message,



                    style:

                    const TextStyle(



                      color:

                      Colors.white70,



                      fontSize:13,


                    ),



                  ),



                ],



              ),



            ),





            const Icon(



              LucideIcons.chevronRight,



              color:

              AppColors.primaryGreen,



            )



          ],



        ),



      ),



    );


  }


}