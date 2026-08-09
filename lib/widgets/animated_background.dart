// import 'package:flutter/material.dart';
// import '../core/constants/app_colors.dart';


// class AnimatedBackground extends StatefulWidget {

//   final Widget child;


//   const AnimatedBackground({

//     super.key,

//     required this.child,

//   });


//   @override
//   State<AnimatedBackground> createState() =>
//       _AnimatedBackgroundState();

// }



// class _AnimatedBackgroundState extends State<AnimatedBackground>
//     with SingleTickerProviderStateMixin {


//   late AnimationController controller;


//   @override
//   void initState(){

//     super.initState();


//     controller = AnimationController(

//       vsync:this,

//       duration:
//       const Duration(seconds:8),

//     )..repeat();

//   }



//   @override
//   void dispose(){

//     controller.dispose();

//     super.dispose();

//   }




//   @override
//   Widget build(BuildContext context){


//     return AnimatedBuilder(

//       animation:controller,


//       builder:(context,child){


//         return Container(

//           decoration:BoxDecoration(


//             gradient:

//             LinearGradient(

//               begin:

//               Alignment(

//                 -1 + controller.value,

//                 -1,

//               ),


//               end:

//               Alignment(

//                 1,

//                 1-controller.value,

//               ),


//               colors:[


//                 const Color(0xff020605),


//                 AppColors.darkGreen,


//                 const Color(0xff071F18),


//               ],

//             ),


//           ),


//           child: Stack(

//             children:[



//               Positioned(

//                 top:
//                 80 +

//                 (controller.value*40),


//                 left:
//                 40,


//                 child:Container(

//                   width:180,

//                   height:180,


//                   decoration:

//                   BoxDecoration(

//                     shape:
//                     BoxShape.circle,


//                     color:

//                     AppColors.primaryGreen
//                         .withOpacity(0.08),

//                   ),

//                 ),

//               ),




//               Positioned(

//                 bottom:
//                 60,


//                 right:
//                 30,


//                 child:Container(

//                   width:220,

//                   height:220,


//                   decoration:

//                   BoxDecoration(

//                     shape:
//                     BoxShape.circle,


//                     color:

//                     AppColors.primaryGreen
//                         .withOpacity(0.06),

//                   ),

//                 ),

//               ),



//               widget.child,


//             ],

//           ),


//         );


//       },


//     );


//   }

// }





import 'dart:math';

import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';



class AnimatedEVBackground extends StatefulWidget {

  final Widget child;


  const AnimatedEVBackground({

    super.key,

    required this.child,

  });


  @override
  State<AnimatedEVBackground> createState() =>
      _AnimatedEVBackgroundState();

}




class _AnimatedEVBackgroundState extends State<AnimatedEVBackground>
    with SingleTickerProviderStateMixin {



  late AnimationController controller;



  @override
  void initState(){

    super.initState();


    controller = AnimationController(

      vsync:this,

      duration:
      const Duration(seconds:10),

    )..repeat();


  }




  @override
  void dispose(){

    controller.dispose();

    super.dispose();

  }





  @override
  Widget build(BuildContext context){


    return AnimatedBuilder(

      animation:controller,


      builder:(context,child){


        return CustomPaint(

          painter:

          EnergyBackgroundPainter(

            controller.value,

          ),


          child:

          widget.child,


        );


      },


    );


  }


}





class EnergyBackgroundPainter extends CustomPainter {


  final double animation;


  EnergyBackgroundPainter(this.animation);



  @override
  void paint(Canvas canvas, Size size){



    // Dark base background

    final paint = Paint()
      ..shader = LinearGradient(

        colors:[

          const Color(0xff020605),

          const Color(0xff06251B),

          const Color(0xff00110D),

        ],

        begin:Alignment.topLeft,

        end:Alignment.bottomRight,

      ).createShader(
        Rect.fromLTWH(
            0,
            0,
            size.width,
            size.height
        ),
      );



    canvas.drawRect(

      Rect.fromLTWH(
          0,
          0,
          size.width,
          size.height
      ),

      paint,

    );





    // glowing waves

    for(int i=0;i<3;i++){


      final wavePaint = Paint()

        ..style = PaintingStyle.stroke

        ..strokeWidth = 2

        ..color = AppColors.primaryGreen
            .withOpacity(0.15);



      Path path = Path();



      double offset =
          animation * size.width;



      for(double x=0;x<=size.width;x++){


        double y =

            size.height * 0.65 +

            sin(
              (x / size.width * 2 * pi)
                  +
                  offset
            )

            *

            (40 + i*25)

            +

            i*30;



        if(x==0){

          path.moveTo(x,y);

        }

        else{

          path.lineTo(x,y);

        }


      }



      canvas.drawPath(

        path,

        wavePaint,

      );


    }





    // floating energy particles

    final particlePaint = Paint()

      ..color = AppColors.primaryGreen;



    Random random = Random(10);



    for(int i=0;i<35;i++){


      double x =
      random.nextDouble()*size.width;



      double y =
      random.nextDouble()*size.height;



      double radius =
      1 + random.nextDouble()*3;



      canvas.drawCircle(

        Offset(

          x,

          y + sin(animation*2*pi)*20,

        ),

        radius,

        particlePaint,

      );


    }




  }





  @override
  bool shouldRepaint(
      covariant CustomPainter oldDelegate
      ){

    return true;

  }



}