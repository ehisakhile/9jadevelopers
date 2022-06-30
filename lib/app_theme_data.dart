import 'package:colibri/core/config/colors.dart';

import 'core/extensions/context_exrensions.dart';
import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';


class AppThemeData {
  static ThemeData appThemeData(BuildContext context) {
    print(context.getScreenWidth);
    return ThemeData(
      fontFamily: 'CeraPro',
      scaffoldBackgroundColor: Colors.white,
      textTheme: appTextTheme,
      primaryColor: AppColors.colorPrimary,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      tabBarTheme: TabBarTheme(
        unselectedLabelStyle:
            context.subTitle2.copyWith(fontWeight: FontWeight.bold),
        labelStyle: context.subTitle2.copyWith(fontWeight: FontWeight.bold),
        labelColor: AppColors.colorPrimary,
        unselectedLabelColor: Colors.grey,
      ),
    );
  }
}
