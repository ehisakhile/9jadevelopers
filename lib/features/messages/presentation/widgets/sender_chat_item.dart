import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:colibri/core/common/widget/pop_up_menu_container.dart';
import 'package:colibri/core/theme/app_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/extensions/color_extension.dart';
import '../../../../core/theme/images.dart';
import '../../../../core/datasource/local_data_source.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/constants/appconstants.dart';
import '../bloc/chat_cubit.dart';
import '../../domain/entity/chat_entity.dart';
import 'package:flutter/material.dart';
import '../../../../extensions.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter/services.dart';

@immutable
class SenderChatItem extends StatelessWidget {
  final ChatEntity? chatEntity;
  final ChatCubit? chatCubit;
  SenderChatItem({Key? key, this.chatEntity, this.chatCubit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _userData = getIt<LocalDataSource>().getUserData();

    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: FractionallySizedBox(
        widthFactor: .9,
        alignment: Alignment.centerRight,
        child: PopupMenuContainer(
          items: [
            PopupMenuItem(
              value: 'Copy message',
              height: 25.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  'Copy message'.toCaption(),
                  Icon(
                    Icons.copy,
                    color: Colors.black54,
                    size: 15.h,
                  ),
                ],
              ),
            ),
            // ignore: unnecessary_cast
            PopupMenuDivider() as PopupMenuEntry,
            PopupMenuItem(
              value: 'Delete message',
              height: 25.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  'Delete message'.toCaption(color: Colors.red),
                  AppIcons.deleteOption(
                    color: Colors.red,
                    height: 15.h,
                    width: 15.w,
                  ),
                ],
              ),
            ),
          ],
          onItemSelected: (s) => _mapChoiceToFunction(s.toString(), context),
          child: Container(
            child: Wrap(
              alignment: WrapAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (chatEntity!.chatMediaType == ChatMediaType.TEXT)
                      Row(
                        children: [
                          5.toSizedBoxHorizontal,
                          Expanded(
                            flex: 8,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue.shade600,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(
                                      !context.isArabic() ? 40 : 0),
                                  bottomLeft: Radius.circular(40),
                                  bottomRight: Radius.circular(40),
                                  topRight: Radius.circular(
                                      context.isArabic() ? 40 : 0),
                                ),
                              ),
                              child: Container(
                                child: chatEntity!.message!
                                    .toCaption(
                                      color: Colors.grey.shade200,
                                      fontWeight: FontWeight.w500,
                                      linkColor: Colors.white,
                                    )
                                    .toPadding(16),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 5.0,
                              right: 5.0,
                              bottom: 20,
                            ),
                            child: _userData!.data!.user!.profilePicture!
                                .toRoundNetworkImage(radius: 10),
                          ),
                        ],
                      )
                    // ProfileUrl is the image sent url
                    else if (chatEntity!.profileUrl!.isValidUrl)
                      Container(
                        height: 250.h,
                        width: 250.w,
                        child: Row(
                          children: [
                            Expanded(
                              child: CachedNetworkImage(
                                placeholder: (c, i) =>
                                    const CircularProgressIndicator(),
                                imageUrl: chatEntity!.profileUrl!,
                                height: 250.h,
                                width: 250.w,
                              ).onTapWidget(
                                () {
                                  showAnimatedDialog(
                                    barrierDismissible: true,
                                    alignment: Alignment.center,
                                    context: context,
                                    builder: (c) => Container(
                                      color: HexColor.fromHex('#24282E')
                                          .withOpacity(1),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          closeButton(context),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 100.0),
                                              child: CachedNetworkImage(
                                                fit: BoxFit.scaleDown,
                                                placeholder: (c, i) => Center(
                                                  child:
                                                      const CircularProgressIndicator(),
                                                ),
                                                imageUrl:
                                                    chatEntity!.profileUrl!,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Container(
                              height: 250.h,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  _userData!.data!.user!.profilePicture!
                                      .toRoundNetworkImage(radius: 10),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Image.file(
                        File(chatEntity!.profileUrl!),
                      ).onTapWidget(
                        () {
                          showAnimatedDialog(
                            barrierDismissible: true,
                            alignment: Alignment.center,
                            context: context,
                            builder: (c) => Container(
                              color: HexColor.fromHex('#24282E').withOpacity(1),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  closeButton(context),
                                  Expanded(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 100.0),
                                      child: Image.file(
                                        File(
                                          chatEntity!.profileUrl!,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    5.toSizedBox,
                    Padding(
                      padding: EdgeInsets.only(
                          right: chatEntity!.chatMediaType == ChatMediaType.TEXT
                              ? 70
                              : 50.w),
                      child: Text(
                        chatEntity!.time!,
                        style: TextStyle(
                          color: const Color(0xFF737880),
                          fontSize: AC.getDeviceHeight(context) * 0.013,
                          fontWeight: FontWeight.w500,
                          fontFamily: "CeraPro",
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).toHorizontalPadding(16).toVerticalPadding(6),
        ),
      ),
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

  void _mapChoiceToFunction(String? choice, BuildContext context) async {
    if (choice!.startsWith('D')) {
      await chatCubit!.deleteMessage(chatEntity!.messageId);
      chatCubit!.chatPagination!.onRefresh();
    } else {
      Clipboard.setData(
          ClipboardData(text: parseHtmlString(chatEntity!.message!)));
      context.showSnackBar(
        message: 'Text Copied to Clipboard',
        isError: false,
      );
    }
  }
}
