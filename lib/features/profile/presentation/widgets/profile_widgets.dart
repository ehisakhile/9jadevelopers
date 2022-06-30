import 'package:auto_route/auto_route.dart';
import 'package:colibri/core/config/colors.dart';
import 'package:colibri/core/widgets/size_provider_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'profile_user_stats_bar.dart';
import 'report_profile_widget.dart';
import '../../../../translations/locale_keys.g.dart';
import '../../../../core/routes/routes.gr.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/images.dart';
import '../../../../core/widgets/media_picker.dart';
import '../../../feed/presentation/bloc/feed_cubit.dart';
import '../../../feed/presentation/widgets/all_home_screens.dart';
import '../../domain/entity/profile_entity.dart';
import '../bloc/profile_cubit.dart';
import '../pages/followers_following_screen.dart';
import '../pages/profile_screen.dart';
import 'package:flutter/material.dart';
import '../../../../extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class GetStatusBar extends StatefulWidget {
  final String? otherUserId;
  final ProfileEntity? profileEntity;
  const GetStatusBar({Key? key, this.otherUserId, this.profileEntity})
      : super(key: key);

  @override
  _GetStatusBarState createState() => _GetStatusBarState();
}

class _GetStatusBarState extends State<GetStatusBar> {
  ProfileCubit? profileCubit;

  @override
  void initState() {
    super.initState();
    profileCubit = BlocProvider.of<ProfileCubit>(context);
  }

  @override
  Widget build(BuildContext context) {
    return ProfileUserStatsBar(
      profileCubit,
      widget.profileEntity,
      userId: widget.otherUserId,
    );
  }
}

class TopAppBar extends StatefulWidget {
  final bool otherUser;
  final ProfileEntity? profileEntity;
  final ProfileNavigationEnum? profileNavigationEnum;
  final String? otherUserId;
  final Function(double)? onSizeAborted;

  const TopAppBar({
    Key? key,
    this.otherUser = false,
    this.profileEntity,
    this.profileNavigationEnum,
    this.otherUserId,
    this.onSizeAborted,
  }) : super(key: key);

  @override
  _TopAppBarState createState() => _TopAppBarState();
}

class _TopAppBarState extends State<TopAppBar> {
  var buttonText = '';
  late ProfileCubit profileCubit;

  @override
  void initState() {
    super.initState();
    profileCubit = BlocProvider.of<ProfileCubit>(context);
    buttonText = widget.otherUserId != null
        ? !widget.profileEntity!.isFollowing
            ? LocaleKeys.follow.tr()
            : LocaleKeys.unfollow.tr()
        : LocaleKeys.settings.tr().capitalize();
  }

  @override
  Widget build(BuildContext context) =>
      getTopAppBar(otherUser: widget.otherUser);

  Widget getTopAppBar({otherUser = false}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        [
          Container(
            child: widget.profileEntity!.backgroundUrl!.toNetWorkOrLocalImage(
              width: double.infinity,
              height: context.getScreenHeight * .2,
              borderRadius: 0,
            ),
          ),
          [
            20.toSizedBoxHorizontal,
            [
              [
                Theme(
                  data: Theme.of(context).copyWith(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                  ),
                  child: setUpList().toPopUpMenuButton(
                    _mapChoiceToFunction,
                    icon: Padding(
                      padding: EdgeInsets.only(top: 12.h),
                      child: Icon(
                        Icons.more_horiz,
                        color: AppColors.colorPrimary,
                      ),
                    ),
                    rowIcon: _mapChoiceToIcon,
                  ),
                ),
                if (otherUser)
                  AppIcons.messageProfile().onTapWidget(
                    () {
                      context.router.root.push(
                        ChatScreenRoute(
                          otherPersonProfileUrl:
                              widget.profileEntity!.profileUrl,
                          otherPersonUserId: widget.profileEntity!.id,
                          otherUserFullName: widget.profileEntity!.fullName,
                        ),
                      );
                    },
                  ),
                if (otherUser) 10.toSizedBox,
                LocaleKeys.settings
                    .tr()
                    .toUpperCase()
                    .toCaption(
                      fontWeight: FontWeight.bold,
                      color: AppColors.colorPrimary,
                    )
                    .toOutlinedBorder(() {
                      context.router.root
                          .push(SettingsScreenRoute(fromProfile: true));
                    })
                    .toContainer(height: 30, alignment: Alignment.center)
                    .toVisibility(!widget.otherUser),
                getOtherUserButton().toVisibility(widget.otherUser)
              ].toRow(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center),
              [
                widget.profileEntity!.fullName
                    .capitalizedStringLetters()
                    .toHeadLine6(
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade700,
                    )
                    .toEllipsis
                    .toFlexible(),
                4.toSizedBoxHorizontal,
                AppIcons.verifiedIcons
                    .toVisibility(widget.profileEntity!.isVerified!)
              ].toRow(crossAxisAlignment: CrossAxisAlignment.center),
              widget.profileEntity!.userName.toSubTitle2(
                fontWeight: FontWeight.w500,
                color: Colors.black54,
                fontFamily1: "CeraPro",
              ),
              if (widget.profileEntity!.about!.isNotEmpty) 10.h.toSizedBox,
              [
                SizeProviderWidget(
                  onChildSize: (size) => widget.onSizeAborted!(size.height),
                  child: widget.profileEntity!.about!
                      .toSubTitle2(
                        fontWeight: FontWeight.w500,
                        color: widget.profileEntity!.about == ''
                            ? Colors.transparent
                            : Colors.black54,
                        fontFamily1: "CeraPro",
                      )
                      .toContainer(maxWidth: context.getScreenWidth * .9)
                      .onTapWidget(
                    () {
                      context.showOkAlertDialog(
                        desc: widget.profileEntity!.about!,
                        title: LocaleKeys.about_you.tr(),
                      );
                    },
                  ),
                )
              ]
                  .toRow(crossAxisAlignment: CrossAxisAlignment.center)
                  .toVisibility(
                    widget.profileEntity!.about!.isNotEmpty &&
                        widget.profileEntity!.about != '',
                  ),
              if (widget.profileEntity!.website!.isNotEmpty) 13.toSizedBox,
              [
                const Icon(
                  Icons.insert_link_outlined,
                  size: 15,
                  color: AppColors.optionIconColor,
                )
                    .toVisibility(
                      widget.profileEntity!.website!.isNotEmpty,
                    )
                    .toVerticalPadding(2),
                5.toSizedBoxHorizontal,
                widget.profileEntity!.website!
                    .toCaption(
                      maxLines: 1,
                      textOverflow: TextOverflow.ellipsis,
                    )
                    .toVisibility(
                      widget.profileEntity!.website!.isNotEmpty,
                    )
                    .toContainer(
                      height: context.getScreenHeight * .02,
                      width: context.getScreenWidth * .5,
                    )
              ].toRow(),
              if (widget.profileEntity!.website!.isNotEmpty) 5.toSizedBox,
              Row(
                children: [
                  [
                    Images.profileCounry
                        .toSvg(color: AppColors.optionIconColor),
                    5.toSizedBoxHorizontal,
                    widget.profileEntity!.country!.toCaption(),
                  ].toRow(),
                  Padding(
                    padding: EdgeInsets.only(left: 25.0.w),
                    child: [
                      Images.profileCalendar
                          .toSvg(color: AppColors.optionIconColor),
                      5.toSizedBoxHorizontal,
                      'Joined - ${widget.profileEntity!.memberSince!}'
                          .toCaption()
                    ].toRow(),
                  ),
                ],
              ),
              13.toSizedBox,
              GetStatusBar(
                otherUserId: widget.otherUserId,
                profileEntity: widget.profileEntity!,
              ),
            ].toColumn().toExpanded(),
            10.toSizedBoxHorizontal
          ].toRow().toExpanded(flex: 3),
        ].toColumn(),
        Positioned(
          top: context.getScreenHeight * .145,
          right: context.isArabic() ? 20.toWidth as double? : null,
          left: context.isArabic() ? null : 20.toWidth as double?,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 3.0),
              shape: BoxShape.circle,
            ),
            child: widget.profileEntity!.profileUrl!
                .toRoundNetworkImage(radius: 17),
          ).onTapWidget(
            () async {
              if (!widget.otherUser)
                await openMediaPicker(
                  context,
                  (media) async {
                    profileCubit.changeProfileEntity(
                      widget.profileEntity!.copyWith(profileImage: media),
                    );
                    await profileCubit.updateProfileAvatar(media);
                  },
                );
            },
          ),
        ),
        Positioned(
          top: 10.toHeight as double?,
          left: !context.isArabic() ? 10.toWidth as double? : null,
          right: context.isArabic() ? 10.toWidth as double? : null,
          child: IconButton(
            icon: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.black26,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back, color: Colors.white),
            ),
            onPressed: () {
              switch (widget.profileNavigationEnum!) {
                case ProfileNavigationEnum.FROM_BOOKMARKS:
                  BlocProvider.of<FeedCubit>(context)
                      .changeCurrentPage(const ScreenType.home());
                  break;
                case ProfileNavigationEnum.FROM_FEED:
                  context.router.root.pop();
                  break;
                case ProfileNavigationEnum.FROM_SEARCH:
                  BlocProvider.of<FeedCubit>(context)
                      .changeCurrentPage(const ScreenType.search());
                  break;
                case ProfileNavigationEnum.FROM_VIEW_POST:
                  break;
                case ProfileNavigationEnum.FROM_MY_PROFILE:
                  BlocProvider.of<FeedCubit>(context)
                      .changeCurrentPage(const ScreenType.home());
                  break;
                case ProfileNavigationEnum.FROM_OTHER_PROFILE:
                  BlocProvider.of<FeedCubit>(context)
                      .changeCurrentPage(const ScreenType.home());
                  break;
                case ProfileNavigationEnum.FROM_MESSAGES:
                  BlocProvider.of<FeedCubit>(context)
                      .changeCurrentPage(const ScreenType.message());
                  break;
                case ProfileNavigationEnum.FROM_NOTIFICATION:
                  BlocProvider.of<FeedCubit>(context)
                      .changeCurrentPage(const ScreenType.notification());
                  break;
              }
            },
          ),
        )
      ],
    );
  }

  Widget getOtherUserButton() {
    if (buttonText == LocaleKeys.unfollow.tr())
      return buttonText
          .toCaption(color: Colors.white, fontWeight: FontWeight.w800)
          .toMaterialButton(
        () {
          context.showOkCancelAlertDialog(
              desc: LocaleKeys
                  .please_note_that_if_you_unsubscribe_then_this_user_s_posts_will_n
                  .tr(),
              title: LocaleKeys.please_confirm_your_actions.tr(),
              onTapOk: () {
                context.router.root.pop();
                profileCubit.followUnFollow();
                setState(
                  () {
                    buttonText = LocaleKeys.follow.tr();
                  },
                );
              },
              okButtonTitle: LocaleKeys.unfollow.tr());
        },
      ).toContainer(height: 25);
    else
      return buttonText
          .toCaption(fontWeight: FontWeight.bold, color: AppColors.colorPrimary)
          .toOutlinedBorder(
        () {
          if (widget.otherUser) {
            setState(
              () {
                buttonText = LocaleKeys.unfollow.tr();
              },
            );
            profileCubit.followUnFollow();
          } else
            context.router.root.push(SettingsScreenRoute(fromProfile: true));
        },
      ).toContainer(height: 25);
  }

  List<String> setUpList() {
    List<String> _list = [
      LocaleKeys.show_followings.tr(),
      LocaleKeys.show_followers.tr(),
    ];
    if (widget.otherUser) _list.add(LocaleKeys.report_this_profile.tr());
    if (widget.otherUser) _list.add(LocaleKeys.block.tr());
    return _list;
  }

  void _mapChoiceToFunction(String? choice) {
    if (choice == LocaleKeys.report_this_profile.tr())
      showModalBottomSheet(
        context: context,
        builder: (_) => ReportProfileWidget(widget.otherUserId!),
      );
    else if (choice == LocaleKeys.block.tr())
      context.showOkCancelAlertDialog(
        desc: LocaleKeys
            .blocked_users_will_no_longer_be_able_to_write_a_message_to_you_fo
            .tr(),
        title: LocaleKeys.please_confirm_your_actions.tr(),
        okButtonTitle: LocaleKeys.block.tr(),
        onTapOk: () => profileCubit.blockUser(
          int.parse(widget.otherUserId!),
        ),
      );
    else if (choice == LocaleKeys.show_followings.tr())
      context.router.root.push(
        FollowingFollowersScreenRoute(
          userId: widget.otherUserId,
          followScreenEnum: FollowUnFollowScreenEnum.FOLLOWING,
        ),
      );
    else if (choice == LocaleKeys.show_followers.tr())
      context.router.root.push(
        FollowingFollowersScreenRoute(
          userId: widget.otherUserId,
          followScreenEnum: FollowUnFollowScreenEnum.FOLLOWERS,
        ),
      );
  }

  Widget _mapChoiceToIcon(String choice) {
    if (choice == LocaleKeys.show_followings.tr())
      return Images.showFollowing.toSvg(
        color: Colors.black38,
        height: 23.h,
        width: 23.w,
      );
    else if (choice == LocaleKeys.show_followers.tr())
      return Images.showFollowers.toSvg(
        color: Colors.black38,
        height: 23.h,
        width: 23.w,
      );
    else if (choice == LocaleKeys.report_this_profile.tr())
      return Icon(
        Icons.flag_outlined,
        color: Colors.black38,
        size: 23,
      );
    else if (choice == LocaleKeys.block.tr())
      return Icon(
        Icons.block,
        color: Colors.black38,
        size: 23,
      );
    else
      return Container();
  }
}
                  // onChildSize: (size) => widget.onSizeAborted!(size.height),
