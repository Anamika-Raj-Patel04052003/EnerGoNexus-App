class UserModel {


  final int? id;

  final String name;

  final String email;

  final String mobile;



  UserModel({

    this.id,

    required this.name,

    required this.email,

    required this.mobile,

  });





  factory UserModel.fromJson(

      Map<String,dynamic> json

      ){


    return UserModel(

      id: json["id"],

      name: json["full_name"] ?? "",

      email: json["email"] ?? "",

      mobile: json["mobile_number"] ?? "",

    );


  }



}