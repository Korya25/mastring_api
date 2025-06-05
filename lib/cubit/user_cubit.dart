import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:masrtiongapi/core/api/api_consumer.dart';
import 'package:masrtiongapi/core/api/end_points.dart';
import 'package:masrtiongapi/core/cache/cache_helper.dart';
import 'package:masrtiongapi/core/errors/exceptions.dart';
import 'package:masrtiongapi/core/functions/upload_image.to_api.dart';
import 'package:masrtiongapi/cubit/user_state.dart';
import 'package:masrtiongapi/models/sign_in_model.dart';
import 'package:masrtiongapi/models/sign_up_model.dart';
import 'package:masrtiongapi/models/update_data.dart';
import 'package:masrtiongapi/models/user_model.dart';

class UserCubit extends Cubit<UserState> {
  final ApiConsumer apiConsumer;
  UserCubit(this.apiConsumer) : super(UserInitial());

  // Controllers
  GlobalKey<FormState> signInFormKey = GlobalKey();
  TextEditingController signInEmail = TextEditingController();
  TextEditingController signInPassword = TextEditingController();

  GlobalKey<FormState> signUpFormKey = GlobalKey();
  XFile? profilePic;
  TextEditingController signUpName = TextEditingController();
  TextEditingController signUpPhoneNumber = TextEditingController();
  TextEditingController signUpEmail = TextEditingController();
  TextEditingController signUpPassword = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();

  TextEditingController upDateName = TextEditingController();
  SignInModel? user;

  void clearUpdateFields() {
    upDateName.clear();
  }

  Future<void> uploadProfilePic(XFile image) async {
    profilePic = image;
    emit(UploadProfilePic());
  }

  Future<void> signUp() async {
    try {
      emit(SignUpLoading());
      final response = await apiConsumer.post(
        EndPoints.signUp,
        isFromData: true,
        data: {
          ApiKey.name: signUpName.text,
          ApiKey.email: signUpEmail.text,
          ApiKey.phone: signUpPhoneNumber.text,
          ApiKey.password: signUpPassword.text,
          ApiKey.confirmPassword: confirmPassword.text,
          ApiKey.profilePic: await uploadImageToApi(profilePic!),
          ApiKey.location:
              '{"name":"methalfa","address":"meet halfa","coordinates":[30.1572709,31.224779]}',
        },
      );
      final signUpModel = SignUpModel.fromjson(response);
      emit(SignUpSuccess(message: signUpModel.message));
    } on ServerException catch (e) {
      emit(SignUpFailure(errorMessage: e.errorModel.errorMessage));
    }
  }

  Future<void> signIn() async {
    try {
      emit(SignInLoading());
      final response = await apiConsumer.post(
        EndPoints.signIn,
        data: {
          ApiKey.email: signInEmail.text,
          ApiKey.password: signInPassword.text,
        },
      );
      user = SignInModel.fromJson(response);
      final decodedToken = JwtDecoder.decode(user!.token);
      await CacheHelper().saveData(key: ApiKey.token, value: user!.token);
      await CacheHelper().saveData(
        key: ApiKey.id,
        value: decodedToken[ApiKey.id],
      );
      emit(SignInSuccess());
      await getUserProfile();
    } on ServerException catch (e) {
      emit(SignInFailure(errorMessage: e.errorModel.errorMessage));
    }
  }

  Future<void> getUserProfile() async {
    try {
      emit(GetUserLoading());
      final response = await apiConsumer.get(
        EndPoints.getUserDataEndPoint(CacheHelper().getData(key: ApiKey.id)),
      );
      emit(GetUserSuccess(user: UserModel.fromjson(response)));
    } on ServerException catch (e) {
      emit(GetUserFailure(errorMessage: e.errorModel.errorMessage));
    }
  }

  Future<void> upDateUserData() async {
    try {
      emit(UpDateUserDataLoading());
      final response = await apiConsumer.patch(
        EndPoints.upDateUserData,
        isFromData: true,
        data: {
          ApiKey.name: upDateName.text,
          ApiKey.phone: '01126414087',
          ApiKey.location:
              '{"name":"Egypt","address":"meet halfa","coordinates":[1214451511,12541845]}',
        },
      );
      emit(
        UpDateUserDataSuccess(
          updateDataModel: UpdateDataModel.fromjson(response),
        ),
      );
      await getUserProfile(); // Refresh user data after update
    } on ServerException catch (e) {
      emit(UpDateUserDataFailure(errorMessage: e.errorModel.errorMessage));
    }
  }

  @override
  Future<void> close() {
    signInEmail.dispose();
    signInPassword.dispose();
    signUpName.dispose();
    signUpPhoneNumber.dispose();
    signUpEmail.dispose();
    signUpPassword.dispose();
    confirmPassword.dispose();
    upDateName.dispose();
    return super.close();
  }
}
