import 'package:auto_route/src/router/auto_router_x.dart';
import '../../../../core/routes/routes.gr.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import '../../../../extensions.dart';

class ProfileUserStatsBarItem extends StatelessWidget {
  const ProfileUserStatsBarItem({
    Key? key,
    required this.number,
    required this.text,
    this.function,
  }) : super(key: key);
  final String number;
  final String text;
  final VoidCallback? function;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: function,
      child: Row(
        children: [
          number.toSubTitle1(
            (url) => context.router.root.push(WebViewScreenRoute(url: url)),
            color: Colors.blueAccent.shade400,
            fontWeight: FontWeight.w500,
          ),
          4.toSizedBoxHorizontal,
          FittedBox(
            child: Text(
              parseHtmlString(text),
              overflow: TextOverflow.ellipsis,
              style: AppTheme.subTitle2.copyWith(
                fontSize: AppFontSize.subTitle2.toSp as double?,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
                fontFamily: 'CeraPro',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
