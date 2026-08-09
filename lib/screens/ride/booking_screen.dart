import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/animated_ev_background.dart';
import '../../services/api_service.dart';


class BookingScreen extends StatefulWidget {


  const BookingScreen({super.key});


  @override
  State<BookingScreen> createState() =>
      _BookingScreenState();

}


class _BookingScreenState extends State<BookingScreen> {



  GoogleMapController? mapController;



  String selectedVehicle = "Mini EV";

final TextEditingController pickupController =
TextEditingController();

final TextEditingController destinationController =
TextEditingController();


bool isBooking = false;

  final vehicles = [

    "Mini EV",
    "Sedan EV",
    "SUV EV"

  ];


  LatLng currentLocation = const LatLng(

    23.2599,

    77.4126,

  );


  bool isLocationLoading = true;


  @override
  void initState(){


    super.initState();


    getCurrentLocation();


  }


  Future<void> getCurrentLocation() async {

    bool serviceEnabled =

    await Geolocator.isLocationServiceEnabled();


    if(!serviceEnabled){


      setState((){

        isLocationLoading = false;

      });


      return;

    }






    LocationPermission permission =

    await Geolocator.checkPermission();





    if(permission == LocationPermission.denied){



      permission =

      await Geolocator.requestPermission();



    }





    if(permission == LocationPermission.deniedForever){


      setState((){

        isLocationLoading = false;

      });


      return;

    }





    Position position =

    await Geolocator.getCurrentPosition();





    setState((){



      currentLocation = LatLng(

        position.latitude,

        position.longitude,

      );



      isLocationLoading = false;



    });





    mapController?.animateCamera(


      CameraUpdate.newLatLngZoom(

        currentLocation,

        15,

      ),


    );



  }


Future<void> bookRide() async {


  setState((){

    isBooking = true;

  });



  var response = await ApiService.bookRide(


    pickup:

    pickupController.text,


    destination:

    destinationController.text,


    vehicleType:

    selectedVehicle,


  );



  setState((){

    isBooking = false;

  });





  if(response["status"] == true){


    ScaffoldMessenger.of(context)
    .showSnackBar(


      const SnackBar(

        content:

        Text(

          "Ride booked successfully"

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

          "Ride booking failed"

        ),

      ),


    );


  }


}


@override
void dispose(){

 pickupController.dispose();

 destinationController.dispose();

 super.dispose();

}



  @override
  Widget build(BuildContext context){


    return Scaffold(



      body:


      AnimatedEVBackground(


        child:


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



                const Text(


                  "Book Your Ride 🚗",


                  style:


                  TextStyle(


                    color:

                    Colors.white,


                    fontSize:28,


                    fontWeight:

                    FontWeight.bold,


                  ),


                ),



                const SizedBox(height:25),


// GOOGLE MAP

Container(

  height:250,

  width:double.infinity,


  decoration:

  BoxDecoration(

    borderRadius:

    BorderRadius.circular(25),

    border:

    Border.all(

      color:

      AppColors.primaryGreen
          .withOpacity(0.3),

    ),

  ),



  child:

  ClipRRect(

    borderRadius:

    BorderRadius.circular(25),



    child:



    isLocationLoading



    ?



    const Center(

      child:

      CircularProgressIndicator(

        color:

        AppColors.primaryGreen,

      ),

    )



    :



    GoogleMap(



      initialCameraPosition:



      CameraPosition(

        target:

        currentLocation,

        zoom:15,

      ),




      myLocationEnabled:true,



      myLocationButtonEnabled:true,




      markers:{



        Marker(


          markerId:

          const MarkerId("user_location"),



          position:

          currentLocation,



          infoWindow:

          const InfoWindow(

            title:

            "Your Location",

          ),



        ),



      },





      onMapCreated:(controller){


        mapController = controller;


      },



    ),



  ),



),





const SizedBox(height:25),






locationField(

"Pickup Location",

Icons.my_location,

pickupController,

),




const SizedBox(height:15),





locationField(

"Destination",

Icons.location_on,

destinationController,

),





const SizedBox(height:25),

const Text(


"Select Vehicle",


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


Wrap(


spacing:10,


children:


vehicles.map((vehicle){



return ChoiceChip(



label:


Text(vehicle),



selected:

selectedVehicle == vehicle,



onSelected:(value){



setState((){


selectedVehicle = vehicle;


});



},



selectedColor:

AppColors.primaryGreen,



);



}).toList(),



),






const SizedBox(height:25),






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



mainAxisAlignment:

MainAxisAlignment.spaceBetween,



children:[



const Text(



"Estimated Fare",



style:


TextStyle(



color:

Colors.white70,


),



),




const Text(



"₹ 120",



style:


TextStyle(



color:

AppColors.primaryGreen,


fontSize:24,


fontWeight:

FontWeight.bold,


),



),



],



),



),





const SizedBox(height:25),





SizedBox(

  width: double.infinity,

  child: ElevatedButton(

    style: ElevatedButton.styleFrom(

      backgroundColor:
      AppColors.primaryGreen,

      padding:
      const EdgeInsets.symmetric(
        vertical:16,
      ),

      shape:
      RoundedRectangleBorder(

        borderRadius:
        BorderRadius.circular(30),

      ),

    ),


    onPressed:

    isBooking

        ? null

        : bookRide,


    child:

    isBooking

        ?

    const CircularProgressIndicator(

      color: Colors.black,

    )

        :

    const Text(

      "BOOK RIDE",

      style:

      TextStyle(

        color: Colors.black,

        fontWeight: FontWeight.bold,

        fontSize:16,

      ),

    ),

  ),

),


              ],
            ),

          ),

        ),

      ),
    
    );

  }



// ===============================
// LOCATION FIELD WIDGET
// ===============================

Widget locationField(

    String hint,

    IconData icon,

    TextEditingController controller,

    )
    {

  return Container(

    padding:

    const EdgeInsets.symmetric(

      horizontal: 15,

      vertical: 5,

    ),


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

            .withOpacity(0.2),

      ),

    ),


    child:


    TextField(

      controller: controller,


      style:

      const TextStyle(

        color: Colors.white,

      ),


      decoration:

      InputDecoration(


        hintText: hint,


        hintStyle:

        const TextStyle(

          color: Colors.white54,

        ),


        prefixIcon:

        Icon(

          icon,

          color:

          AppColors.primaryGreen,

        ),


        border:

        InputBorder.none,


      ),

    ),

  );

}

}