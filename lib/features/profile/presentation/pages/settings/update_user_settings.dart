import 'package:auto_route/auto_route.dart';
import 'package:colibri/core/config/colors.dart';
import 'package:colibri/core/config/strings.dart';
import 'package:colibri/extensions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_awesome_select/flutter_awesome_select.dart';

import '../../../../../core/common/buttons/custom_button.dart';
import '../../../../../core/common/static_data/all_countries.dart';
import '../../../../../core/common/uistate/common_ui_state.dart';
import '../../../../../core/routes/routes.gr.dart';
import '../../../../../core/widgets/loading_bar.dart';
import '../../../../../core/widgets/media_picker.dart';
import '../../../../../translations/locale_keys.g.dart';
import '../../../../feed/presentation/widgets/create_post_card.dart';
import '../../../domain/entity/setting_entity.dart';
import '../../bloc/settings/user_setting_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UpdateUserProfile extends StatefulWidget {
  final UpdateSettingEnum updateSettingEnum;
  final Function()? onTapSave;

  const UpdateUserProfile(
      {Key? key, required this.updateSettingEnum, this.onTapSave})
      : super(key: key);

  @override
  _UpdateUserProfileState createState() => _UpdateUserProfileState();
}

class _UpdateUserProfileState extends State<UpdateUserProfile> {
  UserSettingCubit? userSettingCubit;

  @override
  void initState() {
    super.initState();
    userSettingCubit = BlocProvider.of<UserSettingCubit>(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () {
          userSettingCubit!.resetAllData();
          context.router.root.pop();
          return Future.value(true);
        },
        child: BlocBuilder<UserSettingCubit, CommonUIState>(
          bloc: userSettingCubit,
          builder: (context, state) => state.maybeWhen(
            orElse: () => SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: [
                  ListTile(
                    leading: const BackButton(),
                    title: _getTitle(widget.updateSettingEnum)
                        .toSubTitle1(
                            (url) => context.router.root
                                .push(WebViewScreenRoute(url: url)),
                            fontWeight: FontWeight.w500)
                        .toHorizontalPadding(8),
                    tileColor: AppColors.sfBgColor,
                  ),
                  getHomeWidget(widget.updateSettingEnum).toPadding(16),
                  10.toSizedBox,
                  CustomButton(
                    text: _getButtonText(
                      widget.updateSettingEnum,
                    ),
                    onTap: () {
                      widget.onTapSave!.call();
                    },
                    color: widget.updateSettingEnum ==
                            UpdateSettingEnum.DELETE_ACCOUNT
                        ? Colors.red
                        : AppColors.colorPrimary,
                  ).toPadding(16),
                ].toColumn(
                  mainAxisSize: MainAxisSize.min,
                ),
              ),
            ),
            loading: () => LoadingBar(),
          ),
        ),
      ),
    );
  }

  Widget getHomeWidget(UpdateSettingEnum updateSettingEnum) {
    switch (updateSettingEnum) {
      case UpdateSettingEnum.USERNAME:
        return _updateUsername();
      case UpdateSettingEnum.EMAIL:
        return _updateEmail();
      case UpdateSettingEnum.WEBSITE:
        return _updateWebsite();
      case UpdateSettingEnum.ABOUT_YOU:
        return _updateAbout();
      case UpdateSettingEnum.GENDER:
        return _updateGender();
      case UpdateSettingEnum.COUNTRY:
        return _updateCountry();
      case UpdateSettingEnum.PASSWORD:
        return _updatePassword();
      case UpdateSettingEnum.VERIFY_MY_ACCOUNT:
        return _verifyMyAccount();
      case UpdateSettingEnum.DELETE_ACCOUNT:
        return _deleteAccount();
      case UpdateSettingEnum.CHANGE_LANGUAGE:
        return _changeLanguage();
      default:
        return const SizedBox();
    }
  }

  String _getTitle(UpdateSettingEnum updateSettingEnum) {
    String title = "";
    switch (updateSettingEnum) {
      case UpdateSettingEnum.USERNAME:
        title = LocaleKeys.username.tr();
        break;
      case UpdateSettingEnum.EMAIL:
        title = LocaleKeys.user_e_mail.tr();
        break;
      case UpdateSettingEnum.WEBSITE:
        title = LocaleKeys.user_site_url.tr();
        break;
      case UpdateSettingEnum.ABOUT_YOU:
        title = LocaleKeys.about_you.tr();
        break;
      case UpdateSettingEnum.GENDER:
        title = LocaleKeys.user_gender.tr();
        break;
      case UpdateSettingEnum.COUNTRY:
        title = LocaleKeys.change_country.tr();
        break;
      case UpdateSettingEnum.PASSWORD:
        title = LocaleKeys.profile_password.tr();
        break;
      case UpdateSettingEnum.VERIFY_MY_ACCOUNT:
        title = LocaleKeys.verify_my_account.tr();
        break;
      case UpdateSettingEnum.DELETE_ACCOUNT:
        title = LocaleKeys.delete_account.tr();
        break;
      case UpdateSettingEnum.CHANGE_LANGUAGE:
        title = LocaleKeys.display_language.tr();
        break;
    }
    return title;
  }

  Widget _updateUsername() {
    return Column(
      children: [
        11.toSizedBox,
        Strings.firstName
            .toTextField()
            .toStreamBuilder(validators: userSettingCubit!.firstNameValidator),
        11.toSizedBox,
        Strings.lastName
            .toTextField()
            .toStreamBuilder(validators: userSettingCubit!.lastNameValidator),
        10.toSizedBox,
        Strings.userName
            .toTextField()
            .toStreamBuilder(validators: userSettingCubit!.userNameValidator),
      ],
    );
  }

  Widget _updateEmail() {
    return [
      11.toSizedBox,
      Strings.emailAddress
          .toTextField()
          .toStreamBuilder(validators: userSettingCubit!.emailValidator),
      11.toSizedBox,
      LocaleKeys
          .please_note_that_after_changing_the_email_address_the_email_addre
          .tr()
          .toCaption(
              fontWeight: FontWeight.w500,
              color: AppColors.colorPrimary,
              maxLines: 5)
          .toFlexible()
    ].toColumn();
  }

  Widget _updateWebsite() {
    return [
      11.toSizedBox,
      Strings.userSiteUrl
          .toTextField()
          .toStreamBuilder(validators: userSettingCubit!.websiteValidators),
      11.toSizedBox,
      LocaleKeys
          .please_note_that_this_url_will_appear_on_your_profile_page_if_you
          .tr()
          .toCaption(
            fontWeight: FontWeight.w500,
            color: AppColors.colorPrimary,
            maxLines: 5,
          )
          .toFlexible()
    ].toColumn();
  }

  Widget _updateAbout() {
    return [
      11.toSizedBox,
      Strings.aboutYou
          .toTextField(maxLength: 140)
          .toStreamBuilder(validators: userSettingCubit!.aboutYouValidators),
      11.toSizedBox,
      LocaleKeys
          .please_enter_a_brief_description_of_yourself_with_a_maximum_of_14
          .tr()
          .toCaption(
            fontWeight: FontWeight.w500,
            color: AppColors.colorPrimary,
            maxLines: 5,
          )
          .toFlexible()
    ].toColumn();
  }

  Widget _updateGender() {
    return StreamBuilder<SettingEntity>(
      stream: userSettingCubit!.settingEntity,
      builder: (context, snapshot) {
        return snapshot.data == null
            ? const SizedBox()
            : [
                11.toSizedBox,
                SmartSelect<String?>.single(
                  choiceStyle: S2ChoiceStyle(
                      titleStyle: context.subTitle2
                          .copyWith(fontWeight: FontWeight.w500)),
                  modalConfig: S2ModalConfig(
                    title: LocaleKeys.your_gender.tr(),
                    headerStyle: S2ModalHeaderStyle(
                      textStyle: context.subTitle1
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
                  modalType: S2ModalType.bottomSheet,
                  selectedValue: snapshot.data!.gender == 'Male'
                      ? LocaleKeys.male.tr()
                      : LocaleKeys.female.tr(),
                  onChange: (s) {
                    userSettingCubit!
                      ..changeSettingEntity(
                        snapshot.data!.copyWith(
                          updatedGender: s.value == LocaleKeys.male.tr()
                              ? LocaleKeys.male.tr()
                              : LocaleKeys.female.tr(),
                        ),
                      )
                      ..gender = s.value!;
                  },
                  tileBuilder: (c, s) => ListTile(
                    trailing: const Icon(
                      Icons.arrow_forward_ios_outlined,
                      size: 14,
                    ),
                    onTap: () {
                      s.showModal();
                    },
                    title: LocaleKeys.your_gender
                        .tr()
                        .toSubTitle2(fontWeight: FontWeight.w500),
                    subtitle: _mapSubtitleToGender(snapshot.data!.gender),
                  ),
                  choiceItems: [LocaleKeys.male.tr(), LocaleKeys.female.tr()]
                      .toList()
                      .map(
                        (e) => S2Choice(
                          value: e == LocaleKeys.male.tr()
                              ? LocaleKeys.male.tr()
                              : LocaleKeys.female.tr(),
                          title: e,
                        ),
                      )
                      .toList(),
                ),
                11.toSizedBox,
                LocaleKeys
                    .please_choose_your_gender_this_is_necessary_for_a_more_complete_i
                    .tr()
                    .toCaption(
                        fontWeight: FontWeight.w500,
                        color: AppColors.colorPrimary,
                        maxLines: 5)
                    .toFlexible()
              ].toColumn();
      },
    );
  }

  Widget _mapSubtitleToGender(String gender) {
    if (gender == 'Male' || gender == LocaleKeys.male.tr())
      return LocaleKeys.male.tr().toCaption(fontWeight: FontWeight.w500);
    return LocaleKeys.female.tr().toCaption(fontWeight: FontWeight.w500);
  }

  Widget _updatePassword() {
    return [
      11.toSizedBox,
      Strings.currentPassword
          .toTextField()
          .toStreamBuilder(validators: userSettingCubit!.oldPasswordValidator!),
      11.toSizedBox,
      Strings.newPassword
          .toTextField()
          .toStreamBuilder(validators: userSettingCubit!.newPasswordValidator!),
      11.toSizedBox,
      Strings.confirmNewPassword.toTextField().toStreamBuilder(
          validators: userSettingCubit!.confirmPasswordValidator!),
      11.toSizedBox,
      LocaleKeys
          .before_changing_your_current_password_please_follow_these_tips_in
          .tr()
          .toCaption(
              fontWeight: FontWeight.w500,
              color: AppColors.colorPrimary,
              maxLines: 5)
          .toFlexible()
    ].toColumn();
  }

  Widget _verifyMyAccount() {
    return [
      11.toSizedBox,
      Strings.fullName.toTextField().toStreamBuilder(
          validators: userSettingCubit!.verifyFullNameValidator),
      11.toSizedBox,
      Strings.messageToReceiver.toTextField().toStreamBuilder(
          validators: userSettingCubit!.verifyMessageValidator),
      15.toSizedBox,
      LocaleKeys.video_message.tr().toSubTitle2(fontWeight: FontWeight.w500),
      5.toSizedBox,
      LocaleKeys.please_select_a_video_appeal_to_the_reviewer
          .tr()
          .toSubTitle2(align: TextAlign.center)
          .toTextStreamBuilder(
              userSettingCubit!.videoPath.map((event) => event.split('/').last))
          .toPadding(18)
          .toContainer(color: AppColors.sfBgColor, alignment: Alignment.center)
          .onTapWidget(() async {
        await openMediaPicker(context, (media) {
          if (media != null && media.isNotEmpty)
            userSettingCubit!.changeVideoPath(media);
        }, mediaType: MediaTypeEnum.VIDEO);
      }),
      15.toSizedBox,
      LocaleKeys
          .please_note_that_this_material_will_not_be_published_or_shared_wi
          .tr()
          .toCaption(
              fontWeight: FontWeight.w500,
              color: AppColors.colorPrimary,
              maxLines: 10)
          .toFlexible()
    ].toColumn();
  }

  Widget _deleteAccount() {
    return [
      11.toSizedBox,
      Strings.password.toTextField().toStreamBuilder(
          validators: userSettingCubit!.deleteAccountValidator),
      11.toSizedBox,
      LocaleKeys
          .please_note_that_after_deleting_your_account_all_your_publication
          .tr()
          .toCaption(
              fontWeight: FontWeight.w500,
              color: AppColors.colorPrimary,
              maxLines: 5)
          .toFlexible()
    ].toColumn();
  }

  Widget _updateCountry() {
    return StreamBuilder<SettingEntity>(
      stream: userSettingCubit!.settingEntity,
      builder: (context, snapshot) {
        return snapshot.data == null
            ? const SizedBox()
            : StreamBuilder<List<String?>>(
                stream: userSettingCubit!.countries,
                builder: (context, countrySnapshot) {
                  return countrySnapshot.data == null
                      ? const SizedBox()
                      : [
                          11.toSizedBox,
                          SmartSelect<String?>.single(
                            modalFilter: true,
                            modalFilterBuilder:
                                (ctx, S2SingleState<String?> cont) => TextField(
                              decoration: InputDecoration(
                                hintStyle: context.subTitle1
                                    .copyWith(fontWeight: FontWeight.w500),
                                hintText: "Search Country",
                                border: InputBorder.none,
                              ),
                            ),
                            choiceStyle: S2ChoiceStyle(
                              titleStyle: context.subTitle2.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            modalConfig: S2ModalConfig(
                              title: LocaleKeys.change_country.tr(),
                              headerStyle: S2ModalHeaderStyle(
                                textStyle: context.subTitle1.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            modalType: S2ModalType.fullPage,
                            selectedValue: snapshot.data!.country,
                            onChange: (s) {
                              userSettingCubit!
                                ..changeSettingEntity(
                                  snapshot.data!.copyWith(
                                    country: s.value,
                                  ),
                                );
                            },
                            tileBuilder: (c, s) => ListTile(
                              trailing: const Icon(
                                Icons.arrow_forward_ios_outlined,
                                size: 14,
                              ),
                              onTap: () {
                                s.showModal();
                              },
                              title: 'Country'
                                  .toSubTitle2(fontWeight: FontWeight.w500),
                              subtitle: snapshot.data!.country!
                                  .toCaption(fontWeight: FontWeight.w500),
                            ),
                            choiceItems: countrySnapshot.data!
                                .toList()
                                .map((e) => S2Choice(
                                      value: e,
                                      title: e!,
                                    ))
                                .toList(),
                          ),
                          11.toSizedBox,
                          ListTile(
                            title: LocaleKeys
                                .choose_the_country_in_which_you_live_this_information_will_be_pub
                                .tr()
                                .toCaption(
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.colorPrimary,
                                    maxLines: 5),
                          ).toFlexible()
                        ].toColumn();
                },
              );
      },
    );
  }

  String _getButtonText(UpdateSettingEnum updateSettingEnum) {
    String title = "";
    switch (updateSettingEnum) {
      case UpdateSettingEnum.VERIFY_MY_ACCOUNT:
        title = LocaleKeys.submit_request.tr();
        break;
      case UpdateSettingEnum.DELETE_ACCOUNT:
        title = LocaleKeys.delete_account.tr();
        break;
      default:
        title = LocaleKeys.save_changes.tr();
        break;
    }
    return title;
  }

  Widget _changeLanguage() {
    return StreamBuilder<SettingEntity>(
      stream: userSettingCubit!.settingEntity,
      builder: (context, snapshot) {
        return snapshot.data == null
            ? const SizedBox()
            : StreamBuilder<List<String>>(
                stream: userSettingCubit!.languages,
                builder:
                    (context, AsyncSnapshot<List<String>> countrySnapshot) {
                  return countrySnapshot.data == null
                      ? const SizedBox()
                      : [
                          11.toSizedBox,
                          SmartSelect<String?>.single(
                              modalFilter: true,
                              modalFilterBuilder: (ctx, cont) => TextField(
                                    decoration: InputDecoration(
                                      hintStyle: context.subTitle1.copyWith(
                                          fontWeight: FontWeight.w500),
                                      hintText: "Search Language",
                                      border: InputBorder.none,
                                    ),
                                  ),
                              choiceStyle: S2ChoiceStyle(
                                titleStyle: context.subTitle2.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              // title
                              modalConfig: S2ModalConfig(
                                title: LocaleKeys.language.tr(),
                                headerStyle: S2ModalHeaderStyle(
                                  textStyle: context.subTitle1.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              tileBuilder: (c, s) => ListTile(
                                    trailing: const Icon(
                                      Icons.arrow_forward_ios_outlined,
                                      size: 14,
                                    ),
                                    onTap: () => s.showModal(),
                                    title: LocaleKeys.select_display_language
                                        .tr()
                                        .toSubTitle2(
                                            fontWeight: FontWeight.w500),
                                    subtitle: allLanguagesMap[
                                            snapshot.data!.displayLanguage!]!
                                        .toCaption(fontWeight: FontWeight.w500),
                                  ),
                              choiceItems: countrySnapshot.data!
                                  .map((e) => S2Choice(
                                      value: e, title: allLanguagesMap[e]))
                                  .toList(),
                              selectedValue: snapshot.data!.displayLanguage,
                              onChange: (s) {
                                userSettingCubit!
                                  ..changeSettingEntity(
                                    snapshot.data!.copyWith(
                                      displayLang: s.value,
                                    ),
                                  )
                                  ..changeSelectedLang(s.value);
                              }
                              // Tile before choice
                              ),
                          11.toSizedBox,
                          ListTile(
                            title: LocaleKeys
                                .choose_your_preferred_language_for_your_account_interface_this_do
                                .tr()
                                .toCaption(
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.colorPrimary,
                                    maxLines: 5),
                          ).toFlexible()
                        ].toColumn();
                });
      },
    );
  }

  @override
  void dispose() {
    userSettingCubit!.resetAllData();
    userSettingCubit!.newPasswordValidator!..textController.clear();
    userSettingCubit!.oldPasswordValidator!..textController.clear();
    userSettingCubit!.confirmPasswordValidator!..textController.clear();
    super.dispose();
  }
}

enum UpdateSettingEnum {
  USERNAME,
  EMAIL,
  WEBSITE,
  ABOUT_YOU,
  GENDER,
  COUNTRY,
  PASSWORD,
  VERIFY_MY_ACCOUNT,
  CHANGE_LANGUAGE,
  DELETE_ACCOUNT,
}
