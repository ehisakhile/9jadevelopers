import 'package:auto_route/auto_route.dart';
import 'package:colibri/core/config/colors.dart';
import 'package:colibri/core/listeners/profile_listeners.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sized_context/sized_context.dart';
import '../../../../translations/locale_keys.g.dart';
import '../../../../core/common/uistate/common_ui_state.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_icons.dart';

import '../../../../core/widgets/loading_bar.dart';
import '../../../../core/widgets/media_picker.dart';
import '../../../../extensions.dart';
import '../../../feed/presentation/widgets/create_post_card.dart';
import '../../../feed/presentation/widgets/feed_widgets.dart';
import '../../../feed/presentation/widgets/no_data_found_screen.dart';
import '../../../posts/presentation/widgets/post_pagination_widget.dart';
import '../../domain/entity/profile_entity.dart';
import '../bloc/profile_cubit.dart';
import '../bloc/user_likes/user_likes_cubit.dart';
import '../bloc/user_media/user_media_cubit.dart';
import '../bloc/user_posts/user_post_cubit.dart';
import '../widgets/profile_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

class ProfileScreen extends StatefulWidget {
  // ignore: deprecated_member_use_from_same_package
  final ProfileNavigationEnum profileNavigationEnum;
  final String? otherUserId;
  final String? profileUrl;
  final String? coverUrl;
  const ProfileScreen({
    Key? key,
    this.otherUserId,
    this.profileUrl,
    this.coverUrl,
    this.profileNavigationEnum = ProfileNavigationEnum.FROM_FEED,
  }) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  ProfileCubit? _profileCubit;
  UserPostCubit? userPostCubit;
  UserMediaCubit? userMediaCubit;
  UserLikesCubit? userLikesCubit;
  TabController? tabController;
  Size? size;
  @override
  void initState() {
    _profileCubit = BlocProvider.of<ProfileCubit>(context);
    tabController = TabController(length: 3, vsync: this);
    userPostCubit = getIt<UserPostCubit>();
    userMediaCubit = getIt<UserMediaCubit>();
    userLikesCubit = getIt<UserLikesCubit>();
    _profileCubit!.profileEntity.listen((event) {
      userLikesCubit!.userId = event.id;
      userMediaCubit!.userId = event.id;
      userPostCubit!.userId = event.id;
    });

    super.initState();
    _profileCubit!
        .getUserProfile(widget.otherUserId, widget.coverUrl, widget.profileUrl);
  }

  double textSizePred = 0.0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ProfileCubit, CommonUIState>(
        listener: (context, state) => state.maybeWhen(
          orElse: () => null,
          success: (state) => ProfileListener.success(state, context),
          error: (e) => ProfileListener.error(e!, context),
        ),
        builder: (_, state) {
          return state.when(
            initial: () => LoadingBar(),
            success: (s) => getHomeWidget(),
            loading: () => LoadingBar(),
            error: (e) => Center(
              child: NoDataFoundScreen(
                onTapButton: context.router.root.pop,
                icon: AppIcons.personOption(
                    color: AppColors.colorPrimary, size: 40),
                title: 'Profile Not found',
                message: e!.contains("invalid")
                    ? LocaleKeys
                        .sorry_we_cannot_find_the_page_you_are_looking_for_if_you_still_ne
                        .tr()
                    : e,
                buttonText: LocaleKeys.go_back.tr(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget getHomeWidget() {
    return StreamBuilder<ProfileEntity>(
        stream: _profileCubit!.profileEntity,
        builder: (context, snapshot) {
          return DefaultTabController(
            length: 3,
            child: SafeArea(
              child: NestedScrollView(
                headerSliverBuilder: (context, value) {
                  return [
                    SliverAppBar(
                      automaticallyImplyLeading: false,
                      leading: null,
                      systemOverlayStyle: SystemUiOverlayStyle.light,
                      elevation: 0.0,
                      expandedHeight: calculateHeight(
                        context: context,
                        item: snapshot.data!,
                      ) as double?,
                      floating: true,
                      pinned: true,
                      actions: [
                        IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              await openMediaPicker(
                                context,
                                (media) async {
                                  _profileCubit!.changeProfileEntity(
                                    snapshot.data!
                                        .copyWith(backgroundImage: media),
                                  );
                                  await _profileCubit!
                                      .updateProfileCover(media);
                                },
                                mediaType: MediaTypeEnum.IMAGE,
                                allowCropping: true,
                              );
                            }).toVisibility(widget.otherUserId == null)
                      ],
                      // title: Text('Profile'),
                      backgroundColor: Colors.white,
                      flexibleSpace: FlexibleSpaceBar(
                        collapseMode: CollapseMode.pin,
                        background: snapshot.data == null
                            ? Container()
                            : TopAppBar(
                                otherUserId: snapshot.data!.id,
                                otherUser: widget.otherUserId != null,
                                profileEntity: snapshot.data,
                                profileNavigationEnum:
                                    widget.profileNavigationEnum,
                                onSizeAborted: (size) {
                                  setState(() {
                                    textSizePred = size;
                                  });
                                },
                              ),
                      ),
                      // posts,media,likes row
                      bottom: PreferredSize(
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey,
                                      width: 0.2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            TabBar(
                              indicatorWeight: 1,
                              indicatorSize: TabBarIndicatorSize.label,
                              labelPadding: const EdgeInsets.all(0),
                              labelStyle: TextStyle(
                                fontFamily: 'CeraPro',
                                fontWeight: FontWeight.w500,
                              ),
                              unselectedLabelStyle: TextStyle(
                                fontFamily: 'CeraPro',
                                fontWeight: FontWeight.bold,
                              ),
                              tabs: [
                                Tab(
                                  text: LocaleKeys.posts.tr(),
                                ).toContainer(
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    border: Border(
                                      top: BorderSide(
                                        color: Colors.grey,
                                        width: 0.2,
                                      ),
                                    ),
                                  ),
                                ),
                                Tab(
                                  text: LocaleKeys.media.tr(),
                                ).toContainer(
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    border: Border(
                                      top: BorderSide(
                                        color: Colors.grey,
                                        width: 0.2,
                                      ),
                                    ),
                                  ),
                                ),
                                Tab(
                                  text: LocaleKeys.likes.tr(),
                                ).toContainer(
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    border: Border(
                                      top: BorderSide(
                                        color: Colors.grey,
                                        width: 0.2,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        preferredSize: const Size(500, 56),
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  children: [
                    /// Add the block widget here thhree times
                    Container(
                      child: RefreshIndicator(
                        onRefresh: () {
                          userPostCubit!.onRefresh();
                          return Future.value();
                        },
                        child: PostPaginationWidget(
                          isComeHome: false,
                          isFromProfileSearch: true,
                          isPrivateAccount: (value) {
                            _profileCubit!.isPrivateUser = value;
                          },
                          isSliverList: false,
                          noDataFoundScreen: NoDataFoundScreen(
                            buttonText: LocaleKeys.go_to_the_homepage.tr(),
                            title: LocaleKeys.no_posts_yet.tr(),
                            message: "",
                            onTapButton: () {
                              context.router.root.pop();
                            },
                          ),
                          pagingController: userPostCubit!.pagingController,
                          onTapLike: userPostCubit!.likeUnlikePost,
                          onOptionItemTap:
                              (PostOptionsEnum postOptionsEnum, int index) =>
                                  userPostCubit!.onOptionItemSelected(
                                      context, postOptionsEnum, index),
                          onTapRepost: userPostCubit!.repost,
                        ),
                      ),
                    ),
                    Container(
                        child: RefreshIndicator(
                      onRefresh: () {
                        userMediaCubit!.onRefresh();
                        return Future.value();
                      },
                      child: PostPaginationWidget(
                        isComeHome: false,
                        isPrivateAccount: (value) {
                          _profileCubit!.isPrivateUser = value;
                        },
                        isSliverList: false,
                        noDataFoundScreen: NoDataFoundScreen(
                          title: LocaleKeys.no_media_yet.tr(),
                          icon: AppIcons.imageIcon(height: 35, width: 35),
                          buttonText: LocaleKeys.go_to_the_homepage.tr(),
                          message: "",
                          onTapButton: () {
                            context.router.root.pop();
                            // BlocProvider.of<FeedCubit>(context).changeCurrentPage(ScreenType.home());
                            // context.router.root.push(Routes.createPost);
                          },
                        ),
                        pagingController: userMediaCubit!.pagingController,
                        onTapLike: userMediaCubit!.likeUnlikePost,
                        onOptionItemTap: (PostOptionsEnum postOptionsEnum,
                                int index) async =>
                            await userMediaCubit!.onOptionItemSelected(
                                context, postOptionsEnum, index),
                        onTapRepost: userMediaCubit!.repost,
                      ),
                    )),
                    Container(
                        child: RefreshIndicator(
                      onRefresh: () {
                        userLikesCubit!.onRefresh();
                        return Future.value();
                      },
                      child: PostPaginationWidget(
                        isComeHome: false,
                        isPrivateAccount: (value) {
                          _profileCubit!.isPrivateUser = value;
                        },
                        isSliverList: false,
                        noDataFoundScreen: NoDataFoundScreen(
                          title: LocaleKeys.no_likes_yet.tr(),
                          icon: AppIcons.likeOption(
                              size: 35, color: AppColors.colorPrimary),
                          buttonText: LocaleKeys.go_to_the_homepage.tr(),
                          message: LocaleKeys
                              .you_don_t_have_any_favorite_posts_yet_all_posts_that_you_like_wil
                              .tr(),
                          onTapButton: () {
                            context.router.root.pop();
                            // BlocProvider.of<FeedCubit>(context).changeCurrentPage(ScreenType.home());
                            // context.router.root.push(Routes.createPost);
                          },
                        ),
                        pagingController: userLikesCubit!.pagingController,
                        onTapLike: userLikesCubit!.likeUnlikePost,
                        onOptionItemTap:
                            (PostOptionsEnum postOptionsEnum, int index) =>
                                userLikesCubit!.onOptionItemSelected(
                          context,
                          postOptionsEnum,
                          index,
                        ),
                        onTapRepost: userLikesCubit!.repost,
                      ),
                    )),
                  ],
                ),
              ),
            ),
          );
        });
  }

  num calculateHeight({
    required BuildContext context,
    required ProfileEntity item,
  }) {
    print('INCHES: ${context.diagonalInches}');
    bool isSmallInches = context.diagonalInches <= 4.7;
    bool hasWebsite = item.website != null && item.website!.isNotEmpty;
    final height = context.getScreenHeight;
    final defaultHeight = isSmallInches ? height * .6 : height * .47;
    final websiteHeight = hasWebsite ? height * .03 : 0;
    final sizeBoxHeight = textSizePred != 0.0 ? 10.h : 0;
    return textSizePred + defaultHeight + websiteHeight + sizeBoxHeight;
  }
}

/// helps to determine from where user navigated to profile
/// so that on back press of the profile screen we can go back the correct page

/// we're using this because according to the UI we will have the keep the bottom navigation bar under the profile page
enum ProfileNavigationEnum {
  FROM_BOOKMARKS,
  FROM_FEED,
  FROM_SEARCH,
  FROM_VIEW_POST,
  FROM_MY_PROFILE,
  FROM_OTHER_PROFILE,
  FROM_MESSAGES,
  FROM_NOTIFICATION
}
