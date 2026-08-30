import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';



class DriverDocumentsScreen extends StatefulWidget {

  const DriverDocumentsScreen({
    super.key,
  });


  @override
  State<DriverDocumentsScreen> createState() =>
      _DriverDocumentsScreenState();

}



class _DriverDocumentsScreenState
    extends State<DriverDocumentsScreen> {


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

          "Driver Documents",

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



            documentCard(

              title:"Driving License",

              status:"Verified",

              icon:Icons.badge,

              verified:true,

            ),



            documentCard(

              title:"Vehicle RC",

              status:"Verified",

              icon:Icons.description,

              verified:true,

            ),




            documentCard(

              title:"Insurance",

              status:"Pending",

              icon:Icons.security,

              verified:false,

            ),




            documentCard(

              title:"Permit",

              status:"Pending",

              icon:Icons.assignment,

              verified:false,

            ),





            const SizedBox(height:25),




            Container(

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



                  const Text(

                    "Account Verification",

                    style:

                    TextStyle(

                      fontSize:20,

                      fontWeight:
                      FontWeight.bold,

                    ),

                  ),



                  const SizedBox(height:15),



                  Row(

                    children:[


                      const Icon(

                        Icons.verified,

                        color:
                        Colors.green,

                      ),



                      const SizedBox(width:10),



                      const Text(

                        "Driver Account Verified",

                        style:

                        TextStyle(

                          color:
                          Colors.green,

                          fontWeight:
                          FontWeight.bold,

                        ),

                      )


                    ],

                  )



                ],

              ),



            )



          ],


        ),


      ),


    );


  }







  Widget documentCard({

    required String title,

    required String status,

    required IconData icon,

    required bool verified,

  }){


    return Container(


      margin:

      const EdgeInsets.only(

        bottom:20,

      ),



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



          Row(


            children:[



              Icon(

                icon,

                size:35,

                color:

                AppColors.primaryGreen,

              ),



              const SizedBox(width:15),



              Expanded(

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



                    const SizedBox(height:5),



                    Text(

                      status,

                      style:

                      TextStyle(

                        color:

                        verified
                        ? Colors.green
                        : Colors.orange,

                        fontWeight:
                        FontWeight.bold,

                      ),

                    )


                  ],

                ),

              )



            ],


          ),




          const SizedBox(height:20),




          SizedBox(

            width:

            double.infinity,


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

                  BorderRadius.circular(18),

                ),

              ),



              child:

              Text(

                verified
                ? "VIEW DOCUMENT"
                : "UPLOAD DOCUMENT",

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