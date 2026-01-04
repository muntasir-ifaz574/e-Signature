class AppUrls {
  AppUrls._();

  // API Constants
  static const String baseUrl = 'https://auth-demo-phi.vercel.app';
  static const String apiVersion = '/api/v1';

  /// Authentication api's
  // Sign_up
  static const signup = '$baseUrl/$apiVersion/auth/signup';
  static const signupVerifyOtp = '$baseUrl/$apiVersion/auth/signup/verify';
  static const signupResendOtp = '$baseUrl/$apiVersion/auth/signup/resend';
  // Sign_in
  static const signin = '$baseUrl/$apiVersion/auth/signin';
  static const signinVerifyOtp = '$baseUrl/$apiVersion/auth/signin/verify';
  static const signinResendOtp = '$baseUrl/$apiVersion/auth/signin/resend';
  // Forgot Password
  static const forgotPassword = '$baseUrl/$apiVersion/auth/password/forgot';
  static const forgotPasswordVerifyOtp = '$baseUrl/$apiVersion/auth/password/forgot/verify';
  static const forgotPasswordResendOtp = '$baseUrl/$apiVersion/auth/password/forgot/resend';
  // User
  static const updatePassword = '$baseUrl/$apiVersion/auth/password';
  static const userProfile = '$baseUrl/$apiVersion/auth/profile';
}
