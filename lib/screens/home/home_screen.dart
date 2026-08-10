import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/animated_ev_background.dart';

import '../../widgets/home/premium_header.dart';
import '../../widgets/home/ride_search_card.dart';
import '../../widgets/home/service_grid.dart';
import '../../widgets/home/wallet_summary_card.dart';
import '../../widgets/home/active_trip_card.dart';
import '../../widgets/home/charging_station_card.dart';
import '../../widgets/home/ai_suggestion_card.dart';

import '../../widgets/section_title.dart';

import '../../services/api_service.dart';

import '../ride/booking_screen.dart';
import '../wallet/wallet_screen.dart';



class HomeScreen extends StatefulWidget {

  const HomeScreen({
    super.key,
  });


  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();

}





class _HomeScreenState extends State<HomeScreen> {


  String userName = "EnerGo User";


  double walletBalance = 0;


  String rideStatus =
      "No active ride";



  bool loading = true;




  @override
  void initState(){

    super.initState();

    loadHomeData();

  }





  Future<void> loadHomeData() async {


    try{


      var profile =
      await ApiService.getProfile();



      if(profile["user"] != null){


        userName =
        profile["user"]["full_name"] ??
            "EnerGo User";


      }



      /*
      Wallet API integration later:

      var wallet =
      await ApiService.getWallet();


      walletBalance =
      wallet["balance"];

      */



      setState((){


        loading = false;


      });



    }

    catch(e){


      setState((){


        loading = false;


      });


      debugPrint(
          e.toString()
      );


    }



  }





  @override
  Widget build(BuildContext context) {



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



              children: [



                // HEADER


                PremiumHeader(


                  name:userName,


                  location:
                  "Bengaluru, India",


                ),




                const SizedBox(height:28),






                // RIDE SEARCH


                RideSearchCard(



                  onTap:(){



                    Navigator.push(


                      context,


                      MaterialPageRoute(


                        builder:(context)=>

                        const BookingScreen(),


                      ),


                    );


                  },


                ),






                const SizedBox(height:30),






                const SectionTitle(

                  title:
                  "Quick Services",

                ),




                const SizedBox(height:15),




                ServiceGrid(



                  onRideTap:(){


                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder:(context)=>

                        const BookingScreen(),

                      ),

                    );


                  },



                  onChargingTap:(){


                  },



                  onParcelTap:(){


                  },



                  onFacilityTap:(){


                  },


                ),






                const SizedBox(height:30),






                const SectionTitle(

                  title:
                  "Wallet",

                ),




                const SizedBox(height:15),





                WalletSummaryCard(



                  balance:

                  walletBalance,



                  onAddMoney:(){


                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder:(context)=>

                        const WalletScreen(),

                      ),

                    );


                  },



                  onHistory:(){


                  },


                ),






                const SizedBox(height:30),






                const SectionTitle(

                  title:
                  "Current Ride",

                ),






                const SizedBox(height:15),






                ActiveTripCard(



                  status:

                  rideStatus,



                  driverName:

                  "No Driver Assigned",



                  eta:

                  "--",



                  onTrackRide:(){


                  },


                ),






                const SizedBox(height:30),






                const SectionTitle(

                  title:

                  "Nearby EV Stations",


                ),




                const SizedBox(height:15),






                ChargingStationCard(



                  stationName:

                  "EnerGo Fast Charging Hub",



                  distance:

                  "2.5 km away",



                  ports:

                  "4 Ports Available",



                  chargingType:

                  "Fast Charging",



                  price:

                  "₹12/unit",


                  onTap:(){



                  },


                ),







                const SizedBox(height:30),






                const SectionTitle(

                  title:

                  "AI Smart Assistant",


                ),






                const SizedBox(height:15),






                AISuggestionCard(



                  onTap:(){


                  },


                ),






                const SizedBox(height:30),



              ],


            ),


          ),



        ),



      ),


    );


  }


}