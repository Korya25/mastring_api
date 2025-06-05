import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:masrtiongapi/core/api/api_consumer.dart';
import 'package:masrtiongapi/core/api/end_points.dart';
import 'package:masrtiongapi/core/cache/cache_helper.dart';
import 'package:masrtiongapi/core/errors/exceptions.dart';
import 'package:masrtiongapi/core/functions/upload_image.to_api.dart';
import 'package:masrtiongapi/models/sign_in_model.dart';
import 'package:masrtiongapi/models/sign_up_model.dart';
import 'package:masrtiongapi/models/update_data.dart';
import 'package:masrtiongapi/models/user_model.dart';

class UserRepo {
  final ApiConsumer apiConsumer;

  UserRepo({required this.apiConsumer});

  Future<Either<String, SignInModel>> signIn({
    required String email,
    required String pass,
  }) async {
    try {
      final response = await apiConsumer.post(
        EndPoints.signIn,
        data: {ApiKey.email: email, ApiKey.password: pass},
      );
      final user = SignInModel.fromJson(response);
      final decodedToken = JwtDecoder.decode(user.token);
      await CacheHelper().saveData(key: ApiKey.token, value: user.token);
      await CacheHelper().saveData(
        key: ApiKey.id,
        value: decodedToken[ApiKey.id],
      );
      return Right(user);
    } on ServerException catch (e) {
      return Left(e.errorModel.errorMessage);
    }
  }

  Future<Either<String, SignUpModel>> signUp({
    required String name,
    required String email,
    required String pass,
    required String phone,
    required String confirmpass,
    required XFile profilePic,
  }) async {
    try {
      final response = await apiConsumer.post(
        EndPoints.signUp,
        isFromData: true,
        data: {
          ApiKey.name: name,
          ApiKey.email: email,
          ApiKey.phone: phone,
          ApiKey.password: pass,
          ApiKey.confirmPassword: confirmpass,
          ApiKey.profilePic: await uploadImageToApi(profilePic),
          ApiKey.location:
              '{"name":"methalfa","address":"meet halfa","coordinates":[30.1572709,31.224779]}',
        },
      );
      final signUpModel = SignUpModel.fromjson(response);
      return Right(signUpModel);
    } on ServerException catch (e) {
      return Left(e.errorModel.errorMessage);
    }
  }

  Future<Either<String, UserModel>> getUserProfile() async {
    try {
      final response = await apiConsumer.get(
        EndPoints.getUserDataEndPoint(CacheHelper().getData(key: ApiKey.id)),
      );
      return Right(UserModel.fromjson(response));
    } on ServerException catch (e) {
      return Left(e.errorModel.errorMessage);
    }
  }

  Future<Either<String, UpdateDataModel>> upDateUserData({
    required String name,
  }) async {
    try {
      final response = await apiConsumer.patch(
        EndPoints.upDateUserData,
        isFromData: true,
        data: {
          ApiKey.name: name,
          ApiKey.phone: '01065171195',
          ApiKey.location:
              '{"name":"Egypt","address":"meet halfa","coordinates":[1214451511,12541845]}',
        },
      );
      return Right(UpdateDataModel.fromjson(response));
    } on ServerException catch (e) {
      return left(e.errorModel.errorMessage);
    }
  }
}
