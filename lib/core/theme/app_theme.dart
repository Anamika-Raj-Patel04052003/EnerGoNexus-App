import 'package:flutter/material.dart';
import '../constants/app_colors.dart';


class AppTheme {


static ThemeData darkTheme = ThemeData(

  brightness: Brightness.dark,

  scaffoldBackgroundColor:
      AppColors.background,


  colorScheme:
      ColorScheme.fromSeed(

    seedColor:
        AppColors.primaryGreen,

    brightness:
        Brightness.dark,

  ),


  inputDecorationTheme:

  InputDecorationTheme(

    filled:true,

    fillColor:
        AppColors.card,


    border:
    OutlineInputBorder(

      borderRadius:
      BorderRadius.circular(18),

      borderSide:
      BorderSide.none,

    ),

  ),



  elevatedButtonTheme:

  ElevatedButtonThemeData(

    style:
    ElevatedButton.styleFrom(

      backgroundColor:
          AppColors.primaryGreen,

      foregroundColor:
          Colors.black,


      minimumSize:
          const Size(
              double.infinity,
              55
          ),


      shape:
      RoundedRectangleBorder(

        borderRadius:
        BorderRadius.circular(18),

      ),

    ),

  ),


);

}