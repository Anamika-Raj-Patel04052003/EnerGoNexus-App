import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

import '../payment/payment_screen.dart';



class RideCompletedScreen extends StatelessWidget {


  final dynamic rideId;

  final double amount;



  const RideCompletedScreen({

    super.key,

    required this.rideId,

    required this.amount,

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

          "Ride Completed",

          style:

          TextStyle(

            fontWeight:
            FontWeight.bold,

          ),

        ),

      ),



      body:


      Center(


        child:


        Padding(

          padding:
          const EdgeInsets.all(25),


          child:


          Column(


            mainAxisAlignment:
            MainAxisAlignment.center,



            children:[



              const Icon(

                Icons.check_circle,

                color:
                Colors.green,

                size:100,

              ),



              const SizedBox(height:25),




              const Text(

                "Ride Completed Successfully",

                textAlign:
                TextAlign.center,


                style:

                TextStyle(

                  color:
                  Colors.white,

                  fontSize:24,

                  fontWeight:
                  FontWeight.bold,

                ),

              ),



              const SizedBox(height:20),




              Container(

                width:
                double.infinity,


                padding:

                const EdgeInsets.all(20),


                decoration:

                BoxDecoration(


                  color:
                  AppColors.card,


                  borderRadius:

                  BorderRadius.circular(20),


                ),



                child:


                Column(


                  children:[



                    const Text(

                      "Total Fare",

                      style:

                      TextStyle(

                        color:
                        Colors.white60,

                        fontSize:16,

                      ),

                    ),



                    const SizedBox(height:10),



                    Text(

                      "₹$amount",

                      style:

                      const TextStyle(

                        color:
                        Colors.green,

                        fontSize:32,

                        fontWeight:
                        FontWeight.bold,

                      ),

                    ),



                  ],


                ),


              ),





              const SizedBox(height:35),





              SizedBox(


                width:
                double.infinity,


                height:55,


                child:


                ElevatedButton(


                  onPressed:(){



                    Navigator.pushReplacement(


                      context,


                      MaterialPageRoute(


                        builder:(context)=>


                        PaymentScreen(


                          rideId: rideId,


                          amount: amount,


                        ),


                      ),


                    );



                  },



                  style:

                  ElevatedButton.styleFrom(


                    backgroundColor:

                    AppColors.primaryGreen,


                    foregroundColor:

                    Colors.black,



                    shape:

                    RoundedRectangleBorder(


                      borderRadius:

                      BorderRadius.circular(20),


                    ),


                  ),



                  child:


                  const Text(


                    "PAY NOW",


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


      ),


    );


  }


}