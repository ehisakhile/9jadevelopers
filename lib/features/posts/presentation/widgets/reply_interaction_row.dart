import 'package:colibri/core/config/strings.dart';

import '../../../../core/theme/app_icons.dart';

import '../../../../core/widgets/media_picker.dart';
import '../../../../extensions.dart';
import '../../../feed/presentation/widgets/create_post_card.dart';
import '../bloc/createpost_cubit.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:giphy_picker/giphy_picker.dart';
import 'package:velocity_x/src/flutter/gesture.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as em;

class ReplyInteractionRow extends StatelessWidget {
  const ReplyInteractionRow({
    Key? key,
    required this.createPostCubit,
    required this.threadID,
  }) : super(key: key);
  final CreatePostCubit? createPostCubit;
  final int? threadID;
  @override
  Widget build(BuildContext context) {
    return [
      StreamBuilder<bool>(
        stream: createPostCubit!.imageButton,
        initialData: true,
        builder: (_, snapshot) => AppIcons.imageIcon(
          enabled: snapshot.data!,
          height: 20,
          width: 20,
        ).onInkTap(
          () async {
            if (snapshot.data!)
              await openMediaPicker(
                context,
                (image) {
                  createPostCubit!.addImage(image);
                },
                mediaType: MediaTypeEnum.IMAGE,
              );
          },
        ),
      ),
      20.toSizedBoxHorizontal,
      StreamBuilder<bool>(
        stream: createPostCubit!.videoButton,
        initialData: true,
        builder: (_, snapshot) => AppIcons.videoIcon(
          enabled: snapshot.data!,
          height: 20,
          width: 20,
        ).onInkTap(
          () async {
            if (snapshot.data!)
              await openMediaPicker(context, (video) {
                createPostCubit!.addVideo(video!);
              }, mediaType: MediaTypeEnum.VIDEO);
          },
        ),
      ),
      20.toSizedBoxHorizontal,
      AppIcons.smileIcon(height: 17, width: 17).onInkTap(() {
        showEmojiSheet(context);
      }),
      20.toSizedBoxHorizontal,
      StreamBuilder<bool>(
        stream: createPostCubit!.gifButton,
        initialData: true,
        builder: (context, snapshot) => AppIcons.createSearchIcon(
                enabled: snapshot.data!, height: 20, width: 20)
            .onInkTap(
          () async {
            if (snapshot.data!) {
              final gif = await GiphyPicker.pickGif(
                context: context,
                apiKey: Strings.giphyApiKey,
              );
              if (gif?.images.original?.url != null)
                createPostCubit!.addGif(gif?.images.original?.url);
            }
            // context.showModelBottomSheet(GiphyImage.original(gif: gif));
          },
        ),
      ),
      StreamBuilder<bool>(
        stream: createPostCubit!.enablePublishButton,
        initialData: false,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return [
            "Reply"
                .toCaption(color: Colors.white, fontWeight: FontWeight.bold)
                .toMaterialButton(
              () {
                createPostCubit!.createPost(threadId: threadID.toString());
              },
              enabled: snapshot.data,
            )
          ]
              .toRow(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end)
              .toContainer(height: 30)
              .toExpanded();
        },
      ),
    ]
        .toRow(crossAxisAlignment: CrossAxisAlignment.center)
        .toSymmetricPadding(12, 8);
  }

  void showEmojiSheet(BuildContext context) {
    context.showModelBottomSheet(
      em.EmojiPicker(
        onEmojiSelected: (_, Emoji emoji) {
          createPostCubit!.postTextValidator.textController.text =
              createPostCubit!.postTextValidator.text + emoji.emoji;
        },
      ).toContainer(
        height: context.getScreenWidth > 600 ? 300 : 250,
        color: Colors.transparent,
      ),
    );
  }
}
