class RideModel {


  final int? id;

  final String pickup;

  final String destination;

  final String vehicleType;

  final double fare;

  final String status;



  RideModel({

    this.id,

    required this.pickup,

    required this.destination,

    required this.vehicleType,

    required this.fare,

    required this.status,

  });





  factory RideModel.fromJson(
      Map<String,dynamic> json
      ){


    return RideModel(


      id:

      json["id"],



      pickup:

      json["pickup_location"] ?? "",



      destination:

      json["destination"] ?? "",



      vehicleType:

      json["vehicle_type"] ?? "",



      fare:

      double.tryParse(

        json["estimated_fare"]
            .toString()

      ) ?? 0,



      status:

      json["status"] ?? "searching",


    );


  }




}