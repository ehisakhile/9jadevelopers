import 'dart:io';
import 'package:colibri/core/config/api_constants.dart';

import 'core/common/stream_validators.dart';
import 'core/extensions/string_extensions.dart';
import 'core/extensions/widget_extensions.dart';
import 'features/feed/domain/entity/post_entity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:video_compress/video_compress.dart';

import 'core/common/widget/menu_item_widget.dart';
import 'core/theme/app_theme.dart';

export 'package:colibri/core/extensions/context_exrensions.dart';
export 'package:colibri/core/extensions/string_extensions.dart';
export 'package:colibri/core/extensions/text_extensions.dart';
export 'package:colibri/core/extensions/widget_extensions.dart';

extension DioExtension on DioError {
  String get handleError {
    String errorDescription = "";
    try {
      switch (this.type) {
        case DioErrorType.connectTimeout:
          errorDescription = "Connection timeout with API server";
          break;
        case DioErrorType.sendTimeout:
          errorDescription = "Send timeout";
          break;
        case DioErrorType.receiveTimeout:
          errorDescription = "Receive timeout";
          break;
        case DioErrorType.response:
          errorDescription = "${response!.data["error"]["error"][0]}";
          break;
        case DioErrorType.cancel:
          errorDescription = "Request to API server was cancelled";
          break;
        case DioErrorType.other:
          errorDescription = "Request failed due to internet connection";
          break;
      }
    } catch (e) {
      errorDescription = "Something went wrong";
    }
    return errorDescription;
  }
}

extension ScreenUtilExtension on num {
  num get toSp => ScreenUtil().setSp(this);

  num get toWidth => ScreenUtil().setWidth(this);

  num get toHeight => ScreenUtil().setHeight(this);

  num get toHorizontal => ScreenUtil().setWidth(this);

  num get toVertical => ScreenUtil().setHeight(this);

  SizedBox get toSizedBox => SizedBox(
        height: this.h,
        width: this.w,
      );

  SizedBox get toSizedBoxVertical => SizedBox(height: this.h);

  SizedBox get toSizedBoxHorizontal => SizedBox(width: this.w);

  Widget toContainer({required num height, required num width, Color? color}) =>
      Container(
        color: color,
        width: width.w,
        height: height.h,
      );
  RoundedRectangleBorder get toRoundRectTop => RoundedRectangleBorder(
      borderRadius:
          BorderRadius.vertical(top: Radius.circular(this as double)));
}

extension ExtensionContainer on Container {
  Container get autoScale => Container(
        width: this.constraints!.maxWidth.w,
        height: this.constraints!.maxHeight.h,
      );
}

extension ListWidgetExtension on List<Widget?> {
  Column toColumn(
          {MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
          CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
          MainAxisSize mainAxisSize = MainAxisSize.min}) =>
      Column(
        children: this as List<Widget>,
        mainAxisSize: mainAxisSize,
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
      );

  ListView toListView(
          {MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
          CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
          MainAxisSize mainAxisSize = MainAxisSize.min}) =>
      ListView(
        children: this as List<Widget>,
      );

  ListView toListViewSeparated({required int itemCount, Widget? child}) =>
      ListView.separated(
        itemBuilder: (BuildContext context, int index) => child!,
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemCount: itemCount,
      );

  Row toRow(
          {MainAxisSize mainAxisSize = MainAxisSize.max,
          MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
          CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start}) =>
      Row(
        children: this as List<Widget>,
        mainAxisSize: mainAxisSize,
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
      );

  Wrap toWrap() => Wrap(
        children: this as List<Widget>,
        spacing: 3,
        // textDirection: TextDirection.rtl,
        //     runAlignment: WrapAlignment.ce,
        crossAxisAlignment: WrapCrossAlignment.center,
        // alignment: WrapAlignment.end,
      );
  Widget toPopWithMenuItems(StringToVoidFunc fun, {Widget? icon}) =>
      PopupMenuButton<MenuItemWidget>(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        icon: icon != null
            ? icon
            : const Icon(
                FontAwesomeIcons.ellipsisV,
                size: 20,
                color: Colors.grey,
              ),
        onSelected: (value) {
          fun.call(value.text);
        },
        padding: EdgeInsets.zero,
        itemBuilder: (context) {
          return this
              .map((choice) => PopupMenuItem<MenuItemWidget>(
                    height: 25.toHeight as double,
                    value: choice as MenuItemWidget?,
                    child: choice,
                  ))
              .toList();
        },
      ).toContainer();
}

extension ColmnExtension on Column {
  Widget makeScrollable({bool disableScroll = false}) => !disableScroll
      ? SingleChildScrollView(
          child: this,
        )
      : this;
}

extension TextFieldExtension on TextField {
  StreamBuilder<T> toStreamBuilder<T>({
    required StreamValidators<T> validators,
    TextInputType? keyboardType,
  }) {
    return StreamBuilder<T>(
      stream: validators.stream,
      builder: (context, snapshot) {
        print(snapshot.error);
        return TextField(
          keyboardType: keyboardType,
          maxLength: this.maxLength,
          maxLines: this.maxLines,
          style: AppTheme.button.copyWith(fontWeight: FontWeight.w500),
          obscureText: validators.obsecureTextBool,
          focusNode: validators.focusNode,
          textInputAction: validators.nextFocusNode == null
              ? TextInputAction.done
              : TextInputAction.next,
          controller: validators.textController,
          decoration: this.decoration!,
          onChanged: validators.onChange,
          inputFormatters: [LengthLimitingTextInputFormatter(this.maxLength)],
          onSubmitted: (value) {
            this.onSubmitted!(value);
            if (validators.nextFocusNode != null)
              FocusScope.of(context).requestFocus(validators.nextFocusNode);
          },
        );
      },
    );
  }

  Widget toPostBuilder<T>({
    required StreamValidators<T> validators,
    VoidCallback? fun,
    bool autofocus = false,
    FocusNode? focusNode,
    int maxLength = 600,
  }) =>
      StreamBuilder<T>(
        stream: validators.stream,
        builder: (context, snapshot) => TextField(
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          maxLength: maxLength,
          autofocus: autofocus,
          maxLines: this.maxLines,
          style: AppTheme.button.copyWith(fontWeight: FontWeight.w500),
          obscureText: validators.obsecureTextBool,
          focusNode: focusNode ?? validators.focusNode,
          controller: validators.textController,
          inputFormatters: [LengthLimitingTextInputFormatter(this.maxLength)],
          decoration:
              this.decoration!.copyWith(errorText: snapshot.error as String?),
          onChanged: (value) {
            if (fun != null) fun();
            if (validators.text.length < 601) {
              validators.onChange(value);
            } else {
              validators.onChange(value.substring(0, 599)[0]);
            }
          },
          onSubmitted: (value) {
            this.onSubmitted!(value);
            if (validators.nextFocusNode != null)
              FocusScope.of(context).requestFocus(validators.nextFocusNode);
          },
        ),
      );
}

extension BoolExtension on bool {
  bool get not => this == false;
}

extension ListStringExtension on List<String> {
  Widget toPopUpMenuButton(
    StringToVoidFunc fun, {
    Widget? icon,
    Color? backGroundColor,
    TextStyle? textStyle,
    Widget Function(String)? rowIcon,
  }) =>
      PopupMenuButton<String>(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        icon: icon != null
            ? icon
            : const Icon(
                FontAwesomeIcons.ellipsisV,
                size: 20,
                color: Colors.grey,
              ),
        onSelected: fun,
        offset: Offset(0, 25.h),
        color: Color.fromARGB(255, 243, 243, 243).withOpacity(.96),
        padding: EdgeInsets.only(left: 10, bottom: 10),
        elevation: 0,
        itemBuilder: (context) {
          List<PopupMenuEntry<String>> _menuList = [];
          for (int i = 0; i < this.length; i++) {
            final String choice = this[i];
            _menuList.add(PopupMenuItem<String>(
              value: choice,
              textStyle: TextStyle(),
              height: 0,
              child: [
                choice.toCaption(color: backGroundColor, fontSize: 13),
                if (rowIcon != null)
                  Container(
                    child: rowIcon(choice),
                  ),
              ].toRow(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
              ),
            ));

            if (i < this.length - 1) _menuList.add(PopupMenuDivider());
          }

          return _menuList;
        },
      ).toContainer();
}

typedef StringToVoidFunc = void Function(String?);
typedef IntToVoidFunc = void Function(int);

extension FileExtension on File {
  Future<MediaInfo?> get compressVideo async =>
      await VideoCompress.compressVideo(
        this.path,
        quality: VideoQuality.LowQuality,
        deleteOrigin: false, // It's false by default
      );

  Future<File> get getThumbnail async => await VideoCompress.getFileThumbnail(
        this.path,
        quality: 50, // default(100)
      );
}

extension PostListExtensions on List<PostEntity> {
  bool get isLastPage {
    if (this.last.isAdvertisement! && this.length == ApiConstants.pageSize + 1)
      return false;
    return !this.last.isAdvertisement! && this.length < ApiConstants.pageSize;
  }

  PostEntity get getItemWithoutAd {
    if (this.last.isAdvertisement!) return this[this.length - 2];
    return this.last;
  }
}
