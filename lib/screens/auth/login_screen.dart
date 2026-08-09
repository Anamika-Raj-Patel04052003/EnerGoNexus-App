import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/animated_ev_background.dart';
import '../../services/api_service.dart';
import '../main/main_navigation.dart';
import 'register_screen.dart';



class LoginScreen extends StatefulWidget {


  const LoginScreen({super.key});


  @override
  State<LoginScreen> createState() => _LoginScreenState();


}
class _LoginScreenState extends State<LoginScreen> {


  final mobileController = TextEditingController();

  final passwordController = TextEditingController();



  bool isLoading = false;



  Future<void> login() async {


  if(mobileController.text.length != 10){

    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(

        content:

        Text(
          "Enter valid 10 digit mobile number"
        ),

      ),

    );

    return;

  }



  if(passwordController.text.isEmpty){

    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(

        content:

        Text(
          "Password required"
        ),

      ),

    );

    return;

  }



  setState(() {

    isLoading = true;

  });



    var response = await ApiService.loginUser(


      mobileNumber:

      mobileController.text.trim(),



      password:

      passwordController.text.trim(),


    );



    setState(() {

      isLoading = false;

    });




    if(response["token"] != null){



      Navigator.pushReplacement(


        context,


        MaterialPageRoute(


          builder:(context)=>

          const MainNavigation()


        ),


      );



    }

    else{


      ScaffoldMessenger.of(context).showSnackBar(


        SnackBar(


          content:

          Text(

            response["message"] ??

            "Login Failed",

          ),


        ),


      );

    }


  }






  @override
  Widget build(BuildContext context){


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

                    height:80,

                  ),



                  const SizedBox(height:10),





                  const Text(


                    "Welcome Back",


                    style:


                    TextStyle(

                      color:Colors.white,

                      fontSize:28,

                      fontWeight:FontWeight.bold,

                    ),


                  ),



                  const SizedBox(height:25),




                  TextField(

  controller: mobileController,

  keyboardType: TextInputType.phone,

  maxLength: 10,

  inputFormatters: [

    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(10),
  ],


  style:

  const TextStyle(

    color: Colors.white,

  ),


  decoration:

  inputDecoration(

    "Mobile Number",

    Icons.phone,

  ).copyWith(

    counterText: "",

  ),

),





                  const SizedBox(height:15),





                  TextField(


                    controller:

                    passwordController,


                    obscureText:true,


                    style:

                    const TextStyle(

                      color:Colors.white,

                    ),




                    decoration:

                    inputDecoration(

                      "Password",

                      Icons.lock,

                    ),



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

                      login,





                      child:


                      isLoading


                      ?


                      const CircularProgressIndicator(

                        color:Colors.black,

                      )



                      :


                      const Text(

                        "LOGIN",


                        style:

                        TextStyle(

                          color:Colors.black,

                          fontWeight:FontWeight.bold,

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

                        "New User? ",

                        style:

                        TextStyle(

                          color:Colors.white70,

                        ),

                      ),





                      GestureDetector(


                        onTap:(){


                          Navigator.push(


                            context,


                            MaterialPageRoute(


                              builder:(context)=>

                              const RegisterScreen(),


                            ),


                          );


                        },



                        child:

                        const Text(


                          "Register",



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






  InputDecoration inputDecoration(

      String hint,

      IconData icon

      ){



    return InputDecoration(



      hintText:hint,


      hintStyle:

      const TextStyle(

        color:Colors.white54,

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



    );


  }



}