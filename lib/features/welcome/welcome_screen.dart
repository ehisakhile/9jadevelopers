import 'package:auto_route/auto_route.dart';
import 'package:colibri/core/config/colors.dart';
import 'package:colibri/core/config/strings.dart';
import '../../../../core/routes/routes.gr.dart';
import '../../../../core/theme/app_icons.dart';

import '../../../../extensions.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: [
        buildTopView(),
        buildMiddleView(),
        buildBottomView(),
      ].toColumn().toContainer(),
    );
  }

  Widget buildTopView() {
    return [
      Strings.welcome.toHeadLine5(color: AppColors.colorPrimary),
      10.toSizedBox,
      Strings.seeWhats
          .toHeadLine6(fontWeight: FontWeight.w500)
          .toAlign(TextAlign.center)
          .toHorizontalPadding(32),
    ]
        .toColumn(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center)
        .toContainer(alignment: Alignment.bottomCenter)
        .toExpanded();
  }

  Widget buildMiddleView() {
    return [AppIcons.appLogo]
        .toColumn(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center)
        .toContainer(alignment: Alignment.center)
        .toExpanded();
  }

  Widget buildBottomView() {
    return [
      Strings.login
          .toButton(color: Colors.white)
          .toCustomButton(
            () => {
              context.router.root.pushAndPopUntil(
                LoginScreenRoute(),
                predicate: (f) => false,
              )
            },
          )
          .toSymmetricPadding(25, 8),
      Strings.signUp
          .toButton(color: Colors.black, fontWeight: FontWeight.w500)
          .toFlatButton(() => {
                context.router.root.pushAndPopUntil(
                  SignUpScreenRoute(),
                  predicate: (f) => false,
                )
              })
    ].toColumn(crossAxisAlignment: CrossAxisAlignment.center).toExpanded();
  }
}
