import 'package:flutter/material.dart';
import 'app_text_styles.dart';
import '../colors/colors.dart';

class AppTextTheme {
  static TextTheme light = TextTheme(
    displayLarge: AppTextStyles.h1.copyWith(color: AppColors.black),
    displayMedium: AppTextStyles.h2.copyWith(color: AppColors.black),
    displaySmall: AppTextStyles.h3.copyWith(color: AppColors.black),

    headlineMedium: AppTextStyles.h4.copyWith(color: AppColors.black),
    headlineSmall: AppTextStyles.h5.copyWith(color: AppColors.black),

    titleLarge: AppTextStyles.h6.copyWith(color: AppColors.black),
    titleMedium: AppTextStyles.label.copyWith(color: AppColors.greyDark),

    bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.black),
    bodyMedium: AppTextStyles.body.copyWith(color: AppColors.greyDark),
    bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.grey),

    labelLarge: AppTextStyles.button.copyWith(color: AppColors.white),
    labelMedium: AppTextStyles.label.copyWith(color: AppColors.greyDark),
  );

  static TextTheme dark = TextTheme(
    displayLarge: AppTextStyles.h1.copyWith(color: AppColors.white),
    displayMedium: AppTextStyles.h2.copyWith(color: AppColors.white),
    displaySmall: AppTextStyles.h3.copyWith(color: AppColors.white),

    headlineMedium: AppTextStyles.h4.copyWith(color: AppColors.white),
    headlineSmall: AppTextStyles.h5.copyWith(color: AppColors.white),

    titleLarge: AppTextStyles.h6.copyWith(color: AppColors.white),
    titleMedium: AppTextStyles.label.copyWith(color: AppColors.grey),

    bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
    bodyMedium: AppTextStyles.body.copyWith(color: AppColors.greyLight),
    bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.grey),

    labelLarge: AppTextStyles.button.copyWith(color: AppColors.white),
    labelMedium: AppTextStyles.label.copyWith(color: AppColors.grey),
  );
}
