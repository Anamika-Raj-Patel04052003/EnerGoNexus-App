import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/animated_ev_background.dart';
import '../../services/api_service.dart';

import 'login_screen.dart';



class RegisterScreen extends StatefulWidget {

  const RegisterScreen({super.key});


  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();

}




class _RegisterScreenState extends State<RegisterScreen> {


  final fullNameController =
      TextEditingController();

  final mobileController =
      TextEditingController();

  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  final cityController =
      TextEditingController();

  final stateController =
      TextEditingController();

  final referralController =
      TextEditingController();



  bool isLoading = false;




  Future<void> register() async {


    if(fullNameController.text.isEmpty ||
        mobileController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty){


      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(

          content:
          Text(
              "Please fill all required fields"
          ),

        ),

      );


      return;

    }





    setState(() {

      isLoading = true;

    });

    var response = await ApiService.registerUser(


      fullName:

      fullNameController.text.trim(),



      mobileNumber:

      mobileController.text.trim(),



      email:

      emailController.text.trim(),



      password:

      passwordController.text.trim(),



      city:

      cityController.text.trim(),



      state:

      stateController.text.trim(),



      referralCode:

      referralController.text.trim(),


    );

print(response);



    setState(() {

      isLoading = false;

    });







    if(response["message"] != null){



      ScaffoldMessenger.of(context).showSnackBar(


        const SnackBar(


          content:

          Text(

              "Registration Successful"

          ),


        ),


      );





      Navigator.pushReplacement(


        context,


        MaterialPageRoute(


          builder:(context)=>

          const LoginScreen(),


        ),


      );



    }

    else{



      ScaffoldMessenger.of(context).showSnackBar(


        SnackBar(


          content:

          Text(

              response["message"] ??

              response["error"] ??

              "Registration Failed"

          ),



        ),


      );



    }




  }







  @override
  void dispose(){


    fullNameController.dispose();

    mobileController.dispose();

    emailController.dispose();

    passwordController.dispose();

    cityController.dispose();

    stateController.dispose();

    referralController.dispose();


    super.dispose();


  }







  @override
  Widget build(BuildContext context) {


    return Scaffold(


      body:


      AnimatedEVBackground(


        child:


        Center(


          child:


          SingleChildScrollView(


            child:


            Container(


              width:350,


              padding:

              const EdgeInsets.all(25),



              decoration:

              BoxDecoration(


                color:

                Colors.white.withOpacity(0.08),



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


              Column(


                children:[



                  Image.asset(

                    "assets/images/logoEnergo.png",

                    height:75,

                  ),





                  const SizedBox(height:10),





                  const Text(

                    "Create Account",

                    style:

                    TextStyle(

                      color:Colors.white,

                      fontSize:28,

                      fontWeight:

                      FontWeight.bold,

                    ),

                  ),





                  const SizedBox(height:20),





                  buildTextField(

                    "Full Name",

                    Icons.person,

                    fullNameController,

                  ),





                  const SizedBox(height:12),




                  buildTextField(

                    "Mobile Number",

                    Icons.phone,

                    mobileController,

                  ),





                  const SizedBox(height:12),




                  buildTextField(

                    "Email",

                    Icons.email,

                    emailController,

                  ),





                  const SizedBox(height:12),




                  buildTextField(

                    "Password",

                    Icons.lock,

                    passwordController,

                    isPassword:true,

                  ),





                  const SizedBox(height:12),




                  buildTextField(

                    "City",

                    Icons.location_city,

                    cityController,

                  ),





                  const SizedBox(height:12),




                  buildTextField(

                    "State",

                    Icons.map,

                    stateController,

                  ),





                  const SizedBox(height:12),




                  buildTextField(

                    "Referral Code (Optional)",

                    Icons.card_giftcard,

                    referralController,

                  ),





                  const SizedBox(height:25),





                  SizedBox(


                    width:double.infinity,



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

                      isLoading

                      ?

                      null

                      :

                      register,






                      child:


                      isLoading


                      ?


                      const CircularProgressIndicator(

                        color:Colors.black,

                      )



                      :


                      const Text(

                        "CREATE ACCOUNT",


                        style:

                        TextStyle(

                          color:Colors.black,

                          fontWeight:

                          FontWeight.bold,

                          fontSize:15,

                        ),

                      ),



                    ),


                  ),





                  const SizedBox(height:20),





                  Row(


                    mainAxisAlignment:

                    MainAxisAlignment.center,



                    children:[



                      const Text(

                        "Already have account? ",

                        style:

                        TextStyle(

                          color:

                          Colors.white70,

                        ),

                      ),






                      GestureDetector(



                        onTap:(){


                          Navigator.pushReplacement(


                            context,


                            MaterialPageRoute(


                              builder:(context)=>

                              const LoginScreen(),


                            ),


                          );


                        },



                        child:


                        const Text(


                          "Login",



                          style:

                          TextStyle(

                            color:

                            AppColors.primaryGreen,


                            fontWeight:

                            FontWeight.bold,

                          ),


                        ),


                      )



                    ],

                  )



                ],

              ),

            ),


          ),

        ),


      ),


    );


  }







  Widget buildTextField(


      String hint,


      IconData icon,


      TextEditingController controller,


      {

        bool isPassword=false

      }


      ){



    return TextField(



      controller:

      controller,



      obscureText:

      isPassword,



      style:

      const TextStyle(

        color:Colors.white,

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

          BorderRadius.circular(20),



          borderSide:

          BorderSide.none,


        ),



      ),



    );


  }


}