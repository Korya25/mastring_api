// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:masrtiongapi/core/api/api_consumer.dart';
import 'package:masrtiongapi/core/api/end_points.dart';
import 'package:masrtiongapi/core/cache/cache_helper.dart';
import 'package:masrtiongapi/core/errors/exceptions.dart';
import 'package:masrtiongapi/cubit/user_state.dart';
import 'package:masrtiongapi/models/sign_in_model.dart';

class UserCubit extends Cubit<UserState> {
  final ApiConsumer apiConsumer;
  UserCubit(this.apiConsumer) : super(UserInitial());
  //Sign in Form key
  GlobalKey<FormState> signInFormKey = GlobalKey();
  //Sign in email
  TextEditingController signInEmail = TextEditingController();
  //Sign in password
  TextEditingController signInPassword = TextEditingController();
  //Sign Up Form key
  GlobalKey<FormState> signUpFormKey = GlobalKey();
  //Profile Pic
  XFile? profilePic;
  //Sign up name
  TextEditingController signUpName = TextEditingController();
  //Sign up phone number
  TextEditingController signUpPhoneNumber = TextEditingController();
  //Sign up email
  TextEditingController signUpEmail = TextEditingController();
  //Sign up password
  TextEditingController signUpPassword = TextEditingController();
  //Sign up confirm password
  TextEditingController confirmPassword = TextEditingController();
  SignInModel? user;
  // sign In
  signIn() async {
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
      CacheHelper().saveData(key: ApiKey.token, value: user!.token);
      CacheHelper().saveData(key: ApiKey.id, value: decodedToken[ApiKey.id]);

      emit(SignInSuccess());
    } on ServerException catch (e) {
      emit(SignInFailure(errorMessage: e.errorModel.errorMessage));
    }
  }
}
