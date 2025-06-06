import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masrtiongapi/core/api/dio_consumer.dart';
import 'package:masrtiongapi/core/cache/cache_helper.dart';
import 'package:masrtiongapi/cubit/user_cubit.dart';
import 'package:masrtiongapi/repos/user_repo.dart';
import 'package:masrtiongapi/screens/sign_in_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  CacheHelper().init();
  runApp(
    BlocProvider(
      create: (context) =>
          UserCubit(UserRepo(apiConsumer: DioConsumer(dio: Dio()))),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignInScreen(),
    );
  }
}
