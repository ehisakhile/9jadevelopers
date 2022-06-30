import 'package:colibri/features/feed/data/models/og_data.dart';
import 'package:colibri/features/feed/presentation/widgets/link_fetch/thumbnail_link_preview.dart';
import 'package:colibri/features/posts/presentation/bloc/createpost_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:html/dom.dart' as htmlDom;
import 'package:html/parser.dart';

import '../../../../../../../core/extensions/string_extensions.dart';
import '../../../../../core/common/add_thumbnail/check_link.dart';

typedef SetStateFun = void Function(void Function());

class CreatePostLinkPreview {
  static String? _linkTitle = "";
  static String? _linkDescription = "";
  static String? _linkImage = "";
  static String _linkUrl = "";
  static String _tempLinkUrl = "";
  static List<String> canceledList = [];

  static void _getUrlData(
    String url,
    SetStateFun setState,
    BuildContext context,
  ) async {
    if (!url.isValidYoutubeOrNot) return;
    final _createPostCubit = BlocProvider.of<CreatePostCubit>(context);

    final response = await DefaultCacheManager().getSingleFile(url);

    final document = parse(await response.readAsString());

    Map data = {};
    _extractOGData(document, data, 'og:title');
    _extractOGData(document, data, 'og:description');
    _extractOGData(document, data, 'og:site_name');
    _extractOGData(document, data, 'og:image');
    _extractOGData(document, data, 'og:url');

    if (data.length == 5) {
      Future.delayed(
        Duration(seconds: 1),
        () {
          setState(() {
            _linkTitle = data['og:title'];
            _linkDescription = data['og:description'];
            _linkImage = data['og:image'];
            _linkUrl = url;
            _createPostCubit.ogDataMap = OgData(
              title: _linkTitle,
              description: _linkDescription,
              image: _linkImage,
              url: _linkUrl,
            );
          });
        },
      );
    }
  }

  static void _extractOGData(
    htmlDom.Document document,
    Map data,
    String parameter,
  ) {
    final titleMetaTag = document
        .getElementsByTagName("meta")
        .firstWhereOrNull((meta) => meta.attributes['property'] == parameter);

    if (titleMetaTag != null)
      data[parameter] = titleMetaTag.attributes['content'];
  }

  static Widget showPostWiseData(
    String title,
    SetStateFun setState,
    BuildContext context,
  ) {
    // Reset canceled list when title is empty
    if (title.isEmpty) canceledList.clear();
    // extract all links from text
    List<String> urls = title.extractAllLinks();
    // Remove all canceled links
    urls.removeWhere((element) => canceledList.contains(element));
    // If there is no link in text remove any link widget
    if (urls.isNotEmpty) _getUrlData(urls[0], setState, context);

    if (_tempLinkUrl.isEmpty && _linkUrl.isNotEmpty) {
      return ThumbnailLinkPreview(
        url: CheckLink.checkYouTubeLink(_linkUrl),
        linkTitle: _linkTitle,
        linkDescription: _linkDescription,
        linkImageUrl: _linkImage,
        clearText: () {
          _clearText();
          setState(() {});
        },
      );
    } else {
      return Container();
    }
  }

  static void _clearText() {
    canceledList.add(_linkUrl);
    _tempLinkUrl = "";
    _linkTitle = "";
    _linkDescription = "";
    _linkImage = "";
    _linkUrl = "";
  }
}
