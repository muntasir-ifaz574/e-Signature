import 'package:flutter/material.dart';
import 'typography/app_text_theme.dart';
import 'colors/color_extensions.dart';
import 'colors/colors.dart';

part 'components/app_bar.dart';
part 'components/button.dart';

class AppTheme {
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: "Roboto",
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      surface: AppColors.greyLight,
    ),
    scaffoldBackgroundColor: AppColors.greyLight,
    textTheme: AppTextTheme.light,

    // Extensions
    extensions: [
      AppExtraColors(
        success: AppColors.success,
        warning: AppColors.warning,
        error: AppColors.error,
      ),
    ],
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: "Roboto",
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF101010), // Deep dark for OLED
    textTheme: AppTextTheme.dark,

    // Extensions
    extensions: [
      AppExtraColors(
        success: AppColors.success,
        warning: AppColors.warning,
        error: AppColors.error,
      ),
    ],
  );
}
