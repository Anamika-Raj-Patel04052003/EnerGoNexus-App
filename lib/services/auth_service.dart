import 'api_service.dart';


class AuthService {


  static Future<bool> isLoggedIn() async {


    String? token =

    await ApiService.getToken();



    if(token != null && token.isNotEmpty){

      return true;

    }


    return false;


  }



}