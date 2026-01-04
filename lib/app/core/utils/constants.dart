/// App-wide constants
class AppConstants {
  AppConstants._();

  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String displayDateTimeFormat = 'MMM dd, yyyy hh:mm a';

  // Storage Keys
  static const String isLoggedInKey = 'IS_LOGGED_IN';
  static const String accessTokenKey = 'ACCESS_TOKEN';
  static const String userDataKey = 'USER_DATA_KEY';
  static const String refreshTokenKey = 'REFRESH_TOKEN';
  static const String themeKey = 'THEME_MODE';
  static const String languageKey = 'LANGUAGE';
  static const String onboardingKey = 'ONBOARDING_COMPLETE';

  // HTTP Status Codes
  static const int statusOk = 200;
  static const int statusCreated = 201;
  static const int statusBadRequest = 400;
  static const int statusUnauthorized = 401;
  static const int statusForbidden = 403;
  static const int statusNotFound = 404;
  static const int statusInternalServerError = 500;
}
