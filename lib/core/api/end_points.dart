class EndPoints {
  static const String baseUrl = 'https://food-api-omega.vercel.app/api/v1/';

  static const String signIn = 'user/signin';
  static const String signUp = 'user/signup';
  static String getUserDataEndPoint(id) {
    return "user/get-user/$id";
  }

  static const String upDateUserData = 'user/update';
}

class ApiKey {
  static const String user = 'user';
  static const String status = 'status';
  static const String message = 'message';
  static const String errorMessage = 'ErrorMessage';
  static const String error = 'Error';
  static const String email = 'email';
  static const String password = 'password';

  static const String token = 'token';
  static const String id = 'id';
  static const String name = 'name';
  static const String phone = 'phone';
  static const String confirmPassword = 'confirmPassword';
  static const String location = 'location';
  static const String profilePic = 'profilePic';
}
