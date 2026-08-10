import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_colors.dart';



class WalletSummaryCard extends StatelessWidget {


  final double balance;

  final VoidCallback? onAddMoney;

  final VoidCallback? onHistory;



  const WalletSummaryCard({

    super.key,

    required this.balance,

    this.onAddMoney,

    this.onHistory,

  });



  @override
  Widget build(BuildContext context) {


    return Container(


      padding:

      const EdgeInsets.all(22),



      decoration: BoxDecoration(


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


            blurRadius:20,


            offset:

            const Offset(0,8),


          )



        ],



      ),




      child: Column(


        crossAxisAlignment:

        CrossAxisAlignment.start,



        children: [



          // Header


          Row(


            mainAxisAlignment:

            MainAxisAlignment.spaceBetween,



            children: [



              const Text(


                "Wallet Balance",



                style:

                TextStyle(



                  color:

                  Colors.white70,



                  fontSize:14,


                ),



              ),





              Container(


                height:38,

                width:38,



                decoration:

                BoxDecoration(



                  color:

                  AppColors.primaryGreen

                      .withOpacity(0.15),



                  borderRadius:

                  BorderRadius.circular(12),


                ),



                child:

                const Icon(


                  LucideIcons.wallet,


                  color:

                  AppColors.primaryGreen,


                  size:20,


                ),



              )



            ],



          ),





          const SizedBox(height:15),





          // Balance


          Text(


            "₹ ${balance.toStringAsFixed(0)}",



            style:

            const TextStyle(



              color:

              Colors.white,



              fontSize:32,



              fontWeight:

              FontWeight.bold,


              letterSpacing:0.5,


            ),



          ),




          const SizedBox(height:20),





          Row(


            children: [



              Expanded(



                child:

                ElevatedButton.icon(



                  onPressed:

                  onAddMoney,



                  icon:

                  const Icon(


                    LucideIcons.plus,


                    size:18,


                  ),




                  label:

                  const Text(


                    "Add Money",


                  ),



                  style:

                  ElevatedButton.styleFrom(



                    backgroundColor:

                    AppColors.primaryGreen,



                    foregroundColor:

                    Colors.black,



                    elevation:0,



                    padding:

                    const EdgeInsets.symmetric(

                      vertical:13,

                    ),



                    shape:

                    RoundedRectangleBorder(


                      borderRadius:

                      BorderRadius.circular(18),


                    ),


                  ),



                ),



              ),




              const SizedBox(width:12),





              Expanded(



                child:

                OutlinedButton.icon(



                  onPressed:

                  onHistory,



                  icon:

                  const Icon(


                    LucideIcons.history,


                    size:18,


                  ),



                  label:

                  const Text(


                    "History",


                  ),



                  style:

                  OutlinedButton.styleFrom(



                    foregroundColor:

                    Colors.white,



                    side:

                    BorderSide(


                      color:

                      AppColors.primaryGreen

                          .withOpacity(0.5),


                    ),



                    padding:

                    const EdgeInsets.symmetric(

                      vertical:13,

                    ),



                    shape:

                    RoundedRectangleBorder(



                      borderRadius:

                      BorderRadius.circular(18),



                    ),



                  ),



                ),



              ),



            ],



          )



        ],



      ),



    );


  }



}