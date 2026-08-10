import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';


class HomeHeader extends StatelessWidget {

  final String name;

  const HomeHeader({
    super.key,
    required this.name,
  });


  @override
  Widget build(BuildContext context) {

    return Row(

      mainAxisAlignment:
      MainAxisAlignment.spaceBetween,


      children: [


        Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,


          children: [


            Text(

              "Hello, $name 👋",

              style: const TextStyle(

                color: Colors.white,

                fontSize: 26,

                fontWeight: FontWeight.bold,

              ),

            ),



            const SizedBox(height: 6),



            const Text(

              "Your smart EV journey starts here",

              style: TextStyle(

                color: Colors.white70,

                fontSize: 14,

              ),

            ),



          ],

        ),




        Container(

          height:45,

          width:45,


          decoration: BoxDecoration(

            color:
            AppColors.card,


            borderRadius:
            BorderRadius.circular(15),

          ),



          child: const Icon(

            Icons.notifications_none,

            color:
            AppColors.primaryGreen,

          ),


        )

      ],

    );

  }

}