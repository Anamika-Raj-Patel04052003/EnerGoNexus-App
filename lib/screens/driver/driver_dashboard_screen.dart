import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../services/api_service.dart';

import 'driver_ride_requests_screen.dart';
import 'driver_history_screen.dart';
import 'driver_active_ride_screen.dart';



class DriverDashboardScreen extends StatefulWidget {

  const DriverDashboardScreen({
    super.key,
  });

  @override
  State<DriverDashboardScreen> createState() =>
      _DriverDashboardScreenState();

}

class _DriverDashboardScreenState
    extends State<DriverDashboardScreen> {

  bool loading = true;

  int requestCount = 0;
Map<String,dynamic>? activeRide;


  @override
  void initState(){

    super.initState();

    loadDriverData();

  }

  Future<void> loadDriverData() async {

    try{

      final response =
      await ApiService.getDriverRideRequests();

      final activeResponse =
    await ApiService.getDriverActiveRide();



    if(activeResponse["status"] == true){

      setState((){

        activeRide =
        activeResponse["ride"];

      });

    }



      if(response["status"] == true){


        final requests =
        response["requests"];



        if(requests is List){


          setState((){

            requestCount =
                requests.length;

          });


        }


      }


    }

    catch(e){

      debugPrint(
        "DRIVER DASHBOARD ERROR : $e",
      );

    }



    finally{


      if(mounted){

        setState((){

          loading=false;

        });

      }


    }


  }






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

          "Driver Dashboard",

          style:

          TextStyle(

            fontWeight:
            FontWeight.bold,

          ),

        ),

      ),





      body:


      loading

          ?

      const Center(

        child:

        CircularProgressIndicator(),

      )


          :


      RefreshIndicator(


        onRefresh:
        loadDriverData,


        child:


        SingleChildScrollView(


          physics:
          const AlwaysScrollableScrollPhysics(),



          padding:

          const EdgeInsets.all(20),




          child:


          Column(


            crossAxisAlignment:

            CrossAxisAlignment.start,



            children:[





              // DRIVER STATUS


              Container(


                width:
                double.infinity,


                padding:

                const EdgeInsets.all(20),



                decoration:

                BoxDecoration(


                  color:
                  Colors.black26,


                  borderRadius:

                  BorderRadius.circular(25),



                  border:

                  Border.all(

                    color:

                    AppColors.primaryGreen
                        .withOpacity(.3),

                  ),


                ),




                child:


                Column(


                  crossAxisAlignment:

                  CrossAxisAlignment.start,



                  children:[


                    const Text(


                      "Welcome Driver",


                      style:

                      TextStyle(

                        fontSize:24,

                        fontWeight:
                        FontWeight.bold,

                      ),


                    ),




                    const SizedBox(height:10),




                    Row(


                      children:[



                        const Icon(

                          Icons.circle,

                          color:
                          Colors.green,

                          size:14,

                        ),



                        const SizedBox(width:8),




                        const Text(

                          "Online",

                          style:

                          TextStyle(

                            color:
                            Colors.green,

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


if(activeRide != null)
Container(

width: double.infinity,

padding: const EdgeInsets.all(20),

decoration: BoxDecoration(

color: AppColors.card,

borderRadius:
BorderRadius.circular(25),

),

child: Column(

crossAxisAlignment:
CrossAxisAlignment.start,

children:[


const Text(
"Active Ride",
style: TextStyle(
fontSize:20,
fontWeight:FontWeight.bold,
),
),


const SizedBox(height:15),


Text(
"Status : ${activeRide!["ride_status"] ?? ""}",
),


Text(
"Pickup : ${activeRide!["pickup_location"] ?? ""}",
),


Text(
"Destination : ${activeRide!["destination"] ?? ""}",
),


const SizedBox(height:15),



ElevatedButton(

  style: ElevatedButton.styleFrom(

    backgroundColor: AppColors.primaryGreen,

    foregroundColor: Colors.black,

    shape: RoundedRectangleBorder(

      borderRadius: BorderRadius.circular(18),

    ),

  ),


  onPressed:(){

    Navigator.push(

      context,

      MaterialPageRoute(

        builder:(context)=>

        DriverActiveRideScreen(

          rideData: activeRide!,

        ),

      ),

    );

  },


  child:

  const Text(

    "OPEN ACTIVE RIDE",

    style: TextStyle(

      fontWeight: FontWeight.bold,

    ),

  ),

),


],

),

),

if(activeRide == null)

dashboardCard(

  title:"No Active Ride",

  subtitle:"No accepted ride available",

  buttonText:"REFRESH",

  onTap:(){

    loadDriverData();

  },

),


              // REQUEST CARD


              dashboardCard(


                title:

                "New Ride Requests",



                subtitle:

                "$requestCount requests available",



                buttonText:

                "VIEW REQUESTS",



                onTap:(){



                  Navigator.push(


                    context,


                    MaterialPageRoute(


                      builder:(context)=>


                      const DriverRideRequestsScreen(),


                    ),


                  ).then((_){

                    loadDriverData();

                  });

                },

              ),
              const SizedBox(height:25),

              // HISTORY CARD


              dashboardCard(


                title:

                "Ride History",



                subtitle:

                "View completed rides",



                buttonText:

                "VIEW HISTORY",



                onTap:(){



                  Navigator.push(


                    context,


                    MaterialPageRoute(


                      builder:(context)=>


                      const DriverHistoryScreen(),


                    ),


                  );


                },


              ),





            ],


          ),


        ),


      ),


    );


  }








  Widget dashboardCard({

    required String title,

    required String subtitle,

    required String buttonText,

    required VoidCallback onTap,

  }){


    return Container(


      width:

      double.infinity,



      padding:

      const EdgeInsets.all(20),



      decoration:

      BoxDecoration(


        color:

        AppColors.card,



        borderRadius:

        BorderRadius.circular(25),


      ),




      child:


      Column(


        crossAxisAlignment:

        CrossAxisAlignment.start,



        children:[



          Text(

            title,


            style:

            const TextStyle(

              fontSize:20,

              fontWeight:
              FontWeight.bold,

            ),


          ),





          const SizedBox(height:10),





          Text(

            subtitle,


            style:

            const TextStyle(

              color:
              Colors.white60,

            ),


          ),





          const SizedBox(height:20),






          SizedBox(


            width:

            double.infinity,



            child:


            ElevatedButton(


              onPressed:onTap,



              style:

              ElevatedButton.styleFrom(


                backgroundColor:

                AppColors.primaryGreen,



                foregroundColor:

                Colors.black,



                shape:

                RoundedRectangleBorder(

                  borderRadius:

                  BorderRadius.circular(18),

                ),


              ),



              child:

              Text(

                buttonText,

                style:

                const TextStyle(

                  fontWeight:
                  FontWeight.bold,

                ),

              ),



            ),



          )



        ],


      ),


    );


  }



}