import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/animated_ev_background.dart';

import '../../services/api_service.dart';

import 'vehicle_selection_screen.dart';
import 'ride_confirmation_screen.dart';



class BookingScreen extends StatefulWidget {

  const BookingScreen({
    super.key,
  });


  @override
  State<BookingScreen> createState() =>
      _BookingScreenState();

}




class _BookingScreenState extends State<BookingScreen> {



  final pickupController =
  TextEditingController();



  final destinationController =
  TextEditingController();





  String selectedVehicle = "Mini EV";



  double distanceKm = 5;

int serviceTypeId = 1; // Ride

int vehicleCategoryId = 1; // Default Bike

  bool isLoading = false;





  @override
  void dispose(){


    pickupController.dispose();


    destinationController.dispose();


    super.dispose();

  }







  // =========================
  // FARE CALCULATION
  // =========================


  double calculateFare(){


    double rate = 10;



    if(selectedVehicle == "Bike"){

      rate = 8;

    }


    else if(selectedVehicle == "Auto"){

      rate = 12;

    }


    else if(selectedVehicle == "Mini EV"){

      rate = 10;

    }


    else if(selectedVehicle == "Sedan EV"){

      rate = 15;

    }


    else if(selectedVehicle == "Premium EV"){

      rate = 25;

    }



    return distanceKm * rate;


  }









  // =========================
  // CURRENT LOCATION
  // =========================


  Future getCurrentLocation() async{


    bool serviceEnabled;


    LocationPermission permission;





    serviceEnabled =

    await Geolocator.isLocationServiceEnabled();




    if(!serviceEnabled){


      ScaffoldMessenger.of(context)
          .showSnackBar(


        const SnackBar(


          content:

          Text(
              "Please enable location service"
          ),


        ),


      );


      return;


    }






    permission =

    await Geolocator.checkPermission();





    if(permission ==

    LocationPermission.denied){



      permission =

      await Geolocator.requestPermission();


    }





    if(permission ==

    LocationPermission.deniedForever){



      ScaffoldMessenger.of(context)
          .showSnackBar(


        const SnackBar(


          content:

          Text(
              "Location permission denied"
          ),


        ),


      );



      return;


    }







    Position position =

    await Geolocator.getCurrentPosition();






    setState((){


      pickupController.text =


      "${position.latitude}, ${position.longitude}";



    });




  }


    // =========================
  // CONFIRM RIDE
  // =========================


  Future confirmRide() async {



    if(
    pickupController.text.trim().isEmpty ||
        destinationController.text.trim().isEmpty
    ){


      ScaffoldMessenger.of(context)
          .showSnackBar(



        const SnackBar(


          content:

          Text(
              "Please enter pickup and destination"
          ),


        ),


      );


      return;


    }







    setState((){


      isLoading = true;



    });







    try{



      var response =

      await ApiService.bookRide(



        pickup:

        pickupController.text.trim(),



        destination:

        destinationController.text.trim(),



        vehicleType:

        selectedVehicle,



        distance:

        distanceKm,



        fare:

        calculateFare(),

        serviceTypeId: serviceTypeId,

vehicleCategoryId: vehicleCategoryId,

      );








      setState((){


        isLoading = false;



      });


if(response["status"] == true){


  final ride = response["ride"];


  final assignResponse =
      await ApiService.autoAssignRide(
        ride["id"]
      );


  if(assignResponse["status"] == true){


    Navigator.pushReplacement(

      context,

      MaterialPageRoute(

        builder:(context)=>

        RideConfirmationScreen(

          rideData: assignResponse["ride"],

        ),

      ),

    );


  }
  else{


    ScaffoldMessenger.of(context)
    .showSnackBar(

      SnackBar(

        content: Text(
          assignResponse["message"]
          ??
          "Driver not found"
        ),

      ),

    );


  }


}
      else{

        ScaffoldMessenger.of(context)
            .showSnackBar(



          SnackBar(



            content:


            Text(



              response["message"]

                  ??

                  "Ride booking failed"



            ),



          ),



        );



      }





    }



    catch(e){



      setState((){


        isLoading = false;


      });





      ScaffoldMessenger.of(context)
          .showSnackBar(



        SnackBar(



          content:

          Text(

              e.toString()

          ),



        ),



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


          SingleChildScrollView(



            padding:


            const EdgeInsets.all(20),




            child:


            Column(



              crossAxisAlignment:

              CrossAxisAlignment.start,



              children: [





                Row(



                  children: [



                    IconButton(



                      onPressed:(){


                        Navigator.pop(context);


                      },



                      icon:


                      const Icon(



                        LucideIcons.arrowLeft,


                        color:

                        Colors.white,


                      ),



                    ),






                    const Text(



                      "Book Your Ride",



                      style:


                      TextStyle(



                        color:

                        Colors.white,



                        fontSize:24,



                        fontWeight:

                        FontWeight.bold,


                      ),



                    )



                  ],



                ),







                const SizedBox(height:25),






                rideInputCard(),







                const SizedBox(height:25),







                const Text(



                  "Select Vehicle",



                  style:


                  TextStyle(



                    color:

                    Colors.white,



                    fontSize:18,



                    fontWeight:

                    FontWeight.bold,


                  ),



                ),








                const SizedBox(height:15),






                vehicleCard(),








                const SizedBox(height:25),








                fareCard(),







                const SizedBox(height:30),







                SizedBox(



                  width:

                  double.infinity,



                  height:

                  55,



                  child:


                  ElevatedButton(



                    onPressed:


                    isLoading

                        ?

                    null

                        :

                    confirmRide,





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


                    isLoading



                        ?



                    const CircularProgressIndicator(



                      color:

                      Colors.black,


                    )



                        :



                    const Text(



                      "CONFIRM RIDE",



                      style:


                      TextStyle(



                        fontWeight:

                        FontWeight.bold,


                      ),



                    ),




                  ),



                )





              ],



            ),



          ),



        ),



      ),



    );


  }









  Widget rideInputCard(){



    return Container(



      padding:

      const EdgeInsets.all(20),




      decoration:


      BoxDecoration(



        color:

        AppColors.card,



        borderRadius:

        BorderRadius.circular(25),



        border:

        Border.all(



          color:

          AppColors.primaryGreen

              .withOpacity(0.15),


        ),



      ),




      child:


      Column(



        children: [





          locationField(



            LucideIcons.navigation,


            "Pickup Location",


            pickupController,


          ),






          const SizedBox(height:10),





          Align(



            alignment:

            Alignment.centerRight,



            child:


            TextButton.icon(



              onPressed:

              getCurrentLocation,



              icon:


              const Icon(



                LucideIcons.locateFixed,



                size:18,


              ),



              label:


              const Text(



                "Use Current Location",



              ),



              style:


              TextButton.styleFrom(



                foregroundColor:

                AppColors.primaryGreen,


              ),



            ),



          ),






          const SizedBox(height:10),







          locationField(



            LucideIcons.mapPin,


            "Destination",


            destinationController,


          ),




        ],



      ),



    );


  }









  Widget locationField(



      IconData icon,


      String hint,


      TextEditingController controller,


      ){



    return TextField(



      controller:

      controller,



      style:


      const TextStyle(



        color:

        Colors.white,


      ),





      decoration:


      InputDecoration(



        hintText:

        hint,



        hintStyle:


        const TextStyle(



          color:

          Colors.white54,


        ),






        prefixIcon:


        Icon(



          icon,



          color:

          AppColors.primaryGreen,


        ),





        filled:true,



        fillColor:

        Colors.black26,





        border:


        OutlineInputBorder(



          borderRadius:

          BorderRadius.circular(18),



          borderSide:

          BorderSide.none,



        ),



      ),



    );


  }

    Widget vehicleCard(){


    return InkWell(



      onTap:(){



        Navigator.push(



          context,



          MaterialPageRoute(



            builder:(context)=>



            VehicleSelectionScreen(

  selected: selectedVehicle,

  distance: distanceKm,

),



          ),



        ).then((value){



          if(value != null){



            setState((){



setState(() {

  selectedVehicle = value;

  if (value == "Bike") {
    vehicleCategoryId = 1;
  }
  else if (value == "Auto") {
    vehicleCategoryId = 2;
  }
  else if (value == "Mini EV") {
    // Backend category 3 = Car
    vehicleCategoryId = 3;
  }
  else if (value == "Sedan EV") {
    // Backend category 4 = Premium
    vehicleCategoryId = 4;
  }
  else if (value == "Premium EV") {
    // Backend currently has no separate Premium EV category.
    // Use Premium category.
    vehicleCategoryId = 4;
  }

});



            });



          }



        });



      },



      child:



      Container(



        padding:

        const EdgeInsets.all(20),




        decoration:


        BoxDecoration(



          color:

          AppColors.card,



          borderRadius:

          BorderRadius.circular(25),





          border:


          Border.all(



            color:

            AppColors.primaryGreen

                .withOpacity(0.25),



          ),



        ),





        child:



        Row(



          children: [





            Container(



              height:55,



              width:55,



              decoration:


              BoxDecoration(



                color:

                AppColors.primaryGreen

                    .withOpacity(0.15),



                borderRadius:

                BorderRadius.circular(18),



              ),





              child:


              Icon(



                getVehicleIcon(),



                color:

                AppColors.primaryGreen,



                size:30,



              ),



            ),





            const SizedBox(width:15),






            Expanded(



              child:



              Column(



                crossAxisAlignment:

                CrossAxisAlignment.start,



                children: [



                  Text(



                    selectedVehicle,



                    style:


                    const TextStyle(



                      color:

                      Colors.white,



                      fontSize:18,



                      fontWeight:

                      FontWeight.bold,


                    ),



                  ),





                  const SizedBox(height:5),





                  Text(



                    "Change vehicle",



                    style:


                    const TextStyle(



                      color:

                      Colors.white54,



                      fontSize:13,


                    ),



                  ),




                ],



              ),



            ),





            const Icon(



              LucideIcons.chevronRight,



              color:

              Colors.white54,



            )



          ],



        ),



      ),



    );



  }









  IconData getVehicleIcon(){



    if(selectedVehicle == "Bike"){


      return LucideIcons.bike;


    }


    else if(selectedVehicle == "Auto"){


      return LucideIcons.carFront;


    }


    else if(selectedVehicle == "Premium EV"){


      return LucideIcons.sparkles;


    }


    else{


      return LucideIcons.car;


    }



  }









  Widget fareCard(){



    return Container(



      padding:

      const EdgeInsets.all(22),




      decoration:


      BoxDecoration(



        gradient:


        LinearGradient(



          colors:[



            AppColors.darkGreen

                .withOpacity(0.5),



            AppColors.card,



          ],



        ),



        borderRadius:

        BorderRadius.circular(25),



        border:


        Border.all(



          color:

          AppColors.primaryGreen

              .withOpacity(0.25),



        ),



      ),





      child:


      Row(



        mainAxisAlignment:

        MainAxisAlignment.spaceBetween,



        children: [





          Column(



            crossAxisAlignment:

            CrossAxisAlignment.start,



            children: [





              const Text(



                "Estimated Fare",



                style:


                TextStyle(



                  color:

                  Colors.white70,



                  fontSize:14,


                ),



              ),





              const SizedBox(height:6),





              Text(



                "${distanceKm.toStringAsFixed(0)} km",



                style:


                const TextStyle(



                  color:

                  Colors.white54,



                  fontSize:13,


                ),



              ),




            ],



          ),








          Text(



            "₹${calculateFare().toStringAsFixed(0)}",



            style:


            const TextStyle(



              color:

              AppColors.primaryGreen,



              fontSize:28,



              fontWeight:

              FontWeight.bold,


            ),



          )





        ],



      ),



    );



  }



}