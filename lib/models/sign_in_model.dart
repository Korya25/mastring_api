import 'package:masrtiongapi/core/api/end_points.dart';

class SignInModel {
  final String message;
  final String token;

  SignInModel({required this.message, required this.token});
  factory SignInModel.fromJson(Map<String, dynamic> json) {
    return SignInModel(
      message: json[ApiKey.message],
      token: json[ApiKey.token],
    );
  }
}
