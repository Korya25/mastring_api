import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:masrtiongapi/cubit/user_state.dart';
import 'package:masrtiongapi/models/sign_in_model.dart';
import 'package:masrtiongapi/models/sign_up_model.dart';
import 'package:masrtiongapi/repos/user_repo.dart';

class UserCubit extends Cubit<UserState> {
  final UserRepo userRepo;
  UserCubit(this.userRepo) : super(UserInitial());

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
    emit(SignUpLoading());
    final response = await userRepo.signUp(
      name: signUpName.text,
      email: signUpEmail.text,
      pass: signUpPassword.text,
      phone: signUpPhoneNumber.text,
      confirmpass: confirmPassword.text,
      profilePic: profilePic!,
    );
    response.fold(
      (errorMessage) => emit(SignUpFailure(errorMessage: errorMessage)),
      (signUpModel) => emit(SignUpSuccess(message: signUpModel.message)),
    );
  }

  Future<void> signIn() async {
    emit(SignInLoading());
    final response = await userRepo.signIn(
      email: signInEmail.text,
      pass: signInPassword.text,
    );
    response.fold(
      (errorMessage) => emit(SignInFailure(errorMessage: errorMessage)),
      (signInModel) => emit(SignInSuccess()),
    );
  }

  Future<void> getUserProfile() async {
    emit(GetUserLoading());
    final response = await userRepo.getUserProfile();
    response.fold(
      (errorMessage) => emit(GetUserFailure(errorMessage: errorMessage)),
      (user) => emit(GetUserSuccess(user: user)),
    );
  }

  Future<void> upDateUserData() async {
    emit(UpDateUserDataLoading());
    final response = await userRepo.upDateUserData(name: upDateName.text);

    response.fold(
      (errorMessage) => emit(UpDateUserDataFailure(errorMessage: errorMessage)),
      (updateDataModel) async {
        emit(UpDateUserDataSuccess(updateDataModel: updateDataModel));
        await getUserProfile();
      },
    );
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
