import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';



class WalletCard extends StatelessWidget {


  final double balance;

  final VoidCallback onTap;



  const WalletCard({

    super.key,

    required this.balance,

    required this.onTap,

  });



  @override
  Widget build(BuildContext context) {


    return GestureDetector(


      onTap:onTap,



      child: Container(


        width:
        double.infinity,



        padding:
        const EdgeInsets.all(22),




        decoration:
        BoxDecoration(


          gradient:
          LinearGradient(


            colors:[


              AppColors.darkGreen,

              AppColors.primaryGreen,


            ],


          ),



          borderRadius:
          BorderRadius.circular(25),


        ),




        child:
        Row(


          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,



          children:[



            Column(


              crossAxisAlignment:
              CrossAxisAlignment.start,



              children:[



                const Text(


                  "Wallet Balance",


                  style:
                  TextStyle(


                    color:
                    Colors.black87,


                    fontSize:15,


                  ),


                ),




                const SizedBox(height:8),




                Text(


                  "₹ ${balance.toStringAsFixed(0)}",



                  style:
                  const TextStyle(


                    color:
                    Colors.black,


                    fontSize:30,


                    fontWeight:
                    FontWeight.bold,


                  ),


                ),


              ],


            ),





            Container(


              padding:
              const EdgeInsets.all(12),



              decoration:
              const BoxDecoration(


                color:
                Colors.black12,


                shape:
                BoxShape.circle,


              ),



              child:
              const Icon(


                Icons.account_balance_wallet,


                color:
                Colors.black,


                size:30,


              ),


            )



          ],


        ),



      ),


    );


  }

}