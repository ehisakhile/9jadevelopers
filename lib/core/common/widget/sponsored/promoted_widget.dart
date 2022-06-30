import '../common_divider.dart';
import 'sponsored_body_widget.dart';
import 'sponsored_header.dart';

import '../../../../features/feed/domain/entity/post_entity.dart';
import 'package:flutter/material.dart';

class PromotedWidget extends StatefulWidget {
  const PromotedWidget({
    Key? key,
    required this.postEntity,
    required this.replyCountIncreased,
    required this.onTapRepost,
    required this.onLikeTap,
  }) : super(key: key);
  final PostEntity? postEntity;
  final ValueChanged<bool>? replyCountIncreased;
  final VoidCallback? onTapRepost;
  final VoidCallback? onLikeTap;

  @override
  State<PromotedWidget> createState() => _PromotedWidgetState();
}

class _PromotedWidgetState extends State<PromotedWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(height: 10),
          SponsoredHeader(
            advertisementEntity: widget.postEntity!.advertisementEntity,
          ),
          SizedBox(height: 10),
          SponsoredBodyWidget(widget.postEntity!.advertisementEntity),
          SizedBox(
            height: 10,
          ),
          commonDivider,
        ],
      ),
    );
  }
}
 // Padding(
          //   padding: const EdgeInsets.only(left: 70.0, right: 30),
          //   child: FeedInteractionRow(
          //     postEntity: widget.postEntity,
          //     onClickAction: _onClickAction,
          //     onLikeTap: widget.onLikeTap,
          //     onTapRepost: widget.onTapRepost,
          //     replyCountIncreased: widget.replyCountIncreased,
          //   ),
          // ),