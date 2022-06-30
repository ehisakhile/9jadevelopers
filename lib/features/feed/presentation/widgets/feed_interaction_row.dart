import 'package:colibri/core/config/colors.dart';

import '../../../../core/theme/app_icons.dart';

import '../../../../core/theme/images.dart';
import '../../../../extensions.dart';
import '../../domain/entity/post_entity.dart';
import '../../../posts/domain/entiity/reply_entity.dart';
import '../../../posts/presentation/pages/create_post.dart';
import '../../../../translations/locale_keys.g.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

class FeedInteractionRow extends StatelessWidget {
  const FeedInteractionRow({
    Key? key,
    required this.postEntity,
    required this.onClickAction,
    required this.onLikeTap,
    required this.onTapRepost,
    required this.replyCountIncreased,
  }) : super(key: key);
  final PostEntity? postEntity;
  final Function? onClickAction;
  final Function? onLikeTap;
  final Function? onTapRepost;
  final Function(bool)? replyCountIncreased;
  @override
  Widget build(BuildContext context) {
    return [
      [
        InkWell(
          onTap: () async {
            showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (c) => DraggableScrollableSheet(
                      initialChildSize: 1,
                      maxChildSize: 1,
                      minChildSize: 1,
                      expand: true,
                      builder: (BuildContext context, _) => Container(
                        margin: EdgeInsets.only(
                            top: MediaQueryData.fromWindow(
                          WidgetsBinding.instance!.window,
                        ).padding.top),
                        child: CreatePost(
                          postEntity: postEntity,
                          onClickAction: onClickAction,
                          isCreatePost: false,
                          title: LocaleKeys.post_a_reply.tr(),
                          replyTo: postEntity!.userName,
                          threadId: postEntity!.postId,
                          replyEntity: ReplyEntity.fromPostEntity(
                            postEntity: postEntity!,
                          ),
                        ),
                      ),
                    )).then((value) {
              if (value != null && value) replyCountIncreased!(true);
            });
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Images.comment
                  .toSvg(width: 12, height: 12, color: Color(0xFF737880)),
              Padding(
                padding: context.isArabic()
                    ? const EdgeInsets.only(bottom: 0, right: 5)
                    : const EdgeInsets.only(bottom: 0, left: 5),
                child: Text(
                  postEntity!.commentCount ?? "",
                  style: const TextStyle(
                      color: Color(0xFF737880),
                      fontFamily: "CeraPro",
                      fontWeight: FontWeight.w400,
                      fontSize: 14),
                ),
              )
            ],
          ),
        ),
        InkWell(
          onTap: () => onLikeTap!(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              postEntity!.isLiked == null
                  ? AppIcons.heartIcon(
                      color: AppColors.optionIconColor,
                    )
                  : postEntity!.isLiked!
                      ? AppIcons.filledHeartIcon()
                      : AppIcons.heartIcon(
                          color: AppColors.optionIconColor,
                        ),
              Padding(
                padding: context.isArabic()
                    ? const EdgeInsets.only(bottom: 0, right: 5)
                    : const EdgeInsets.only(bottom: 0, left: 5),
                child: Text(
                  postEntity!.likeCount ?? "0",
                  style: TextStyle(
                    color: postEntity!.isLiked == null
                        ? Color(0xFF737880)
                        : postEntity!.isLiked!
                            ? Colors.red
                            : Color(0xFF737880),
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
            onTapRepost!();
            if (!postEntity!.isReposted!) {
              context.showSnackBar(
                message: LocaleKeys.reposted.tr(
                  namedArgs: {'@uname@': 'Post'},
                ),
              );
            }
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 0),
                child: Images.repost.toSvg(
                  color: postEntity!.isReposted == null
                      ? Color(0xFF737880)
                      : postEntity!.isReposted!
                          ? AppColors.alertBg
                          : Color(0xFF737880),
                ),
              ),
              Padding(
                padding: context.isArabic()
                    ? const EdgeInsets.only(bottom: 0, right: 5)
                    : const EdgeInsets.only(bottom: 0, left: 5),
                child: Text(
                  postEntity!.repostCount ?? "",
                  style: TextStyle(
                    color: postEntity!.isReposted == null
                        ? Color(0xFF737880)
                        : postEntity!.isReposted!
                            ? AppColors.alertBg
                            : Color(0xFF737880),
                    fontFamily: "CeraPro",
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              )
            ],
          ),
        ),
        AppIcons.shareIcon().onTapWidget(
          () async {
            await Share.share(postEntity!.urlForSharing!);
          },
        )
      ]
          .toRow(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center)
          .toExpanded(),
    ].toRow(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly);
  }
}
