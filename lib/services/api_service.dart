import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';



class ApiService {


  // Laravel Backend URL

  static const String baseUrl =
       "http://127.0.0.1:8000/api";
        // "http://10.0.2.2:8000/api";


  // =========================
  // USER REGISTER
  // =========================


  static Future<dynamic> registerUser({

    required String fullName,

    required String mobileNumber,

    required String email,

    required String password,

    required String city,

    required String state,

    String? referralCode,

  }) async {



    try {



      var response = await http.post(


        Uri.parse(

          "$baseUrl/register",

        ),



        headers:{


          "Accept":"application/json",


          "Content-Type":"application/json",


        },



        body:jsonEncode({


          "full_name":fullName,


          "mobile_number":mobileNumber,


          "email":email,


          "password":password,


          "city":city,


          "state":state,


          "referral_code":referralCode,


        }),



      );




      return jsonDecode(response.body);



    }

    catch(e){


      return {


        "error":e.toString()


      };


    }


  }





  // =========================
  // USER LOGIN
  // =========================



  static Future<dynamic> loginUser({

    required String mobileNumber,

    required String password,


  }) async {



    try {



      var response = await http.post(



        Uri.parse(

          "$baseUrl/login",

        ),




        headers:{


          "Accept":"application/json",


          "Content-Type":"application/json",


        },



        body:jsonEncode({



          "mobile_number":mobileNumber,



          "password":password,


        }),



      );





      var data=jsonDecode(response.body);




      // Save JWT Token


      if(data["token"] != null){



        await saveToken(

          data["token"],

        );


      }




      return data;



    }



    catch(e){



      return {


        "error":e.toString()


      };



    }


  }






  // =========================
  // SAVE TOKEN
  // =========================



  static Future<void> saveToken(

      String token

      ) async {



    final prefs =

    await SharedPreferences.getInstance();



    await prefs.setString(

      "token",

      token,

    );


  }






  // =========================
  // GET TOKEN
  // =========================



  static Future<String?> getToken()

  async {



    final prefs =

    await SharedPreferences.getInstance();



    return prefs.getString(

      "token",

    );


  }







  // =========================
  // LOGOUT
  // =========================



  static Future<void> logout()

  async {



    final prefs =

    await SharedPreferences.getInstance();



    await prefs.remove(

      "token",

    );


  }


  // =========================
// GET USER PROFILE
// =========================


static Future<dynamic> getProfile() async {


  try{


    String? token = await getToken();



    var response = await http.get(


      Uri.parse(

        "$baseUrl/profile",

      ),



      headers:{


        "Accept":"application/json",


        "Authorization":

        "Bearer $token",


      },


    );



    return jsonDecode(response.body);



  }

  catch(e){


    return {

      "error":e.toString()

    };


  }


}


// =========================
// BOOK RIDE
// =========================


static Future<dynamic> bookRide({

  required String pickup,

  required String destination,

  required String vehicleType,

})

 async {


  try{


    String? token = await getToken();



    var response = await http.post(


      Uri.parse(

        "$baseUrl/ride/book",

      ),



      headers:{


        "Accept":"application/json",


        "Content-Type":"application/json",


        "Authorization":

        "Bearer $token",


      },



    body:jsonEncode({


  "passenger_id":1,


  "pickup_location":pickup,


  "destination":destination,


  "distance_km":5,


  "estimated_fare":120,


  "vehicle_type":vehicleType,


}),



    );



    return jsonDecode(response.body);



  }

  catch(e){


    return {


      "error":e.toString()


    };


  }


}


}