import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';



class DriverHistoryScreen extends StatelessWidget {


  const DriverHistoryScreen({
    super.key,
  });



  @override
  Widget build(BuildContext context) {


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

          "Ride History",

          style:

          TextStyle(

            fontWeight:
            FontWeight.bold,

          ),

        ),

      ),




      body:


      ListView.builder(


        padding:

        const EdgeInsets.all(20),



        itemCount:5,



        itemBuilder:(context,index){



          return historyCard();



        },



      ),



    );


  }







  Widget historyCard(){


    return Container(


      margin:

      const EdgeInsets.only(

        bottom:20,

      ),



      padding:

      const EdgeInsets.all(20),



      decoration:

      BoxDecoration(


        color:

        AppColors.card,



        borderRadius:

        BorderRadius.circular(25),



        border:

        Border.all(

          color:

          AppColors.primaryGreen
              .withOpacity(.25),

        ),


      ),




      child:


      Column(


        crossAxisAlignment:

        CrossAxisAlignment.start,



        children:[



          Row(


            mainAxisAlignment:

            MainAxisAlignment.spaceBetween,



            children:[



              const Text(


                "Completed Ride",

                style:

                TextStyle(

                  fontSize:20,

                  fontWeight:
                  FontWeight.bold,

                ),

              ),



              const Text(


                "₹250",

                style:

                TextStyle(

                  color:
                  Colors.green,

                  fontSize:20,

                  fontWeight:
                  FontWeight.bold,

                ),

              ),



            ],

          ),





          const SizedBox(height:20),




          const Text(

            "Pickup",

            style:

            TextStyle(

              color:
              Colors.white54,

            ),

          ),



          const SizedBox(height:5),



          const Text(

            "MG Road, Bengaluru",

            style:

            TextStyle(

              fontSize:16,

            ),

          ),




          const SizedBox(height:15),




          const Text(

            "Destination",

            style:

            TextStyle(

              color:
              Colors.white54,

            ),

          ),



          const SizedBox(height:5),



          const Text(

            "Airport Terminal",

            style:

            TextStyle(

              fontSize:16,

            ),

          ),




          const SizedBox(height:15),




          Container(


            padding:

            const EdgeInsets.symmetric(

              horizontal:12,

              vertical:6,

            ),



            decoration:

            BoxDecoration(


              color:

              Colors.green.withOpacity(.15),



              borderRadius:

              BorderRadius.circular(20),


            ),



            child:

            const Text(

              "Completed",

              style:

              TextStyle(

                color:
                Colors.green,

                fontWeight:
                FontWeight.bold,

              ),

            ),


          ),



        ],

      ),


    );


  }


}