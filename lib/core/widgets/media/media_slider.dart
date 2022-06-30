import 'package:auto_route/src/router/auto_router_x.dart';
import '../../../features/feed/domain/entity/post_media.dart';
import '../../extensions/color_extension.dart';
import '../../extensions/context_exrensions.dart';
import '../../extensions/string_extensions.dart';
import '../../theme/images.dart';
import 'image_slider.dart';
import 'video_slider.dart';
import '../../../features/feed/domain/entity/post_entity.dart';
import '../../../features/feed/presentation/widgets/create_post_card.dart';
import '../../../features/feed/presentation/widgets/interaction_row.dart';
import 'package:flutter/material.dart';

class MediaSlider extends StatefulWidget {
  const MediaSlider({
    Key? key,
    required this.postEntity,
    required this.onClickAction,
    required this.length,
    required this.mediaType,
    required this.mediaUrls,
    required this.pageControllerClick,
    required this.startDuration,
  }) : super(key: key);
  final PostEntity? postEntity;
  final Function? onClickAction;
  final int? length;
  final MediaTypeEnum mediaType;
  final List<PostMedia>? mediaUrls;
  final PageController pageControllerClick;
  final Duration startDuration;
  @override
  State<MediaSlider> createState() => _MediaSliderState();
}

class _MediaSliderState extends State<MediaSlider> {
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: HexColor.fromHex('#24282E').withOpacity(1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            closeButton(),
            Expanded(
              child: widget.mediaType == MediaTypeEnum.VIDEO
                  ? VideoSlider(widget.mediaUrls![0].url!, widget.startDuration)
                  : PageView.builder(
                      itemCount: widget.length ?? 0,
                      controller: widget.pageControllerClick,
                      itemBuilder: (context, index) =>
                          ImageSlider(widget.mediaUrls![index].url!),
                    ),
            ),
            SizedBox(
              height: 10,
            ),
            InteractionRow(
              onClickAction: widget.onClickAction!,
              postEntity: widget.postEntity!,
            ),
            SizedBox(
              height: context.getScreenHeight * .1,
            )
          ],
        ),
      ),
    );
  }

  Widget closeButton() {
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
}
