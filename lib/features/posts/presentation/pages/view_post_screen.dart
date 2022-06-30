import 'package:auto_route/auto_route.dart';
import 'package:colibri/core/config/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelines/timelines.dart';
import '../../../../core/common/uistate/common_ui_state.dart';
import '../../../../core/constants/appconstants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/routes/routes.gr.dart';
import '../../../../core/widgets/loading_bar.dart';
import '../../../../extensions.dart';
import '../../../feed/domain/entity/post_entity.dart';
import '../../../feed/presentation/widgets/feed_widgets.dart';
import '../../../feed/presentation/widgets/no_data_found_screen.dart';
import '../../../search/presentation/bloc/search_cubit.dart';
import '../bloc/createpost_cubit.dart';
import '../bloc/view_post_cubit.dart';
import '../widgets/create_reply_box.dart';
import '../widgets/report_post_widget.dart';
import 'show_likes_screen.dart';

class ViewPostScreen extends StatefulWidget {
  final int? threadID;
  final PostEntity? postEntity;
  const ViewPostScreen({Key? key, this.threadID, required this.postEntity})
      : super(key: key);

  @override
  _ViewPostScreenState createState() => _ViewPostScreenState();
}

class _ViewPostScreenState extends State<ViewPostScreen> {
  ViewPostCubit? viewPostCubit;
  CreatePostCubit? createPostCubit;
  String? lastPostId;

  @override
  void initState() {
    super.initState();
    viewPostCubit = getIt<ViewPostCubit>()
      ..getParentPost(widget.threadID.toString());
    createPostCubit = getIt<CreatePostCubit>();
    AC.searchCubitHash = getIt<SearchCubit>();
    AC.searchCubitA = getIt<SearchCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
        title: 'Thread'.toSubTitle1(
          (url) => context.router.root.push(WebViewScreenRoute(url: url)),
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        elevation: 0.0,
        backgroundColor: Colors.white,
      ),
      body: BlocListener<ViewPostCubit, CommonUIState>(
        bloc: viewPostCubit,
        listener: (_, state) {
          state.maybeWhen(
            orElse: () {},
            error: (e) => context.showSnackBar(message: e, isError: true),
            success: (s) {
              if (s != null && s is String && s.isNotEmpty) {
                viewPostCubit!.getParentPost(widget.threadID.toString());
                context.showSnackBar(message: s, isError: false);
              }
            },
          );
        },
        child: BlocListener<CreatePostCubit, CommonUIState>(
          bloc: createPostCubit,
          listener: (_, state) {
            state.maybeWhen(
              orElse: () {},
              error: (e) => context.showSnackBar(message: e, isError: true),
              success: (s) {
                if (s is String && s.isNotEmpty) {
                  context.showSnackBar(message: s, isError: false);
                  viewPostCubit!.getParentPost(widget.threadID.toString());
                }
              },
            );
          },
          child: BlocBuilder<CreatePostCubit, CommonUIState>(
            bloc: createPostCubit,
            builder: (_, state) => state.when(
              initial: buildHomeWithStream,
              success: (s) => buildHomeWithStream(),
              loading: () => LoadingBar(),
              error: (e) => Container(child: e!.toText),
            ),
          ),
        ),
      ),
    );
  }

  /// This is for creating new post
  Widget buildHomeWithStream() => BlocBuilder<ViewPostCubit, CommonUIState>(
        bloc: viewPostCubit,
        builder: (_, state) => state.when(
          initial: () => StreamBuilder<List<PostEntity>>(
            stream: viewPostCubit!.parentPostEntity,
            builder: (context, snapshot) {
              if (snapshot.data == null) return Container();
              return StreamBuilder<List<PostEntity>>(
                stream: viewPostCubit!.parentPostEntity,
                builder: (context, items) => buildHomeScreen(items.data, 5),
              );
            },
          ),
          success: (c) => StreamBuilder<List<PostEntity>>(
            stream: viewPostCubit!.parentPostEntity,
            builder: (context, snapshot) {
              if (snapshot.data == null) return Container();
              return StreamBuilder<List<PostEntity>>(
                stream: viewPostCubit!.parentPostEntity,
                builder: (context, items) => buildHomeScreen(items.data, 5),
              );
            },
          ),
          loading: () => LoadingBar(),
          error: (e) => Center(
            child: e!.toSubTitle1(
              (url) => context.router.root.push(WebViewScreenRoute(url: url)),
            ),
          ),
        ),
      );

  Widget buildHomeScreen(List<PostEntity>? postItems, int size) {
    if (postItems == null) return LoadingBar();
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // if there are replies and next or prev
        if (postItems.length > 1)
          [getTimeLineView(postItems), 150.toSizedBox]
              .toColumn()
              .makeScrollable(),

        if (postItems.length == 1)
          [
            PostItem(
              postEntity: postItems[0],
              detailedPost: true,
            ),
            40.toSizedBox,
            NoDataFoundScreen(
              title: "No replys yet!",
              buttonVisibility: false,
              icon: const Icon(
                Icons.comment_bank,
                color: AppColors.colorPrimary,
                size: 40,
              ),
              message:
                  "It seems that this publication does not yet have any comments."
                  " In order to respond to this publication from ${postItems[0].name}",
            )
          ].toColumn().makeScrollable(),
        CreateReplyBox(
          createPostCubit: createPostCubit,
          postItems: postItems,
          threadID: widget.threadID,
        )
      ],
    );
  }

  Widget getTimeLineView(List<PostEntity> postEntity) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: FixedTimeline.tileBuilder(
          builder: TimelineTileBuilder(
            nodePositionBuilder: (c, index) => 0.0,
            indicatorPositionBuilder: (c, index) => 0.0,
            startConnectorBuilder: (c, i) => Container(),
            indicatorBuilder: (c, index) =>
                postEntity[index].isConnected || postEntity[index].isReplyItem
                    ? Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: postEntity[index]
                            .profileUrl!
                            .toRoundNetworkImage(radius: 11),
                      )
                    : Container(),
            endConnectorBuilder: (c, index) =>
                postEntity[index].isConnected && postEntity[index].isReplyItem
                    ? const Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: SolidLineConnector(),
                      )
                    : Container(),
            itemCount: postEntity.length,
            contentsBuilder: (c, index) {
              return displayItem(postEntity, index);
            },
          ),
          theme: const TimelineThemeData.raw(
            direction: Axis.vertical,
            color: Colors.red,
            nodePosition: 0.0,
            nodeItemOverlap: true,
            indicatorPosition: 0.0,
            indicatorTheme: IndicatorThemeData(
              color: AppColors.placeHolderColor,
              size: 0,
              position: 0,
            ),
            connectorTheme: ConnectorThemeData(
              color: AppColors.placeHolderColor,
            ),
          ),
          verticalDirection: VerticalDirection.down,
        ),
      ).toFlexible();

  Widget displayItem(List<PostEntity> postEntity, int index) {
    final item = postEntity[index];
    if (item.parentPostTime.isNotEmpty)
      lastPostId = postEntity[index - 1].postId;
    if (item.showFullDivider)
      return const Divider(
        thickness: 2,
        color: AppColors.sfBgColor,
      );
    else if (item.parentPostTime.isNotEmpty)
      return [
        const Divider(
          thickness: 2,
          color: AppColors.sfBgColor,
        ),
        item.parentPostTime
            .toCaption(fontWeight: FontWeight.bold)
            .toHorizontalPadding(16),
        const Divider(
          thickness: 2,
          color: AppColors.sfBgColor,
        ),
      ].toColumn();

    return PostItem(
      replyCountIncreased: (value) {
        var item = viewPostCubit!.items[index];
        if (value)
          viewPostCubit!.items[index] = item.copyWith(
            commentCount: item.commentCount!.inc.toString(),
          );
        viewPostCubit!.changePostEntity(viewPostCubit!.items);
      },
      postEntity: item,
      isComeHome: false,
      detailedPost: !item.isReplyItem,
      onPostOptionItem: (optionSelected) async {
        FocusManager.instance.primaryFocus!.unfocus();

        final getOptionsEnum = optionSelected!.getOptionsEnum;
        switch (getOptionsEnum) {
          case PostOptionsEnum.REPORT:
            showModalBottomSheet(
              context: context,
              builder: (_) => ReportPostWidget(
                item.postId,
              ),
            );
            break;
          case PostOptionsEnum.BLOCK:
            break;
          case PostOptionsEnum.SHOW_LIKES:
            showModalBottomSheet(
                context: context, builder: (c) => ShowLikeScreen(item.postId));
            break;
          case PostOptionsEnum.BOOKMARK:
            viewPostCubit!.addRemoveBook(index);
            break;
          case PostOptionsEnum.DELETE:
            context.showDeleteDialog(
              onOkTap: () async {
                await viewPostCubit!.deletePost(context, index);
              },
            );
            break;
        }
      },
      onLikeTap: () => viewPostCubit!.likeUnLikePost(index),
      onTapRepost: () => viewPostCubit!.repost(index),
    );
  }

  void doSearch(String tag, String lastLatter) {
    if (tag == "#") {
      AC.searchCubitHash!.hashTagPagination!.changeSearch(lastLatter);
    } else if (tag == "@") {
      AC.searchCubitA!.peoplePagination!.changeSearch(lastLatter);
    }
  }
}
