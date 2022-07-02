import 'package:auto_route/auto_route.dart';
import 'package:colibri/core/config/colors.dart';
import 'package:colibri/core/config/strings.dart';
import 'package:colibri/features/feed/data/models/og_data.dart';
import 'package:colibri/features/feed/presentation/bloc/feed_cubit.dart';
import '../../../../core/theme/images.dart';
import '../../domain/entity/post_entity.dart';
import 'link_fetch/create_post_link_preview.dart';
import 'mention_suggestion_list.dart';
import '../../../posts/presentation/widgets/replying_media_row.dart';
import 'create_poll_container.dart';
import '../../../../translations/locale_keys.g.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as em;
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import '../../../../core/common/media/media_data.dart';
import '../../../../core/common/uistate/common_ui_state.dart';
import '../../../../core/constants/appconstants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/routes/routes.gr.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/MediaOpener.dart';
import '../../../../core/widgets/loading_bar.dart';
import '../../../../core/widgets/media_picker.dart';
import '../../../../core/widgets/slider.dart';
import '../../../../core/widgets/thumbnail_widget.dart';
import '../../../posts/domain/entiity/reply_entity.dart';
import '../../../posts/presentation/bloc/createpost_cubit.dart';
import '../../../posts/presentation/bloc/post_cubit.dart';
import '../../../profile/domain/entity/profile_entity.dart';
import '../../../search/presentation/bloc/search_cubit.dart';

import '../../../../main.dart';
import 'package:flutter/cupertino.dart';
import '../../../../extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:giphy_picker/giphy_picker.dart';
import 'package:timelines/timelines.dart';
import 'package:video_compress/video_compress.dart';
import 'package:easy_localization/easy_localization.dart';

import 'hashtag_suggestion_list.dart';

class CreatePostCard extends StatefulWidget {
  final String? threadId;
  final ReplyEntity? replyEntity;
  final VoidCallback? refreshHomeScreen;
  final Function? backData;
  final bool isCreatePost;
  final Function? onClickAction;
  final PostEntity? postEntity;
  final bool isCreateSwift;
  const CreatePostCard({
    Key? key,
    required this.isCreatePost,
    this.threadId,
    this.replyEntity,
    this.onClickAction,
    this.postEntity,
    this.refreshHomeScreen,
    this.backData,
    required this.isCreateSwift,
  }) : super(key: key);

  @override
  _CreatePostCardState createState() => _CreatePostCardState();
}

class _CreatePostCardState extends State<CreatePostCard> {
  String everyOneReplayTitle = LocaleKeys.everyone_can_reply.tr();

  CreatePostCubit? createPostCubit;
  CreatePostCubit? createPostCubit1;
  late Subscription sub;
  bool _isPoll = false;
  var loginResponse;

  late TextEditingController _controller1;
  late TextEditingController _controller2;
  late TextEditingController _controller3;
  late TextEditingController _controller4;
  late FocusNode _focusNode;
  @override
  void initState() {
    super.initState();
    linkTitle = "";
    linkDescription = "";
    linkImage = "";
    linkSiteName = "";
    linkUrl = "";
    _controller1 = TextEditingController();
    _controller2 = TextEditingController();
    _controller3 = TextEditingController();
    _controller4 = TextEditingController();
    _focusNode = FocusNode();
    try {
      createPostCubit = BlocProvider.of<CreatePostCubit>(context);
    } catch (e) {
      createPostCubit = getIt<CreatePostCubit>();
    }
    createPostCubit!.getUserData();
    loginData();

    if (VideoCompress.compressProgress$.notSubscribed)
      sub = VideoCompress.compressProgress$.subscribe((progress) {
        if (progress < 99.99)
          EasyLoading.showProgress(
            (progress / 100),
            status: 'Compressing ${progress.toInt()}%',
          );
        else
          EasyLoading.dismiss();
      });

    if (widget.replyEntity != null)
      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
        SystemChannels.textInput.invokeMethod('TextInput.show');
      });

    AC.searchCubitHash = getIt<SearchCubit>();
    AC.searchCubitA = getIt<SearchCubit>();
    AC.postCubit = getIt<PostCubit>();
    AC.textEditingController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _focusNode.requestFocus();
  }

  loginData() async {
    loginResponse = await localDataSource!.getUserAuth();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreatePostCubit, CommonUIState>(
      bloc: createPostCubit,
      listener: (_, state) {
        state.maybeWhen(
          orElse: () {},
          error: (e) => context.showSnackBar(message: e, isError: true),
          success: (s) {
            final _feedCubit = BlocProvider.of<FeedCubit>(context);
            if (s is String && s.isNotEmpty) {
              createPostCubit!.postTextValidator.textController.clear();
              createPostCubit!.mediaItems.clear();
              linkTitle = "";
              linkDescription = "";
              linkImage = "";
              linkSiteName = "";
              linkUrl = "";
              if (s == 'Post published')
                context.router
                    .pop()
                    .whenComplete(() => _feedCubit.onRefresh())
                    .whenComplete(
                      () => context.showSnackBar(message: s, isError: false),
                    );
              if (widget.backData != null) widget.backData!(0);
              if (widget.replyEntity != null) Navigator.of(context).pop(true);
            }
          },
        );
      },
      builder: (_, state) {
        return state.when(
            initial: () => Stack(
                  children: [
                    widget.replyEntity != null ? buildReplyView() : buildHome(),
                    LoadingBar().toVerticalPadding(8),
                  ],
                ),
            success: (s) =>
                widget.replyEntity != null ? buildReplyView() : buildHome(),
            loading: () => Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    widget.replyEntity != null ? buildReplyView() : buildHome(),
                    LoadingBar().toVerticalPadding(8),
                  ],
                ).toVerticalPadding(8),
            error: (e) =>
                widget.replyEntity != null ? buildReplyView() : buildHome());
      },
    );
  }

  Widget buildReplyView() {
    return StreamBuilder<ProfileEntity>(
        stream: createPostCubit!.drawerEntity,
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return LoadingBar().toContainer(
                height: context.getScreenHeight as double,
                alignment: Alignment.center);
          } else {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                FixedTimeline.tileBuilder(
                  builder: TimelineTileBuilder(
                    nodePositionBuilder: (c, index) => 0.0,
                    indicatorPositionBuilder: (c, index) => 0.0,
                    indicatorBuilder: (c, index) => Padding(
                      padding: const EdgeInsets.only(left: 24.0),
                      child: (index == 1
                          ? snapshot.data!.profileUrl!.toRoundNetworkImage()
                          : widget.replyEntity!.profileUrl!
                              .toRoundNetworkImage()),
                    ),
                    endConnectorBuilder: (c, index) => Padding(
                      padding: const EdgeInsets.only(left: 24.0),
                      child: (index == 0
                          ? const SolidLineConnector(
                              color: Colors.grey,
                            )
                          : const SolidLineConnector(
                              color: Colors.transparent,
                            )),
                    ),
                    contentsBuilder: (c, index) => index == 0
                        ? buildReplyTopView(widget.replyEntity!)
                        : [
                            10.toSizedBox,
                            "${widget.replyEntity == null ? 'What is happening? #Hashtag...@Mention' : LocaleKeys.post_a_reply.tr()}"
                                .toNoBorderTextField(
                                  colors: const Color(0xFF1D88F0),
                                )
                                .toPostBuilder(
                                    validators:
                                        createPostCubit!.postTextValidator,
                                    maxLength: widget.isCreateSwift ? 200 : 600)
                                .toHorizontalPadding(12),
                            Stack(
                              children: [
                                if (widget.replyEntity != null)
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: ReplyingMediaRow(createPostCubit),
                                  ),
                                HashTagSuggestionList(
                                  isComment: true,
                                  createPostCubit: createPostCubit,
                                ),
                                MentionSuggestionList(
                                  isComment: true,
                                  createPostCubit: createPostCubit,
                                ),
                              ],
                            )
                          ].toColumn(),
                    itemCount: 2,
                  ),
                ).toVerticalPadding(8),
                getPostInteractionBar(enableSideWidth: false)
                    .toHorizontalPadding(16),
              ],
            );
          }
        });
  }

  Widget buildHome() {
    return StreamBuilder<ProfileEntity>(
        stream: createPostCubit!.drawerEntity,
        builder: (context, snapshot) {
          if (snapshot.data == null)
            return Container(
              height: context.getScreenHeight as double?,
              child: LoadingBar(),
              alignment: Alignment.center,
            );
          return buildCreatePostCard(context, snapshot.data!);
        });
  }

  List textFiledData = [];
  void _clearData() {
    createPostCubit!.postTextValidator.textController.clear();
    for (int i = 0; i < createPostCubit!.mediaItems.length; i++)
      createPostCubit!.removedFile(i);
    linkTitle = "";
    linkDescription = "";
    linkImage = "";
    linkSiteName = "";
    linkUrl = "";
    _isPoll = false;
  }

  Widget buildCreatePostCard(BuildContext context, ProfileEntity data) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        [
          5.toSizedBox,
          Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: AppIcons.appLogo.toContainer(height: 35, width: 35),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: InkWell(
                    onTap: () {
                      _clearData();
                      context.router.root.pop();
                    },
                    child: Images.closeButton.toSvg(
                      color: AppColors.colorPrimary,
                      height: 30,
                      width: 30,
                    ),
                  ),
                ),
              )
            ],
          ),
          Expanded(
            child: ListView(
              children: [
                // profile url and textt field row
                [
                  Padding(
                    padding: EdgeInsets.only(
                      left: context.isArabic() ? 0 : 17,
                      right: !context.isArabic() ? 0 : 17,
                    ),
                    child: data.profileUrl!
                        .toRoundNetworkImage()
                        .toContainer(
                          alignment: Alignment.topCenter,
                        )
                        .onTapWidget(
                      () {
                        context.router.root.push(
                          ProfileScreenRoute(otherUserId: null),
                        );
                      },
                    ),
                  ),
                  (_isPoll
                          ? LocaleKeys.enter_your_question_here
                              .tr(namedArgs: {'@name@': data.firstName!})
                          : widget.isCreateSwift
                              ? 'Add text to swift'
                              : 'What\'s happening?')
                      .toNoBorderTextField(
                        colors: AppColors.optionIconColor,
                      )
                      .toPostBuilder(
                        validators: createPostCubit!.postTextValidator,
                        autofocus: true,
                        focusNode: _focusNode,
                        fun: () {
                          int cursorPos = createPostCubit!.postTextValidator
                              .textController.selection.base.offset;
                          print(cursorPos);
                        },
                      )
                      .toHorizontalPadding(5)
                      .toContainer(alignment: Alignment.topCenter)
                      .toFlexible(),
                ].toRow(),
                CreatePollContainer(
                  () => setState(
                    () {
                      _isPoll = false;
                    },
                  ),
                  controller1: _controller1,
                  controller2: _controller2,
                  controller3: _controller3,
                  controller4: _controller4,
                ).toVisibility(_isPoll),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, bottom: 15),
                  child: StreamBuilder<List<MediaData>>(
                      stream: createPostCubit!.images,
                      initialData: [],
                      builder: (context, snapshot) {
                        return AnimatedSwitcher(
                          key: UniqueKey(),
                          duration: const Duration(milliseconds: 500),
                          child: Wrap(
                              runSpacing: 20.0,
                              spacing: 5.0,
                              children: List.generate(
                                snapshot.data!.length,
                                (index) {
                                  return AnimatedSwitcher(
                                    duration:
                                        const Duration(milliseconds: 1000),
                                    child: getMediaWidget(
                                        snapshot.data![index], index),
                                  );
                                },
                              )).toContainer(),
                        );
                      }),
                ),
                StreamBuilder(
                  stream: createPostCubit!.postTextValidator.stream,
                  initialData: 0,
                  builder: (context, snapshot) {
                    final text =
                        createPostCubit!.postTextValidator.textController.text;
                    return CreatePostLinkPreview.showPostWiseData(
                      text,
                      setState,
                      context,
                    );
                  },
                ),
              ],
            ),
          ),
          getPostInteractionBar(),
        ].toColumn(mainAxisAlignment: MainAxisAlignment.spaceBetween),
        Positioned(
          top: context.getScreenHeight * .13,
          child: HashTagSuggestionList(
            height: context.getScreenHeight as double,
            width: context.getScreenWidth as double,
            isComment: false,
            createPostCubit: createPostCubit,
          ),
        ),
        Positioned(
          top: context.getScreenHeight * .15,
          child: MentionSuggestionList(
            height: context.getScreenHeight as double,
            width: context.getScreenWidth as double,
            isComment: false,
            createPostCubit: createPostCubit,
          ),
        ),
      ],
    );
  }

  Widget getMediaWidget(MediaData mediaData, int index) {
    switch (mediaData.type) {
      case MediaTypeEnum.IMAGE:
        return ThumbnailWidget(
          data: mediaData,
          onCloseTap: () async {
            await createPostCubit!.removedFile(index);
          },
        ).onTapWidget(
          () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (c) => MediaOpener(
                  data: mediaData,
                ),
              ),
            );
          },
        ).toContainer(width: context.getScreenWidth * .45);
      case MediaTypeEnum.VIDEO:
        return Stack(
          children: [
            ThumbnailWidget(
              data: mediaData,
              onCloseTap: () async {
                await createPostCubit!.removedFile(index);
              },
            ),
            const Positioned.fill(
                child: const Icon(
              FontAwesomeIcons.play,
              color: Colors.white,
              size: 45,
            )),
          ],
        ).toHorizontalPadding(12).onTapWidget(() {
          Navigator.of(context).push(CupertinoPageRoute(
              builder: (c) => MediaOpener(
                    data: mediaData,
                  )));
        });
      case MediaTypeEnum.GIF:
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: GiphyWidget(
            path: mediaData.path,
            fun: () async {
              await createPostCubit!.removedFile(index);
            },
          ),
        );
      case MediaTypeEnum.EMOJI:
        return ThumbnailWidget(data: mediaData);
      default:
        return Container();
    }
  }

  void showEmojiSheet(BuildContext context, {VoidCallback? onDismiss}) {
    context.showModelBottomSheet(
      em.EmojiPicker(
        onEmojiSelected: (_, Emoji emoji) {
          createPostCubit!.postTextValidator
            ..textController.text =
                createPostCubit!.postTextValidator.text + emoji.emoji
            ..changeData(createPostCubit!.postTextValidator.text);
        },
      ).toContainer(
        height: context.getScreenWidth > 600 ? 400 : 250,
        color: Colors.transparent,
      ),
      onDismiss: onDismiss,
    );
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    _controller4.dispose();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    sub.unsubscribe();
    _clearData();
    super.dispose();
  }

  Widget buildReplyTopView(ReplyEntity replyEntity) {
    return [
      [
        replyEntity.name!
            .toSubTitle1(
                (url) => context.router.root.push(WebViewScreenRoute(url: url)),
                fontWeight: FontWeight.bold)
            .toFlexible(),
        replyEntity.time!.toCaption(fontWeight: FontWeight.w500).toFlexible()
      ].toRow(mainAxisAlignment: MainAxisAlignment.spaceBetween),
      replyEntity.username1!.toCaption(fontWeight: FontWeight.w500),
      5.toSizedBox.toVisibility(replyEntity.description.isNotEmpty),
      replyEntity.description.toSubTitle1(
        (url) => context.router.root.push(WebViewScreenRoute(url: url)),
      ),
      10.toSizedBox.toVisibility(replyEntity.description.isNotEmpty),
      [
        "Replying to ".toCaption(fontWeight: FontWeight.w500),
        widget.replyEntity!.username1!.toSubTitle1(
            (url) => context.router.root.push(WebViewScreenRoute(url: url)),
            fontWeight: FontWeight.w500,
            color: AppColors.colorPrimary,
            fontSize: 12, onTapMention: (mention) {
          context.router.root.push(ProfileScreenRoute(otherUserId: mention));
        }),
        ' ${LocaleKeys.and.tr()} '
            .toCaption(fontWeight: FontWeight.w500)
            .toVisibility(
              widget.replyEntity!.username2.isNotEmpty &&
                  widget.replyEntity!.username2 !=
                      widget.replyEntity!.username1,
            ),
        widget.replyEntity!.username2.toSubTitle1(
            (url) => context.router.root.push(WebViewScreenRoute(url: url)),
            fontWeight: FontWeight.w500,
            color: AppColors.colorPrimary,
            fontSize: 12, onTapMention: (mention) {
          context.router.root.push(
            ProfileScreenRoute(otherUserId: mention),
          );
        }).toVisibility(widget.replyEntity!.username2.isNotEmpty &&
            widget.replyEntity!.username2 != widget.replyEntity!.username1)
      ].toRow(),
      10.toSizedBox.toVisibility(widget.replyEntity!.items.isNotEmpty),
      CustomSlider(
        mediaItems: widget.replyEntity!.items,
        isOnlySocialLink: false,
        ogData: null,
        fromComments: true,
        postEntity: widget.postEntity,
        onClickAction: widget.onClickAction,
      ).toVisibility(widget.replyEntity!.items.isNotEmpty)
    ].toColumn().toHorizontalPadding(20).toVerticalPadding(8);
  }

  String? linkTitle = "";
  String? linkDescription = "";
  String? linkImage = "";
  String? linkSiteName = "";
  String linkUrl = "";

  String tempLinkUrl = "";
  String textFiledValue = "";

  // String tempLinkUrl1 = "";

  Widget getPostInteractionBar({bool enableSideWidth = true}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          color: Colors.transparent,
          child: Padding(
            padding: EdgeInsets.only(left: 30, right: 20, bottom: 10, top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                StreamBuilder<int>(
                  // streaming the text length
                  stream: createPostCubit!.postTextValidator.stream.map(
                    (event) => event!.length,
                  ),
                  initialData: 0,
                  builder: (context, snapshot) {
                    String textLength = widget.isCreateSwift ? '200' : '600';
                    return Visibility(
                      visible: true,
                      child: "${snapshot.data}/$textLength".toCaption(
                        color: Color(0xFF737880),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        Container(
          height: 2,
          width: MediaQuery.of(context).size.width,
          color: AppColors.sfBgColor,
        ),
        [
          [
            if (context.getScreenWidth < 321 && enableSideWidth)
              20.toSizedBoxHorizontal,
            if (context.getScreenWidth > 321 && enableSideWidth)
              30.toSizedBoxHorizontal,
            StreamBuilder<bool>(
              stream: createPostCubit!.imageButton,
              initialData: true,
              builder: (context, snapshot) {
                return AppIcons.imageIcon(
                  enabled: snapshot.data! && !_isPoll,
                  height: 20,
                  width: 20,
                ).onTapWidget(
                  () async {
                    if (snapshot.data! && !_isPoll) {
                      await openMediaPicker(
                        context,
                        (image) {
                          createPostCubit!.addImage(image);
                        },
                        mediaType: MediaTypeEnum.IMAGE,
                        onDismiss: () => _focusNode.requestFocus(),
                      );
                    }
                  },
                );
              },
            ),
            20.toSizedBoxHorizontal,
            StreamBuilder<bool>(
                stream: createPostCubit!.videoButton,
                initialData: true,
                builder: (context, snapshot) {
                  return AppIcons.videoIcon(
                          enabled: snapshot.data! && !_isPoll,
                          height: 20,
                          width: 20)
                      .onTapWidget(() async {
                    if (snapshot.data! && !_isPoll)
                      await openMediaPicker(
                        context,
                        (video) {
                          createPostCubit!.addVideo(video!);
                        },
                        mediaType: MediaTypeEnum.VIDEO,
                        onDismiss: () => _focusNode.requestFocus(),
                      );
                  });
                }),
            20.toSizedBoxHorizontal,
            AppIcons.smileIcon(height: 17, width: 17).onTapWidget(
              () {
                showEmojiSheet(
                  context,
                  onDismiss: () => _focusNode.requestFocus(),
                );
              },
            ),
            20.toSizedBoxHorizontal,
            StreamBuilder<bool>(
              stream: createPostCubit!.gifButton,
              initialData: true,
              builder: (context, snapshot) {
                return AppIcons.createSearchIcon(
                        enabled: snapshot.data! && !_isPoll,
                        height: 20,
                        width: 20)
                    .onTapWidget(
                  () async {
                    if (snapshot.data! && !_isPoll) {
                      final gif = await GiphyPicker.pickGif(
                        context: context,
                        apiKey: Strings.giphyApiKey,
                      );
                      _focusNode.requestFocus();
                      if (gif?.images.original?.url != null)
                        createPostCubit!.addGif(gif?.images.original?.url);
                    }
                  },
                ).toVisibility(!widget.isCreateSwift);
              },
            ),
            20.toSizedBoxHorizontal,
            StreamBuilder<bool>(
              stream: createPostCubit!.pollButton,
              initialData: true,
              builder: (context, snapshot) {
                return InkWell(
                  onTap: !snapshot.data!
                      ? null
                      : () {
                          setState(() {
                            _isPoll = true;
                          });
                        },
                  child: AppIcons.pollIcon((snapshot.data! && !_isPoll))
                      .toVisibility(
                          widget.isCreatePost && !widget.isCreateSwift),
                );
              },
            ),
            [
              StreamBuilder<bool>(
                  stream: createPostCubit!.enablePublishButton,
                  initialData: false,
                  builder: (context, snapshot) {
                    return "${widget.replyEntity == null ? widget.isCreateSwift ? LocaleKeys.create_new_swift.tr() : LocaleKeys.publish.tr() : 'Reply'}"
                        .toCaption(color: Colors.white)
                        .toMaterialButton(() async {
                      final _createPostCubit =
                          BlocProvider.of<CreatePostCubit>(context);

                      List<Map<String, String>> _pollMap = [
                        {'value': _controller1.text},
                        {'value': _controller2.text},
                      ];
                      if (_controller3.text.isNotEmpty)
                        _pollMap.add(
                          {'value': _controller3.text},
                        );

                      if (_controller4.text.isNotEmpty)
                        _pollMap.add(
                          {'value': _controller4.text},
                        );
                      if (_isPoll &
                          (_controller1.text.isEmpty ||
                              _controller2.text.isEmpty)) {
                        context.showSnackBar(
                            message: 'Poll must at least contain 2 options',
                            isError: true);
                      } else
                        await createPostCubit!.createPost(
                          threadId: widget.threadId,
                          pollData: _isPoll ? _pollMap : null,
                          isPoll: _isPoll,
                        );
                    },
                            enabled: snapshot.data! ||
                                linkUrl.isNotEmpty).toHorizontalPadding(4);
                  }),
              10.toSizedBoxHorizontal
            ]
                .toRow(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end)
                .toExpanded()
          ]
              .toRow(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center)
              .toFlexible(),
        ].toRow(mainAxisAlignment: MainAxisAlignment.spaceBetween),
      ],
    );
  }
}

enum MediaTypeEnum { IMAGE, VIDEO, GIF, EMOJI }
