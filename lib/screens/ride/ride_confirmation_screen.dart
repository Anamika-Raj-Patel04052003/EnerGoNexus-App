import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/animated_ev_background.dart';
import '../../services/api_service.dart';
import 'active_ride_screen.dart';


class RideConfirmationScreen extends StatefulWidget {

  final Map<String,dynamic> rideData;


  const RideConfirmationScreen({
    super.key,
    required this.rideData,
  });


  @override
  State<RideConfirmationScreen> createState() =>
      _RideConfirmationScreenState();

}



class _RideConfirmationScreenState
    extends State<RideConfirmationScreen>
    with SingleTickerProviderStateMixin {



  bool driverFound=false;
  bool rideCancelled=false;

  Timer? rideStatusTimer;


  Map<String,dynamic>? updatedRide;

String driverRating = "5.0";

  late AnimationController pulseController;



  @override
  void initState(){

    super.initState();


    pulseController = AnimationController(
      vsync:this,
      duration:const Duration(seconds:1),
    )..repeat(reverse:true);



Future<void> assignDriver() async {
 
  try {

    final rideId = widget.rideData["id"];

    if(rideId == null){
      return;
    }


    final response =
    await ApiService.autoAssignRide(
      rideId
    );


    if(response["status"]==true){

      debugPrint(
        "Driver assigned successfully"
      );
      await checkRideStatus();
    }
    else{

      debugPrint(
        response["message"]
      );

    }


  }
  catch(e){

    debugPrint(
      "Auto assign error : $e"
    );

  }

}


    assignDriver();
    checkRideStatus();



    rideStatusTimer =
        Timer.periodic(
          const Duration(seconds:5),
          (timer){

            if(!rideCancelled){

              checkRideStatus();

            }

          },
        );

  }





  Future<void> checkRideStatus() async {


    try{


      final response =
      await ApiService.getRide(
        widget.rideData["id"],
      );



      if(response["status"]==true){


        final ride=response["ride"];



        setState((){


          updatedRide =
          Map<String,dynamic>.from(ride);



          if(
          ride["driver_id"] != null || ride["driver"] != null
          ){

            driverFound=true;

            pulseController.stop();

          }


        });



      }



    }
    catch(e){

      debugPrint(
          "Ride status error : $e"
      );

    }


  }





  @override
  void dispose(){

    rideStatusTimer?.cancel();

    pulseController.dispose();

    super.dispose();

  }





  String get pickup {


    return _getString(
        [
          "pickup_location",
          "pickup",
          "pickupLocation"
        ],
        "Current Location"
    );


  }





  String get destination {


    return _getString(
        [
          "destination",
          "destination_location",
          "destinationLocation"
        ],
        "Destination"
    );


  }


  String get vehicleType {

    return updatedRide?["vehicle"]
        ?["vehicle_type"]
        ??
        widget.rideData["vehicle_type"]
        ??
        "EV Vehicle";

  }

  String get vehicleNumber {

  final vehicle = updatedRide?["vehicle"];

  if(vehicle is Map){

    final number =
        vehicle["vehicle_number"] ??
        vehicle["registration_number"] ??
        vehicle["vehicleNumber"];


    if(number != null &&
       number.toString().trim().isNotEmpty){

      return number.toString();

    }

  }


  return "Vehicle number unavailable";

}

  String get driverName {


    return updatedRide?
    ["driver"]
    ?["full_name"]
        ??
        "Finding Driver";


  }




  String get fare {


    final value =
    updatedRide?["estimated_fare"]
        ??
        widget.rideData["estimated_fare"]
        ??
        0;



    return "₹${value.toString()}";


  }





  String get distance {


    final value =
    updatedRide?["distance_km"]
        ??
        widget.rideData["distance_km"]
        ??
        0;



    return "${value.toString()} km";


  }






  String _getString(
      List<String> keys,
      String fallback
      ){


    for(final key in keys){


      final value =
      updatedRide?[key]
          ??
          widget.rideData[key];



      if(value!=null &&
          value.toString().trim().isNotEmpty){

        return value.toString();

      }


    }



    return fallback;


  }






  @override
  Widget build(BuildContext context){


    return Scaffold(

      body: AnimatedEVBackground(

        child: SafeArea(

          child: Padding(

            padding:
            const EdgeInsets.all(20),

            child: Column(

              crossAxisAlignment:
              CrossAxisAlignment.start,


              children:[



                Row(

                  children:[


                    IconButton(

                      onPressed:(){

                        Navigator.pop(context);

                      },


                      icon:const Icon(

                        LucideIcons.arrowLeft,

                        color:Colors.white,

                      ),

                    ),



                    const Text(

                      "Ride Status",

                      style:TextStyle(

                        color:Colors.white,

                        fontSize:24,

                        fontWeight:
                        FontWeight.bold,

                      ),

                    )



                  ],

                ),



                const SizedBox(height:20),




                statusSection(),




                const SizedBox(height:25),



                Expanded(

                  child:SingleChildScrollView(

                    child:Column(

                      children:[



                        mapPlaceholder(),



                        const SizedBox(height:18),



                        rideInfoCard(),



                        const SizedBox(height:18),



                        if(driverFound)

                          driverCard(),



                        const SizedBox(height:18),



                        safetyCard(),



                      ],

                    ),

                  ),

                ),




                if(driverFound)

                  trackButton()

                else

                  cancelButton(),




              ],

            ),

          ),

        ),

      ),

    );


  }

    // ============================================================
  // GOOGLE MAP PLACEHOLDER
  // ============================================================

  Widget mapPlaceholder(){

    return Container(

      height:220,

      width:double.infinity,


      decoration:BoxDecoration(

        color:AppColors.card,

        borderRadius:
        BorderRadius.circular(25),


        border:Border.all(

          color:AppColors.primaryGreen
              .withOpacity(0.20),

        ),

      ),


      child:const Center(

        child:Text(

          "// GOOGLE MAP API WILL BE ADDED HERE",

          style:TextStyle(

            color:Colors.white54,

            fontSize:14,

          ),

        ),

      ),

    );


  }





  // ============================================================
  // STATUS SECTION
  // ============================================================

  Widget statusSection(){


    return Column(

      children:[


        Center(

          child:AnimatedBuilder(

            animation:pulseController,


            builder:(context,child){


              final scale =
              1 +
              (pulseController.value * 0.08);



              return Transform.scale(

                scale:scale,

                child:child,

              );


            },


            child:Container(

              height:100,

              width:100,


              decoration:BoxDecoration(

                shape:BoxShape.circle,


                color:AppColors.primaryGreen
                    .withOpacity(.10),


                border:Border.all(

                  color:AppColors.primaryGreen
                      .withOpacity(.30),

                ),

              ),


              child:Icon(

                driverFound

                    ? LucideIcons.car

                    : LucideIcons.search,


                color:
                AppColors.primaryGreen,


                size:38,

              ),

            ),

          ),

        ),




        const SizedBox(height:20),



        Text(

          driverFound

              ? "Driver Found"

              : "Finding Driver...",



          style:const TextStyle(

            color:Colors.white,

            fontSize:23,

            fontWeight:FontWeight.bold,

          ),

        ),




        const SizedBox(height:8),



        Text(

          driverFound

              ? "Your driver is coming to pickup"

              : "Searching nearby drivers",



          style:const TextStyle(

            color:Colors.white54,

            fontSize:13,

          ),

        ),



      ],

    );


  }





  // ============================================================
  // RIDE INFO CARD
  // ============================================================

  Widget rideInfoCard(){


    return Container(

      width:double.infinity,


      padding:
      const EdgeInsets.all(20),



      decoration:BoxDecoration(

        color:AppColors.card,


        borderRadius:
        BorderRadius.circular(25),

      ),



      child:Column(

        crossAxisAlignment:
        CrossAxisAlignment.start,


        children:[



          const Text(

            "Ride Details",

            style:TextStyle(

              color:Colors.white,

              fontSize:18,

              fontWeight:FontWeight.bold,

            ),

          ),



          const SizedBox(height:20),



          detailRow(

            LucideIcons.navigation,

            "Pickup",

            pickup,

          ),



          const SizedBox(height:15),



          detailRow(

            LucideIcons.mapPin,

            "Destination",

            destination,

          ),



          const SizedBox(height:15),



          detailRow(

            LucideIcons.car,

            "Vehicle",

            vehicleType,

          ),



          const SizedBox(height:15),



          detailRow(

            LucideIcons.route,

            "Distance",

            distance,

          ),



          const SizedBox(height:15),



          detailRow(

            LucideIcons.wallet,

            "Fare",

            fare,

            highlight:true,

          ),



        ],

      ),

    );


  }





  Widget detailRow(

      IconData icon,

      String title,

      String value,

      {

        bool highlight=false

      }

      ){



    return Row(


      children:[



        Container(

          height:40,

          width:40,


          decoration:BoxDecoration(

            color:AppColors.primaryGreen
                .withOpacity(.10),

            borderRadius:
            BorderRadius.circular(12),

          ),


          child:Icon(

            icon,

            color:AppColors.primaryGreen,

            size:20,

          ),

        ),




        const SizedBox(width:12),




        Expanded(

          child:Column(

            crossAxisAlignment:
            CrossAxisAlignment.start,


            children:[



              Text(

                title,

                style:const TextStyle(

                  color:Colors.white54,

                  fontSize:11,

                ),

              ),



              Text(

                value,

                style:TextStyle(

                  color:highlight

                      ? AppColors.primaryGreen

                      : Colors.white,


                  fontSize:
                  highlight ? 18 : 14,


                  fontWeight:
                  FontWeight.bold,

                ),

              ),



            ],

          ),

        )



      ],


    );


  }

  // ============================================================
// DRIVER CARD
// ============================================================

Widget driverCard(){


return Container(

width:double.infinity,


padding:
const EdgeInsets.all(20),



decoration:BoxDecoration(

color:AppColors.card,

borderRadius:
BorderRadius.circular(25),

),



child:Column(

crossAxisAlignment:
CrossAxisAlignment.start,


children:[


const Text(

"Driver Details",

style:TextStyle(

color:Colors.white,

fontSize:18,

fontWeight:FontWeight.bold,

),

),



const SizedBox(height:20),



Row(

children:[


Container(

height:60,

width:60,


decoration:BoxDecoration(

shape:BoxShape.circle,

color:AppColors.primaryGreen
.withOpacity(.15),

),



child:const Icon(

LucideIcons.userRound,

color:AppColors.primaryGreen,

size:30,

),

),



const SizedBox(width:15),



Expanded(

child:Column(

crossAxisAlignment:
CrossAxisAlignment.start,


children:[


Text(

driverName.isEmpty

?"Searching Driver"

:driverName,


style:const TextStyle(

color:Colors.white,

fontSize:17,

fontWeight:FontWeight.bold,

),

),



const SizedBox(height:5),



Text(

driverRating,

style:const TextStyle(

color:Colors.white54,

fontSize:13,

),

),



],

),

)



],

),




const SizedBox(height:20),



Container(

padding:
const EdgeInsets.all(15),


decoration:BoxDecoration(

color:Colors.black12,

borderRadius:
BorderRadius.circular(15),

),


child:Column(

children:[



infoLine(

"Vehicle",

vehicleNumber,

),



const SizedBox(height:12),



infoLine(

"Vehicle Type",

vehicleType,

),



],

),

),



],

),

);

}

// ============================================================
// TRACK DRIVER BUTTON
// ============================================================


Widget trackButton(){


return GestureDetector(


onTap:(){


/*

GOOGLE MAP LIVE TRACKING API WILL BE ADDED HERE


Example:

Driver location API

Socket connection

Google Map Marker Update


*/


},



child:Container(

height:55,

width:double.infinity,


decoration:BoxDecoration(

color:AppColors.primaryGreen,


borderRadius:
BorderRadius.circular(18),

),



child:const Center(

child:Row(

mainAxisAlignment:
MainAxisAlignment.center,


children:[


Icon(

LucideIcons.map,

color:Colors.black,

),



SizedBox(width:10),



Text(

"Track Driver",

style:TextStyle(

color:Colors.black,

fontSize:16,

fontWeight:FontWeight.bold,

),

),



],

),

),


),


);


}





// ============================================================
// CANCEL RIDE BUTTON
// ============================================================


Widget cancelButton(){


return GestureDetector(


onTap:(){


showDialog(

context:context,

builder:(context){


return AlertDialog(

backgroundColor:AppColors.card,


title:const Text(

"Cancel Ride?",

style:TextStyle(

color:Colors.white,

),

),



content:const Text(

"Are you sure you want to cancel this ride?",

style:TextStyle(

color:Colors.white54,

),

),



actions:[


TextButton(

onPressed:(){

Navigator.pop(context);

},

child:const Text(

"NO",

),

),



TextButton(

onPressed:(){


/*

CANCEL RIDE API WILL BE ADDED HERE


PUT:

/api/ride/{id}/cancel


*/


Navigator.pop(context);


},


child:const Text(

"YES",

style:TextStyle(

color:Colors.red,

),

),


),



],



);


},

);


},



child:Container(

height:55,

width:double.infinity,


decoration:BoxDecoration(

borderRadius:
BorderRadius.circular(18),


border:Border.all(

color:Colors.red,

),

),



child:const Center(

child:Text(

"Cancel Ride",

style:TextStyle(

color:Colors.red,

fontSize:16,

fontWeight:FontWeight.bold,

),

),

),

),
);
}


  // ============================================================
  // INFO LINE
  // ============================================================

  Widget infoLine(
    String title,
    String value,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 13,
            ),
          ),
        ),

        const SizedBox(width: 15),

        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,

            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

      ],
    );
  }


  // ============================================================
  // SAFETY CARD
  // ============================================================

  Widget safetyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: AppColors.darkGreen.withOpacity(0.30),
        borderRadius: BorderRadius.circular(18),

        border: Border.all(
          color: AppColors.primaryGreen.withOpacity(0.12),
        ),
      ),

      child: Row(
        children: [

          Container(
            height: 40,
            width: 40,

            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),

            child: const Icon(
              LucideIcons.shieldCheck,
              color: AppColors.primaryGreen,
              size: 21,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  "Ride Safety",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  "Your trip is protected",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                  ),
                ),

              ],
            ),
          ),

        ],
      ),
    );
  }


  // ============================================================
  // CANCEL DIALOG
  // ============================================================

  void showCancelDialog() {
    showDialog(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.card,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),

          title: const Text(
            "Cancel Ride?",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
  
          content: const Text(
            "Are you sure you want to cancel this ride?",
            style: TextStyle(
              color: Colors.white70,
            ),
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },

              child: const Text(
                "NO",
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
            ),

            TextButton(
              onPressed: () async {

                Navigator.pop(dialogContext);

                /*
                  ==================================================
                  CANCEL RIDE API WILL BE ADDED HERE

                  Example:
                  PUT /api/ride/{id}/cancel
                  ==================================================
                */

                setState(() {
                  rideCancelled = true;
                });

                rideStatusTimer?.cancel();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Ride cancellation API will be connected here.",
                    ),
                  ),
                );
              },

              child: const Text(
                "CANCEL",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          ],
        );
      },
    );
  }
}