import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../services/api_service.dart';
import '../ride/ride_completed_screen.dart';


class DriverActiveRideScreen extends StatefulWidget {


  final Map<String,dynamic> rideData;



  const DriverActiveRideScreen({

    super.key,

    required this.rideData,

  });



  @override
  State<DriverActiveRideScreen> createState() =>
      _DriverActiveRideScreenState();

}





class _DriverActiveRideScreenState
    extends State<DriverActiveRideScreen> {



  late Map<String,dynamic> ride;


  bool loading = false;




  @override
  void initState(){

    super.initState();

    ride = widget.rideData;

  }







  String get status{

    return ride["ride_status"] ??
        "Accepted";

  }





  String get pickup{

    return ride["pickup_location"] ??
        "";

  }




  String get destination{

    return ride["destination"] ??
        "";

  }





  String get fare{

    return "₹${ride["estimated_fare"] ?? 0}";

  }







  Future<void> driverArrived() async {


    await updateRide(
      "arrived",
    );


  }






  Future<void> startRide() async {


    await updateRide(
      "start",
    );


  }

Future<void> completeRide() async {

  await updateRide(
    "complete",
  );


}

  Future<void> updateRide(String action) async {


    try{


      setState((){

        loading = true;

      });




      Map<String,dynamic> response;




      if(action=="arrived"){


        response =
        await ApiService.rideArrived(
            ride["id"]
        );


      }


      else if(action=="start"){


        response =
        await ApiService.startRide(
            ride["id"]
        );


      }


      else{


       response = 
await ApiService.completeRide(
  ride["id"],
  double.tryParse(
    ride["estimated_fare"].toString()
  ) ?? 0,
);


      }





      if(response["status"]==true){


        setState((){


          ride =
          response["ride"] ??
              ride;


        });


if(action=="complete"){


  Navigator.pushReplacement(

    context,

    MaterialPageRoute(

      builder:(context)=>

      RideCompletedScreen(

        rideId: ride["id"],

        amount: double.tryParse(
  (response["ride"]["final_fare"] ??
   ride["estimated_fare"])
   .toString()
) ?? 0,

      ),

    ),

  );


  return;

}



        ScaffoldMessenger.of(context)
            .showSnackBar(


          SnackBar(

            content:

            Text(

              response["message"] ??
                  "Updated",

            ),

          ),


        );



      }



    }

    catch(e){


      debugPrint(
          "UPDATE RIDE ERROR : $e"
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

          "Active Ride",

          style:

          TextStyle(

            fontWeight:
            FontWeight.bold,

          ),

        ),


      ),





      body:


      Padding(


        padding:

        const EdgeInsets.all(20),



        child:


        Column(



          crossAxisAlignment:

          CrossAxisAlignment.start,



          children:[




            Container(


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


                    status,


                    style:

                    const TextStyle(


                      fontSize:24,

                      fontWeight:
                      FontWeight.bold,


                    ),


                  ),



                  const SizedBox(height:20),




                  Text(

                    "Pickup",

                    style:

                    TextStyle(

                      color:
                      Colors.grey,

                    ),

                  ),



                  Text(

                    pickup,

                    style:

                    const TextStyle(

                      fontSize:18,

                    ),

                  ),





                  const SizedBox(height:15),




                  Text(

                    "Destination",

                    style:

                    TextStyle(

                      color:
                      Colors.grey,

                    ),

                  ),



                  Text(

                    destination,

                    style:

                    const TextStyle(

                      fontSize:18,

                    ),

                  ),




                  const SizedBox(height:15),




                  Text(

                    fare,

                    style:

                    const TextStyle(

                      color:
                      Colors.green,

                      fontSize:24,

                      fontWeight:
                      FontWeight.bold,

                    ),

                  ),




                ],


              ),


            ),






            const Spacer(),






            if(status=="Accepted")


              actionButton(

                "DRIVER ARRIVED",

                driverArrived,

              ),






            if(status=="Driver Arrived")


              actionButton(

                "START RIDE",

                startRide,

              ),






            if(status=="Started")


              actionButton(

                "COMPLETE RIDE",

                completeRide,

              ),





          ],


        ),


      ),


    );

  }







  Widget actionButton(

      String text,

      VoidCallback action,

      ){


    return SizedBox(


      width:

      double.infinity,



      height:

      55,



      child:

      ElevatedButton(


        onPressed:

        loading
            ? null
            : action,



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

        Text(

          text,

          style:

          const TextStyle(

            fontWeight:
            FontWeight.bold,

          ),

        ),


      ),


    );


  }



}