import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/animated_ev_background.dart';
import '../../services/api_service.dart';



class HomeScreen extends StatefulWidget {


  const HomeScreen({super.key});



  @override
  State<HomeScreen> createState() => _HomeScreenState();


}





class _HomeScreenState extends State<HomeScreen> {


  String userName = "User";

  String email = "";

  double walletBalance = 0;

  String activeRide = "No Active Ride";

  bool loading = true;




  @override
  void initState(){


    super.initState();


    loadUser();


  }







  Future<void> loadUser() async {


    try{


      var response = await ApiService.getProfile();




      if(response["user"] != null){



        setState((){


          userName =

          response["user"]["full_name"] ?? "User";



          email =

          response["user"]["email"] ?? "";



          loading = false;



        });



      }

      else{


        setState((){


          loading = false;


        });


      }



    }

    catch(e){


      setState((){


        loading = false;


      });



    }



  }








  @override
  Widget build(BuildContext context){



    return Scaffold(


      body:


      AnimatedEVBackground(



        child:


        SafeArea(



          child:



          loading



          ?


          const Center(



            child:


            CircularProgressIndicator(



              color:

              AppColors.primaryGreen,



            ),



          )



          :



          SingleChildScrollView(



            padding:

            const EdgeInsets.all(20),



            child:



            Column(



              crossAxisAlignment:

              CrossAxisAlignment.start,



              children:[




                // HEADER



                Row(



                  mainAxisAlignment:

                  MainAxisAlignment.spaceBetween,



                  children:[



                    Column(



                      crossAxisAlignment:

                      CrossAxisAlignment.start,



                      children:[



                        Text(



                          "Hello $userName 👋",



                          style:

                          const TextStyle(



                            color:

                            Colors.white70,



                            fontSize:16,



                          ),



                        ),





                        const SizedBox(height:5),






                        const Text(



                          "Welcome to EnerGo",



                          style:

                          TextStyle(



                            color:

                            Colors.white,



                            fontSize:26,



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

                      BoxDecoration(



                        color:

                        AppColors.primaryGreen

                        .withOpacity(0.15),



                        shape:

                        BoxShape.circle,



                      ),



                      child:


                      const Icon(



                        Icons.notifications,



                        color:

                        AppColors.primaryGreen,



                      ),



                    )



                  ],



                ),






                const SizedBox(height:30),






                // SMART EV BANNER



                Container(



                  padding:

                  const EdgeInsets.all(20),



                  decoration:

                  BoxDecoration(



                    gradient:

                    LinearGradient(



                      colors:[



                        AppColors.primaryGreen

                        .withOpacity(0.25),



                        Colors.black26,



                      ],



                    ),



                    borderRadius:

                    BorderRadius.circular(25),



                  ),




                  child:



                  Row(



                    children:[



                      Expanded(



                        child:



                        Column(



                          crossAxisAlignment:

                          CrossAxisAlignment.start,



                          children:[



                            const Text(



                              "Smart EV Mobility",



                              style:

                              TextStyle(



                                color:

                                Colors.white,



                                fontSize:20,



                                fontWeight:

                                FontWeight.bold,



                              ),



                            ),




                            const SizedBox(height:8),





                            const Text(



                              "Ride greener,\ntravel smarter",



                              style:

                              TextStyle(



                                color:

                                Colors.white70,



                                fontSize:14,



                              ),



                            ),



                          ],



                        ),



                      ),





                      const Icon(



                        Icons.electric_car,



                        size:70,



                        color:

                        AppColors.primaryGreen,



                      )



                    ],



                  ),



                ),






                const SizedBox(height:25),





                // WALLET CARD



                Container(



                  padding:

                  const EdgeInsets.all(20),



                  decoration:

                  BoxDecoration(



                    color:

                    Colors.white.withOpacity(0.08),



                    borderRadius:

                    BorderRadius.circular(20),



                    border:

                    Border.all(



                      color:

                      AppColors.primaryGreen

                      .withOpacity(0.3),



                    ),



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

                              Colors.white70,



                            ),



                          ),





                          const SizedBox(height:8),





                          Text(



                            "₹ ${walletBalance.toStringAsFixed(0)}",



                            style:

                            const TextStyle(



                              color:

                              Colors.white,



                              fontSize:24,



                              fontWeight:

                              FontWeight.bold,



                            ),



                          ),



                        ],



                      ),





                      const Icon(



                        Icons.account_balance_wallet,



                        color:

                        AppColors.primaryGreen,



                        size:35,



                      )



                    ],



                  ),



                ),




                const SizedBox(height:15),





                // ACTIVE RIDE CARD



                Container(



                  padding:

                  const EdgeInsets.all(20),



                  decoration:

                  BoxDecoration(



                    color:

                    Colors.white.withOpacity(0.08),



                    borderRadius:

                    BorderRadius.circular(20),



                  ),




                  child:



                  Row(



                    children:[



                      const Icon(



                        Icons.electric_car,



                        color:

                        AppColors.primaryGreen,



                        size:35,



                      ),





                      const SizedBox(width:15),





                      Column(



                        crossAxisAlignment:

                        CrossAxisAlignment.start,



                        children:[



                          const Text(



                            "Active Ride",



                            style:

                            TextStyle(



                              color:

                              Colors.white70,



                            ),



                          ),





                          Text(



                            activeRide,



                            style:

                            const TextStyle(



                              color:

                              Colors.white,



                              fontWeight:

                              FontWeight.bold,



                            ),



                          ),



                        ],



                      )



                    ],



                  ),



                ),





                const SizedBox(height:30),





                const Text(



                  "Services",



                  style:

                  TextStyle(



                    color:

                    Colors.white,



                    fontSize:22,



                    fontWeight:

                    FontWeight.bold,



                  ),



                ),


       const SizedBox(height:15),





GridView.count(



  shrinkWrap:true,



  physics:

  const NeverScrollableScrollPhysics(),



  crossAxisCount:2,



  crossAxisSpacing:15,



  mainAxisSpacing:15,



  children:[




    serviceCard(


      "Book Ride",


      Icons.directions_car,


    ),





    serviceCard(


      "Charging",


      Icons.ev_station,


    ),





    serviceCard(


      "Rental",


      Icons.car_rental,


    ),





    serviceCard(


      "Parcel",


      Icons.local_shipping,


    ),



  ],



),





              ],



            ),



          ),



        ),



      ),



    );



  }








  // SERVICE CARD WIDGET





  Widget serviceCard(



      String title,



      IconData icon



      ){





    return Container(




      decoration:

      BoxDecoration(



        color:

        Colors.white.withOpacity(0.08),



        borderRadius:

        BorderRadius.circular(20),



        border:

        Border.all(



          color:

          AppColors.primaryGreen

          .withOpacity(0.25),



        ),



      ),






      child:



      Column(



        mainAxisAlignment:

        MainAxisAlignment.center,



        children:[





          Icon(



            icon,



            size:40,



            color:

            AppColors.primaryGreen,



          ),

          const SizedBox(height:10),

          Text(

            title,

            style:

            const TextStyle(



              color:

              Colors.white,



              fontWeight:

              FontWeight.bold,



            ),



          )



        ],



      ),



    );



  }



}         