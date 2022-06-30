import '../../../../core/common/media/media_data.dart';
import '../../../../core/extensions/context_exrensions.dart';
import '../../../../core/extensions/widget_extensions.dart';
import '../../../../core/widgets/MediaOpener.dart';
import '../../../../core/widgets/thumbnail_widget.dart';
import '../../../feed/presentation/widgets/create_post_card.dart';
import '../bloc/createpost_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:velocity_x/src/flutter/gesture.dart';

class ReplyingMediaRow extends StatelessWidget {
  const ReplyingMediaRow(this.createPostCubit, {Key? key}) : super(key: key);
  final CreatePostCubit? createPostCubit;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0),
      child: StreamBuilder<List<MediaData>>(
          stream: createPostCubit!.images,
          initialData: [],
          builder: (context, snapshot) => Wrap(
                children: List.generate(
                  snapshot.data!.length,
                  (index) {
                    switch (snapshot.data![index].type) {
                      case MediaTypeEnum.IMAGE:
                        return ThumbnailWidget(
                          height: context.getScreenHeight * .1,
                          width: context.getScreenWidth * .3,
                          data: snapshot.data![index],
                          onCloseTap: () async {
                            await createPostCubit!.removedFile(index);
                          },
                        ).onInkTap(
                          () {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (c) => MediaOpener(
                                  data: snapshot.data![index],
                                ),
                              ),
                            );
                          },
                        ).toContainer(width: context.getScreenWidth * .35);

                      case MediaTypeEnum.VIDEO:
                        return Stack(
                          children: [
                            ThumbnailWidget(
                              height: context.getScreenHeight * .1,
                              width: context.getScreenWidth * .3,
                              data: snapshot.data![index],
                              onCloseTap: () async {
                                await createPostCubit!.removedFile(index);
                              },
                            ),
                            const Positioned.fill(
                              child: Icon(
                                FontAwesomeIcons.play,
                                color: Colors.white,
                                size: 45,
                              ),
                            ),
                          ],
                        ).onInkTap(
                          () {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (c) => MediaOpener(
                                  data: snapshot.data![index],
                                ),
                              ),
                            );
                          },
                        ).toContainer(width: context.getScreenWidth * .35);

                      case MediaTypeEnum.GIF:
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: GiphyWidget(
                            height: context.getScreenHeight * .2,
                            width: context.getScreenWidth * .4,
                            path: snapshot.data![index].path,
                            fun: () async {
                              await createPostCubit!.removedFile(index);
                            },
                          ),
                        );
                      case MediaTypeEnum.EMOJI:
                        return ThumbnailWidget(data: snapshot.data![index]);
                      default:
                        return Container();
                    }
                  },
                ),
              ).toContainer()),
    );
  }
}
