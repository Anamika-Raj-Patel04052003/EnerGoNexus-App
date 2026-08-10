import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';



class ActiveRideCard extends StatelessWidget {


  final String status;

  final VoidCallback onTap;



  const ActiveRideCard({

    super.key,

    required this.status,

    required this.onTap,

  });



  @override
  Widget build(BuildContext context) {


    return Container(


      padding:
      const EdgeInsets.all(20),



      decoration:
      BoxDecoration(


        color:
        AppColors.card,


        borderRadius:
        BorderRadius.circular(22),



      ),



      child:
      Column(


        crossAxisAlignment:
        CrossAxisAlignment.start,



        children:[



          const Row(


            children:[



              Icon(

                Icons.electric_car,

                color:
                AppColors.primaryGreen,

              ),



              SizedBox(width:10),




              Text(


                "Current Ride",



                style:
                TextStyle(


                  color:
                  Colors.white,


                  fontSize:18,


                  fontWeight:
                  FontWeight.bold,


                ),


              )



            ],


          ),




          const SizedBox(height:15),




          Text(


            status,


            style:
            const TextStyle(


              color:
              Colors.white70,


              fontSize:15,


            ),


          ),





          const SizedBox(height:15),





          SizedBox(


            width:
            double.infinity,



            child:
            ElevatedButton(


              onPressed:onTap,



              child:
              const Text("Track Ride"),


            ),


          )



        ],


      ),


    );


  }

}