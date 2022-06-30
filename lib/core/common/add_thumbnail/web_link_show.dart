// library simple_url_preview;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:colibri/core/config/colors.dart';
import 'package:colibri/core/routes/routes.gr.dart';
import 'package:colibri/features/feed/domain/entity/post_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:simple_url_preview/widgets/preview_description.dart';
// import 'package:simple_url_preview/widgets/preview_image.dart';
// import 'package:simple_url_preview/widgets/preview_site_name.dart';
import 'package:simple_url_preview/widgets/preview_title.dart';
import 'package:string_validator/string_validator.dart';
import 'package:auto_route/auto_route.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// Provides URL preview
class SimpleUrlPreviewWeb extends StatefulWidget {
  /// URL for which preview is to be shown
  final String url;

  /// Height of the preview
  final double previewHeight;

  final String? linkImageUrl;
  final String? linkTitle;
  final String? linkDescription;

  /// Whether or not to show close button for the preview
  final bool? isClosable;

  /// Background color
  final Color? bgColor;

  /// Style of Title.
  final TextStyle? titleStyle;

  /// Number of lines for Title. (Max possible lines = 2)
  final int titleLines;

  /// Style of Description
  final TextStyle? descriptionStyle;

  /// Number of lines for Description. (Max possible lines = 3)
  final int descriptionLines;

  /// Style of site title
  final TextStyle? siteNameStyle;

  /// Color for loader icon shown, till image loads
  final Color? imageLoaderColor;

  /// Container padding
  final EdgeInsetsGeometry? previewContainerPadding;

  /// onTap URL preview, by default opens URL in default browser
  final VoidCallback? onTap;

  final bool homePagePostCreate;
  final Function? clearText;

  final PostEntity? postEntity;

  SimpleUrlPreviewWeb({
    required this.url,
    this.previewHeight = 130.0,
    this.isClosable,
    this.bgColor,
    this.titleStyle,
    this.titleLines = 2,
    this.descriptionStyle,
    this.descriptionLines = 3,
    this.siteNameStyle,
    this.imageLoaderColor,
    this.previewContainerPadding,
    this.onTap,
    this.homePagePostCreate = false,
    this.clearText,
    this.postEntity,
    this.linkDescription,
    this.linkImageUrl,
    this.linkTitle,
  })  : assert(previewHeight >= 130.0,
            'The preview height should be greater than or equal to 130'),
        assert(titleLines <= 2 && titleLines > 0,
            'The title lines should be less than or equal to 2 and not equal to 0'),
        assert(descriptionLines <= 3 && descriptionLines > 0,
            'The description lines should be less than or equal to 3 and not equal to 0');

  @override
  _SimpleUrlPreviewWebState createState() => _SimpleUrlPreviewWebState();
}

class _SimpleUrlPreviewWebState extends State<SimpleUrlPreviewWeb> {
  late bool _isClosable;
  double? _previewHeight;
  TextStyle? _titleStyle;
  TextStyle? _descriptionStyle;
  Color? _imageLoaderColor;
  EdgeInsetsGeometry? _previewContainerPadding;
  VoidCallback? _onTap;

  bool isVideoPlay = false;
  //widget.homePagePostCreate true close icon show : -

  @override
  void initState() {
    super.initState();
    _getUrlData();
  }

  @override
  void didUpdateWidget(SimpleUrlPreviewWeb oldWidget) {
    super.didUpdateWidget(oldWidget);
    _getUrlData();
  }

  void _initialize() {
    _previewHeight = widget.previewHeight;
    _descriptionStyle = widget.descriptionStyle;
    _titleStyle = widget.titleStyle;
    _previewContainerPadding = widget.previewContainerPadding;
    _onTap = widget.onTap ?? _launchURL;
  }

  void _getUrlData() async {
    if (!isURL(widget.url)) {
      // setState(() {
      //   _urlPreviewData = null;
      // });
      return;
    }

    await DefaultCacheManager()
        .getSingleFile(widget.url)
        .catchError((error) {});

    if (!this.mounted) {
      return;
    }
    // setState(() {
    //   _urlPreviewData = null;
    // });
    return;
  }

  void _launchURL() async {
    // isVideoPlay = !isVideoPlay;
    // setState(() {});
    final encoded = Uri.encodeFull(widget.url);
    if (await canLaunchUrlString(encoded)) {
      String? title = widget.postEntity?.ogData?.title ?? widget.linkTitle;
      context.router.root
          .push(WebViewScreenRoute(url: widget.url, name0: title));
    } else {
      throw 'Could not launch ${widget.url}';
    }
  }

  @override
  Widget build(BuildContext context) {
    _isClosable = widget.isClosable ?? false;
    _imageLoaderColor =
        // ignore: deprecated_member_use
        widget.imageLoaderColor ?? Theme.of(context).accentColor;
    _initialize();

    // if (_urlPreviewData == null || !_isVisible) {
    //   return SizedBox();
    // }

    return GestureDetector(
      onTap: _onTap,
      child: Container(
        padding: _previewContainerPadding,
        height: _previewHeight,
        child: Stack(
          children: [
            _buildPreviewCard(context),
            _buildClosablePreview(),
            widget.homePagePostCreate
                ? Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: () {
                        // _onTap();
                        widget.clearText!();
                      },
                      child: Container(
                        height: 20,
                        width: 20,
                        margin: EdgeInsets.only(right: 20, top: 5),
                        decoration: BoxDecoration(
                            color: AppColors.twitterBlue,
                            shape: BoxShape.circle),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 15),
                      ),
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  Widget _buildClosablePreview() {
    return _isClosable
        ? Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: Icon(
                Icons.clear,
              ),
              onPressed: () {},
            ),
          )
        : SizedBox();
  }

  _buildPreviewCard(BuildContext context) {
    return Container(
      // elevation: 5,
      margin: EdgeInsets.only(
        left: widget.homePagePostCreate ? 70 : 0,
        right: widget.homePagePostCreate ? 15 : 0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
              flex: 6,
              child: PreviewImage(
                widget.postEntity?.ogData!.image ?? widget.linkImageUrl ?? '',
                _imageLoaderColor,
              )),
          Expanded(
            flex: 4,
            child: Container(
              padding: EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  PreviewTitle(
                    widget.postEntity?.ogData!.title ?? widget.linkTitle,
                    _titleStyle == null
                        ? const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            fontFamily: "CeraPro",
                            color: Colors.black,
                          )
                        : _titleStyle,
                    1,
                    // _titleLines
                  ),
                  PreviewDescription(
                    widget.postEntity?.ogData!.description ??
                        widget.linkDescription,
                    _descriptionStyle == null
                        ? const TextStyle(
                            fontSize: 10,
                            color: Colors.black,
                          )
                        : _descriptionStyle,
                    2,

                    // _descriptionLines,
                  ),
                  // PreviewSiteName(
                  //   widget.url,
                  //   // _urlPreviewData['og:site_name'],
                  //   _siteNameStyle == null
                  //       ? TextStyle(
                  //           fontSize: 10,
                  //           color: Theme.of(context).colorScheme.secondary,
                  //         )
                  //       : _siteNameStyle,
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows site name of URL
class PreviewSiteName extends StatelessWidget {
  final String _siteName;
  final TextStyle? _textStyle;

  PreviewSiteName(this._siteName, this._textStyle);

  @override
  Widget build(BuildContext context) {
    return Text(
      _siteName,
      textAlign: TextAlign.left,
      maxLines: 2,
      style: _textStyle,
    );
  }
}

/// Shows image of URL
class PreviewImage extends StatelessWidget {
  final String _image;
  final Color? _imageLoaderColor;

  PreviewImage(this._image, this._imageLoaderColor);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      child: CachedNetworkImage(
        imageUrl: _image,
        width: MediaQuery.of(context).size.width,
        fit: BoxFit.fill,
        errorWidget: (context, url, error) => Icon(
          Icons.error,
          color: _imageLoaderColor,
        ),
        progressIndicatorBuilder: (context, url, downloadProgress) => Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Container(
                height: 20,
                width: 20,
                margin: EdgeInsets.all(5),
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              ),
            ),
          ],
        ),
        /* progressIndicatorBuilder: (context, url, downloadProgress) => Icon(
            Icons.more_horiz,
            color: _imageLoaderColor,
          ),*/
      ),
    );
  }
}
