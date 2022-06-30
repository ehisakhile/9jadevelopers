import 'package:colibri/core/config/colors.dart';

import '../../../../core/extensions/context_exrensions.dart';
import '../widgets/create_post_card.dart';
import 'package:flutter/material.dart';

class RedeemConfirmationScreen extends StatefulWidget {
  final Function? backRefresh;
  final bool? isCreateSwift;
  const RedeemConfirmationScreen(
      {Key? key, this.backRefresh, this.isCreateSwift})
      : super(key: key);

  @override
  _RedeemConfirmationScreenState createState() =>
      _RedeemConfirmationScreenState();
}

class _RedeemConfirmationScreenState extends State<RedeemConfirmationScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: AnimatedContainer(
          width: MediaQuery.of(context).size.width,
          height: context.getScreenHeight as double,
          decoration: BoxDecoration(
            color: AppColors.alertBg.withOpacity(0.5),
          ),
          duration: const Duration(microseconds: 500),
          curve: Curves.easeInCirc,
          child: Container(
            color: Colors.white,
            child: CreatePostCard(
              isCreateSwift: widget.isCreateSwift ?? false,
              isCreatePost: true,
            ),
          ),
        ),
      ),
    );
  }
}
