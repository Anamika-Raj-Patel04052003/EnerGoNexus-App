import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../services/api_service.dart';
import 'driver_active_ride_screen.dart';


class DriverRideRequestsScreen extends StatefulWidget {

  const DriverRideRequestsScreen({
    super.key,
  });


  @override
  State<DriverRideRequestsScreen> createState() =>
      _DriverRideRequestsScreenState();

}





class _DriverRideRequestsScreenState
    extends State<DriverRideRequestsScreen> {


  bool loading = true;


List<Map<String,dynamic>> requests = [];

  @override
  void initState(){

    super.initState();

    loadRequests();

  }






  Future<void> loadRequests() async {


    try{


      setState((){

        loading = true;

      });



      final response =
      await ApiService.getDriverRideRequests();




      if(response["status"] == true){


        final data =
        response["requests"];



        if(data is List){


          setState((){

         requests =
    List<Map<String,dynamic>>.from(data);

          });


        }


      }



    }

    catch(e){


      debugPrint(
          "REQUEST ERROR : $e"
      );


    }

    finally{


      if(mounted){

        setState((){

          loading = false;

        });

      }


    }

  }

 Future<void> acceptRide(
  Map<String,dynamic> ride
) async {

    try{

      final response =
    await ApiService.acceptRideRequest(
  ride["id"],
);


if(response["status"] == true){


  ScaffoldMessenger.of(context)
      .showSnackBar(

    const SnackBar(

      content:

      Text(
        "Ride accepted successfully",
      ),

    ),

  );


  Navigator.pushReplacement(

    context,

    MaterialPageRoute(

      builder:(context)=>

      DriverActiveRideScreen(

       rideData: {
    ...ride,
    "ride_status":"Accepted",
  },

      ),

    ),

  );

}
      else{

        ScaffoldMessenger.of(context)
            .showSnackBar(


          SnackBar(

            content:

            Text(

              response["message"] ??
                  "Unable to accept ride",

            ),

          ),


        );


      }



    }

    catch(e){

      debugPrint(
          e.toString()
      );

    }

  }
  Future<void> rejectRide(dynamic id) async {

    try{

      final response =
      await ApiService.rejectRideRequest(id);

      if(response["status"] == true){

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(

            content:

            Text(
              "Ride rejected",
            ),

          ),


        );



        loadRequests();


      }



    }

    catch(e){


      debugPrint(
          e.toString()
      );


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

          "Ride Requests",

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


      requests.isEmpty


          ?


      const Center(

        child:

        Text(

          "No ride requests available",

          style:

          TextStyle(

            color:
            Colors.white70,

            fontSize:18,

          ),

        ),

      )



          :



      RefreshIndicator(


        onRefresh:
        loadRequests,


        child:


        ListView.builder(



          padding:

          const EdgeInsets.all(20),



          itemCount:

          requests.length,



          itemBuilder:(context,index){



            final ride =
            requests[index];



            return rideCard(ride);



          },


        ),


      ),


    );


  }

 Widget rideCard(Map<String,dynamic> ride){

    return Container(
      margin:

      const EdgeInsets.only(
          bottom:20
      ),

      padding:

      const EdgeInsets.all(20),

      decoration:

      BoxDecoration(

        color: AppColors.card,

        borderRadius:

        BorderRadius.circular(25),

        border:

        Border.all(

          color:

          AppColors.primaryGreen
              .withOpacity(.25),

        ),



      ),






      child:

      Column(



        crossAxisAlignment:

        CrossAxisAlignment.start,



        children:[




          Row(


            mainAxisAlignment:

            MainAxisAlignment.spaceBetween,


            children:[



              const Text(


                "New Ride",

                style:

                TextStyle(

                  fontSize:20,

                  fontWeight:
                  FontWeight.bold,

                ),

              ),



              Text(

                "₹${ride["estimated_fare"] ?? 0}",

                style:

                const TextStyle(

                  color:
                  Colors.green,

                  fontSize:20,

                  fontWeight:
                  FontWeight.bold,

                ),

              ),



            ],


          ),




          const SizedBox(height:20),





          ListTile(

            contentPadding:
            EdgeInsets.zero,


            leading:

            const Icon(

              Icons.location_on,

              color:
              Colors.green,

            ),



            title:

            const Text(
              "Pickup",
            ),



            subtitle:

            Text(

              ride["pickup_location"] ??
                  "",

            ),


          ),





          ListTile(

            contentPadding:
            EdgeInsets.zero,


            leading:

            const Icon(

              Icons.flag,

              color:
              Colors.red,

            ),



            title:

            const Text(
              "Destination",
            ),



            subtitle:

            Text(

              ride["destination"] ??
                  "",

            ),


          ),





          const SizedBox(height:15),






          Row(



            children:[



              Expanded(


                child:

                ElevatedButton(

onPressed:(){

  acceptRide(
    ride,
  );

},


                  style:

                  ElevatedButton.styleFrom(


                    backgroundColor:
                    Colors.green,


                    foregroundColor:
                    Colors.black,


                  ),


                  child:

                  const Text(

                    "ACCEPT",

                  ),


                ),


              ),




              const SizedBox(width:15),





              Expanded(


                child:

                OutlinedButton(


                  onPressed:(){


                    rejectRide(
                        ride["id"]
                    );


                  },


                  style:

                  OutlinedButton.styleFrom(


                    foregroundColor:
                    Colors.red,


                  ),



                  child:

                  const Text(

                    "REJECT",

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