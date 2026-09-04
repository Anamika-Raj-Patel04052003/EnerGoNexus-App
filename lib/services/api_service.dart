import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ============================================================
  // BASE URL
  // ============================================================

  static const String baseUrl =
      "http://127.0.0.1:8000/api";

  // ============================================================
  // COMMON HEADERS
  // ============================================================

  static Map<String, String> jsonHeaders() {
    return {
      "Accept": "application/json",
      "Content-Type": "application/json",
    };
  }

  static Map<String, String> authHeaders(
    String token,
  ) {
    return {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // ============================================================
  // REGISTER USER
  // ============================================================

  static Future<Map<String, dynamic>> registerUser({
    required String fullName,
    required String mobileNumber,
    required String email,
    required String password,
    required String city,
    required String state,
    String? referralCode,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
          "$baseUrl/register",
        ),
        headers: jsonHeaders(),
        body: jsonEncode({
          "full_name": fullName,
          "mobile_number": mobileNumber,
          "email": email,
          "password": password,
          "city": city,
          "state": state,
          "referral_code": referralCode,
        }),
      );

      return _decodeResponse(response);
    } catch (e) {
      return {
        "status": false,
        "message": "Unable to connect to server",
        "error": e.toString(),
      };
    }
  }

  // ============================================================
  // LOGIN USER
  // ============================================================

  static Future<Map<String, dynamic>> loginUser({
    required String mobileNumber,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
          "$baseUrl/login",
        ),
        headers: jsonHeaders(),
        body: jsonEncode({
          "mobile_number": mobileNumber,
          "password": password,
        }),
      );

      final data =
          _decodeResponse(response);

      // --------------------------------------------------------
      // SAVE JWT TOKEN
      // --------------------------------------------------------

      if (data["status"] == true) {
        final token = data["token"];

        if (token != null &&
            token.toString().isNotEmpty) {
          await saveToken(
            token.toString(),
          );
        }
      }

      return data;
    } catch (e) {
      return {
        "status": false,
        "message": "Unable to connect to server",
        "error": e.toString(),
      };
    }
  }

  // ============================================================
  // SAVE TOKEN
  // ============================================================

  static Future<void> saveToken(
    String token,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      "token",
      token,
    );
  }

  // ============================================================
  // GET TOKEN
  // ============================================================

  static Future<String?> getToken() async {
    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getString(
      "token",
    );
  }

  // ============================================================
  // CHECK LOGIN
  // ============================================================

  static Future<bool> isLoggedIn() async {
    final token =
        await getToken();

    return token != null &&
        token.isNotEmpty;
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  static Future<void> logout() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(
      "token",
    );

    await prefs.remove(
      "passenger_id",
    );
  }

  // ============================================================
  // PROFILE
  // ============================================================

  static Future<Map<String, dynamic>>
      getProfile() async {
    try {
      final token =
          await getToken();

      if (token == null ||
          token.isEmpty) {
        return {
          "status": false,
          "message": "User is not logged in",
        };
      }

      final response =
          await http.get(
        Uri.parse(
          "$baseUrl/profile",
        ),
        headers:
            authHeaders(token),
      );

      return _decodeResponse(
        response,
      );
    } catch (e) {
      return {
        "status": false,
        "message": "Unable to connect to server",
        "error": e.toString(),
      };
    }
  }

  // ============================================================
  // REGISTER PASSENGER
  // ============================================================

  static Future<Map<String, dynamic>>
      registerPassenger({
    required dynamic userId,
    required String fullName,
    required String mobileNumber,
    required String email,
  }) async {
    try {
      final response =
          await http.post(
        Uri.parse(
          "$baseUrl/passenger/register",
        ),
        headers:
            jsonHeaders(),
        body:
            jsonEncode({
          "user_id": userId,
          "full_name": fullName,
          "mobile_number": mobileNumber,
          "email": email,
        }),
      );

      return _decodeResponse(
        response,
      );
    } catch (e) {
      return {
        "status": false,
        "message":
            "Unable to connect to server",
        "error": e.toString(),
      };
    }
  }

  // ============================================================
  // GET ALL PASSENGERS
  // ============================================================

  static Future<Map<String, dynamic>>
      getPassengers() async {
    try {
      final response =
          await http.get(
        Uri.parse(
          "$baseUrl/passengers",
        ),
        headers: {
          "Accept":
              "application/json",
        },
      );

      return _decodeResponse(
        response,
      );
    } catch (e) {
      return {
        "status": false,
        "message":
            "Unable to connect to server",
        "error": e.toString(),
      };
    }
  }

  // ============================================================
  // SAVE PASSENGER ID
  // ============================================================

  static Future<void>
      savePassengerId(
    dynamic passengerId,
  ) async {
    if (passengerId == null) {
      return;
    }

    final id =
        int.tryParse(
      passengerId.toString(),
    );

    if (id == null) {
      return;
    }

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setInt(
      "passenger_id",
      id,
    );
  }

  // ============================================================
  // GET PASSENGER ID
  // ============================================================

  static Future<int?>
      getPassengerId() async {
    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getInt(
      "passenger_id",
    );
  }

  // ============================================================
  // ENSURE PASSENGER PROFILE
  // ============================================================
  //
  // IMPORTANT:
  //
  // Existing passenger ko:
  //
  // 1. user_id
  // 2. mobile_number
  // 3. email
  //
  // ke through search karega.
  //
  // Existing mil gaya -> ID save.
  //
  // Sirf agar truly nahi mila tab create karega.
  //
  // ============================================================

  static Future<Map<String, dynamic>>
      ensurePassengerProfile({
    required dynamic userId,
    required String fullName,
    required String mobileNumber,
    required String email,
  }) async {
    try {
      if (userId == null) {
        return {
          "status": false,
          "message": "User ID not found",
        };
      }

      print(
        "========================================",
      );

      print(
        "       PASSENGER PROFILE CHECK",
      );

      print(
        "========================================",
      );

      print(
        "USER ID: $userId",
      );

      print(
        "MOBILE: $mobileNumber",
      );

      print(
        "EMAIL: $email",
      );

      // ========================================================
      // GET PASSENGERS
      // ========================================================

      final response =
          await getPassengers();

      print(
        "PASSENGER LIST RESPONSE:",
      );

      print(
        response,
      );

      if (response["status"] != true) {
        return {
          "status": false,
          "message":
              response["message"] ??
                  "Unable to get passengers",
        };
      }

      final passengers =
          response["passengers"];

      if (passengers is! List) {
        return {
          "status": false,
          "message":
              "Invalid passenger list received",
        };
      }

      // ========================================================
      // STEP 1
      // FIND BY USER ID
      // ========================================================

      for (final passenger
          in passengers) {
        if (passenger is! Map) {
          continue;
        }

        final existingUserId =
            passenger["user_id"];

        if (existingUserId != null &&
            existingUserId.toString() ==
                userId.toString()) {
          final passengerId =
              passenger["id"];

          if (passengerId != null) {
            await savePassengerId(
              passengerId,
            );

            print(
              "PASSENGER FOUND BY USER ID",
            );

            print(
              "PASSENGER ID: $passengerId",
            );

            print(
              "========================================",
            );

            return {
              "status": true,
              "message":
                  "Passenger profile found",
              "passenger": passenger,
            };
          }
        }
      }

      // ========================================================
      // STEP 2
      // FIND BY MOBILE NUMBER
      // ========================================================

      for (final passenger
          in passengers) {
        if (passenger is! Map) {
          continue;
        }

        final existingMobile =
            passenger["mobile_number"];

        if (existingMobile != null &&
            existingMobile
                    .toString()
                    .trim() ==
                mobileNumber
                    .trim()) {
          final passengerId =
              passenger["id"];

          if (passengerId != null) {
            await savePassengerId(
              passengerId,
            );

            print(
              "PASSENGER FOUND BY MOBILE",
            );

            print(
              "PASSENGER ID: $passengerId",
            );

            print(
              "========================================",
            );

            return {
              "status": true,
              "message":
                  "Passenger profile found",
              "passenger": passenger,
            };
          }
        }
      }

      // ========================================================
      // STEP 3
      // FIND BY EMAIL
      // ========================================================

      for (final passenger
          in passengers) {
        if (passenger is! Map) {
          continue;
        }

        final existingEmail =
            passenger["email"];

        if (existingEmail != null &&
            existingEmail
                    .toString()
                    .trim()
                    .toLowerCase() ==
                email
                    .trim()
                    .toLowerCase()) {
          final passengerId =
              passenger["id"];

          if (passengerId != null) {
            await savePassengerId(
              passengerId,
            );

            print(
              "PASSENGER FOUND BY EMAIL",
            );

            print(
              "PASSENGER ID: $passengerId",
            );

            print(
              "========================================",
            );

            return {
              "status": true,
              "message":
                  "Passenger profile found",
              "passenger": passenger,
            };
          }
        }
      }

      // ========================================================
      // NOT FOUND
      // CREATE PASSENGER
      // ========================================================

      print(
        "PASSENGER NOT FOUND",
      );

      print(
        "CREATING PASSENGER PROFILE...",
      );

      final createResponse =
          await registerPassenger(
        userId: userId,
        fullName: fullName,
        mobileNumber:
            mobileNumber,
        email: email,
      );

      print(
        "PASSENGER CREATE RESPONSE:",
      );

      print(
        createResponse,
      );

      if (createResponse["status"] ==
          true) {
        final passenger =
            createResponse["passenger"];

        if (passenger is Map &&
            passenger["id"] != null) {
          await savePassengerId(
            passenger["id"],
          );

          print(
            "NEW PASSENGER ID: ${passenger["id"]}",
          );
        }
      }

      print(
        "========================================",
      );

      return createResponse;
    } catch (e) {
      print(
        "ENSURE PASSENGER ERROR: $e",
      );

      return {
        "status": false,
        "message":
            "Unable to prepare passenger profile",
        "error": e.toString(),
      };
    }
  }

  // ============================================================
  // PREPARE PASSENGER PROFILE
  // ============================================================
  //
  // Current logged-in User ko profile se read karta hai.
  //
  // ============================================================

  static Future<Map<String, dynamic>>
      preparePassengerProfile() async {
    try {
      final profile =
          await getProfile();

      print(
        "PROFILE RESPONSE:",
      );

      print(
        profile,
      );

      if (profile["status"] != true) {
        return {
          "status": false,
          "message":
              profile["message"] ??
                  "Unable to get user profile",
        };
      }

      final user =
          profile["user"];

      if (user is! Map) {
        return {
          "status": false,
          "message":
              "User profile not found",
        };
      }

      final userId =
          user["id"];

      if (userId == null) {
        return {
          "status": false,
          "message":
              "User ID not found",
        };
      }

      return await ensurePassengerProfile(
        userId: userId,
        fullName:
            user["full_name"]
                    ?.toString() ??
                "",
        mobileNumber:
            user["mobile_number"]
                    ?.toString() ??
                "",
        email:
            user["email"]
                    ?.toString() ??
                "",
      );
    } catch (e) {
      return {
        "status": false,
        "message":
            "Unable to prepare passenger profile",
        "error": e.toString(),
      };
    }
  }

  // ============================================================
  // BOOK RIDE
  // ============================================================

static Future<Map<String, dynamic>> bookRide({
  required String pickup,
  required String destination,
  required String vehicleType,
  required double distance,
  required double fare,
  required int serviceTypeId,
  required int vehicleCategoryId,
}) async {
  try {
      // ========================================================
      // TOKEN
      // ========================================================

      final token =
          await getToken();

      if (token == null ||
          token.isEmpty) {
        return {
          "status": false,
          "message":
              "User is not logged in",
        };
      }

      // ========================================================
      // PASSENGER ID
      // ========================================================

      int? passengerId =
          await getPassengerId();

      print(
        "========================================",
      );

      print(
        "             BOOK RIDE DEBUG",
      );

      print(
        "========================================",
      );

      print(
        "TOKEN: FOUND",
      );

      print(
        "SAVED PASSENGER ID: $passengerId",
      );

      // ========================================================
      // PASSENGER ID NOT SAVED
      // PREPARE IT NOW
      // ========================================================

      if (passengerId == null) {
        print(
          "PASSENGER ID NOT FOUND LOCALLY",
        );

        final passengerResponse =
            await preparePassengerProfile();

        print(
          "PASSENGER PREPARATION RESPONSE:",
        );

        print(
          passengerResponse,
        );

        if (passengerResponse["status"] !=
            true) {
          return {
            "status": false,
            "message":
                passengerResponse[
                        "message"] ??
                    "Passenger profile not available",
          };
        }

        // ------------------------------------------------------
        // Read saved ID again
        // ------------------------------------------------------

        passengerId =
            await getPassengerId();

        // ------------------------------------------------------
        // Fallback
        // ------------------------------------------------------

        if (passengerId == null) {
          final passenger =
              passengerResponse[
                  "passenger"];

          if (passenger is Map &&
              passenger["id"] != null) {
            passengerId =
                int.tryParse(
              passenger["id"]
                  .toString(),
            );

            if (passengerId != null) {
              await savePassengerId(
                passengerId,
              );
            }
          }
        }
      }

      // ========================================================
      // FINAL CHECK
      // ========================================================

      if (passengerId == null) {
        print(
          "FINAL PASSENGER ID: NULL",
        );

        return {
          "status": false,
          "message":
              "Passenger profile not available",
        };
      }

      print(
        "PASSENGER ID: $passengerId",
      );

      print(
        "PICKUP: $pickup",
      );

      print(
        "DESTINATION: $destination",
      );

      print(
        "DISTANCE: $distance",
      );

      print(
        "FARE: $fare",
      );

      print(
        "VEHICLE TYPE: $vehicleType",
      );

      // ========================================================
      // BACKEND REQUEST BODY
      // ========================================================


final requestBody = {

"passenger_id": passengerId,

"service_type_id": serviceTypeId,

"vehicle_category_id": vehicleCategoryId,

"pickup_location": pickup.trim(),

"destination": destination.trim(),

"distance_km": distance,

"estimated_fare": fare,

};

      print(
        "REQUEST BODY:",
      );

      print(
        jsonEncode(requestBody),
      );

      // ========================================================
      // API REQUEST
      // ========================================================

      final response =
          await http.post(
        Uri.parse(
          "$baseUrl/ride/book",
        ),
        headers:
            authHeaders(token),
        body:
            jsonEncode(requestBody),
      );

      final data =
          _decodeResponse(
        response,
      );

      // ========================================================
      // DEBUG RESPONSE
      // ========================================================

      print(
        "BOOK RIDE STATUS: ${response.statusCode}",
      );

      print(
        "BOOK RIDE RESPONSE:",
      );

      print(
        response.body,
      );

      print(
        "========================================",
      );

      return data;
    } catch (e) {
      print(
        "BOOK RIDE EXCEPTION: $e",
      );

      return {
        "status": false,
        "message":
            "Unable to connect to server",
        "error": e.toString(),
      };
    }
  }

  // ============================================================
  // GET ALL RIDES
  // ============================================================

  static Future<Map<String, dynamic>>
      getRides() async {
    try {
      final token =
          await getToken();

      if (token == null ||
          token.isEmpty) {
        return {
          "status": false,
          "message":
              "User is not logged in",
        };
      }

      final response =
          await http.get(
        Uri.parse(
          "$baseUrl/rides",
        ),
        headers:
            authHeaders(token),
      );

      return _decodeResponse(
        response,
      );
    } catch (e) {
      return {
        "status": false,
        "message":
            "Unable to connect to server",
        "error": e.toString(),
      };
    }
  }

  // GET PASSENGER RIDES

static Future<Map<String, dynamic>> getPassengerRides(
    dynamic passengerId
) async {

  try {

    final token = await getToken();

     if(token == null || token.isEmpty){

    return {
      "status":false,
      "message":"User is not logged in"
    };

  }

    final response = await http.get(
      Uri.parse(
        "$baseUrl/passenger/rides/$passengerId"
      ),
      headers: authHeaders(token),
    );


    return _decodeResponse(response);


  } catch(e) {

    return {
      "status":false,
      "message":e.toString()
    };

  }

}

  // ============================================================
  // GET SINGLE RIDE
  // ============================================================

  static Future<Map<String, dynamic>>
      getRide(
    dynamic rideId,
  ) async {
    try {
      final token =
          await getToken();

      if (token == null ||
          token.isEmpty) {
        return {
          "status": false,
          "message":
              "User is not logged in",
        };
      }

      if (rideId == null) {
        return {
          "status": false,
          "message":
              "Ride ID is required",
        };
      }

      final response =
          await http.get(
        Uri.parse(
          "$baseUrl/ride/$rideId",
        ),
        headers:
            authHeaders(token),
      );

      return _decodeResponse(
        response,
      );
    } catch (e) {
      return {
        "status": false,
        "message":
            "Unable to connect to server",
        "error": e.toString(),
      };
    }
  }

  // ============================================================
  // GET PASSENGER
  // ============================================================

  static Future<Map<String, dynamic>>
      getPassenger(
    dynamic passengerId,
  ) async {
    try {
      final token =
          await getToken();

      if (token == null ||
          token.isEmpty) {
        return {
          "status": false,
          "message":
              "User is not logged in",
        };
      }

      if (passengerId == null) {
        return {
          "status": false,
          "message":
              "Passenger ID is required",
        };
      }

      final response =
          await http.get(
        Uri.parse(
          "$baseUrl/passenger/$passengerId",
        ),
        headers:
            authHeaders(token),
      );

      return _decodeResponse(
        response,
      );
    } catch (e) {
      return {
        "status": false,
        "message":
            "Unable to connect to server",
        "error": e.toString(),
      };
    }
  }


  static Future<Map<String, dynamic>> autoAssignRide(
    dynamic rideId
) async {

  try {

    final token = await getToken();

    if(token == null || token.isEmpty){
      return {
        "status": false,
        "message": "User is not logged in"
      };
    }


    final response = await http.put(

      Uri.parse(
        "$baseUrl/ride/$rideId/auto-assign"
      ),

      headers: authHeaders(token),

    );


    final data = _decodeResponse(response);


    print("AUTO ASSIGN STATUS: ${response.statusCode}");

    print("AUTO ASSIGN RESPONSE:");

    print(response.body);


    return data;


  } catch(e){

    return {
      "status": false,
      "message": "Unable to assign driver",
      "error": e.toString()
    };

  }

}


// ============================================================
// DRIVER ARRIVED
// ============================================================

static Future<Map<String,dynamic>> rideArrived(
    dynamic rideId
) async {

  try {

    final token = await getToken();

    if(token == null || token.isEmpty){
      return {
        "status":false,
        "message":"User not logged in"
      };
    }


    final response = await http.put(

      Uri.parse(
        "$baseUrl/ride/$rideId/arrived"
      ),

      headers: authHeaders(token),

    );


    return _decodeResponse(response);


  }catch(e){

    return {

      "status":false,
      "message":"Unable to update ride status",
      "error":e.toString()

    };

  }

}





// ============================================================
// START RIDE
// ============================================================


static Future<Map<String,dynamic>> startRide(
    dynamic rideId
) async {


 try {


  final token = await getToken();


  if(token == null || token.isEmpty){

    return {
      "status":false,
      "message":"User not logged in"
    };

  }



  final response = await http.put(

    Uri.parse(
      "$baseUrl/ride/$rideId/start"
    ),

    headers: authHeaders(token),

  );


  return _decodeResponse(response);



 }catch(e){


  return {

   "status":false,
   "message":"Unable to start ride",
   "error":e.toString()

  };


 }


}





// ============================================================
// COMPLETE RIDE
// ============================================================


static Future<Map<String,dynamic>> completeRide(

 dynamic rideId,
 double finalFare

) async {



try{


final token = await getToken();


if(token == null || token.isEmpty){

 return {

  "status":false,
  "message":"User not logged in"

 };

}




final response = await http.put(

 Uri.parse(

   "$baseUrl/ride/$rideId/complete"

 ),


 headers:authHeaders(token),


 body:jsonEncode({

   "final_fare":finalFare

 })

);



return _decodeResponse(response);



}catch(e){


return {

 "status":false,
 "message":"Unable to complete ride",
 "error":e.toString()

};
}
}

// ============================================================
// DRIVER RIDE REQUESTS
// ============================================================

static Future<Map<String,dynamic>> getDriverRideRequests() async {

  try {

    final token = await getToken();


    if(token == null || token.isEmpty){

      return {
        "status":false,
        "message":"User not logged in"
      };

    }


    final response = await http.get(

      Uri.parse(
        "$baseUrl/driver/ride-requests"
      ),

      headers: authHeaders(token),

    );


    return _decodeResponse(response);


  }catch(e){

    return {

      "status":false,

      "message":
      "Unable to fetch ride requests",

      "error":
      e.toString()

    };

  }

}

// ==========================================================
// DRIVER ACTIVE RIDE
// ==========================================================

static Future<Map<String,dynamic>> getDriverActiveRide() async {

  try {


    final token = await getToken();


    if(token == null){

      return {

        "status":false,

        "message":"Unauthenticated"

      };

    }



    final response = await http.get(

      Uri.parse(
        "$baseUrl/driver/active-ride"
      ),


      headers: {

        "Authorization":
        "Bearer $token",


        "Accept":
        "application/json",

      },

    );



    return jsonDecode(response.body);

  }

  catch(e){


    return {

      "status":false,

      "message":e.toString(),

    };


  }

}

// ============================================================
// ACCEPT RIDE REQUEST
// ============================================================

static Future<Map<String,dynamic>> acceptRideRequest(
    dynamic requestId
) async {


  try {


    final token = await getToken();


    if(token == null || token.isEmpty){

      return {
        "status":false,
        "message":"User not logged in"
      };

    }



    final response = await http.put(

      Uri.parse(
        "$baseUrl/ride-request/$requestId/accept"
      ),

      headers: authHeaders(token),

    );



    return _decodeResponse(response);



  }catch(e){

    return {

      "status":false,

      "message":
      "Unable to accept ride",

      "error":
      e.toString()

    };

  }


}


// ============================================================
// REJECT RIDE REQUEST
// ============================================================

static Future<Map<String,dynamic>> rejectRideRequest(
    dynamic requestId
) async {


  try {


    final token = await getToken();


    if(token == null || token.isEmpty){

      return {
        "status":false,
        "message":"User not logged in"
      };

    }



    final response = await http.put(

      Uri.parse(
        "$baseUrl/ride-request/$requestId/reject"
      ),

      headers: authHeaders(token),

    );




    return _decodeResponse(response);



  }catch(e){

    return {

      "status":false,

      "message":
      "Unable to reject ride",

      "error":
      e.toString()

    };

  }


}


// ============================================================
// GET PAYMENT RECEIPT
// ============================================================

static Future<Map<String, dynamic>> getPaymentReceipt(
  dynamic paymentId,
) async {

  try {

    final token = await getToken();

    if (token == null || token.isEmpty) {
      return {
        "status": false,
        "message": "User is not logged in",
      };
    }

    if (paymentId == null) {
      return {
        "status": false,
        "message": "Payment ID is required",
      };
    }

    final response = await http.get(
      Uri.parse(
        "$baseUrl/payment/receipt/$paymentId",
      ),
      headers: authHeaders(token),
    );

    return _decodeResponse(response);

  } catch (e) {

    return {
      "status": false,
      "message": "Unable to fetch payment receipt",
      "error": e.toString(),
    };

  }
}


static Future<Map<String, dynamic>>
    downloadPaymentReceipt(
  dynamic paymentId,
) async {
  try {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      return {
        "status": false,
        "message": "User is not logged in",
      };
    }

    if (paymentId == null) {
      return {
        "status": false,
        "message": "Payment ID is required",
      };
    }

    final response = await http.get(
      Uri.parse(
        "$baseUrl/payment/receipt/$paymentId/pdf",
      ),
      headers: authHeaders(token),
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return {
        "status": true,
        "bytes": response.bodyBytes,
        "content_type":
            response.headers["content-type"],
      };
    }

    return {
      "status": false,
      "message": "Unable to download receipt",
      "http_status": response.statusCode,
    };
  } catch (e) {
    return {
      "status": false,
      "message": "Unable to download receipt",
      "error": e.toString(),
    };
  }
}


// ============================================================
// RIDE PAYMENT
// ============================================================

static Future<Map<String, dynamic>> payRide({
  required dynamic rideId,
  required String paymentMethod,
}) async {

  try {

    final token = await getToken();

    if (token == null || token.isEmpty) {
      return {
        "status": false,
        "message": "User is not logged in",
      };
    }

    final response = await http.post(
      Uri.parse(
        "$baseUrl/payment/pay",
      ),
      headers: authHeaders(token),
      body: jsonEncode({
        "ride_id": rideId,
        "payment_method": paymentMethod,
      }),
    );

    return _decodeResponse(response);

  } catch (e) {

    return {
      "status": false,
      "message": "Unable to process payment",
      "error": e.toString(),
    };

  }
}


// ============================================================
// WALLET RIDE PAYMENT
// ============================================================

static Future<Map<String, dynamic>> walletPayRide({
  required dynamic rideId,
}) async {

  try {

    final token = await getToken();

    if (token == null || token.isEmpty) {
      return {
        "status": false,
        "message": "User is not logged in",
      };
    }

    final response = await http.post(
      Uri.parse(
        "$baseUrl/wallet/pay-ride",
      ),
      headers: authHeaders(token),
      body: jsonEncode({
        "ride_id": rideId,
      }),
    );

    return _decodeResponse(response);

  } catch (e) {

    return {
      "status": false,
      "message": "Unable to process wallet payment",
      "error": e.toString(),
    };

  }
}

// ============================================================
// CHARGING PAYMENT
// ============================================================

static Future<Map<String, dynamic>> chargingPayment({
  required dynamic chargingSessionId,
  required String paymentMethod,
}) async {

  try {

    final token = await getToken();

    if (token == null || token.isEmpty) {
      return {
        "status": false,
        "message": "User is not logged in",
      };
    }

    if (chargingSessionId == null) {
      return {
        "status": false,
        "message": "Charging session ID is required",
      };
    }

    final response = await http.post(
      Uri.parse(
        "$baseUrl/payment/charging",
      ),
      headers: authHeaders(token),
      body: jsonEncode({
        "charging_session_id": chargingSessionId,
        "payment_method": paymentMethod,
      }),
    );

    return _decodeResponse(response);

  } catch (e) {

    return {
      "status": false,
      "message": "Unable to process charging payment",
      "error": e.toString(),
    };
  }
}

// ============================================================
// GET MY WALLET
// ============================================================

static Future<Map<String, dynamic>> getWallet() async {
  try {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      return {
        "status": false,
        "message": "User is not logged in",
      };
    }

    final response = await http.post(
      Uri.parse(
        "$baseUrl/wallet/show",
      ),
      headers: authHeaders(token),
    );

    return _decodeResponse(response);
  } catch (e) {
    return {
      "status": false,
      "message": "Unable to fetch wallet",
      "error": e.toString(),
    };
  }
}


// ============================================================
// ADD MONEY TO WALLET
// ============================================================

static Future<Map<String, dynamic>> addMoneyToWallet({
  required double amount,
}) async {
  try {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      return {
        "status": false,
        "message": "User is not logged in",
      };
    }

    if (amount <= 0) {
      return {
        "status": false,
        "message": "Amount must be greater than zero",
      };
    }

    final response = await http.post(
      Uri.parse(
        "$baseUrl/wallet/add-money",
      ),
      headers: authHeaders(token),
      body: jsonEncode({
        "amount": amount,
      }),
    );

    final data = _decodeResponse(response);

    print(
      "WALLET ADD MONEY STATUS: ${response.statusCode}",
    );

    print(
      "WALLET ADD MONEY RESPONSE: ${response.body}",
    );

    return data;
  } catch (e) {
    return {
      "status": false,
      "message": "Unable to add money to wallet",
      "error": e.toString(),
    };
  }
}


// ============================================================
// GET WALLET TRANSACTION HISTORY
// ============================================================

static Future<Map<String, dynamic>> getWalletHistory() async {
  try {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      return {
        "status": false,
        "message": "User is not logged in",
      };
    }

   final response = await http.post(
  Uri.parse(
    "$baseUrl/wallet/history",
  ),
  headers: authHeaders(token),
);

    return _decodeResponse(response);
  } catch (e) {
    return {
      "status": false,
      "message": "Unable to fetch wallet history",
      "error": e.toString(),
    };
  }
}

  // ============================================================
  // COMMON RESPONSE DECODER
  // ============================================================

  static Map<String, dynamic>
      _decodeResponse(
    http.Response response,
  ) {
    if (response.body
        .trim()
        .isEmpty) {
      return {
        "status":
            response.statusCode >= 200 &&
                response.statusCode < 300,
        "message":
            "Empty server response",
        "http_status":
            response.statusCode,
      };
    }

    try {
      final decoded =
          jsonDecode(
        response.body,
      );

      if (decoded
          is Map<String, dynamic>) {
        decoded["http_status"] =
            response.statusCode;

        return decoded;
      }

      return {
        "status": false,
        "message":
            "Invalid server response",
        "http_status":
            response.statusCode,
      };
    } catch (e) {
      return {
        "status": false,
        "message":
            "Invalid JSON response",
        "http_status":
            response.statusCode,
        "raw_response":
            response.body,
      };
    }
  }


// ============================================================
// GET CHARGING STATIONS
// ============================================================

static Future<Map<String, dynamic>> getChargingStations() async {
  try {
    final response = await http.get(
      Uri.parse(
        "$baseUrl/stations",
      ),
      headers: {
        "Accept": "application/json",
      },
    );

    return _decodeResponse(response);
  } catch (e) {
    return {
      "status": false,
      "message": "Unable to fetch charging stations",
      "error": e.toString(),
    };
  }
}


// ============================================================
// GET CHARGING PORTS
// ============================================================

static Future<Map<String, dynamic>> getChargingPorts() async {
  try {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      return {
        "status": false,
        "message": "User is not logged in",
      };
    }

    final response = await http.get(
      Uri.parse("$baseUrl/ports"),
      headers: authHeaders(token),
    );

    final data = _decodeResponse(response);

    debugPrint(
      "CHARGING PORTS STATUS: ${response.statusCode}",
    );

    debugPrint(
      "CHARGING PORTS RESPONSE: ${response.body}",
    );

    return data;
  } catch (e) {
    return {
      "status": false,
      "message": "Unable to fetch charging ports",
      "error": e.toString(),
    };
  }
}

// ============================================================
// GET SINGLE CHARGING STATION
// ============================================================

static Future<Map<String, dynamic>> getChargingStation(
  dynamic stationId,
) async {
  try {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      return {
        "status": false,
        "message": "User is not logged in",
      };
    }

    if (stationId == null) {
      return {
        "status": false,
        "message": "Station ID is required",
      };
    }

    final response = await http.get(
      Uri.parse(
        "$baseUrl/station/$stationId",
      ),
      headers: authHeaders(token),
    );

    return _decodeResponse(response);
  } catch (e) {
    return {
      "status": false,
      "message": "Unable to fetch charging station",
      "error": e.toString(),
    };
  }
}


// ============================================================
// GET MY VEHICLES
// ============================================================

static Future<Map<String, dynamic>> getMyVehicles() async {
  try {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      return {
        "status": false,
        "message": "User is not logged in",
      };
    }

    final response = await http.get(
      Uri.parse(
        "$baseUrl/vehicles",
      ),
      headers: authHeaders(token),
    );

    return _decodeResponse(response);
  } catch (e) {
    return {
      "status": false,
      "message": "Unable to fetch vehicles",
      "error": e.toString(),
    };
  }
}


// ============================================================
// CREATE CHARGING BOOKING
// ============================================================

static Future<Map<String, dynamic>> createChargingBooking({
  required dynamic chargingStationId,
  required dynamic chargingPortId,
  required dynamic vehicleId,
  required String bookingDate,
  required String startTime,
  required String endTime,
}) async {
  try {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      return {
        "status": false,
        "message": "User is not logged in",
      };
    }

    final requestBody = {
      "charging_station_id": chargingStationId,
      "charging_port_id": chargingPortId,
      "vehicle_id": vehicleId,
      "booking_date": bookingDate,
      "start_time": startTime,
      "end_time": endTime,
    };

    print(
      "========================================",
    );

    print(
      "       CHARGING BOOKING REQUEST",
    );

    print(
      "========================================",
    );

    print(
      "REQUEST BODY:",
    );

    print(
      jsonEncode(requestBody),
    );

    final response = await http.post(
      Uri.parse(
        "$baseUrl/charging-booking",
      ),
      headers: authHeaders(token),
      body: jsonEncode(requestBody),
    );

    final data = _decodeResponse(response);

    print(
      "CHARGING BOOKING STATUS: ${response.statusCode}",
    );

    print(
      "CHARGING BOOKING RESPONSE:",
    );

    print(
      response.body,
    );

    print(
      "========================================",
    );

    return data;
  } catch (e) {
    print(
      "CHARGING BOOKING ERROR: $e",
    );

    return {
      "status": false,
      "message": "Unable to create charging booking",
      "error": e.toString(),
    };
  }
}


// ============================================================
// GET CHARGING BOOKING
// ============================================================

static Future<Map<String, dynamic>> getChargingBooking(
  dynamic bookingId,
) async {
  try {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      return {
        "status": false,
        "message": "User is not logged in",
      };
    }

    if (bookingId == null) {
      return {
        "status": false,
        "message": "Charging booking ID is required",
      };
    }

    final response = await http.get(
      Uri.parse(
        "$baseUrl/charging-booking/$bookingId",
      ),
      headers: authHeaders(token),
    );

    return _decodeResponse(response);
  } catch (e) {
    return {
      "status": false,
      "message": "Unable to fetch charging booking",
      "error": e.toString(),
    };
  }
}


// ============================================================
// START CHARGING SESSION
// ============================================================

static Future<Map<String, dynamic>> startChargingSession({
  required dynamic chargingBookingId,
}) async {
  try {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      return {
        "status": false,
        "message": "User is not logged in",
      };
    }

    if (chargingBookingId == null) {
      return {
        "status": false,
        "message": "Charging booking ID is required",
      };
    }

    final requestBody = {
      "charging_booking_id": chargingBookingId,
    };

    print(
      "========================================",
    );

    print(
      "       START CHARGING SESSION",
    );

    print(
      "========================================",
    );

    print(
      "REQUEST BODY:",
    );

    print(
      jsonEncode(requestBody),
    );

    final response = await http.post(
      Uri.parse(
        "$baseUrl/charging-session/start",
      ),
      headers: authHeaders(token),
      body: jsonEncode(requestBody),
    );

    final data = _decodeResponse(response);

    print(
      "CHARGING SESSION START STATUS: ${response.statusCode}",
    );

    print(
      "CHARGING SESSION START RESPONSE:",
    );

    print(
      response.body,
    );

    print(
      "========================================",
    );

    return data;
  } catch (e) {
    print(
      "START CHARGING SESSION ERROR: $e",
    );

    return {
      "status": false,
      "message": "Unable to start charging session",
      "error": e.toString(),
    };
  }
}


// ============================================================
// GET CHARGING SESSION
// ============================================================

static Future<Map<String, dynamic>> getChargingSession(
  dynamic sessionId,
) async {
  try {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      return {
        "status": false,
        "message": "User is not logged in",
      };
    }

    if (sessionId == null) {
      return {
        "status": false,
        "message": "Charging session ID is required",
      };
    }

    final response = await http.get(
      Uri.parse(
        "$baseUrl/charging-session/$sessionId",
      ),
      headers: authHeaders(token),
    );

    return _decodeResponse(response);
  } catch (e) {
    return {
      "status": false,
      "message": "Unable to fetch charging session",
      "error": e.toString(),
    };
  }
}


// ============================================================
// COMPLETE CHARGING SESSION
// ============================================================

static Future<Map<String, dynamic>> completeChargingSession({
  required dynamic sessionId,
  required double unitsConsumed,
}) async {
  try {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      return {
        "status": false,
        "message": "User is not logged in",
      };
    }

    if (sessionId == null) {
      return {
        "status": false,
        "message": "Charging session ID is required",
      };
    }

    if (unitsConsumed <= 0) {
      return {
        "status": false,
        "message": "Units consumed must be greater than zero",
      };
    }

    final requestBody = {
      "units_consumed": unitsConsumed,
    };

    print(
      "========================================",
    );

    print(
      "      COMPLETE CHARGING SESSION",
    );

    print(
      "========================================",
    );

    print(
      "SESSION ID: $sessionId",
    );

    print(
      "UNITS CONSUMED: $unitsConsumed",
    );

    print(
      "REQUEST BODY:",
    );

    print(
      jsonEncode(requestBody),
    );

    final response = await http.put(
      Uri.parse(
        "$baseUrl/charging-session/$sessionId/complete",
      ),
      headers: authHeaders(token),
      body: jsonEncode(requestBody),
    );

    final data = _decodeResponse(response);

    print(
      "CHARGING COMPLETE STATUS: ${response.statusCode}",
    );

    print(
      "CHARGING COMPLETE RESPONSE:",
    );

    print(
      response.body,
    );

    print(
      "========================================",
    );

    return data;
  } catch (e) {
    print(
      "COMPLETE CHARGING SESSION ERROR: $e",
    );

    return {
      "status": false,
      "message": "Unable to complete charging session",
      "error": e.toString(),
    };
  }
}


  
}