import 'package:flutter/material.dart';

class AppExtraColors extends ThemeExtension<AppExtraColors> {
  final Color success;
  final Color warning;
  final Color error;

  AppExtraColors({
    required this.success,
    required this.warning,
    required this.error,
  });

  @override
  AppExtraColors copyWith({Color? success, Color? warning, Color? error}) {
    return AppExtraColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
    );
  }

  @override
  AppExtraColors lerp(ThemeExtension<AppExtraColors>? other, double t) {
    if (other is! AppExtraColors) return this;

    return AppExtraColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error:  Color.lerp(error, other.error, t)!,
    );
  }
}
