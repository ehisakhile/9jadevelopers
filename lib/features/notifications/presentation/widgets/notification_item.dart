import 'package:auto_route/auto_route.dart';
import 'package:colibri/core/config/colors.dart';
import '../../../../translations/locale_keys.g.dart';
import 'package:easy_localization/src/public_ext.dart';
import '../../../../core/routes/routes.gr.dart';
import '../../../../core/theme/images.dart';
import '../../domain/entity/notification_entity.dart';
import 'package:flutter/material.dart';
import '../../../../extensions.dart';

// ignore: must_be_immutable
class NotificationItem extends StatefulWidget {
  final NotificationEntity? notificationEntity;
  final ValueChanged<bool?>? onChanged;
  bool? isSelected;

  NotificationItem(
      {Key? key, this.notificationEntity, this.onChanged, this.isSelected})
      : super(key: key);

  @override
  _NotificationItemState createState() => _NotificationItemState();
}

class _NotificationItemState extends State<NotificationItem>
    with SingleTickerProviderStateMixin {
  AnimationController? animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return notificationItem(widget.notificationEntity!).onTapWidget(() {
      if (widget.notificationEntity!.postId != null &&
          widget.notificationEntity!.postId != "null") {
        // context.showSnackBar(message: widget.notificationEntity.postId);
        context.router.root.push(
          ViewPostScreenRoute(
            threadID: int.tryParse(widget.notificationEntity!.postId!),
            postEntity: null,
          ),
        );
      } else {
        context.router.root.push(
          ProfileScreenRoute(
            otherUserId: widget.notificationEntity!.userID,
          ),
        );
      }
    }, onLongPress: () {
      widget.onChanged!(!widget.isSelected!);
      setState(() {
        widget.isSelected = !widget.isSelected!;
      });
    });
  }

  Widget notificationItem(NotificationEntity notificationEntity) =>
      AnimatedContainer(
        width: widget.isSelected! ? context.getScreenWidth as double? : 0,
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
            color: widget.isSelected!
                ? AppColors.colorPrimary.withOpacity(.1)
                : Colors.transparent),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            notificationEntity.profileUrl!
                .toRoundNetworkImage(radius: 10)
                .toHorizontalPadding(8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  runSpacing: 2,
                  children: [
                    notificationEntity.name!
                        .toSubTitle2(fontWeight: FontWeight.w800, fontSize: 15)
                        .toHorizontalPadding(2),
                    Images.verified
                        .toSvg(height: 15, width: 15)
                        .toVisibility(widget.notificationEntity!.verifiedUser)
                        .toHorizontalPadding(2),
                    _translateNotificationMessage(notificationEntity.title)
                        .toSubTitle2(fontWeight: FontWeight.w500, fontSize: 13)
                        .toVerticalPadding(1),
                  ],
                ),
                5.toSizedBox,
                "${notificationEntity.time}"
                    .toCaption(maxLines: 2, fontSize: 11)
                    .toHorizontalPadding(4)
              ],
            ).toHorizontalPadding(8).toExpanded(),
            Checkbox(
              value: widget.isSelected,
              onChanged: (value) {
                // if (!mounted) return
                setState(() {
                  widget.isSelected = value;
                });
                widget.onChanged!(value);
              },
              shape: CircleBorder(),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              side: BorderSide(width: .9, color: AppColors.greyText),
            ).toContainer(alignment: Alignment.centerRight)
          ],
        ).toPadding(10).toContainer().makeBottomBorder,
      );

  String _translateNotificationMessage(String message) {
    switch (message) {
      case 'Replied to your post':
        return LocaleKeys.replied_to_your_post.tr();
      case 'Started following you':
        return LocaleKeys.started_following_you.tr();
      case 'Visited your profile':
        return LocaleKeys.visited_your_profile.tr();
      case 'Shared your publication':
        return LocaleKeys.shared_your_publication.tr();
      case 'Liked your post':
        return LocaleKeys.liked_your_post.tr();
      case 'Mentioned you in a post':
        return LocaleKeys.mentioned_you_in_a_post.tr();
      default:
        return message;
    }
  }
}
