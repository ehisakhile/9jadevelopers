import 'package:auto_route/src/router/auto_router_x.dart';
import 'package:colibri/core/config/colors.dart';
import '../../../../core/routes/routes.gr.dart';
import '../../../../extensions.dart';
import '../../../feed/domain/entity/post_entity.dart';
import '../../../feed/presentation/widgets/hashtag_suggestion_list.dart';
import '../../../feed/presentation/widgets/mention_suggestion_list.dart';
import '../bloc/createpost_cubit.dart';
import 'reply_interaction_row.dart';
import 'replying_media_row.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/src/flutter/container.dart';

class CreateReplyBox extends StatefulWidget {
  const CreateReplyBox({
    Key? key,
    required this.createPostCubit,
    required this.postItems,
    required this.threadID,
  }) : super(key: key);
  final CreatePostCubit? createPostCubit;
  final List<PostEntity> postItems;
  final int? threadID;
  @override
  State<CreateReplyBox> createState() => _CreateReplyBoxState();
}

class _CreateReplyBoxState extends State<CreateReplyBox> {
  int counter = -1;

  @override
  Widget build(BuildContext context) {
    counter++;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Column(
                children: [
                  _replyingToWidget(widget.postItems),
                  5.toSizedBox,
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ReplyingMediaRow(widget.createPostCubit),
                    ),
                  ),
                ],
              ),
              HashTagSuggestionList(
                isComment: true,
                createPostCubit: widget.createPostCubit,
              ),
              MentionSuggestionList(
                isComment: true,
                createPostCubit: widget.createPostCubit,
              ),
            ],
          ),
          "Reply".toNoBorderTextField().toStreamBuilder(
                validators: widget.createPostCubit!.postTextValidator,
              ),
          StreamBuilder<bool>(
              stream: widget.createPostCubit!.enablePublishButton,
              initialData: false,
              builder: (context, snapshot) {
                return ReplyInteractionRow(
                  createPostCubit: widget.createPostCubit,
                  threadID: widget.threadID,
                ).toVisibility(counter > 0 || snapshot.data!);
              }),
        ],
      ).toPadding(4).box.white.border(color: Colors.black12, width: 1).make(),
    );
  }

  Widget _replyingToWidget(List<PostEntity> postItems) {
    return [
      "Replying to".toCaption(),
      3.toSizedBoxHorizontal,
      postItems[0].userName!.toSubTitle1(
        (url) => context.router.root.push(WebViewScreenRoute(url: url)),
        onTapMention: (mention) {
          context.router.root.push(
            ProfileScreenRoute(
              otherUserId: postItems[0].otherUserId,
            ),
          );
        },
        fontSize: 12,
        color: AppColors.colorPrimary,
        fontWeight: FontWeight.bold,
      )
    ].toRow().toHorizontalPadding(8);
  }
}
