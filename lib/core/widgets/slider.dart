import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../features/feed/presentation/widgets/link_fetch/thumbnail_link_preview.dart';
import 'media/media_slider.dart';
import '../common/add_thumbnail/check_link.dart';
import 'package:colibri/core/config/colors.dart';
import 'MediaOpener.dart';
import 'media/media_page_builder.dart';
import 'thumbnail_widget.dart';
import '../../features/feed/domain/entity/post_entity.dart';
import '../../features/feed/domain/entity/post_media.dart';
import '../../features/feed/presentation/widgets/create_post_card.dart';
import 'package:flutter/material.dart';
import '../../extensions.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:velocity_x/velocity_x.dart';

class CustomSlider extends StatefulWidget {
  final PostEntity? postEntity;
  final bool? isOnlySocialLink;
  final bool? isComeHome;
  final bool fromComments;
  final List<PostMedia>? mediaItems;
  final bool dialogView;
  final int currentIndex;
  final Function? onClickAction;
  final ogData;
  // final OgDataClass1  ogData;

  const CustomSlider(
      {Key? key,
      this.onClickAction,
      this.postEntity,
      this.isOnlySocialLink,
      this.mediaItems,
      this.dialogView = false,
      this.currentIndex = 0,
      this.fromComments = false,
      this.ogData,
      this.isComeHome})
      : super(key: key);
  @override
  _CustomSliderState createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {
  int _current = 0;
  late PageController pageController;

  final ValueNotifier<int> _pageNotifier = new ValueNotifier<int>(0);
  PageController _pageController = PageController();
  late PageController _pageControllerClick;

  @override
  void initState() {
    super.initState();

    _current = widget.currentIndex;
    pageController = PageController(initialPage: widget.currentIndex);
    _pageControllerClick = PageController(initialPage: 0);

    if (widget.mediaItems != null && widget.mediaItems!.length != 0) {
      print(widget.mediaItems![0].mediaType == MediaTypeEnum.IMAGE);
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    _pageController.dispose();
    _pageControllerClick.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String addOgText = '';
    final ogData = widget.postEntity!.ogData;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(50)),
      child: ogData != null
          ? ThumbnailLinkPreview(
              url: ogData.url!,
              linkDescription: ogData.description,
              linkTitle: ogData.title,
              linkImageUrl: ogData.image,
              isFeed: true,
            )
          : showGrid(widget.mediaItems?.length ?? 0),
    );
  }

  double heightSet() {
    if (widget.postEntity?.ogData != null) {
      return 135.0;
    } else {
      if (widget.isOnlySocialLink!) {
        return context.getScreenHeight * .23;
      } else {
        if (widget.mediaItems != null && widget.mediaItems!.length != 0) {
          print(widget.mediaItems![0].mediaType == MediaTypeEnum.VIDEO);
          if (widget.mediaItems![0].mediaType == MediaTypeEnum.VIDEO) {
            return 135.0;
          } else {
            return 160.0;
          }
        } else {
          return 160.0;
        }
      }
    }
  }

  Widget showGrid(int length) {
    if (length == 1) {
      return Container(
        decoration: const BoxDecoration(
          // color: Colors.black,
          borderRadius: BorderRadius.all(
            Radius.circular(15),
          ),
        ),
        child: gridData(0, length),
      );
    } else if (length == 2) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            Container(
              height: 200.h,
              width: double.infinity,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.mediaItems?.length ?? 0,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: const BoxDecoration(
                        // color: Colors.black,
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                    child: twoImageShow(index, widget.mediaItems?.length),
                  );
                },
                onPageChanged: (index) {
                  setState(() {
                    print("Hello vishal $index");
                    _current = index;
                    _pageNotifier.value = index;
                    _pageControllerClick = PageController(initialPage: index);
                  });
                },
              ),
            ),
            Container(
              height: 6,
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(
                  right: 5,
                  top: 10,
                  left: MediaQuery.of(context).size.width / 1.65),
              alignment: Alignment.centerRight,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: ListView.builder(
                  controller: _pageController,
                  itemCount: widget.mediaItems?.length ?? 0,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return SizedBox(
                      height: 6,
                      width: _current == index ? 20 : 12,
                      child: Container(
                        height: 6,
                        width: _current == index ? 20 : 12,
                        margin: EdgeInsets.only(right: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          // shape: BoxShape.circle,
                          color: _current == index
                              ? Color(0xFF1D88F0)
                              : Color(0xFF1D88F0).withOpacity(0.7),
                        ),
                      ),
                    );
                  }),
            ),
          ],
        ),
      );
    } else if (length == 3 || length >= 3) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 1,
            child: Container(
              height: context.getScreenHeight * .223,
              margin: EdgeInsets.only(right: 0),
              decoration: const BoxDecoration(
                // color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                ),
              ),
              child: gridData(0, length),
            ),
          ),
          Flexible(
              flex: 1,
              child: Column(children: [
                Container(
                  height: context.getScreenHeight * .11,
                  decoration: const BoxDecoration(
                    // color: Colors.black,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(15),
                    ),
                  ),
                  child: gridData(1, length),
                ),
                Container(
                  height: widget.fromComments
                      ? context.getScreenHeight * .085
                      : context.getScreenHeight * .11,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: const BoxDecoration(
                      // color: Colors.black,
                      borderRadius:
                          BorderRadius.only(bottomRight: Radius.circular(15))),
                  child: gridData(2, length),
                ),
              ]))
        ],
      );
    } else {
      return Container();
    }
  }

  twoImageShow(int itemIndex, int? length) {
    if (widget.mediaItems![itemIndex].mediaType == MediaTypeEnum.IMAGE) {
      return ClipRRect(
          borderRadius: BorderRadius.circular(0),
          child: CachedNetworkImage(
              imageUrl: widget.mediaItems![itemIndex].url!,
              width: context.getScreenWidth as double?,
              height: 180,
              fit: BoxFit.cover,
              progressIndicatorBuilder: (_, ___, progress) {
                Vx.teal100;
                return const CircularProgressIndicator()
                    .toPadding(8)
                    .toCenter();
              })).toHorizontalPadding(0).onTapWidget(
        () {
          if (!widget.dialogView)
            Navigator.of(context).push(
              MediaPageBuilder(
                MediaSlider(
                  postEntity: widget.postEntity,
                  onClickAction: widget.onClickAction,
                  length: length,
                  mediaType: widget.mediaItems![itemIndex].mediaType!,
                  mediaUrls: widget.mediaItems,
                  pageControllerClick: _pageControllerClick,
                  startDuration: Duration(seconds: 0),
                ),
              ),
            );
        },
      );
    } else if (widget.mediaItems![itemIndex].mediaType == MediaTypeEnum.VIDEO) {
      GlobalKey<MyVideoPlayerState> videoKey = GlobalKey();
      return ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: MyVideoPlayer(
          withAppBar: false,
          key: videoKey,
          path: widget.mediaItems![itemIndex].url,
        ),
      ).onTapWidget(
        () {
          videoKey.currentState!.pause();
          showAnimatedDialog(
            barrierDismissible: true,
            context: context,
            builder: (c) => MyVideoPlayer(
              path: widget.mediaItems![itemIndex].url,
              withAppBar: false,
              fullVideoControls: true,
            ),
          );
        },
      );
    } else if (widget.mediaItems![itemIndex].mediaType == MediaTypeEnum.GIF) {
      return GiphyWidget(
        path: widget.mediaItems![itemIndex].url,
        enableClose: false,
      ).toContainer(color: Colors.red);
    } else if (widget.mediaItems![itemIndex].mediaType == MediaTypeEnum.EMOJI) {
      return GiphyWidget(
        path: widget.mediaItems![itemIndex].url,
      ).toContainer(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)));
    }
  }

  gridData(int itemIndex, int length) {
    if (widget.mediaItems == null || widget.mediaItems!.length == 0) {
      return Container();
    } else {
      if (widget.mediaItems![itemIndex].mediaType == MediaTypeEnum.IMAGE) {
        return ClipRRect(
          borderRadius: boarderRadiusCheck(itemIndex, length),
          child: CachedNetworkImage(
            imageUrl: widget.mediaItems![itemIndex].url!,
            width: context.getScreenWidth as double?,
            fit: BoxFit.cover,
            progressIndicatorBuilder: (_, ___, progress) {
              Vx.teal100;
              return const CircularProgressIndicator().toPadding(8).toCenter();
            },
          ),
        ).toHorizontalPadding(1).onTapWidget(
          () {
            print("cureenty index show $itemIndex");

            _pageControllerClick = PageController(initialPage: itemIndex);

            setState(() {});
            if (!widget.dialogView)
              Navigator.of(context).push(
                MediaPageBuilder(
                  MediaSlider(
                    postEntity: widget.postEntity,
                    onClickAction: widget.onClickAction,
                    length: length,
                    mediaType: widget.mediaItems![itemIndex].mediaType!,
                    mediaUrls: widget.mediaItems,
                    pageControllerClick: _pageControllerClick,
                    startDuration: Duration(seconds: 0),
                  ),
                ),
              );
          },
        );
      } else if (widget.mediaItems![itemIndex].mediaType ==
          MediaTypeEnum.VIDEO) {
        GlobalKey<MyVideoPlayerState> videoKey = GlobalKey();
        return ClipRRect(
          borderRadius: boarderRadiusCheck(itemIndex, length),
          child: MyVideoPlayer(
            withAppBar: false,
            key: videoKey,
            path: widget.mediaItems![itemIndex].url,
            isComeHome: widget.isComeHome,
          ).onTapWidget(
            () {
              Duration _startDuration = videoKey.currentState!.videoTimePlayed;
              videoKey.currentState!.pause();
              Navigator.of(context).push(
                MediaPageBuilder(
                  MediaSlider(
                    postEntity: widget.postEntity,
                    onClickAction: widget.onClickAction,
                    length: length,
                    mediaType: widget.mediaItems![itemIndex].mediaType!,
                    mediaUrls: widget.mediaItems,
                    pageControllerClick: _pageControllerClick,
                    startDuration: _startDuration,
                  ),
                ),
              );
            },
          ),
        );
      } else if (widget.mediaItems![itemIndex].mediaType == MediaTypeEnum.GIF) {
        return GiphyWidget(
          path: widget.mediaItems![itemIndex].url,
          enableClose: false,
          itemIndex: itemIndex,
          length: length,
        ).toContainer(color: Colors.red);
      } else if (widget.mediaItems![itemIndex].mediaType ==
          MediaTypeEnum.EMOJI) {
        return GiphyWidget(
          path: widget.mediaItems![itemIndex].url,
          itemIndex: itemIndex,
          length: length,
        ).toContainer(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)));
      } else {
        return Container();
      }
    }
  }

  boarderRadiusCheck(int itemIndex, int length) {
    if (length == 1) {
      return BorderRadius.circular(15);
    } else if (length == 2) {
      if (itemIndex == 0) {
        return const BorderRadius.only(
            topLeft: Radius.circular(15), bottomLeft: Radius.circular(15));
      } else {
        return const BorderRadius.only(
            topRight: Radius.circular(15), bottomRight: Radius.circular(15));
      }
    } else if (length == 3 || length >= 3) {
      if (itemIndex == 0) {
        return const BorderRadius.only(
            topLeft: Radius.circular(15), bottomLeft: Radius.circular(15));
      } else if (itemIndex == 1) {
        return const BorderRadius.only(topRight: Radius.circular(15));
      } else {
        return const BorderRadius.only(bottomRight: Radius.circular(15));
      }
    } else if (length == 4) {
      if (itemIndex == 0) {
        return const BorderRadius.only(topLeft: Radius.circular(15));
      } else if (itemIndex == 1) {
        return const BorderRadius.only(bottomLeft: Radius.circular(15));
      } else if (itemIndex == 2) {
        return const BorderRadius.only(topRight: Radius.circular(15));
      } else {
        return const BorderRadius.only(bottomRight: Radius.circular(15));
      }
    } else {
      return BorderRadius.circular(15);
    }
  }

  imageNotShow() {
    return Container(
      height: 130,
      width: 250,
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 12, right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: AppColors.sfBgColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
              CheckLink.removeHtmlTag(widget.postEntity?.ogData!.title!) ??
                  "Page not found!",
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 17,
                fontFamily: "CeraPro",
                color: Colors.black,
              ),
              maxLines: 1),
          const SizedBox(height: 5),
          Text(
              CheckLink.removeHtmlTag(
                      widget.postEntity?.ogData!.description!) ??
                  "Page not found!",
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                fontFamily: "CeraPro",
                color: AppColors.greyText,
              ),
              maxLines: 2),
          const SizedBox(height: 5),
          Text(
            CheckLink.removeHtmlTag(widget.postEntity?.ogData!.url) ??
                "Page link not found!",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
              fontFamily: "CeraPro",
              color: Theme.of(context).colorScheme.secondary,
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  /// convert from string to duration
  Duration parseDuration(String s) {
    int hours = 0;
    int minutes = 0;
    int micros;
    List<String> parts = s.split(':');
    if (parts.length > 2) {
      hours = int.parse(parts[parts.length - 3]);
    }
    if (parts.length > 1) {
      minutes = int.parse(parts[parts.length - 2]);
    }
    micros = (double.parse(parts[parts.length - 1]) * 1000000).round();
    return Duration(hours: hours, minutes: minutes, microseconds: micros);
  }
}
