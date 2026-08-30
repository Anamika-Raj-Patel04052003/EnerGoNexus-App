import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';



class DriverEarningsScreen extends StatelessWidget {


  const DriverEarningsScreen({
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

          "Earnings",

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


          crossAxisAlignment:
          CrossAxisAlignment.start,



          children:[



            // TOTAL EARNING CARD


            Container(


              width:
              double.infinity,


              padding:

              const EdgeInsets.all(25),



              decoration:

              BoxDecoration(


                color:

                AppColors.primaryGreen
                    .withOpacity(.15),



                borderRadius:

                BorderRadius.circular(25),



                border:

                Border.all(

                  color:

                  AppColors.primaryGreen
                      .withOpacity(.4),

                ),


              ),




              child:

              Column(


                crossAxisAlignment:

                CrossAxisAlignment.start,



                children:[



                  const Text(

                    "Total Earnings",

                    style:

                    TextStyle(

                      color:
                      Colors.white70,

                      fontSize:16,

                    ),

                  ),



                  const SizedBox(height:10),



                  const Text(

                    "₹25,500",

                    style:

                    TextStyle(

                      fontSize:36,

                      fontWeight:
                      FontWeight.bold,

                    ),

                  ),



                  const SizedBox(height:8),



                  const Text(

                    "This Month",

                    style:

                    TextStyle(

                      color:
                      Colors.white54,

                    ),

                  ),



                ],


              ),


            ),




            const SizedBox(height:25),




            const Text(

              "Overview",

              style:

              TextStyle(

                fontSize:22,

                fontWeight:
                FontWeight.bold,

              ),

            ),




            const SizedBox(height:15),




            Row(


              children:[


                Expanded(

                  child:

                  earningCard(

                    title:"Today",

                    amount:"₹850",

                    icon:Icons.today,

                  ),

                ),



                const SizedBox(width:15),



                Expanded(

                  child:

                  earningCard(

                    title:"This Week",

                    amount:"₹5200",

                    icon:Icons.calendar_month,

                  ),

                ),


              ],


            ),




            const SizedBox(height:30),





            const Text(

              "Payment Summary",

              style:

              TextStyle(

                fontSize:22,

                fontWeight:
                FontWeight.bold,

              ),

            ),





            const SizedBox(height:15),





            summaryCard(

              "Online Payments",

              "₹18,000",

              Icons.account_balance_wallet,

            ),



            summaryCard(

              "Cash Collected",

              "₹7,500",

              Icons.money,

            ),



            summaryCard(

              "Commission",

              "₹5,000",

              Icons.percent,

            ),





            const SizedBox(height:30),





            const Text(

              "Recent Rides",

              style:

              TextStyle(

                fontSize:22,

                fontWeight:
                FontWeight.bold,

              ),

            ),




            const SizedBox(height:15),




            rideCard(),


            rideCard(),



          ],


        ),


      ),


    );


  }






  Widget earningCard({

    required String title,

    required String amount,

    required IconData icon,

  }){


    return Container(


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

      Column(


        crossAxisAlignment:

        CrossAxisAlignment.start,



        children:[


          Icon(

            icon,

            color:

            AppColors.primaryGreen,

          ),



          const SizedBox(height:15),



          Text(

            title,

            style:

            const TextStyle(

              color:
              Colors.white60,

            ),

          ),



          const SizedBox(height:5),



          Text(

            amount,

            style:

            const TextStyle(

              fontSize:20,

              fontWeight:
              FontWeight.bold,

            ),

          ),



        ],


      ),


    );


  }






  Widget summaryCard(

      String title,

      String amount,

      IconData icon,

      ){


    return Container(


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



          Icon(

            icon,

            color:

            AppColors.primaryGreen,

          ),



          const SizedBox(width:15),



          Expanded(

            child:

            Text(

              title,

              style:

              const TextStyle(

                fontSize:16,

              ),

            ),

          ),




          Text(

            amount,

            style:

            const TextStyle(

              fontSize:18,

              fontWeight:
              FontWeight.bold,

            ),

          ),



        ],

      ),


    );


  }






  Widget rideCard(){


    return Container(


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

            const Icon(

              Icons.electric_car,

              color:
              AppColors.primaryGreen,

            ),

          ),



          const SizedBox(width:15),



          const Expanded(

            child:

            Column(

              crossAxisAlignment:
              CrossAxisAlignment.start,


              children:[


                Text(

                  "Ride #1024",

                  style:

                  TextStyle(

                    fontWeight:
                    FontWeight.bold,

                  ),

                ),



                SizedBox(height:5),



                Text(

                  "Mini EV • Completed",

                  style:

                  TextStyle(

                    color:
                    Colors.white54,

                  ),

                ),


              ],

            ),

          ),



          const Text(

            "₹120",

            style:

            TextStyle(

              color:
              Colors.green,

              fontWeight:
              FontWeight.bold,

            ),

          ),



        ],

      ),


    );


  }



}