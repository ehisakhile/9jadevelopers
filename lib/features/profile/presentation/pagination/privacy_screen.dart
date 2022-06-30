import 'package:auto_route/auto_route.dart';
import 'package:colibri/core/config/colors.dart';
import 'package:colibri/core/config/strings.dart';
import 'package:flutter_awesome_select/flutter_awesome_select.dart';
import '../../../../core/routes/routes.gr.dart';
import '../../../../core/common/buttons/custom_button.dart';
import '../../domain/entity/setting_entity.dart';
import '../bloc/settings/user_setting_cubit.dart';
import '../pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../extensions.dart';

class PrivacyScreen extends StatefulWidget {
  final List<PrivacyWidgetModel>? privacyModels;

  const PrivacyScreen({Key? key, this.privacyModels}) : super(key: key);

  @override
  _PrivacyScreenState createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  late UserSettingCubit userSettingCubit;
  @override
  void initState() {
    super.initState();
    userSettingCubit = BlocProvider.of<UserSettingCubit>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              title: "Account Privacy".toSubTitle1(
                  (url) =>
                      context.router.root.push(WebViewScreenRoute(url: url)),
                  fontWeight: FontWeight.w500),
              tileColor: AppColors.sfBgColor,
            ),
            // generating lists with title and options
            _generateItem(widget.privacyModels!.sublist(0, 2)),
            _generateItem(widget.privacyModels!.sublist(2, 4)),
            _generateItem(widget.privacyModels!.sublist(4, 6)),
            CustomButton(
                text: "Save",
                onTap: () {
                  context.router.root.pop();
                  userSettingCubit.updateUserPrivacy();
                }).toPadding(16)
          ],
        ),
      ),
    );
  }

  _generateItem(List<PrivacyWidgetModel> items) {
    return StreamBuilder<SettingEntity>(
      stream: userSettingCubit.settingEntity,
      builder: (context, snapshot) {
        return snapshot.data == null
            ? const SizedBox()
            : SmartSelect.single(
                selectedValue: _mapItemsToSelectedValue(items, snapshot.data!),
                modalStyle: const S2ModalStyle(
                  clipBehavior: Clip.hardEdge,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                  ),
                ),
                choiceConfig: S2ChoiceConfig(
                    style: S2ChoiceStyle(
                      titleStyle: context.subTitle2.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    useDivider: true),
                modalConfig: S2ModalConfig(
                  headerStyle: S2ModalHeaderStyle(
                    textStyle: context.subTitle1.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                modalType: S2ModalType.bottomSheet,
                choiceGrouped: false,
                title:
                    PrivacyWidgetModel.getEnumValue(items[0].privacyOptionEnum),
                choiceItems: items
                    .map(
                      (e) => S2Choice(
                        value: e.value,
                        title: e.value,
                        group: PrivacyWidgetModel.getEnumValue(
                          e.privacyOptionEnum,
                        ),
                      ),
                    )
                    .toList(),
                onChange: (S2SingleSelected<String> s) =>
                    _onChange(s, snapshot.data, items),
                choiceTitleBuilder: (
                  c,
                  S2SingleState<Object?> choice,
                  S2Choice<Object?> text,
                ) =>
                    ListTile(
                      onTap: () {
                        // text
                      },
                      title: text.title!.toSubTitle1(
                          (url) => context.router.root
                              .push(WebViewScreenRoute(url: url)),
                          fontWeight: FontWeight.w500),
                      tileColor: AppColors.sfBgColor,
                    ),
                tileBuilder: (c, S2SingleState<String?> s) {
                  String subtitle = '';
                  var settingItem = snapshot.data;
                  switch (items[0].privacyOptionEnum) {
                    case PrivacyOptionEnum.PROFILE_VISIBILITY:
                      subtitle =
                          settingItem!.accountPrivacyEntity.canSeeMyPosts;

                      break;
                    case PrivacyOptionEnum.CONTACT_PRIVACY:
                      subtitle = settingItem!.accountPrivacyEntity.canDMMe ??
                          Strings.privacyEveryOne;

                      break;
                    case PrivacyOptionEnum.SEARCH_VISIBILITY:
                      subtitle = settingItem!
                          .accountPrivacyEntity.showProfileInSearchEngine;

                      break;
                  }
                  return ListTile(
                    onTap: () {
                      s.showModal();
                    },
                    title: PrivacyWidgetModel.getEnumValue(
                            items[0].privacyOptionEnum)
                        .toSubTitle2(fontWeight: FontWeight.w500),
                    subtitle: subtitle.toCaption(fontWeight: FontWeight.w500),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_outlined,
                      size: 14,
                    ),
                  );
                });
      },
    );
  }

  void _onChange(
    S2SingleSelected<String> s,
    SettingEntity? data,
    List<PrivacyWidgetModel> items,
  ) {
    // getting item 0 enum value to update the settings accordingly
    switch (items[0].privacyOptionEnum) {
      case PrivacyOptionEnum.PROFILE_VISIBILITY:
        userSettingCubit.changeSettingEntity(
          data!.copyWith(
            accountPrivacyEntity: data.accountPrivacyEntity.copyWith(
              canSeeMyPosts: s.value.toString(),
            ),
          ),
        );
        break;
      case PrivacyOptionEnum.CONTACT_PRIVACY:
        userSettingCubit.changeSettingEntity(
          data!.copyWith(
            accountPrivacyEntity: data.accountPrivacyEntity.copyWith(
              canFollowMe: s.value.toString(),
            ),
          ),
        );
        break;
      case PrivacyOptionEnum.SEARCH_VISIBILITY:
        userSettingCubit.changeSettingEntity(
          data!.copyWith(
            accountPrivacyEntity: data.accountPrivacyEntity.copyWith(
              showProfileInSearchEngine: s.value.toString(),
            ),
          ),
        );
        break;
    }
  }
}

String _mapItemsToSelectedValue(
  List<PrivacyWidgetModel> items,
  SettingEntity data,
) {
  switch (items[0].privacyOptionEnum) {
    case PrivacyOptionEnum.PROFILE_VISIBILITY:
      return data.accountPrivacyEntity.canSeeMyPosts;

    case PrivacyOptionEnum.CONTACT_PRIVACY:
      return data.accountPrivacyEntity.canDMMe ?? Strings.privacyEveryOne;

    case PrivacyOptionEnum.SEARCH_VISIBILITY:
      return data.accountPrivacyEntity.showProfileInSearchEngine;
  }
}
