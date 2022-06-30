import 'package:auto_route/src/router/auto_router_x.dart';
import 'package:colibri/core/config/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/appconstants.dart';
import '../../../../core/routes/routes.gr.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../extensions.dart';
import '../../../authentication/data/models/login_response.dart';
import '../../domain/entity/post_entity.dart';
import '../../../../translations/locale_keys.g.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';

class PostHeaderRow extends StatelessWidget {
  const PostHeaderRow({
    Key? key,
    required this.detailedPost,
    required this.postEntity,
    this.onPostOptionItem,
    this.loginResponseFeed,
  }) : super(key: key);
  final bool detailedPost;
  final PostEntity? postEntity;
  final StringToVoidFunc? onPostOptionItem;
  final LoginResponse? loginResponseFeed;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        [
          Padding(
            padding: EdgeInsets.only(
              top: AC.getDeviceHeight(context) * 0.013,
              right: !context.isArabic() ? 10 : 0,
              left: context.isArabic() ? 10 : 0,
            ),
            child: postEntity!.profileUrl!
                .toRoundNetworkImage(radius: 11)
                .toContainer(alignment: Alignment.topRight)
                .toVerticalPadding(0)
                .onTapWidget(
              () {
                navigateToProfile(context);
              },
            ),
          ),
        ]
            .toRow(mainAxisAlignment: MainAxisAlignment.end)
            .toVisibility(detailedPost),
        [
          detailedPost
              ? SizedBox(height: AC.getDeviceHeight(context) * 0.010)
              : Container(),
          [
            [
              RichText(
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                maxLines: 1,
                strutStyle: StrutStyle.disabled,
                textWidthBasis: TextWidthBasis.longestLine,
                text: TextSpan(
                  text: postEntity!.name,
                  style: context.subTitle1.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                    fontFamily: "CeraPro",
                  ),
                ),
              ).onTapWidget(() {
                navigateToProfile(context);
              }).toFlexible(flex: 2),
              5.toSizedBoxHorizontal,
              AppIcons.verifiedIcons
                  .toVisibility(postEntity!.postOwnerVerified),
              5.toSizedBoxHorizontal,
              Padding(
                padding: EdgeInsets.only(top: 2),
                child: Text(
                  postEntity!.time!,
                  style: TextStyle(
                    color: AppColors.greyText,
                    fontSize: AC.getDeviceHeight(context) * 0.015,
                    fontWeight: FontWeight.w400,
                    fontFamily: "CeraPro",
                  ),
                ),
              )
            ].toRow(crossAxisAlignment: CrossAxisAlignment.center).toFlexible(),
            6.toSizedBoxHorizontal
          ].toRow(crossAxisAlignment: CrossAxisAlignment.center).toContainer(),
          3.toSizedBoxVertical,
          InkWell(
            onTap: () {
              navigateToProfile(context);
            },
            child: SizedBox(
              height: 15,
              child: Text(
                postEntity!.userName!,
                style: TextStyle(
                  color: const Color(0xFF737880),
                  fontSize: AC.getDeviceHeight(context) * 0.015,
                  fontWeight: FontWeight.w400,
                  fontFamily: "CeraPro",
                ),
              ),
            ),
          ),
          5.toSizedBox.toVisibility(postEntity!.responseTo != null),
          [
            "In response to".toCaption(
                fontSize: 13,
                textOverflow: TextOverflow.ellipsis,
                maxLines: 2,
                color: AppColors.greyText),
            if (postEntity!.responseTo != null)
              InkWell(
                onTap: () {
                  context.router.root.push(
                    ProfileScreenRoute(
                      otherUserId: postEntity!.isOtherUser
                          ? postEntity!.responseToUserId
                          : null,
                    ),
                  );
                },
                child: postEntity!.responseTo!.toCaption(
                    color: AppColors.colorPrimary,
                    fontWeight: FontWeight.w500,
                    textOverflow: TextOverflow.ellipsis,
                    maxLines: 1),
              ),
            LocaleKeys.post.tr().toCaption(
                fontSize: 13,
                textOverflow: TextOverflow.ellipsis,
                maxLines: 1,
                color: AppColors.greyText)
          ].toWrap().toVisibility(
                postEntity!.responseTo != null &&
                    postEntity!.responseTo!.isNotEmpty,
              ),
        ]
            .toColumn(mainAxisAlignment: MainAxisAlignment.center)
            .toExpanded(flex: 8),
        Theme(
          data: Theme.of(context).copyWith(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
          ),
          child: setUpList().toPopUpMenuButton(
            _mapChoiceToFunction,
            icon: Icon(Icons.more_horiz, color: Colors.grey),
            rowIcon: _mapChoiceToIcon,
          ),
        ),
      ],
    ).toHorizontalPadding(20);
  }

  void _mapChoiceToFunction(String? choice) {
    if (choice == LocaleKeys.show_likes.tr()) {
      onPostOptionItem!('Show likes');
    } else if (choice == LocaleKeys.bookmark.tr() ||
        choice == LocaleKeys.unbookmark.tr()) {
      onPostOptionItem!(!postEntity!.isSaved! ? 'Bookmark' : 'UnBookmark');
    } else if (choice == LocaleKeys.report_post.tr()) {
      onPostOptionItem!('Report Post');
    } else if (choice == LocaleKeys.delete.tr()) {
      onPostOptionItem!('Delete');
    } else if (choice == LocaleKeys.block.tr()) {
      onPostOptionItem!('Block');
    }
  }

  Widget _mapChoiceToIcon(String choice) {
    if (choice == LocaleKeys.show_likes.tr())
      return AppIcons.showLikesIcon(
        height: 23.h,
        width: 23.w,
        color: Colors.black38,
      );
    else if (choice == LocaleKeys.bookmark.tr() ||
        choice == LocaleKeys.unbookmark.tr())
      return AppIcons.bookmarkOption(
        height: 23.h,
        width: 23.w,
        color: Colors.black38,
      );
    else if (choice == LocaleKeys.report_post.tr())
      return AppIcons.reportIcon(
        height: 23.h,
        width: 23.w,
        color: Colors.black38,
      );
    else if (choice == LocaleKeys.delete.tr())
      return AppIcons.deleteOption(
        height: 23.h,
        width: 23.w,
        color: Colors.black38,
      );
    else if (choice == LocaleKeys.block.tr())
      return AppIcons.deleteOption(
        height: 23.h,
        width: 23.w,
        color: Colors.black38,
      );
    else
      return Container();
  }

  List<String> setUpList() {
    List<String> _list = [
      LocaleKeys.show_likes.tr(),
      !postEntity!.isSaved!
          ? LocaleKeys.bookmark.tr()
          : LocaleKeys.unbookmark.tr()
    ];
    bool _temp = postEntity!.isOtherUser &&
        postEntity!.userName != loginResponseFeed!.data!.user!.userName;
    _list.add(_temp ? LocaleKeys.report_post.tr() : LocaleKeys.delete.tr());
    if (_temp) _list.add(LocaleKeys.block.tr());
    return _list;
  }

  void navigateToProfile(BuildContext context) {
    if (postEntity!.isOtherUser) {
      context.router.root.push(
        ProfileScreenRoute(
          otherUserId: postEntity!.userName!.split("@")[0],
        ),
      );
    } else
      context.router.root.push(ProfileScreenRoute());
  }
}
