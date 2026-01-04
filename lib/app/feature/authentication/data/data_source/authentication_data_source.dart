import '../model/sign_up_model.dart';

abstract class AuthRemoteDataSource {
  Future<SignUpModel> signUp({
   required String email,
   required String fullName,
   required String password,
   required String phoneNumber,
  });

  Future<void> logout();
}
