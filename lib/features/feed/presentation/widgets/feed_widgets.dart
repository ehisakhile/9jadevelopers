import 'package:auto_route/auto_route.dart';
import 'package:colibri/core/config/colors.dart';
import 'feed_interaction_row.dart';
import 'post_header_row.dart';
import 'package:share/share.dart';
import 'poll_container.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import '../../../../core/common/widget/common_divider.dart';
import '../../../../translations/locale_keys.g.dart';
import '../../../../core/common/social_share/social_share.dart';
import '../../../../core/common/widget/menu_item_widget.dart';
import '../../../../core/constants/appconstants.dart';
import '../../../../core/routes/routes.gr.dart';
import '../../../../core/theme/app_icons.dart';

import '../../../../core/widgets/slider.dart';
import '../../../../extensions.dart';
import '../../domain/entity/post_entity.dart';
import '../pages/feed_screen.dart';
import '../../../posts/domain/entiity/reply_entity.dart';
import '../../../posts/presentation/bloc/post_cubit.dart';
import '../../../posts/presentation/pages/create_post.dart';
import '../../../profile/presentation/pages/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:remove_emoji/remove_emoji.dart';
import 'package:easy_localization/easy_localization.dart';

class PostItem extends StatefulWidget {
  final bool isComeHome;
  final bool showThread;
  final bool showArrowIcon;
  final bool otherUser;
  final bool isLiked;
  final PostEntity? postEntity;
  final VoidCallback? onLikeTap;
  final VoidCallback? onTapRepost;
  final StringToVoidFunc? onPostOptionItem;
  final bool detailedPost;
  final VoidCallback? onRefresh;
  final ValueChanged<String>? onTapMention;

  final ValueChanged<bool>? replyCountIncreased;

  final bool insideSearchScreen;

  final ProfileNavigationEnum profileNavigationEnum;
  const PostItem({
    Key? key,
    this.isComeHome = true,
    this.showThread = true,
    this.showArrowIcon = false,
    this.detailedPost = false,
    this.otherUser = false,
    this.isLiked = false,
    this.postEntity,
    this.onLikeTap,
    this.onRefresh,
    this.onTapRepost,
    this.onPostOptionItem,
    this.onTapMention,
    this.profileNavigationEnum = ProfileNavigationEnum.FROM_FEED,
    this.insideSearchScreen = false,
    this.replyCountIncreased,
  }) : super(key: key);

  @override
  _PostItemState createState() => _PostItemState(otherUser: otherUser);
}

class _PostItemState extends State<PostItem> {
  final bool otherUser;

  _PostItemState({this.otherUser = false});

  int currentIndex = 0;

  bool isKeyBoardShow = false;

  late final ScrollController _controller;

  String url1 = "";

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      checkIsKeyBoardShow();
    });
  }

  void checkIsKeyBoardShow() {
    KeyboardVisibilityController().onChange.listen(
      (bool visible) {
        print(visible);
        if (visible) {
          scrollAnimated(1000);
        }
        isKeyBoardShow = visible;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _postItem(otherUser: this.otherUser);
  }

  Widget _postItem({otherUser = false}) {
    return InkWell(
      onTap: () {
        context.router.root.push(
          ViewPostScreenRoute(
            threadID: widget.postEntity!.threadID,
            postEntity: widget.postEntity,
          ),
        );
      },
      child: Column(
        children: [
          widget.postEntity?.showRepostedText ?? false
              ? Padding(
                  padding: EdgeInsets.only(
                    left: context.isArabic() ? 0 : 73,
                    right: !context.isArabic() ? 10 : 40,
                    top: AC.getDeviceHeight(context) * 0.018,
                  ),
                  child: Row(
                    children: [
                      AppIcons.repostIcon(),
                      12.toSizedBox,
                      "${widget.postEntity!.reposterFullname.toString().toUpperCase()} REPOSTED"
                          .toSubTitle2(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            fontFamily1: "CeraPro",
                          )
                          .toEllipsis
                          .toFlexible()
                    ],
                  ),
                )
              : Container(),
          PostHeaderRow(
            detailedPost: widget.detailedPost,
            loginResponseFeed: loginResponseFeed,
            onPostOptionItem: widget.onPostOptionItem,
            postEntity: widget.postEntity,
          ),
          [
            if (!widget.detailedPost)
              20.toSizedBoxHorizontal
            else
              75.toSizedBoxHorizontal,
            [
              5.toSizedBox.toVisibility(widget.postEntity!.responseTo != null),
              if (widget.postEntity!.description.isNotEmpty)
                widget.postEntity!.description.toSubTitle1(
                    (url) => context.router.root.push(
                          WebViewScreenRoute(
                            url: url,
                          ),
                        ),
                    fontWeight: FontWeight.w400,
                    align: TextAlign.left,
                    fontSize: 14,
                    color: Colors.black,
                    fontFamily1: "CeraPro", onTapHashtag: (hTag) {
                  if (!widget.insideSearchScreen)
                    context.router.root.push(
                      SearchScreenRoute(
                        searchedText: RemoveEmoji().removemoji(hTag),
                      ),
                    );
                  else
                    BlocProvider.of<PostCubit>(context).searchedText = hTag;
                }, onTapMention: (mention) {
                  context.router.root
                      .push(ProfileScreenRoute(otherUserId: mention));
                }),
              5
                  .toSizedBox
                  .toVisibility(widget.postEntity!.description.isNotEmpty),
              const SizedBox(height: 5),
              if (widget.postEntity!.type == 'poll')
                PollContainer(
                  widget.postEntity!,
                )
              else
                Container(
                  child: imageVideoSliderData(),
                ),
              5.toSizedBox.toVisibility(widget.postEntity!.media.isNotEmpty),
              FeedInteractionRow(
                postEntity: widget.postEntity,
                onClickAction: _onClickAction,
                onLikeTap: widget.onLikeTap,
                onTapRepost: widget.onTapRepost,
                replyCountIncreased: widget.replyCountIncreased,
              ),
              Container(
                height: 2,
              ),
            ]
                .toColumn(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start)
                .toExpanded(flex: 10),
            10.toSizedBox.toExpanded(flex: 1)
          ].toRow(),
          commonDivider.toVisibility(widget.postEntity!.isConnected),
          7.toSizedBox,
        ],
      ),
    );
  }

  Widget getPostOptionMenu(
      bool showThread, bool showArrowIcon, bool otherUser) {
    return [
      MenuItemWidget(
        text: !widget.postEntity!.isSaved!
            ? LocaleKeys.bookmark.tr()
            : LocaleKeys.unbookmark.tr(),
        icon: AppIcons.bookmarkOption().toHorizontalPadding(2),
      ),
      MenuItemWidget(
        icon: AppIcons.likeOption(size: 14),
        text: LocaleKeys.show_likes.tr(),
      ),
      if (!widget.postEntity!.isOtherUser)
        MenuItemWidget(
          text: LocaleKeys.delete.tr(),
          icon:
              AppIcons.deleteOption(color: Colors.white).toHorizontalPadding(1),
        ),
    ]
        .toPopWithMenuItems((value) {
          widget.onPostOptionItem!(value);
        },
            icon: showArrowIcon
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey.withOpacity(.8),
                    ),
                  )
                : AppIcons.optionIcon)
        .toContainer(
          alignment: Alignment.topCenter,
        )
        .toExpanded(flex: 1);
  }

  bottomSheet() {
    return showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
              height: 200,
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(
                left: 30,
                right: 30,
                top: 15,
                bottom: 20,
              ),
              decoration: const BoxDecoration(
                color: Color(0xff0e8df1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: 6,
                    width: 37,
                    margin: EdgeInsets.only(bottom: 10),
                    decoration: const BoxDecoration(
                      color: const Color(0xff0560b2),
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            widget.onPostOptionItem!('Show likes');
                          },
                          child: Container(
                            height: 25,
                            margin: const EdgeInsets.only(top: 30),
                            child: Row(
                              children: [
                                AppIcons.showLikesIcon(color: Colors.white),
                                const SizedBox(width: 20),
                                Text(
                                  LocaleKeys.show_likes.tr(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "CeraPro",
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            widget.onPostOptionItem!(
                              !widget.postEntity!.isSaved!
                                  ? 'Bookmark'
                                  : "UnBookmark",
                            );
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 25,
                            margin: const EdgeInsets.only(top: 15),
                            child: Row(
                              children: [
                                AppIcons.bookmarkOption(),
                                const SizedBox(width: 20),
                                Text(
                                  !widget.postEntity!.isSaved!
                                      ? 'Bookmark'
                                      : "UnBookmark",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "CeraPro",
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        widget.postEntity!.isOtherUser &&
                                widget.postEntity!.userName !=
                                    loginResponseFeed!.data!.user!.userName
                            ? InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  widget.onPostOptionItem!('Report Post');
                                },
                                child: Container(
                                  height: 25,
                                  margin: const EdgeInsets.only(top: 15),
                                  child: Row(
                                    children: [
                                      AppIcons.reportIcon(color: Colors.white),
                                      const SizedBox(width: 20),
                                      Text(
                                        LocaleKeys.report_post.tr(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: "CeraPro",
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            : InkWell(
                                onTap: () {
                                  print("Hel");
                                  Navigator.pop(context);
                                  widget.onPostOptionItem!('Delete');
                                },
                                child: Container(
                                  height: 25,
                                  margin: const EdgeInsets.only(top: 10),
                                  child: Row(
                                    children: [
                                      AppIcons.deleteOption(
                                          color: Colors.white),
                                      const SizedBox(width: 20),
                                      Text(
                                        LocaleKeys.delete.tr(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: "CeraPro",
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                      ],
                    ),
                  )
                ],
              ),
            ));
  }

  reportBottomSheet() {
    return showMaterialModalBottomSheet(
      context: context,
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            height: 525,
            width: MediaQuery.of(context).size.width,
            padding:
                const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 10),
            decoration: const BoxDecoration(
              color: const Color(0xFFFFFFFF),
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: Offset(-1, 1),
                )
              ],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Column(
              children: [
                Container(
                  height: 60,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Color(0xFF1D88F0).withOpacity(0.09),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          height: 6,
                          width: 37,
                          margin: EdgeInsets.only(bottom: 5, top: 10),
                          decoration: BoxDecoration(
                            color: Color(0xFF045CB1).withOpacity(0.1),
                            borderRadius: BorderRadius.all(
                              Radius.circular(6),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 15, right: 15),
                        child: Text(
                          LocaleKeys.report_this_post.tr(),
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: "CeraPro",
                            fontWeight: FontWeight.w400,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                    child: Scrollbar(
                  controller: _controller,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                        left: 15,
                        right: 10,
                        top: 5,
                        bottom: isKeyBoardShow ? 310 : 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                height: 25,
                                margin: const EdgeInsets.only(top: 10),
                                child: Text(
                                  LocaleKeys.what_is_the_problem.tr(),
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: "CeraPro",
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                  ),
                                ),
                              )),
                        ),
                        const SizedBox(height: 15),
                        radioSelection(
                            LocaleKeys.this_is_spam.tr(), 0, setState),
                        const SizedBox(height: 20),
                        radioSelection(
                          LocaleKeys.misleading_or_fraudulent.tr(),
                          1,
                          setState,
                        ),
                        const SizedBox(height: 20),
                        radioSelection(
                          LocaleKeys.publication_of_private_information.tr(),
                          2,
                          setState,
                        ),
                        const SizedBox(height: 20),
                        radioSelection(
                          LocaleKeys.threats_of_violence_or_physical_harm.tr(),
                          3,
                          setState,
                        ),
                        const SizedBox(height: 20),
                        radioSelection(
                          LocaleKeys.i_am_not_interested_in_this_post.tr(),
                          4,
                          setState,
                        ),
                        const SizedBox(height: 20),
                        radioSelection("Other", 5, setState),
                        Container(
                          height: 2,
                          width: MediaQuery.of(context).size.width - 100,
                          margin: const EdgeInsets.only(top: 15, bottom: 20),
                          decoration: BoxDecoration(
                              color: const Color(0xFFE0EDF6),
                              borderRadius: BorderRadius.circular(1)),
                        ),
                        Text(
                          LocaleKeys.message_to_reviewer.tr(),
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: "CeraPro",
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                        Container(
                          height: 80,
                          margin: EdgeInsets.only(top: 10, bottom: 10),
                          padding: EdgeInsets.only(
                              left: 10, right: 10, top: 5, bottom: 5),
                          decoration: BoxDecoration(
                              color: Color(0xFFD8D8D8).withOpacity(0.4),
                              borderRadius: BorderRadius.circular(8)),
                          child: TextField(
                            maxLines: 5,
                            textInputAction: TextInputAction.newline,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                fontFamily: "CeraPro"),
                            decoration: InputDecoration(
                              hintText: LocaleKeys
                                  .please_write_briefly_about_the_problem_with_this_post
                                  .tr(),
                              hintStyle: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                fontFamily: "CeraPro",
                              ),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            height: 32,
                            width: 88,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: Color(0xFF1D89F1),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              LocaleKeys.send_report.tr(),
                              style: TextStyle(
                                color: Color(0xFF1D89F1),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ))
              ],
            ),
          );
        },
      ),
    );
  }

  radioSelection(String title, int index, StateSetter updateState) {
    return InkWell(
      onTap: () {
        currentIndex = index;
        updateState(() {});
      },
      child: Row(
        children: [
          Container(
            height: 15,
            width: 15,
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: currentIndex == index ? Color(0xFF1D89F1) : Colors.black,
                width: 1,
              ),
            ),
            child: currentIndex == index
                ? Container(
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  )
                : Container(),
          ),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: "CeraPro",
              ),
            ),
          )
        ],
      ),
    );
  }

  void scrollAnimated(double position) {
    if (_controller.hasClients) {
      _controller.animateTo(
        position,
        curve: Curves.ease,
        duration: Duration(seconds: 1),
      );
    }
  }

  imageVideoSliderData() {
    print(widget.postEntity?.ogData);

    if (widget.postEntity!.media.length != 0 ||
        (widget.postEntity?.ogData != null)) {
      return CustomSlider(
        isComeHome: widget.isComeHome,
        mediaItems: widget.postEntity?.media,
        postEntity: widget.postEntity,
        onClickAction: _onClickAction,
        ogData: widget.postEntity!.ogData,
        isOnlySocialLink: true,
      );
    } else
      Container();
  }

  void _onClickAction(int index) {
    if (index == 0) {
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (c) => DraggableScrollableSheet(
          initialChildSize: 1,
          maxChildSize: 1,
          minChildSize: 1,
          expand: true,
          builder: (BuildContext context, ScrollController scrollController) =>
              Container(
            margin: EdgeInsets.only(
                top: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                    .padding
                    .top),
            child: CreatePost(
              postEntity: widget.postEntity,
              onClickAction: _onClickAction,
              isCreatePost: false,
              title: LocaleKeys.post_a_reply.tr(),
              replyTo: widget.postEntity!.userName,
              backData: (value) {
                if (value != null && value) widget.replyCountIncreased!(true);
              },
              threadId: widget.postEntity!.postId,
              replyEntity:
                  ReplyEntity.fromPostEntity(postEntity: widget.postEntity!),
            ),
          ),
        ),
      ).then(
        (value) {
          if (value != null && value) widget.replyCountIncreased!(true);
        },
      );
    } else if (index == 1) {
      widget.onLikeTap!.call();
    } else if (index == 2) {
      widget.onTapRepost!.call();
      if (!widget.postEntity!.isReposted!) {
        context.showSnackBar(message: LocaleKeys.reposted.tr());
      }
    } else if (index == 3) {
      Share.share(widget.postEntity!.urlForSharing!);
    }
  }
}

enum PostOptionsEnum { SHOW_LIKES, BOOKMARK, DELETE, REPORT, BLOCK }

Widget buildPostButton(Widget icon, String count,
    {bool isLiked = false, Color? color}) {
  return [
    icon,
    5.toSizedBox,
    count.toBody2(
        fontWeight: FontWeight.w500,
        color: isLiked ? color : AppColors.textColor)
  ].toRow(crossAxisAlignment: CrossAxisAlignment.center);
}

Widget getShareOptionMenu(
    {MySocialShare? share, String? text, List<String>? files}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 4.0),
    child: [
      "Facebook",
      "Twitter",
      "LinkedIn",
      "Pinterest",
      "Reddit",
      "Copy Link"
    ].toPopUpMenuButton((value) {
      share?.shareToOtherPlatforms(text: text!, files: files);
    }, icon: AppIcons.shareIcon()).toContainer(height: 15, width: 15),
  );
}
