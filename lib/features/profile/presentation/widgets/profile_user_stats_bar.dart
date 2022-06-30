import '../../../../core/routes/routes.gr.dart';
import '../../domain/entity/profile_entity.dart';
import '../bloc/profile_cubit.dart';
import '../pages/followers_following_screen.dart';
import 'profile_user_stats_bar_item.dart';
import '../../../../translations/locale_keys.g.dart';
import 'package:flutter/material.dart';
import '../../../../extensions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';

class ProfileUserStatsBar extends StatelessWidget {
  const ProfileUserStatsBar(
    this.profileCubit,
    this.profileEntity, {
    Key? key,
    this.userId,
  }) : super(key: key);
  final ProfileEntity? profileEntity;
  final String? userId;
  final ProfileCubit? profileCubit;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ProfileUserStatsBarItem(
          number: profileEntity!.followingCount,
          text: LocaleKeys.following.tr(),
          function: () {
            if (profileCubit!.isPrivateUser) {
              context.showOkAlertDialog(
                title: LocaleKeys.this_account_is_private.tr(),
                desc: LocaleKeys
                    .only_approved_followers_can_see_the_posts_and_content_of_this_pro
                    .tr(),
              );
            } else
              context.router.root.push(
                FollowingFollowersScreenRoute(
                  userId: userId,
                  followScreenEnum: FollowUnFollowScreenEnum.FOLLOWING,
                ),
              );
          },
        ),
        10.toSizedBoxHorizontal,
        ProfileUserStatsBarItem(
          number: profileEntity!.followerCount,
          text: LocaleKeys.followers.tr(),
          function: (() {
            if (profileCubit!.isPrivateUser) {
              context.showOkAlertDialog(
                title: LocaleKeys.this_account_is_private.tr(),
                desc: LocaleKeys
                    .only_approved_followers_can_see_the_posts_and_content_of_this_pro
                    .tr(),
              );
            }
            context.router.root.push(
              FollowingFollowersScreenRoute(
                userId: userId,
                followScreenEnum: FollowUnFollowScreenEnum.FOLLOWERS,
              ),
            );
          }),
        ),
      ],
    );
  }
}
