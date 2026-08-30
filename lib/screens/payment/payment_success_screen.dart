import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

import 'payment_receipt_screen.dart';



class PaymentSuccessScreen extends StatelessWidget {


final dynamic rideId;

final dynamic paymentId;

final double amount;

final String paymentMethod;



const PaymentSuccessScreen({

  super.key,

  required this.rideId,

  required this.paymentId,

  required this.amount,

  required this.paymentMethod,

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

          "Payment Success",

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

                "Payment Successful",

                style:

                TextStyle(

                  color:
                  Colors.white,

                  fontSize:28,

                  fontWeight:
                  FontWeight.bold,

                ),

              ),




              const SizedBox(height:25),




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



                    Text(

                      "Amount Paid",

                      style:

                      const TextStyle(

                        color:
                        Colors.white60,

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




                    const SizedBox(height:15),




                    Text(

                      "Mode : $paymentMethod",

                      style:

                      const TextStyle(

                        color:
                        Colors.white70,

                        fontSize:16,

                      ),

                    ),



                  ],


                ),



              ),





              const SizedBox(height:35),





              SizedBox(


                width:

                double.infinity,



                height:

                55,



                child:


                ElevatedButton(


                  onPressed:(){



                    Navigator.push(

                      context,


                      MaterialPageRoute(


                        builder:(context)=>


                       PaymentReceiptScreen(

  rideId: rideId,

  paymentId: paymentId,

  amount: amount,

  paymentMethod: paymentMethod,

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

                    "VIEW RECEIPT",

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