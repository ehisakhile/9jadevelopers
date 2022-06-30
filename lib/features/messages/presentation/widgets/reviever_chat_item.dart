import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/extensions/color_extension.dart';
import '../../../../core/theme/images.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/appconstants.dart';
import '../../domain/entity/chat_entity.dart';
import '../../../../extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';

class ReceiverChatItem extends StatelessWidget {
  final ChatEntity? chatEntity;
  final String? otherUserProfileUrl;
  const ReceiverChatItem({Key? key, this.chatEntity, this.otherUserProfileUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: .8,
      alignment: Alignment.centerLeft,
      child: [
        [
          otherUserProfileUrl!.toRoundNetworkImage(radius: 10),
          10.toSizedBox,
          if (chatEntity!.chatMediaType == ChatMediaType.TEXT)
            [
              GestureDetector(
                onLongPress: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: parseHtmlString(chatEntity!.message!),
                    ),
                  );
                  context.showSnackBar(
                    message: 'Text Copied to Clipboard',
                    isError: false,
                  );
                },
                child: chatEntity!.message!
                    .toCaption(
                      color: const Color(0xFF727171),
                      fontWeight: FontWeight.w500,
                    )
                    .toPadding(16)
                    .toContainer(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F6F6),
                        borderRadius: BorderRadius.only(
                          topRight:
                              Radius.circular(!context.isArabic() ? 40 : 0),
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                          topLeft: Radius.circular(context.isArabic() ? 40 : 0),
                        ),
                      ),
                    ),
              ),
              5.toSizedBox,
              [
                Text(
                  chatEntity!.time!,
                  style: TextStyle(
                    color: const Color(0xFF737880),
                    fontSize: AC.getDeviceHeight(context) * 0.013,
                    fontWeight: FontWeight.w500,
                    fontFamily: "CeraPro",
                  ),
                ),
              ].toRow(mainAxisAlignment: MainAxisAlignment.end)
            ]
                .toColumn(crossAxisAlignment: CrossAxisAlignment.start)
                .toFlexible()
          else
            CachedNetworkImage(
              key: ObjectKey(chatEntity),
              placeholder: (c, i) =>
                  Center(child: const CircularProgressIndicator()),
              imageUrl: chatEntity!.profileUrl!,
              height: 250.h,
              width: 250.w,
              alignment: Alignment.centerLeft,
            ).onTapWidget(
              () {
                showAnimatedDialog(
                  barrierDismissible: true,
                  context: context,
                  builder: (c) => Container(
                    color: HexColor.fromHex('#24282E').withOpacity(1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        closeButton(context),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 100.0),
                            child: CachedNetworkImage(
                              fit: BoxFit.scaleDown,
                              placeholder: (c, i) => Center(
                                child: const CircularProgressIndicator(),
                              ),
                              imageUrl: chatEntity!.profileUrl!,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ).toFlexible()
        ].toRow(),
      ].toColumn().toContainer().toHorizontalPadding(16).toVerticalPadding(6),
    );
  }

  Widget closeButton(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: InkWell(
          onTap: () {
            context.router.root.pop();
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Images.closeButton.toSvg(
              color: Colors.white,
              height: 40,
              width: 40,
            ),
          ),
        ),
      ),
    );
  }
}
