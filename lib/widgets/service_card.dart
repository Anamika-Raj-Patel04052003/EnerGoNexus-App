import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';


class ServiceCard extends StatelessWidget {

  final String title;
  final IconData icon;
  final VoidCallback onTap;


  const ServiceCard({

    super.key,

    required this.title,

    required this.icon,

    required this.onTap,

  });



  @override
  Widget build(BuildContext context) {


    return InkWell(

      onTap: onTap,


      borderRadius:
      BorderRadius.circular(20),


      child: Container(


        padding:
        const EdgeInsets.all(18),



        decoration:
        BoxDecoration(


          color:
          AppColors.card,


          borderRadius:
          BorderRadius.circular(20),



          border:
          Border.all(


            color:
            AppColors.primaryGreen
                .withOpacity(0.15),


          ),


        ),




        child:
        Column(


          mainAxisAlignment:
          MainAxisAlignment.center,


          children: [



            Container(


              height:50,

              width:50,


              decoration:
              BoxDecoration(


                color:
                AppColors.primaryGreen
                    .withOpacity(0.15),


                shape:
                BoxShape.circle,


              ),




              child:
              Icon(


                icon,


                color:
                AppColors.primaryGreen,


                size:28,


              ),


            ),




            const SizedBox(height:12),




            Text(


              title,


              textAlign:
              TextAlign.center,


              style:
              const TextStyle(


                color:
                Colors.white,


                fontWeight:
                FontWeight.w600,


                fontSize:14,


              ),


            ),



          ],


        ),


      ),


    );


  }

}