import 'dart:convert';

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

  static Future<Map<String, dynamic>>
      bookRide({
    required String pickup,
    required String destination,
    required String vehicleType,
    required double distance,
    required double fare,
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
      //
      // Tumhare RideController ke according exactly:
      //
      // passenger_id
      // pickup_location
      // destination
      // distance_km
      // estimated_fare
      //
      // vehicle_type backend RideController mein required
      // nahi hai, isliye request mein nahi bhej rahe.
      //
      // ========================================================

      final requestBody = {
        "passenger_id":
            passengerId,

        "pickup_location":
            pickup.trim(),

        "destination":
            destination.trim(),

        "distance_km":
            distance,

        "estimated_fare":
            fare,
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
}