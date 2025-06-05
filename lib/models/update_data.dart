import 'package:masrtiongapi/core/api/end_points.dart';

class UpdateDataModel {
  final String message;

  UpdateDataModel({required this.message});
  factory UpdateDataModel.fromjson(Map<String, dynamic> jsonData) {
    return UpdateDataModel(message: jsonData[ApiKey.message]);
  }
}
