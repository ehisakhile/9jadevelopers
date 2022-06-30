import '../../../../../core/theme/app_icons.dart';
import '../../../../../extensions.dart';
import '../../pages/redeem_confirmation_screen.dart';
import 'package:flutter/material.dart';

class CreateSwiftCircle extends StatelessWidget {
  const CreateSwiftCircle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            opaque: true,
            pageBuilder: (BuildContext context, _, __) =>
                RedeemConfirmationScreen(
              backRefresh: () {},
              isCreateSwift: true,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 10.0, left: 17.0),
        child: Column(
          children: [
            Stack(
              children: [
                Image.asset('images/png_image/user_test.png'),
                Positioned(
                  right: 0.0,
                  bottom: 0.0,
                  child: AppIcons.swiftAddIcon,
                )
              ],
            ),
            3.toSizedBox,
            'Create'.toCaption(),
          ],
        ),
      ),
    );
  }
}
