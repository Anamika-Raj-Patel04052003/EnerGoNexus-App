class RideModel {


  final String pickup;

  final String destination;

  final String status;




  RideModel({

    required this.pickup,

    required this.destination,

    required this.status,

  });




  factory RideModel.fromJson(

      Map<String,dynamic> json

      ){


    return RideModel(

      pickup:

      json["pickup_location"] ?? "",


      destination:

      json["destination"] ?? "",


      status:

      json["status"] ?? "",


    );


  }


}