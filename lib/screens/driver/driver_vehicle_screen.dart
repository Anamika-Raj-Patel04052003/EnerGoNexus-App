import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';


class DriverVehicleScreen extends StatefulWidget {

  const DriverVehicleScreen({
    super.key,
  });


  @override
  State<DriverVehicleScreen> createState() =>
      _DriverVehicleScreenState();

}



class _DriverVehicleScreenState
    extends State<DriverVehicleScreen> {


  String vehicleType = "Electric Bike";

  String vehicleNumber = "MP09 AB 1234";

  String model = "Ather 450X";

  String year = "2025";

  String rcNumber = "RC123456789";


  bool verified = true;



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

          "Vehicle Details",

          style:

          TextStyle(

            fontWeight:
            FontWeight.bold,

          ),

        ),

      ),



      body:


      SingleChildScrollView(

        padding:

        const EdgeInsets.all(20),


        child:

        Column(


          children:[



            Container(


              padding:

              const EdgeInsets.all(25),


              decoration:

              BoxDecoration(


                color:

                AppColors.card,


                borderRadius:

                BorderRadius.circular(25),


              ),



              child:

              Column(

                children:[



                  const Icon(

                    Icons.electric_bike,

                    size:80,

                    color:
                    AppColors.primaryGreen,

                  ),



                  const SizedBox(height:20),



                  Text(

                    vehicleType,

                    style:

                    const TextStyle(

                      fontSize:24,

                      fontWeight:
                      FontWeight.bold,

                    ),

                  ),



                  const SizedBox(height:10),



                  Container(

                    padding:

                    const EdgeInsets.symmetric(

                      horizontal:15,

                      vertical:8,

                    ),


                    decoration:

                    BoxDecoration(

                      color:

                      Colors.green.withOpacity(.15),

                      borderRadius:

                      BorderRadius.circular(20),

                    ),



                    child:

                    Text(

                      verified
                      ? "Verified"
                      : "Pending Verification",


                      style:

                      TextStyle(

                        color:

                        verified
                        ? Colors.green
                        : Colors.orange,

                        fontWeight:
                        FontWeight.bold,

                      ),

                    ),

                  )



                ],

              ),


            ),



            const SizedBox(height:25),




            vehicleTile(
              "Vehicle Number",
              vehicleNumber,
              Icons.confirmation_number,
            ),


            vehicleTile(
              "Model",
              model,
              Icons.electric_scooter,
            ),



            vehicleTile(
              "Registration Year",
              year,
              Icons.calendar_month,
            ),



            vehicleTile(
              "RC Number",
              rcNumber,
              Icons.description,
            ),




            const SizedBox(height:30),




            SizedBox(

              width:
              double.infinity,


              height:
              55,


              child:

              ElevatedButton(


                onPressed:(){


                },


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

                const Text(

                  "EDIT VEHICLE DETAILS",

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


    );

  }





  Widget vehicleTile(
      String title,
      String value,
      IconData icon,
      ){


    return Container(


      margin:

      const EdgeInsets.only(

        bottom:15,

      ),


      padding:

      const EdgeInsets.all(18),



      decoration:

      BoxDecoration(


        color:

        AppColors.card,


        borderRadius:

        BorderRadius.circular(20),

      ),



      child:


      Row(


        children:[


          Icon(

            icon,

            color:

            AppColors.primaryGreen,

          ),



          const SizedBox(width:15),



          Column(

            crossAxisAlignment:

            CrossAxisAlignment.start,


            children:[


              Text(

                title,

                style:

                const TextStyle(

                  color:

                  Colors.white60,

                ),

              ),



              const SizedBox(height:5),



              Text(

                value,

                style:

                const TextStyle(

                  fontSize:17,

                  fontWeight:
                  FontWeight.bold,

                ),

              ),


            ],

          )



        ],

      ),


    );


  }



}