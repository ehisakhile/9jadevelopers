import 'package:colibri/core/config/colors.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../extensions.dart';
import 'package:flutter/material.dart';

class ViewSwiftCircle extends StatelessWidget {
  const ViewSwiftCircle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        right: 10.0,
        left: 10,
      ),
      child: Column(
        children: [
          Image.asset('images/png_image/user_test.png'),
          3.toSizedBox,
          Container(
            width: 60,
            padding: EdgeInsets.only(left: 10),
            child: Text(
              'Karem',
              overflow: TextOverflow.ellipsis,
              style: AppTheme.caption.copyWith(
                fontSize: AppFontSize.caption.toSp as double?,
                color: AppColors.textColor,
                fontWeight: FontWeight.w400,
                fontFamily: "CeraPro",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
