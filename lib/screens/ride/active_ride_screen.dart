import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/animated_ev_background.dart';



class ActiveRideScreen extends StatefulWidget {


  final Map<String,dynamic> rideData;


  const ActiveRideScreen({

    super.key,

    required this.rideData,

  });



  @override
  State<ActiveRideScreen> createState() =>
      _ActiveRideScreenState();

}





class _ActiveRideScreenState extends State<ActiveRideScreen>{


  Timer? timer;


  late Map<String,dynamic> ride;


  bool loading = false;



  @override
  void initState(){

    super.initState();


    ride = widget.rideData;


    startTracking();

  }





  void startTracking(){


    timer = Timer.periodic(

      const Duration(seconds:5),

      (_){

        if(!loading){

          loadRide();

        }

      },

    );


  }





  Future<void> loadRide() async{


    try{


      final id = ride["id"];


      if(id==null){

        return;

      }


      loading=true;



      final response =
      await ApiService.getRide(id);



      if(response["status"]==true){


        if(mounted){


          setState((){


            ride = response["ride"];


          });


        }


      }



    }

    catch(e){


      debugPrint(
          "Ride update error : $e"
      );


    }

    finally{


      loading=false;


    }


  }


Future<void> callArrivedApi() async {

 final response =
 await ApiService.rideArrived(
   ride["id"]
 );

 if(response["status"]==true){
   loadRide();
 }

}


Future<void> callStartRide() async {

 final response =
 await ApiService.startRide(
   ride["id"]
 );

 if(response["status"]==true){
   loadRide();
 }

}


Future<void> callCompleteRide() async {

 final fare =
 double.tryParse(
   ride["estimated_fare"].toString()
 ) ?? 0;


 final response =
 await ApiService.completeRide(
   ride["id"],
   fare
 );


 if(response["status"]==true){
   loadRide();
 }

}




  String get rideStatus{


    return ride["ride_status"] ??
        "Pending";


  }






  String get pickup{


    return ride["pickup_location"] ??
        "";

  }






  String get destination{


    return ride["destination"] ??
        "";

  }






  String get estimatedFare{


    return "₹${ride["estimated_fare"] ?? 0}";

  }

  String get finalFare{


    return "₹${ride["final_fare"] ?? 0}";


  }
  Map<String,dynamic>? get driver{


    if(ride["driver"] is Map){

      return ride["driver"];

    }


    return null;


  }

  Map<String,dynamic>? get vehicle{


    if(ride["vehicle"] is Map){

      return ride["vehicle"];

    }


    return null;


  }







  String get driverName{


    return driver?["full_name"] ??
        "Searching Driver";


  }

  String get driverPhone{


    return driver?["mobile_number"] ??
        "";


  }

  String get vehicleNumber{


    return vehicle?["vehicle_number"] ??
        "EV";


  }

  String get vehicleType{


    return vehicle?["vehicle_type"] ??
        "Electric Vehicle";


  }

  String statusTitle(){


    switch(rideStatus){


      case "Pending":

        return "Searching for nearby driver";


      case "Accepted":

        return "Driver is coming";


      case "Driver Arrived":

        return "Driver reached pickup";


      case "Started":

        return "Ride is running";


      case "Completed":

        return "Ride completed";


      case "Cancelled":

        return "Ride cancelled";


      default:

        return rideStatus;


    }


  }


  int statusIndex(){


    switch(rideStatus){


      case "Accepted":

        return 1;


      case "Driver Arrived":

        return 2;


      case "Started":

        return 3;


      case "Completed":

        return 4;


      default:

        return 0;


    }


  }






  bool completedStep(int index){


    return statusIndex() >= index;


  }







  @override
  void dispose(){


    timer?.cancel();


    super.dispose();


  }







  @override
  Widget build(BuildContext context){


    return Scaffold(


      backgroundColor:
      AppColors.background,

      body:
      Stack(
        children:[

AnimatedEVBackground(

  child: Container(),

),

          SafeArea(
            child:
            SingleChildScrollView(


              padding:
              const EdgeInsets.all(20),
              child:
              Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children:[
                  Row(
                    children:[
                      IconButton(
                        icon:
                        const Icon(
                            Icons.arrow_back
                        ),

                        onPressed:(){

                          Navigator.pop(context);
                        },
                      ),
                      const Text(
                        "Active Ride",
                        style:
                        TextStyle(

                          fontSize:26,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height:20),
                  Container(
                    height:260,
                    width:
                    double.infinity,
                    decoration:
                    BoxDecoration(
                      color:
                      Colors.black26,
                      borderRadius:
                      BorderRadius.circular(25),

                    ),
                    child:
                    const Center(
                      child:
                      Text(
                        "GOOGLE MAP API WILL BE ADDED HERE",
                        style:
                        TextStyle(
                          color:
                          Colors.grey,
                          fontSize:15,
                        ),
                      ),

                    ),
                  ),
                  const SizedBox(height:25),
                  Container(

                    padding:
                    const EdgeInsets.all(20),
                    decoration:
                    BoxDecoration(
                      color:
                      Colors.green.withOpacity(.15),
                      borderRadius:
                      BorderRadius.circular(20),
                    ),
                    child:

                    Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children:[
                        Text(


                          statusTitle(),



                          style:


                          const TextStyle(


                            fontSize:24,


                            fontWeight:
                            FontWeight.bold,


                          ),



                        ),




                        const SizedBox(height:8),




                        Text(


                          rideStatus,



                          style:


                          const TextStyle(


                            color:
                            Colors.green,


                            fontSize:16,


                          ),



                        ),


                      ],



                    ),



                  ),



                  const SizedBox(height:20),



                  buildTimeline(),



                  const SizedBox(height:20),



                  buildDriverCard(),

                         const SizedBox(height:20),


                  buildRouteCard(),


                  const SizedBox(height:20),


                  buildFareCard(),



                  const SizedBox(height:25),

if(rideStatus=="Driver Arrived")

SizedBox(
width:double.infinity,
child:

ElevatedButton(
onPressed:(){

 callStartRide();

},

child:
const Text("START RIDE"),

),

),

if(rideStatus=="Started")

SizedBox(
width:double.infinity,
child:

ElevatedButton(
onPressed:(){

callCompleteRide();

},

child:
const Text("COMPLETE RIDE"),

),

),

                  if(
                  rideStatus=="Pending" ||
                  rideStatus=="Accepted"
                  )

                  SizedBox(


                    width:
                    double.infinity,

                    child:
                    OutlinedButton(

                      style:


                      OutlinedButton.styleFrom(

                        foregroundColor:
                        Colors.red,

                        side:
                        const BorderSide(
                            color:Colors.red
                        ),

                        padding:
                        const EdgeInsets.all(15),

                      ),

                      onPressed:(){

                        // CANCEL RIDE API WILL BE ADDED HERE

                      },

                      child:


                      const Text(

                        "CANCEL RIDE",

                        style:

                        TextStyle(

                          fontSize:16,

                          fontWeight:
                          FontWeight.bold,

                        ),

                      ),



                    ),


                  ),




                  if(rideStatus=="Completed")

                  buildPaymentCard(),




                ],



              ),



            ),



          )



        ],



      ),


    );



  }







  Widget buildTimeline(){


    return Card(


      color:
      Colors.black26,



      shape:


      RoundedRectangleBorder(

        borderRadius:
        BorderRadius.circular(20),

      ),




      child:


      Padding(


        padding:
        const EdgeInsets.all(15),



        child:


        Column(


          children:[


            timelineItem(
              "Driver Assigned",
              1
            ),



            timelineItem(
              "Driver Arrived",
              2
            ),



            timelineItem(
              "Ride Started",
              3
            ),



            timelineItem(
              "Completed",
              4
            ),



          ],



        ),



      ),



    );



  }







  Widget timelineItem(
      String title,
      int index
      ){



    bool done =
    completedStep(index);



    return ListTile(


      leading:


      Icon(


        done
            ? Icons.check_circle
            : Icons.radio_button_unchecked,



        color:


        done
            ? Colors.green
            : Colors.grey,



      ),



      title:


      Text(title),



    );



  }









  Widget buildDriverCard(){



    return Card(


      color:
      Colors.black26,



      shape:


      RoundedRectangleBorder(

        borderRadius:
        BorderRadius.circular(20),

      ),




      child:


      Padding(


        padding:
        const EdgeInsets.all(15),



        child:


        Column(


          crossAxisAlignment:
          CrossAxisAlignment.start,



          children:[



            const Text(

              "Driver Details",

              style:

              TextStyle(

                fontSize:18,

                fontWeight:
                FontWeight.bold,

              ),

            ),




            const SizedBox(height:15),




            Text(

              driverName,

              style:

              const TextStyle(

                fontSize:22,

                fontWeight:
                FontWeight.bold,

              ),

            ),




            const SizedBox(height:8),




            Text(

              vehicleNumber,

              style:

              const TextStyle(

                fontSize:18,

                color:
                Colors.green,

              ),

            ),




            Text(vehicleType),





            const SizedBox(height:15),




            Row(


              children:[



                Expanded(


                  child:


                  ElevatedButton.icon(



                    onPressed:(){


                      // CALL API WILL BE ADDED HERE


                    },



                    icon:

                    const Icon(
                        Icons.call
                    ),



                    label:

                    const Text(
                        "Call"
                    ),



                  ),


                ),




                const SizedBox(width:10),





                Expanded(


                  child:


                  ElevatedButton.icon(



                    onPressed:(){


                      // CHAT FEATURE WILL BE ADDED HERE


                    },



                    icon:

                    const Icon(
                        Icons.chat
                    ),



                    label:

                    const Text(
                        "Chat"
                    ),



                  ),


                ),




              ],



            )



          ],



        ),



      ),



    );



  }









  Widget buildRouteCard(){



    return Card(



      child:


      Column(


        children:[



          ListTile(


            leading:

            const Icon(
                Icons.location_on
            ),



            title:

            const Text(
                "Pickup"
            ),



            subtitle:

            Text(pickup),



          ),





          ListTile(


            leading:

            const Icon(
                Icons.flag
            ),



            title:

            const Text(
                "Destination"
            ),



            subtitle:

            Text(destination),



          ),



        ],



      ),



    );



  }









  Widget buildFareCard(){



    return Card(


      child:


      ListTile(



        leading:

        const Icon(
            Icons.currency_rupee
        ),



        title:

        const Text(
            "Estimated Fare"
        ),



        trailing:


        Text(


          estimatedFare,



          style:


          const TextStyle(


            fontSize:22,

            fontWeight:
            FontWeight.bold,


          ),



        ),



      ),



    );



  }








  Widget buildPaymentCard(){


    return Card(


      color:
      Colors.green.withOpacity(.15),



      child:


      Padding(


        padding:
        const EdgeInsets.all(15),



        child:


        Column(


          crossAxisAlignment:
          CrossAxisAlignment.start,

          children:[



            const Text(


              "Ride Completed",



              style:


              TextStyle(


                fontSize:22,

                fontWeight:
                FontWeight.bold,


              ),



            ),
            const SizedBox(height:10),
            Text(

              "Final Fare : $finalFare",

            ),
            const SizedBox(height:15),
            SizedBox(
              width:
              double.infinity,

              child:
              ElevatedButton(

                onPressed:(){
                  // PAYMENT API WILL BE ADDED HERE

                },
                child:
                const Text(
                    "Pay Now"
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}           