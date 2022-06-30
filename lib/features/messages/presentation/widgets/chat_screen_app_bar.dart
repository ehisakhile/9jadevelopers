import 'package:auto_route/auto_route.dart';
import 'package:colibri/extensions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/routes/routes.gr.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../translations/locale_keys.g.dart';
import '../../domain/entity/message_entity.dart';

class ChatScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatScreenAppBar({
    Key? key,
    required this.navigateToBackWithResult,
    required this.otherUserFullName,
    required this.entity,
    required this.deleteMethod,
    required this.imageUrl,
  }) : super(key: key);
  final void Function()? navigateToBackWithResult;
  final Future<void> Function(bool) deleteMethod;
  final String? otherUserFullName;
  final MessageEntity? entity;
  final String imageUrl;
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: GestureDetector(
        onTap: navigateToBackWithResult,
        child: Icon(
          Icons.arrow_back,
          color: Colors.grey,
        ),
      ),
      elevation: 0.0,
      backgroundColor: Colors.white,
      title: Padding(
        padding: EdgeInsets.only(top: 18.0.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: entity != null && entity!.isVerified
                  ? EdgeInsets.zero
                  : const EdgeInsets.only(right: 15.0),
              child: imageUrl
                  .toRoundNetworkImage()
                  .toContainer(height: 25, width: 25),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                otherUserFullName!.toSubTitle1(
                  (url) =>
                      context.router.root.push(WebViewScreenRoute(url: url)),
                  color: const Color(0xFF3D4146),
                  fontWeight: FontWeight.w700,
                  fontFamily1: 'CeraPro',
                ),
                AppIcons.verifiedIcons
                    .toVisibility(entity == null ? false : entity!.isVerified)
                    .toHorizontalPadding(4),
              ],
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(
            right: context.isArabic() ? 0 : 8.0,
            left: !context.isArabic() ? 0 : 8.0,
          ),
          child: setUpList().toPopUpMenuButton(
            (choice) => _mapChoiceToFunction(choice, context),
            icon: Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: Icon(
                Icons.more_horiz,
                color: Colors.grey,
              ),
            ),
            rowIcon: _mapChoiceToIcon,
          ),
        ),
      ],
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 5.h);

  bottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: context.getScreenHeight * .2,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.only(
          left: 30,
          right: 30,
          top: 15,
          bottom: 20,
        ),
        decoration: const BoxDecoration(
          color: Color(0xff0e8df1),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 6,
              width: 37,
              decoration: const BoxDecoration(
                color: const Color(0xff0560b2),
                borderRadius: BorderRadius.all(
                  Radius.circular(5),
                ),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  InkWell(
                    onTap: () async {
                      (await showAnimatedDialog(
                        context: context,
                        barrierDismissible: true,
                        animationType: DialogTransitionType.size,
                        curve: Curves.fastOutSlowIn,
                        duration: const Duration(seconds: 1),
                        builder: (_) => AlertDialog(
                          title: LocaleKeys.please_confirm_your_actions
                              .tr()
                              .toSubTitle1(
                                  (url) => context.router.root
                                      .push(WebViewScreenRoute(url: url)),
                                  fontWeight: FontWeight.bold),
                          content: LocaleKeys
                              .do_you_want_to_delete_this_chat_with_please_note_that_this_action
                              .tr(namedArgs: {
                            '@interloc_name@': otherUserFullName!
                          }).toSubTitle1(
                            (url) => context.router.root
                                .push(WebViewScreenRoute(url: url)),
                          ),
                          actions: <Widget>[
                            LocaleKeys.cancel.tr().toButton().toFlatButton(
                              () {
                                Navigator.of(context).pop();
                              },
                            ),
                            LocaleKeys.yes.tr().toButton().toFlatButton(
                                  () async => await deleteMethod(true),
                                )
                          ],
                        ),
                      ));
                    },
                    child: Container(
                      height: 25,
                      margin: const EdgeInsets.only(top: 30),
                      child: Row(
                        children: [
                          AppIcons.deleteOption(
                            color: Colors.white,
                            height: 20,
                            width: 20,
                          ),
                          const SizedBox(width: 20),
                          Text(
                            LocaleKeys.delete_chat.tr(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              fontFamily: "CeraPro",
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      (await showAnimatedDialog(
                        context: context,
                        barrierDismissible: true,
                        animationType: DialogTransitionType.size,
                        curve: Curves.fastOutSlowIn,
                        duration: const Duration(seconds: 1),
                        builder: (_) => AlertDialog(
                          title: LocaleKeys.please_confirm_your_actions
                              .tr()
                              .toSubTitle1(
                                  (url) => context.router.root
                                      .push(WebViewScreenRoute(url: url)),
                                  fontWeight: FontWeight.bold),
                          content: LocaleKeys
                              .are_you_sure_you_want_to_delete_all_messages_in_the_chat_with_ple
                              .tr(
                            namedArgs: {'@interloc_name@': otherUserFullName!},
                          ).toSubTitle2(),
                          actions: <Widget>[
                            LocaleKeys.cancel.tr().toButton().toFlatButton(
                              () {
                                Navigator.of(context).pop();
                              },
                            ),
                            LocaleKeys.yes.tr().toButton().toFlatButton(
                                  () async => await deleteMethod(false),
                                )
                          ],
                        ),
                      ));
                    },
                    child: Container(
                      height: 25,
                      margin: const EdgeInsets.only(top: 30),
                      child: Row(
                        children: [
                          AppIcons.clearChatIcon,
                          const SizedBox(width: 25),
                          Text(
                            LocaleKeys.clear_chat.tr(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              fontFamily: "CeraPro",
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  List<String> setUpList() =>
      [LocaleKeys.delete_chat.tr(), LocaleKeys.clear_chat.tr()];

  Widget _mapChoiceToIcon(String choice) {
    if (choice == LocaleKeys.delete_chat.tr())
      return AppIcons.deleteOption(
        color: Colors.black38,
        height: 23.h,
        width: 23.w,
      );
    else if (choice == LocaleKeys.clear_chat.tr())
      return AppIcons.clearChatIcon;
    return Container();
  }

  void _mapChoiceToFunction(String? choice, BuildContext context) async {
    if (choice == LocaleKeys.delete_chat.tr())
      (await showAnimatedDialog(
        context: context,
        barrierDismissible: true,
        animationType: DialogTransitionType.size,
        curve: Curves.fastOutSlowIn,
        duration: const Duration(seconds: 1),
        builder: (_) => AlertDialog(
          title: LocaleKeys.please_confirm_your_actions.tr().toSubTitle1(
              (url) => context.router.root.push(WebViewScreenRoute(url: url)),
              fontWeight: FontWeight.bold),
          content: LocaleKeys
              .do_you_want_to_delete_this_chat_with_please_note_that_this_action
              .tr(namedArgs: {
            '@interloc_name@': otherUserFullName!
          }).toSubTitle1(
            (url) => context.router.root.push(WebViewScreenRoute(url: url)),
          ),
          actions: <Widget>[
            LocaleKeys.cancel.tr().toButton().toFlatButton(
              () {
                Navigator.of(context).pop();
              },
            ),
            LocaleKeys.yes.tr().toButton().toFlatButton(
                  () async => await deleteMethod(true),
                )
          ],
        ),
      ));
    else if (choice == LocaleKeys.clear_chat.tr())
      (await showAnimatedDialog(
        context: context,
        barrierDismissible: true,
        animationType: DialogTransitionType.size,
        curve: Curves.fastOutSlowIn,
        duration: const Duration(seconds: 1),
        builder: (_) => AlertDialog(
          title: LocaleKeys.please_confirm_your_actions.tr().toSubTitle1(
              (url) => context.router.root.push(WebViewScreenRoute(url: url)),
              fontWeight: FontWeight.bold),
          content: LocaleKeys
              .are_you_sure_you_want_to_delete_all_messages_in_the_chat_with_ple
              .tr(
            namedArgs: {'@interloc_name@': otherUserFullName!},
          ).toSubTitle2(),
          actions: <Widget>[
            LocaleKeys.cancel.tr().toButton().toFlatButton(
              () {
                Navigator.of(context).pop();
              },
            ),
            LocaleKeys.yes.tr().toButton().toFlatButton(
                  () async => await deleteMethod(false),
                )
          ],
        ),
      ));
  }
}
