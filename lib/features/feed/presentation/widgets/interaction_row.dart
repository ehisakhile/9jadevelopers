import 'package:colibri/core/config/colors.dart';

import '../../../../core/extensions/context_exrensions.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../../../../core/extensions/widget_extensions.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/images.dart';
import '../../domain/entity/post_entity.dart';
import 'package:flutter/material.dart';

class InteractionRow extends StatefulWidget {
  const InteractionRow({
    Key? key,
    required this.onClickAction,
    required this.postEntity,
  }) : super(key: key);
  final Function onClickAction;
  final PostEntity? postEntity;

  @override
  State<InteractionRow> createState() => _InteractionRowState();
}

class _InteractionRowState extends State<InteractionRow> {
  late bool? _isLiked;
  late bool? _isRetweeted;
  int _likeCount = 0;
  int _retweetCount = 0;

  @override
  void initState() {
    super.initState();
    if (widget.postEntity != null) {
      _isLiked = widget.postEntity!.isLiked;
      _isRetweeted = widget.postEntity!.isReposted;
      _likeCount = int.parse(widget.postEntity!.likeCount!);
      _retweetCount = int.parse(widget.postEntity!.repostCount!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        InkWell(
          onTap: () {
            widget.onClickAction(0);
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 0),
                child: Images.comment.toSvg(
                  height: 14,
                  width: 14,
                  color: Colors.white,
                ),
              ),
              Padding(
                padding: context.isArabic()
                    ? const EdgeInsets.only(bottom: 0, right: 5)
                    : const EdgeInsets.only(bottom: 0, left: 5),
                child: Text(
                  widget.postEntity?.commentCount ?? "0",
                  style: const TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontFamily: "CeraPro",
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              )
            ],
          ),
        ),
        InkWell(
          onTap: () {
            widget.onClickAction(1);
            setState(() {
              if (widget.postEntity != null) {
                _isLiked = !_isLiked!;
                if (_isLiked!)
                  _likeCount++;
                else
                  _likeCount--;
              }
            });
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 0),
                child: _isLiked ?? false
                    ? AppIcons.filledHeartIcon(height: 14, width: 14)
                    : AppIcons.heartIcon(
                        color: Colors.white, height: 17, width: 17),
              ),
              Padding(
                padding: context.isArabic()
                    ? const EdgeInsets.only(bottom: 0, right: 5)
                    : const EdgeInsets.only(bottom: 0, left: 5),
                child: Text(
                  _likeCount.toString(),
                  style: TextStyle(
                    color: _isLiked ?? false ? Colors.red : Color(0xFFFFFFFF),
                    fontFamily: "CeraPro",
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              )
            ],
          ),
        ),
        InkWell(
          onTap: () {
            widget.onClickAction(2);
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            setState(() {
              if (_isRetweeted != null) {
                _isRetweeted = !_isRetweeted!;
                if (_isRetweeted!)
                  _retweetCount++;
                else
                  _retweetCount--;
              }
            });
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 0),
                child: _isRetweeted ?? false
                    ? AppIcons.repostIcon(
                        color: Colors.blue, height: 16, width: 16)
                    : AppIcons.repostIcon(
                        color: Colors.white, height: 16, width: 16),
              ),
              Padding(
                padding: context.isArabic()
                    ? const EdgeInsets.only(bottom: 0, right: 5)
                    : const EdgeInsets.only(bottom: 0, left: 5),
                child: Text(
                  _retweetCount.toString(),
                  style: TextStyle(
                    color: _isRetweeted ?? false
                        ? AppColors.alertBg
                        : Color(0xFFFFFFFF),
                    fontFamily: "CeraPro",
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              )
            ],
          ),
        ),
        AppIcons.shareIcon(color: Colors.white, height: 18, width: 18)
            .toPadding(0)
            .onTapWidget(() {
          widget.onClickAction(3);
        })
      ],
    );
  }
}
