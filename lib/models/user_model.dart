import 'package:masrtiongapi/core/api/end_points.dart';

class UserModel {
  final String profilePic;
  final String email;
  final String name;
  final String phone;
  final Map<String, dynamic> adress;

  UserModel({
    required this.profilePic,
    required this.email,
    required this.name,
    required this.phone,
    required this.adress,
  });
  factory UserModel.fromjson(Map<String, dynamic> jsonData) {
    return UserModel(
      profilePic: jsonData[ApiKey.user][ApiKey.profilePic],
      email: jsonData[ApiKey.user][ApiKey.email],
      name: jsonData[ApiKey.user][ApiKey.name],
      phone: jsonData[ApiKey.user][ApiKey.phone],
      adress: jsonData[ApiKey.user][ApiKey.location],
    );
  }
}
