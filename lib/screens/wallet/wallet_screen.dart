import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/animated_ev_background.dart';



class WalletScreen extends StatelessWidget {


  const WalletScreen({super.key});



  @override
  Widget build(BuildContext context){


    return Scaffold(


      body:


      AnimatedEVBackground(


        child:


        Center(


          child:


          Container(


            padding:

            const EdgeInsets.all(30),



            decoration:

            BoxDecoration(


              color:

              Colors.white.withOpacity(0.08),


              borderRadius:

              BorderRadius.circular(25),


            ),



            child:


            Column(


              mainAxisSize:

              MainAxisSize.min,



              children:[



                const Icon(


                  Icons.account_balance_wallet,


                  size:70,


                  color:

                  AppColors.primaryGreen,


                ),





                const SizedBox(height:20),





                const Text(


                  "Wallet",



                  style:


                  TextStyle(


                    color:

                    Colors.white,


                    fontSize:28,


                    fontWeight:

                    FontWeight.bold,


                  ),


                ),





                const SizedBox(height:10),





                const Text(


                  "₹ 0.00",



                  style:


                  TextStyle(


                    color:

                    AppColors.primaryGreen,


                    fontSize:35,


                    fontWeight:

                    FontWeight.bold,


                  ),


                )



              ],


            ),


          ),


        ),


      ),


    );


  }


}