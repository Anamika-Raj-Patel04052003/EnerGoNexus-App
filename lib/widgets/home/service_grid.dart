import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_colors.dart';



class ServiceGrid extends StatelessWidget {


  final VoidCallback? onRideTap;

  final VoidCallback? onChargingTap;

  final VoidCallback? onParcelTap;

  final VoidCallback? onFacilityTap;



  const ServiceGrid({

    super.key,

    this.onRideTap,

    this.onChargingTap,

    this.onParcelTap,

    this.onFacilityTap,

  });



  @override
  Widget build(BuildContext context) {


    return GridView.count(


      crossAxisCount: 2,


      shrinkWrap: true,


      physics:

      const NeverScrollableScrollPhysics(),



      crossAxisSpacing: 15,


      mainAxisSpacing: 15,



      children: [



        serviceCard(

          title: "Ride",

          subtitle: "Book EV Ride",

          icon: LucideIcons.car,

          onTap: onRideTap,

        ),




        serviceCard(

          title: "Charging",

          subtitle: "Find Station",

          icon: LucideIcons.battery,

          onTap: onChargingTap,

        ),




        serviceCard(

          title: "Parcel",

          subtitle: "Send Package",

          icon: LucideIcons.packageOpen,

          onTap: onParcelTap,

        ),




        serviceCard(

          title: "Facility",

          subtitle: "EV Services",

          icon: LucideIcons.zap,

          onTap: onFacilityTap,

        ),



      ],



    );


  }







  Widget serviceCard({


    required String title,


    required String subtitle,


    required IconData icon,


    VoidCallback? onTap,


  }){


    return InkWell(


      onTap: onTap,


      borderRadius:

      BorderRadius.circular(22),



      child: Container(


        padding:

        const EdgeInsets.all(18),




        decoration: BoxDecoration(


          color:

          AppColors.card,



          borderRadius:

          BorderRadius.circular(22),




          border: Border.all(


            color:

            AppColors.primaryGreen

                .withOpacity(0.18),


          ),




          boxShadow: [



            BoxShadow(


              color:

              Colors.black

                  .withOpacity(0.25),



              blurRadius:15,


              offset:

              const Offset(0,6),


            ),



          ],



        ),





        child: Column(



          crossAxisAlignment:

          CrossAxisAlignment.start,



          children: [



            Container(


              height:45,


              width:45,



              decoration:

              BoxDecoration(



                color:

                AppColors.primaryGreen

                    .withOpacity(0.15),



                borderRadius:

                BorderRadius.circular(15),


              ),



              child:

              Icon(


                icon,


                color:

                AppColors.primaryGreen,


                size:24,


              ),



            ),




            const Spacer(),





            Text(


              title,



              style:

              const TextStyle(



                color:

                Colors.white,



                fontSize:17,



                fontWeight:

                FontWeight.bold,


              ),



            ),




            const SizedBox(height:5),




            Text(


              subtitle,



              style:

              const TextStyle(



                color:

                Colors.white54,



                fontSize:12,


              ),



            ),



          ],



        ),



      ),



    );


  }


}