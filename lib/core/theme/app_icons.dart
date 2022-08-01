import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:colibri/core/config/colors.dart';
import 'images.dart';
import '../../extensions.dart';
import '../../features/feed/presentation/widgets/all_home_screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AppIcons {
  static Image appLogo = Images.logo.toAssetImage(height: 60, width: 70);
  // bottom app bar
  static const bottomBarSize = 30;
  static SvgPicture messageIcon(
          {num height = bottomBarSize,
          num width = bottomBarSize,
          required ScreenType screenType}) =>
      Images.message.toSvg(
          height: height,
          width: width,
          color: screenType.maybeWhen(
              orElse: () => AppColors.optionIconColor,
              message: () => AppColors.colorPrimary));
  static SvgPicture notificationIcon(
          {required ScreenType screenType, double? height, double? width}) =>
      Images.notification.toSvg(
          height: height ?? bottomBarSize,
          width: width ?? bottomBarSize,
          color: screenType.maybeWhen(
              orElse: () => AppColors.optionIconColor,
              notification: () => AppColors.colorPrimary));
  static SvgPicture homeIcon(
          {num height = bottomBarSize,
          num width = bottomBarSize,
          required ScreenType screenType}) =>
      Images.home.toSvg(
          height: height,
          width: width,
          color: screenType.maybeWhen(
            orElse: () => AppColors.optionIconColor,
            home: () => AppColors.colorPrimary,
          ));
  static SvgPicture searchIcon(
          {required ScreenType screenType, double? height, double? width}) =>
      Images.search.toSvg(
          height: height ?? bottomBarSize,
          width: width ?? bottomBarSize,
          color: screenType.maybeWhen(
              orElse: () => AppColors.optionIconColor,
              search: () => AppColors.colorPrimary));
  static SvgPicture addIcon =
      Images.add.toSvg(height: bottomBarSize, width: bottomBarSize);

  static SvgPicture swiftAddIcon =
      Images.swiftAddIcon.toSvg(height: bottomBarSize, width: bottomBarSize);

  static SvgPicture newPostIcon = Images.newPost
      .toSvg(height: bottomBarSize, width: bottomBarSize, color: Colors.white);
  // create post icon
  static SvgPicture gifIcon({bool enabled = true}) => Images.gif.toSvg(
      height: 13,
      width: 13,
      color: enabled
          ? AppColors.colorPrimary
          : AppColors.colorPrimary.withOpacity(.5));
  static SvgPicture videoIcon({bool enabled = true, num? height, num? width}) =>
      Images.video.toSvg(
          height: height ?? 20,
          width: width ?? 20,
          color: enabled
              ? AppColors.colorPrimary
              : AppColors.colorPrimary.withOpacity(.5));
  static SvgPicture smileIcon(
          {bool enabled = true, num height = 15, num width = 15}) =>
      Images.smile.toSvg(
          height: height,
          width: width,
          color: enabled
              ? AppColors.colorPrimary
              : AppColors.colorPrimary.withOpacity(.5));
  static SvgPicture imageIcon(
          {bool enabled = true,
          num height = 18,
          num width = 18,
          Color? color}) =>
      Images.image.toSvg(
          height: height,
          width: width,
          color: color ??
              (enabled
                  ? AppColors.colorPrimary
                  : AppColors.colorPrimary.withOpacity(.5)));
  static SvgPicture pollIcon(bool enabled) => Images.poll.toSvg(
        height: 20,
        width: 20,
        color: enabled
            ? AppColors.colorPrimary
            : AppColors.colorPrimary.withOpacity(.5),
      );

  static SvgPicture createSearchIcon(
          {bool enabled = true, num height = 25, num width = 25}) =>
      Images.createSearch.toSvg(
          height: height,
          width: width,
          color: enabled
              ? AppColors.colorPrimary
              : AppColors.colorPrimary.withOpacity(.5));

  // social bar
  static Widget drawerIcon({num height = 20, num width = 20}) => Images.drawer
      .toSvg(height: height.toHeight, width: width.toWidth)
      .toPadding(8);
  // static Widget likeIcon = Images.likeOption.toSvg();
  static Widget likeIcon({Color? color}) =>
      Images.likeOption.toSvg(height: 18, width: 18, color: color);
  // static Widget heartIcon = Images.heart.toSvg();
  static Widget heartIcon({Color? color, num height = 18, num width = 18}) =>
      Images.heart.toSvg(height: height, width: width, color: color);
  static Widget filledHeartIcon(
          {Color? color, num height = 18, num width = 18}) =>
      Images.filledHeart.toSvg(height: height, width: width, color: color);

  static Widget showLikesIcon(
          {Color? color, double height = 18, double width = 18}) =>
      Images.showLikes.toSvg(height: height, width: width, color: color);
  static Widget commentIcon = Images.comment.toSvg(height: 18, width: 18);
  static Widget repostIcon({Color? color, num height = 18, num width = 18}) =>
      Images.repost.toSvg(height: height, width: width, color: color);
  static Widget shareIcon(
          {Color color = AppColors.optionIconColor,
          num height = 18,
          num width = 18}) =>
      Images.share.toSvg(
        height: height,
        width: width,
        color: color,
      );
  static Widget clearChatIcon = Images.clearChat.toSvg(
    color: Colors.black38,
    height: 23.h,
    width: 23.w,
  );

  static Widget messageIcon1 = Images.messageIcon.toSvg();
  static Widget rePostIcon1({Color? color}) =>
      Images.rePostIcon.toSvg(height: 14, width: 14, color: color);
  // static Widget rePostIcon1 = Images.rePostIcon.toSvg();
  static Widget shareIcon1 = Images.shareIcon.toSvg();

  static Widget reportIcon(
          {Color? color, double height = 30, double width = 30}) =>
      Images.reportOption.toSvg(height: height, width: width, color: color);
  //drawer
  static Widget drawerHome =
      Images.drawerHome.toSvg(height: drawerMenuSize, width: drawerMenuSize);
  static Widget drawerHome1 = Images.drawerHome1.toSvg();
  static Widget drawerMessage = Images.drawerMessage.toSvg();
  static Widget drawerMessage1 = Images.drawerMessage1.toSvg();
  static Widget drawerBookmark({double size = drawerMenuSize}) =>
      Images.drawerBookmark
          .toSvg(height: size, width: size, color: AppColors.optionIconColor);
  static Widget drawerBookmark1 = Images.drawerBookmark1.toSvg();
  static Widget drawerProfile =
      Images.drawerProfile.toSvg(height: drawerMenuSize, width: drawerMenuSize);
  static Widget drawerProfile1 =
      Images.drawerUser1.toSvg(height: 30, width: 30);
  static Widget drawerSetting =
      Images.drawerSetting.toSvg(height: drawerMenuSize, width: drawerMenuSize);
  static Widget verifiedIcons =
      Images.verified.toSvg(height: 15.0, width: 15.0);
  static Widget signOut = Images.signOut.toSvg(color: Colors.black);
  static Widget drawerAdvertising = Images.advertising.toSvg();
  static Widget drawerAffiliates = Images.drawer_affiliates.toSvg();
  static Widget drawerWallet = Images.drawerWallet.toSvg();

  static Widget usIcon = Images.usIcon.toSvg(height: 10, width: 10);
  static Widget folderIcon = Images.folderIcon.toSvg(height: 10, width: 10);
  static Widget optionIcon =
      Images.optionsIcon.toSvg(height: 20, width: 20, color: Colors.black87);
  static Widget messageProfile({num size = 20}) => Images.messageProfileIcon
      .toSvg(height: size, width: size, color: AppColors.colorPrimary);

  //option menu
  static Widget deleteOption(
          {num height = 30, num width = 30, required Color color}) =>
      Images.deleteOption.toSvg(height: height, width: width, color: color);
  static Widget likeOption({double size = drawerMenuSize, Color? color}) =>
      Images.likeOption.toSvg(height: size, width: size, color: color);
  static Widget bookmarkOption(
          {double height = 30,
          double width = 30,
          Color color = Colors.white}) =>
      Images.bookmarkOption.toSvg(height: height, width: width, color: color);
  static Widget personOption(
          {double size = drawerMenuSize,
          Color color = AppColors.optionIconColor}) =>
      Images.personOption.toSvg(height: size, width: size, color: color);
}

const drawerMenuSize = 25.0;
