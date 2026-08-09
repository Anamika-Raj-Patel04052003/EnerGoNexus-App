import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/animated_ev_background.dart';
import '../../services/api_service.dart';

import '../auth/login_screen.dart';



class ProfileScreen extends StatefulWidget {


  const ProfileScreen({super.key});



  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();

}





class _ProfileScreenState extends State<ProfileScreen> {


  String name = "User";

  String email = "";

  String mobile = "";

  String city = "";

  String state = "";



  bool loading = true;




  @override
  void initState(){

    super.initState();

    loadProfile();

  }





  Future<void> loadProfile() async {


    var response =

    await ApiService.getProfile();



    if(response["user"] != null){



      setState(() {



        name =

        response["user"]["full_name"] ?? "";



        email =

        response["user"]["email"] ?? "";



        mobile =

        response["user"]["mobile_number"] ?? "";



        city =

        response["user"]["city"] ?? "";



        state =

        response["user"]["state"] ?? "";



        loading=false;



      });



    }



  }





  Future<void> logout() async {


    await ApiService.logout();



    Navigator.pushAndRemoveUntil(



      context,



      MaterialPageRoute(



        builder:(context)=>

        const LoginScreen(),



      ),



      (route)=>false,



    );



  }







  @override
  Widget build(BuildContext context){


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


              children:[



                const SizedBox(height:30),




                Container(


                  padding:

                  const EdgeInsets.all(20),



                  decoration:

                  BoxDecoration(


                    shape:

                    BoxShape.circle,



                    color:

                    AppColors.primaryGreen

                    .withOpacity(0.15),


                  ),



                  child:


                  const Icon(


                    Icons.person,


                    size:70,


                    color:

                    AppColors.primaryGreen,


                  ),



                ),





                const SizedBox(height:20),




                Text(


                  name,


                  style:

                  const TextStyle(


                    color:

                    Colors.white,


                    fontSize:26,


                    fontWeight:

                    FontWeight.bold,


                  ),



                ),





                const SizedBox(height:30),






                profileCard(

                  Icons.email,

                  "Email",

                  email,

                ),



                profileCard(

                  Icons.phone,

                  "Mobile",

                  mobile,

                ),



                profileCard(

                  Icons.location_city,

                  "City",

                  city,

                ),



                profileCard(

                  Icons.map,

                  "State",

                  state,

                ),





                const SizedBox(height:30),





                SizedBox(


                  width:

                  double.infinity,



                  child:


                  ElevatedButton(



                    style:

                    ElevatedButton.styleFrom(



                      backgroundColor:

                      AppColors.primaryGreen,



                      padding:

                      const EdgeInsets.symmetric(

                        vertical:15,

                      ),



                      shape:

                      RoundedRectangleBorder(

                        borderRadius:

                        BorderRadius.circular(30),

                      ),



                    ),




                    onPressed:

                    logout,



                    child:


                    const Text(


                      "LOGOUT",


                      style:

                      TextStyle(


                        color:

                        Colors.black,


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







  Widget profileCard(

      IconData icon,

      String title,

      String value

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

        Colors.white.withOpacity(0.08),



        borderRadius:

        BorderRadius.circular(20),



        border:

        Border.all(

          color:

          AppColors.primaryGreen

          .withOpacity(0.25),


        ),



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

                  Colors.white70,



                ),



              ),



              Text(



                value,



                style:

                const TextStyle(



                  color:

                  Colors.white,



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