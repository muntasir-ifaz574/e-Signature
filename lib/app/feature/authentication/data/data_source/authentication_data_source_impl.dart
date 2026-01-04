import 'package:dio/dio.dart';

import '../../../../core/data/app_urls.dart';
import '../../../../core/data/network/network_api_services.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure_map.dart';
import '../../../../core/error/failures.dart';
import '../model/sign_up_model.dart';
import 'authentication_data_source.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({required this.apiService});

  final NetworkApiServices apiService;

  @override
  Future<SignUpModel> signUp({
    required String email,
    required String fullName,
    required String password,
    required String phoneNumber,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        "email": email,
        "password": password,
        "fullName": fullName,
        "phoneNumber": phoneNumber,
      });

      final response = await apiService.postApi(
        url: AppUrls.signup,
        data: formData,
      );

      final statusCode = response['status'] as int;
      if (statusCode == 202) {
        return SignUpModel.fromJson(response);
      } else {
        throw AppException(
          message: response['message'] ?? 'OTP send Failed',
          code: statusCode.toString(),
        );
      }
    } on AppException catch (e) {
      throw FailureMapper.mapExceptionToFailure(e);
    } catch (e) {
      throw UnexpectedFailure();
    }
  }

  @override
  Future<void> logout() async {
    await Future.delayed(Duration(milliseconds: 500));
  }
}
