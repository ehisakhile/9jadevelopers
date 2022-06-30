import 'package:auto_route/auto_route.dart';
import 'package:colibri/core/config/colors.dart';
import 'package:colibri/core/extensions/string_extensions.dart';
import 'package:colibri/features/feed/presentation/widgets/link_fetch/thumbnail_image_preview.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_url_preview/widgets/preview_description.dart';
import 'package:simple_url_preview/widgets/preview_title.dart';
import 'package:string_validator/string_validator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../../../../../core/routes/routes.gr.dart';
import '../../../../../core/common/add_thumbnail/check_link.dart';
import '../../../../../core/theme/images.dart';
import '../../../../../core/widgets/circle_painter.dart';

class ThumbnailLinkPreview extends StatefulWidget {
  const ThumbnailLinkPreview({
    required this.url,
    this.linkImageUrl,
    this.clearText,
    this.linkDescription,
    this.linkTitle,
    this.isFeed = false,
    Key? key,
  }) : super(key: key);
  final bool isFeed;
  final String url;
  final String? linkImageUrl;
  final String? linkTitle;
  final String? linkDescription;
  final Function? clearText;

  @override
  State<ThumbnailLinkPreview> createState() => _ThumbnailLinkPreviewState();
}

class _ThumbnailLinkPreviewState extends State<ThumbnailLinkPreview> {
  @override
  void initState() {
    super.initState();
    _getUrlData();
  }

  void _getUrlData() async {
    if (!isURL(widget.url)) return;
    await DefaultCacheManager()
        .getSingleFile(widget.url)
        .catchError((error) {});
  }

  void _launchURL() {
    if (CheckLink.isValidYoutubeLink(widget.url))
      _videoLaunchUrl();
    else
      _websiteLaunchUrl();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230.h,
      child: Stack(
        children: [
          _buildPreviewCard(),
          if (!widget.isFeed)
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => widget.clearText!(),
                child: Container(
                  height: 20,
                  width: 20,
                  margin: EdgeInsets.only(right: 20, top: 5),
                  decoration: BoxDecoration(
                    color: AppColors.colorPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
              ),
            ),
          if (CheckLink.isValidYoutubeLink(widget.url))
            Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: _launchURL,
                child: Padding(
                  padding: widget.isFeed
                      ? EdgeInsets.only(bottom: 80.0.h, right: 30.w)
                      : EdgeInsets.only(bottom: 70.0.h, left: 70.w),
                  child: CustomPaint(
                    painter: CirclePainter(),
                    child: Container(
                      height: 45.h,
                      width: 45.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.colorPrimary,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 2.0),
                        child: const Icon(
                          FontAwesomeIcons.play,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _websiteLaunchUrl() async {
    if (await canLaunch(Uri.encodeFull(widget.url))) {
      context.router.root.push(
        WebViewScreenRoute(url: widget.url),
      );
    } else {
      throw 'Could not launch ${widget.url}';
    }
  }

  void _videoLaunchUrl() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    YoutubePlayerController _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayerController.convertUrlToId(widget.url)!,
      params: const YoutubePlayerParams(
        autoPlay: true,
        mute: false,
        showFullscreenButton: true,
      ),
    );
    showAnimatedDialog(
      barrierDismissible: true,
      barrierColor: AppColors.colorPrimary.withOpacity(1),
      context: context,
      builder: (c) => OrientationBuilder(
        builder: (_, orientation) {
          return Stack(
            children: [
              SafeArea(
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
              ),
              Center(
                child: YoutubePlayerControllerProvider(
                  controller: _controller,
                  child: YoutubePlayerIFrame(
                    aspectRatio: 16 / 9,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ).whenComplete(
      () =>
          SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
    );
  }

  Widget _buildPreviewCard() {
    return Container(
      margin: widget.isFeed
          ? EdgeInsets.zero
          : EdgeInsets.only(left: 70, right: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.dividerColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 8,
                child: ThumbnailImagePreview(widget.linkImageUrl!),
              ),
              Expanded(
                flex: 4,
                child: Container(
                  padding: EdgeInsets.all(8),
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: PreviewTitle(
                          widget.linkTitle,
                          TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            fontFamily: "CeraPro",
                            color: Colors.black,
                          ),
                          2,
                        ),
                      ),
                      PreviewDescription(
                        widget.linkDescription,
                        TextStyle(
                          fontSize: 12,
                          color: AppColors.textColor,
                          fontFamily: 'CeraPro',
                        ),
                        null,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _launchURL,
                splashColor: Colors.black12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
