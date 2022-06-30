import 'package:auto_route/auto_route.dart';
import 'package:colibri/core/extensions/string_extensions.dart';
import 'package:colibri/core/extensions/widget_extensions.dart';
import 'package:flutter/material.dart';

import '../../../../core/datasource/local_data_source.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/routes/routes.gr.dart';

class MessagesAppBarRow extends StatelessWidget {
  const MessagesAppBarRow(this.title, {Key? key}) : super(key: key);
  final String title;
  @override
  Widget build(BuildContext context) {
    final _userData = getIt<LocalDataSource>().getUserData();
    return Row(
      children: [
        _userData!.data!.user!.profilePicture!
            .toRoundNetworkImage(radius: 8)
            .onTapWidget(
              () => Scaffold.of(context).openDrawer(),
            ),
        Spacer(),
        Padding(
          padding: const EdgeInsets.only(right: 35.0),
          child: title.toSubTitle1(
            (url) => context.router.root.push(WebViewScreenRoute(url: url)),
            color: const Color(0xFF3D4146),
            fontWeight: FontWeight.w700,
            fontFamily1: 'CeraPro',
          ),
        ),
        Spacer(),
      ],
    );
  }
}
