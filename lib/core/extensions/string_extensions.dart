import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:colibri/core/config/colors.dart';
import 'package:dio/dio.dart';
import 'package:file_utils/file_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_svg/svg.dart';
import 'package:html/parser.dart';
import 'package:http_parser/src/media_type.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:string_validator/string_validator.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:video_compress/video_compress.dart';

import '../../extensions.dart';
import '../../features/feed/presentation/widgets/create_post_card.dart';
import '../../features/feed/presentation/widgets/feed_widgets.dart';
import '../common/add_thumbnail/check_link.dart';
import '../common/validators.dart';
import '../common/widget/searc_bar.dart';
import '../theme/app_theme.dart';
import '../utils/post_helper/hashtag_linker.dart';
import '../utils/post_helper/mention_linker.dart';

extension StringExtensions on String {
  Future<MultipartFile> toMultiPart() async {
    final mimeTypeData =
        lookupMimeType(this, headerBytes: [0xFF, 0xD8])!.split('/');
    final multipartFile = await MultipartFile.fromFile(this,
        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));
    return multipartFile;
  }

  bool get isValidYoutubeOrNot =>
      (CheckLink.isYoutubeLink(this) && CheckLink.isValidYoutubeLink(this)) ||
      !CheckLink.isYoutubeLink(this);
  List<String> extractAllLinks() {
    final urlRegExp = new RegExp(
        r"((https?:www\.)|(https?:\/\/)|(www\.))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?");
    final urlMatches = urlRegExp.allMatches(this);
    List<String> urls = urlMatches
        .map((urlMatch) => this.substring(urlMatch.start, urlMatch.end))
        .toList();
    urls.removeWhere((url) => !isURL(url));
    return urls;
  }

  bool get isValidEmail {
    final emailRegExp = RegExp(r"^[a-zA-Z0-9.-_]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (this.isEmpty)
      return false;
    else
      return emailRegExp.hasMatch(this);
  }

  bool get isValidUrl {
    return urlPattern.hasMatch(this);
  }

  Future<MediaInfo?> get compressVideo async =>
      await VideoCompress.compressVideo(
        this,
        quality: VideoQuality.DefaultQuality,
        includeAudio: true,
        deleteOrigin: false, // It's false by default
      );
  Future<File> compressImage() async {
    final Directory tempDir = await getTemporaryDirectory();
    final file = File(this);
    print("file is ${file.path}");
    // unsupported compressed file
    if (getFormatType(file.path) == null) return file;
    final result = await (FlutterImageCompress.compressAndGetFile(
        file.path, File(tempDir.path + FileUtils.basename(this)).path,
        quality: 60, format: getFormatType(file.path)!));

    print(file.lengthSync());

    return result!;
  }

  CompressFormat? getFormatType(String name) {
    if (name.endsWith(".jpg") || name.endsWith(".jpeg"))
      return CompressFormat.jpeg;
    else if (name.endsWith(".png"))
      return CompressFormat.png;
    else if (name.endsWith(".heic"))
      return CompressFormat.heic;
    else if (name.endsWith(".webp")) return CompressFormat.webp;
    return null;
  }
}

extension StringExtension on String {
  String capitalize() => '${this[0].toUpperCase()}${this.substring(1)}';
  String capitalizedStringLetters() {
    try {
      String temp = '';
      this.split(' ').forEach((s) {
        temp += '${s[0].toUpperCase()}${s.substring(1)} ';
      });
      return temp;
    } catch (e) {
      return '${this[0].toUpperCase()}${this.substring(1)}';
    }
  }

  bool get isValidPass {
    if (this.isEmpty)
      return false;
    else
      return this.length > 7;
  }

  Text get toText => Text(
        parseHtmlString(this),
        style: const TextStyle(),
      );

  Text toHeadLine6({
    num fontSize = AppFontSize.headLine6,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.textColor,
  }) =>
      Text(
        parseHtmlString(this),
        style: AppTheme.headline6.copyWith(
          fontSize: fontSize.toSp as double?,
          color: color,
          fontWeight: fontWeight,
          fontFamily: "CeraPro",
        ),
        textAlign: TextAlign.start,
      );

  Text toHeadLine5(
          {num fontSize = AppFontSize.headLine5,
          Color color = AppColors.textColor}) =>
      Text(
        parseHtmlString(this),
        style: AppTheme.headline5
            .copyWith(fontSize: fontSize.toSp as double?, color: color),
      );

  Text toHeadLine4(
          {num fontSize = AppFontSize.headLine4,
          Color color = AppColors.textColor}) =>
      Text(
        parseHtmlString(this),
        style: AppTheme.headline4
            .copyWith(fontSize: fontSize.toSp as double?, color: color),
      );

  Text toHeadLine3(
          {num fontSize = AppFontSize.headLine3,
          Color color = AppColors.textColor}) =>
      Text(
        parseHtmlString(this),
        style: AppTheme.headline3
            .copyWith(fontSize: fontSize.toSp as double?, color: color),
      );

  Text toHeadLine2(
          {num fontSize = AppFontSize.headLine2,
          Color color = AppColors.textColor}) =>
      Text(
        parseHtmlString(this),
        style: AppTheme.headline2
            .copyWith(fontSize: fontSize.toSp as double?, color: color),
      );

  Text toHeadLine1(
          {num fontSize = AppFontSize.headLine1,
          Color color = AppColors.textColor}) =>
      Text(
        parseHtmlString(this),
        style: AppTheme.headline1
            .copyWith(fontSize: fontSize.toSp as double?, color: color),
      );

  Text toBody1(
          {num fontSize = AppFontSize.bodyText1,
          Color color = AppColors.textColor}) =>
      Text(
        parseHtmlString(this),
        style: AppTheme.bodyText1
            .copyWith(fontSize: fontSize.toSp as double?, color: color),
      );

  Text toBody2({
    int? maxLines,
    num fontSize = AppFontSize.bodyText2,
    FontWeight fontWeight = FontWeight.w400,
    Color? color = AppColors.textColor,
    String fontFamily1 = "",
  }) =>
      Text(
        parseHtmlString(this),
        maxLines: maxLines,
        style: AppTheme.bodyText2.copyWith(
            fontSize: fontSize.toSp as double?,
            color: color,
            fontWeight: fontWeight,
            fontFamily: fontFamily1),
      );

  Widget toSubTitle1(
    void Function(String) launchFunction, {
    num fontSize = AppFontSize.subTitle1,
    FontWeight fontWeight = FontWeight.w400,
    TextAlign align = TextAlign.left,
    ValueChanged<String>? onTapHashtag,
    ValueChanged<String>? onTapMention,
    Color color = AppColors.textColor,
    String fontFamily1 = "CeraPro",
    TextOverflow? overflow,
  }) =>
      Linkify(
        strutStyle: const StrutStyle(
          height: 1.0,
          forceStrutHeight: false,
        ),
        onOpen: (link) async {
          // closing keyboard
          FocusManager.instance.primaryFocus!.unfocus();
          SystemChannels.textInput.invokeMethod('TextInput.hide');
          if (await canLaunchUrlString(link.url)) {
            launchFunction(link.url);
          } else if (link.url.contains("#")) {
            onTapHashtag!.call(link.text.replaceAll("#", ""));
          } else if (link.url.contains('@'))
            onTapMention!.call(link.text.split("@")[1]);
          else {
            throw 'Could not launch $link';
          }
        },
        linkifiers: [
          const HashTagLinker(),
          const UrlLinkifier(),
          const EmailLinkifier(),
          const MentionLinker()
        ],
        overflow: overflow ?? TextOverflow.clip,
        text: parseHtmlString(this),
        style: AppTheme.subTitle1.copyWith(
            fontSize: fontSize.toSp as double?,
            // fontSize: fontSize.toSp,
            color: color,
            fontWeight: fontWeight,
            fontFamily: fontFamily1),
        linkStyle: const TextStyle(
            color: AppColors.colorPrimary, decoration: TextDecoration.none),
      );

  Text toSubTitle2({
    num fontSize = AppFontSize.subTitle2,
    FontWeight fontWeight = FontWeight.w500,
    TextAlign? align,
    int? maxLines,
    Color color = AppColors.textColor,
    String fontFamily1 = "",
  }) =>
      Text(
        parseHtmlString(this),
        textAlign: align,
        maxLines: maxLines,
        style: AppTheme.subTitle2.copyWith(
            fontSize: fontSize.toSp as double?,
            color: color,
            fontWeight: fontWeight,
            fontFamily: 'CeraPro'),
      );

  Text toButton(
          {num fontSize = AppFontSize.button,
          FontWeight fontWeight = FontWeight.w500,
          Color color = AppColors.textColor}) =>
      Text(
        parseHtmlString(this),
        style: AppTheme.button.copyWith(
            fontSize: fontSize.toSp as double?,
            color: color,
            fontWeight: fontWeight),
      );

  Linkify toCaption(
          {num fontSize = AppFontSize.caption,
          int? maxLines,
          TextAlign textAlign = TextAlign.start,
          FontWeight fontWeight = FontWeight.w400,
          TextOverflow textOverflow = TextOverflow.visible,
          Color? color = AppColors.textColor,
          Color linkColor = AppColors.colorPrimary}) =>
      Linkify(
        onOpen: (link) async {
          if (await canLaunchUrlString(link.url)) {
            await launchUrlString(link.url);
          } else {
            throw 'Could not launch $link';
          }
        },
        textAlign: textAlign,
        text: parseHtmlString(this),
        maxLines: maxLines,
        style: AppTheme.caption.copyWith(
          fontSize: fontSize.toSp as double?,
          color: color,
          fontWeight: fontWeight,
          fontFamily: "CeraPro",
        ),
        linkStyle: TextStyle(
          color: linkColor,
          fontFamily: "CeraPro",
          overflow: textOverflow,
        ),
      );

  TextField toTextField({
    StringToVoidFunc? onSubmit,
    StringToVoidFunc? onChange,
    String? errorText,
    int? maxLength,
    int maxLines = 1,
    TextInputType? keyboardType,
    TextEditingController? controller,
    TextInputAction? textInputAction,
    FocusNode? focusNode,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onVisibilityTap,
  }) =>
      TextField(
        focusNode: focusNode,
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength,
        maxLines: maxLines,
        style: AppTheme.button.copyWith(fontWeight: FontWeight.w500),
        onChanged: onChange ?? null,
        textInputAction: textInputAction,
        onSubmitted: (value) {
          onSubmit!(value);
        },
        obscureText: isPassword && !isPasswordVisible,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(
              vertical: 12.toVertical as double,
              horizontal: 6.toHorizontal as double),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 1, color: Colors.red.withOpacity(.8)),
          ),
          suffixIcon: !isPassword
              ? null
              : GestureDetector(
                  child: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onTap: onVisibilityTap,
                ),
          errorBorder: OutlineInputBorder(
            borderSide:
                BorderSide(width: .8, color: Colors.red.withOpacity(.8)),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(width: 1, color: AppColors.placeHolderColor),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(width: 1, color: AppColors.colorPrimary),
          ),
          border: const OutlineInputBorder(),
          labelText: this,
          labelStyle: AppTheme.caption.copyWith(
              fontWeight: FontWeight.w500, color: AppColors.placeHolderColor),
          errorStyle: AppTheme.caption
              .copyWith(color: Colors.red, fontWeight: FontWeight.w500),
          errorText: errorText,
        ),
      );

  Widget toSearchBarField({
    StringToVoidFunc? onTextChange,
    FocusNode? focusNode,
    TextEditingController? textEditingController,
  }) =>
      SearchBar(onTextChange, this, focusNode, textEditingController);

  TextField toNoBorderTextField({
    Color? colors,
    int? maxlines = null,
    VoidCallback? onTap,
  }) =>
      TextField(
        style: AppTheme.button.copyWith(fontWeight: FontWeight.w500),
        maxLines: maxlines,
        maxLength: 600,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(8),
          counter: const Offstage(),
          hintText: this,
          border: InputBorder.none,
          hintStyle: AppTheme.caption.copyWith(
            fontWeight: FontWeight.w500,
            color: colors,
            fontSize: 16,
            fontFamily: "CeraPro",
          ),
        ),
      );

  SvgPicture toSvg({num height = 15, num width = 15, Color? color}) =>
      SvgPicture.asset(this,
          color: color,
          width: width.toWidth as double?,
          height: width.toHeight as double?,
          semanticsLabel: 'A red up arrow');

  Image toAssetImage({double height = 50, double width = 50}) =>
      Image.asset(this,
          height: height.toHeight as double?, width: width.toWidth as double?);

  Widget toRoundNetworkImage({num radius = 10, num borderRadius = 60.0}) =>
      this.isValidUrl
          ? ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius.toDouble()),
              child: CircleAvatar(
                radius: radius.toHeight + (radius.toWidth as double),
                // backgroundImage:Image(),
                child: CachedNetworkImage(
                  imageUrl: this,
                ),
                backgroundColor: Colors.transparent,
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius.toDouble()),
              child: CircleAvatar(
                radius: radius.toHeight + (radius.toWidth as double),
                // backgroundImage:Image(),
                child: Image.file(
                  File(
                    this,
                  ),
                  fit: BoxFit.cover,
                  width: 100,
                ),
                backgroundColor: Colors.transparent,
              ),
            );

  Widget toNetWorkOrLocalImage(
          {num height = 50, num width = 50, num borderRadius = 20}) =>
      this.isValidUrl
          ? ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius.toDouble()),
              child: CachedNetworkImage(
                imageUrl: this,
                height: height.toHeight as double?,
                width: width.toWidth as double?,
                fit: BoxFit.cover,
              ),
            )
          : Image.file(
              File(this),
              fit: BoxFit.cover,
              width: width.toWidth as double?,
              height: height.toHeight as double?,
            );

  Widget toTab() => Tab(
        text: this,
      ).toContainer(
          alignment: Alignment.center,
          decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey, width: 0.2))));

  bool get toBool {
    final value = int.tryParse(this);
    if (value == null || value == 0) return false;
    return true;
  }

  String get parseHtml => parseHtmlString(this);

  bool get isVerifiedUser => this == "1" ? true : false;
}

extension StringExtensionNumber on String {
  bool get isValidPhone {
    return this.length >= 10;
  }

  String get inc => (int.tryParse(this)! + 1).toString();

  String get dec => (int.tryParse(this)! - 1) > 0
      ? (int.tryParse(this)! - 1).toString()
      : 0.toString();

  MediaTypeEnum? get getMediaType {
    if (this.contains("gif"))
      return MediaTypeEnum.IMAGE;
    else if (this.contains("png") ||
        this.contains("jpeg") ||
        this.contains("jpg")) return MediaTypeEnum.IMAGE;
    return MediaTypeEnum.VIDEO;
  }

  String get toTime {
    // DateFormat dateFormat = DateFormat().add_jms();
    final timeInMili = (int.tryParse(this)! * 1000);
    final DateFormat timeFormatter = DateFormat.jm();
    final DateFormat dateFormatter = DateFormat().add_MMMd().add_y();
    final String time = timeFormatter
        .format(DateTime.fromMillisecondsSinceEpoch(timeInMili, isUtc: false));
    final String date = dateFormatter
        .format(DateTime.fromMillisecondsSinceEpoch(timeInMili, isUtc: false));
    return "$time, $date";
  }

  PostOptionsEnum get getOptionsEnum {
    if (this == "Show likes")
      return PostOptionsEnum.SHOW_LIKES;
    else if (this == "Bookmark" || this == "UnBookmark")
      return PostOptionsEnum.BOOKMARK;
    else if (this == 'Block')
      return PostOptionsEnum.BLOCK;
    else if (this == 'Report Post') return PostOptionsEnum.REPORT;
    return PostOptionsEnum.DELETE;
  }
}

String parseHtmlString(String data) {
  if (!data.contains('href=')) return data;
  final document = parse(data);
  final hrefs = document
      .getElementsByTagName('a')
      .where((e) =>
          e.attributes.containsKey('href') &&
          e.attributes['target'] != null &&
          !e.text.startsWith('@'))
      .map((e) => e.attributes['href'])
      .toList();
  final oldLinks = document
      .getElementsByTagName('a')
      .where((e) =>
          e.attributes.containsKey('href') && e.attributes['target'] != null)
      .toList();
  String newData = data;
  for (int i = 0; i < hrefs.length; i++) {
    newData = newData.replaceAll(oldLinks[i].text, hrefs[i]!);
  }
  final newDocument = parse(newData);
  final String parsedString =
      parse(newDocument.body!.text).documentElement!.text;
  return parsedString;
}
