import 'package:auto_route/src/router/auto_router_x.dart';
import 'package:colibri/core/config/colors.dart';
import '../../../../core/routes/routes.gr.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../extensions.dart';
import '../../../../translations/locale_keys.g.dart';
import '../../domain/entity/people_entity.dart';

class PeopleItem extends StatelessWidget {
  final PeopleEntity? peopleEntity;
  final VoidCallback? onFollowTap;

  const PeopleItem({Key? key, this.peopleEntity, this.onFollowTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return [
      20.toSizedBoxHorizontal,
      peopleEntity!.profileUrl!.toRoundNetworkImage(radius: 11),
      20.toSizedBoxHorizontal,
      [
        [
          peopleEntity!.fullName!
              .toSubTitle2(fontWeight: FontWeight.w500)
              .toEllipsis
              .toFlexible(),
          5.toSizedBoxHorizontal,
          AppIcons.verifiedIcons.toVisibility(peopleEntity!.isVerified),
          5.toSizedBoxHorizontal
        ].toRow(crossAxisAlignment: CrossAxisAlignment.center),
        peopleEntity!.userName!.toCaption(
            fontSize: 10.toSp,
            fontWeight: FontWeight.w500,
            color: Colors.black54)
      ].toColumn().toExpanded(),
      [
        if (peopleEntity!.buttonText == 'Unfollow')
          LocaleKeys.unfollow
              .tr()
              .toSubTitle2(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 11,
              )
              .toOutlinedBorder(
            () {
              context.showOkCancelAlertDialog(
                desc: LocaleKeys
                    .please_note_that_if_you_unsubscribe_then_this_user_s_posts_will_n
                    .tr(),
                title: LocaleKeys.please_confirm_your_actions.tr(),
                onTapOk: () {
                  context.router.root.pop();
                  onFollowTap!.call();
                },
                okButtonTitle: LocaleKeys.unfollow.tr(),
              );
            },
          ).toContainer(
            height: 30,
            alignment: Alignment.topCenter,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.colorPrimary,
            ),
          )
        else
          LocaleKeys.follow
              .tr()
              .toSubTitle2(
                color: AppColors.colorPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              )
              .toOutlinedBorder(
            () {
              onFollowTap!.call();
            },
            borderRadius: 12,
          ).toContainer(
            height: 30,
            alignment: Alignment.topCenter,
          )
      ]
          .toRow(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center)
          .toContainer(alignment: Alignment.center)
          .toVisibility(!peopleEntity!.isCurrentLoggedInUser),
      20.toSizedBoxHorizontal,
    ].toRow(crossAxisAlignment: CrossAxisAlignment.center).onTapWidget(
      () {
        if (!(peopleEntity!.isCurrentLoggedInUser)) {
          context.router.root.push(
            ProfileScreenRoute(
              otherUserId: peopleEntity!.id,
            ),
          );
        }
      },
    );
  }
}
