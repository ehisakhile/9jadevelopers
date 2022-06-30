import 'package:auto_route/auto_route.dart';
import 'package:colibri/core/config/colors.dart';
import 'package:colibri/core/config/strings.dart';
import 'package:colibri/main.dart';
import '../../../../translations/locale_keys.g.dart';
import 'package:flutter/services.dart';
import '../../../../core/common/static_data/all_countries.dart';
import '../../../../core/common/uistate/common_ui_state.dart';
import '../../../../core/datasource/local_data_source.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/routes/routes.gr.dart';
import '../../../../core/widgets/loading_bar.dart';
import '../../../../extensions.dart';
import '../../domain/entity/setting_entity.dart';
import '../bloc/settings/user_setting_cubit.dart';
import 'settings/update_user_settings.dart';
import '../pagination/privacy_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:video_compress/video_compress.dart';
import 'package:easy_localization/easy_localization.dart';

class SettingsScreen extends StatefulWidget {
  final bool fromProfile;

  const SettingsScreen({Key? key, this.fromProfile = false}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  UserSettingCubit? userSettingCubit;

  @override
  void initState() {
    super.initState();
    userSettingCubit = BlocProvider.of<UserSettingCubit>(context)
      ..getUserSettings();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      if (VideoCompress.compressProgress$.notSubscribed) {
        listenCompressions();
      } else {
        // dispose already subscribed stream
        VideoCompress.dispose();
        listenCompressions();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: Colors.white,
        title: LocaleKeys.profile_settings.tr().toSubTitle1(
              (url) => context.router.root.push(WebViewScreenRoute(url: url)),
              color: AppColors.textColor,
              fontWeight: FontWeight.bold,
              fontFamily1: 'CeraPro',
            ),
        centerTitle: true,
        leading: widget.fromProfile
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
                onPressed: () {
                  context.router.root.pop();
                },
              )
            : null,
        automaticallyImplyLeading: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await userSettingCubit!.getUserSettings();
          return Future.value();
        },
        child: BlocListener<UserSettingCubit, CommonUIState>(
          bloc: userSettingCubit,
          listener: (c, state) {
            state.maybeWhen(
                orElse: () {},
                success: (s) {
                  if (s == "Deleted") {
                    context.router.root.pushAndPopUntil(LoginScreenRoute(),
                        predicate: (route) => false);
                  }
                  context.showSnackBar(message: s);
                },
                error: (e) => context.showSnackBar(message: e, isError: true));
          },
          listenWhen: (c, s) => s.maybeWhen(
              orElse: () => false,
              success: (s) => s is String,
              error: (e) => true),
          child: BlocBuilder<UserSettingCubit, CommonUIState>(
            bloc: userSettingCubit,
            builder: (_, state) {
              return state.when(
                initial: () => LoadingBar(),
                success: (settingEntity) => buildHomeUI(settingEntity),
                loading: () => LoadingBar(),
                error: (e) => StreamBuilder<SettingEntity>(
                  stream: userSettingCubit!.settingEntity,
                  builder: (context, snapshot) {
                    return snapshot.data == null
                        ? const SizedBox()
                        : buildHomeUI(snapshot.data!);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildHomeUI(SettingEntity settingEntity) {
    return [
      header(LocaleKeys.general_profile_settings.tr(), context),
      profileItem(
        LocaleKeys.username.tr(),
        "${settingEntity.name} - ${settingEntity.userName}",
        context,
        onTap: () =>
            openUpdateBottomSheet(settingEntity, UpdateSettingEnum.USERNAME),
      ),
      profileItem(
          LocaleKeys.email_address.tr(), settingEntity.email ?? '', context,
          onTap: () {
        openUpdateBottomSheet(settingEntity, UpdateSettingEnum.EMAIL);
      }),
      profileItem(
          LocaleKeys.website_url_address.tr(), settingEntity.website!, context,
          onTap: () {
        openUpdateBottomSheet(settingEntity, UpdateSettingEnum.WEBSITE);
      }),
      profileItem(LocaleKeys.about_you.tr(), settingEntity.about!, context,
          onTap: () {
        openUpdateBottomSheet(settingEntity, UpdateSettingEnum.ABOUT_YOU);
      }),
      profileItem(LocaleKeys.your_gender.tr(),
          _translateGenderString(settingEntity.gender), context, onTap: () {
        openUpdateBottomSheet(settingEntity, UpdateSettingEnum.GENDER);
      }),
      header(LocaleKeys.user_password.tr(), context).toVisibility(
        !settingEntity.socialLogin,
      ),

      profileItem(LocaleKeys.my_password.tr(), "* * * * * *", context,
          onTap: () {
        openUpdateBottomSheet(settingEntity, UpdateSettingEnum.PASSWORD);
      }).toVisibility(!settingEntity.socialLogin),
      header(LocaleKeys.language_and_country.tr(), context),
      // profileItem("Display Language", settingEntity.displayLanguage),
      profileItem(
        LocaleKeys.display_language.tr(),
        allLanguagesMap[settingEntity.displayLanguage!]!,
        context,
        onTap: () {
          openUpdateBottomSheet(
              settingEntity, UpdateSettingEnum.CHANGE_LANGUAGE);
        },
      ),
      profileItem(LocaleKeys.the_country_in_which_you_live.tr(),
          settingEntity.country!, context, onTap: () {
        openUpdateBottomSheet(settingEntity, UpdateSettingEnum.COUNTRY);
      }),
      header(LocaleKeys.account_verification.tr(), context)
          .toVisibility(!settingEntity.isVerified!),
      profileItem(
          LocaleKeys.verify_my_account.tr(),
          LocaleKeys.click_to_submit_a_verification_request.tr(),
          context, onTap: () {
        openUpdateBottomSheet(
            settingEntity, UpdateSettingEnum.VERIFY_MY_ACCOUNT);
      }).toVisibility(!settingEntity.isVerified!),
      header(LocaleKeys.account_privacy_settings.tr(), context),
      profileItem(
        LocaleKeys.account_privacy.tr(),
        LocaleKeys.click_to_set_your_account_privacy.tr(),
        context,
        onTap: () {
          showModalBottomSheet(
            clipBehavior: Clip.antiAlias,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: const Radius.circular(10),
              ),
            ),
            context: context,
            builder: (c) {
              return BlocProvider.value(
                value: userSettingCubit!,
                child: PrivacyScreen(
                  privacyModels: PrivacyWidgetModel.getPrivacyModels(
                    accountPrivacyEntity: settingEntity.accountPrivacyEntity,
                  ),
                ),
              );
            },
          );
        },
      ),

      header(
        "Company",
        context,
      ),
      profileItem(
          LocaleKeys.terms_of_use.tr(), "Click for our terms of usage", context,
          onTap: () {
        // await launch(link.url);
        context.router.root.push(WebViewScreenRoute(
            url: Strings.termsUrl, name0: LocaleKeys.terms_of_use.tr()));
      }),
      profileItem(LocaleKeys.privacy_policy.tr(),
          "Click for our privacy details", context, onTap: () {
        context.router.root.push(WebViewScreenRoute(
            url: Strings.privacyUrl, name0: LocaleKeys.privacy_policy.tr()));
      }),
      profileItem(
        LocaleKeys.cookies.tr(),
        "Click for our cookies",
        context,
        onTap: () {
          context.router.root.push(
            WebViewScreenRoute(
              url: Strings.cookiesPolicy,
              name0: LocaleKeys.cookies.tr(),
            ),
          );
        },
      ),
      profileItem(
        LocaleKeys.about_us.tr(),
        "Read about us",
        context,
        onTap: () {
          context.router.root.push(
            WebViewScreenRoute(
              url: Strings.aboutUs,
              name0: LocaleKeys.about_us.tr(),
            ),
          );
        },
      ),
      header(
        LocaleKeys.delete_profile.tr(),
        context,
      ),
      profileItem(
        LocaleKeys.delete.tr(),
        LocaleKeys.click_to_confirm_deletion_of_your_profile.tr(),
        context,
        onTap: () {
          openUpdateBottomSheet(
              settingEntity, UpdateSettingEnum.DELETE_ACCOUNT);
        },
      ),

      Padding(
        padding: const EdgeInsets.only(top: 30),
        child: LocaleKeys.logout
            .tr()
            .toCaption(fontWeight: FontWeight.w500, fontSize: 15)
            .toCenter()
            .onTapWidget(
          () {
            context.showAlertDialog(
              widgets: [
                "Yes".toButton().toFlatButton(
                  () async {
                    var localDataSource = getIt<LocalDataSource>();
                    await localDataSource.clearData();
                    // Fix the issue
                    context.router.root.pop();
                    context.router.root.pushAndPopUntil(LoginScreenRoute(),
                        predicate: (c) => false);
                  },
                ),
                "No".toButton().toFlatButton(
                  () {
                    context.router.root.pop();
                  },
                ),
              ],
              title: LocaleKeys
                  .are_you_sure_that_you_want_to_log_out_from_your_account
                  .tr(),
            );
          },
        ),
      ),

      [
        "Version $versionNumber".toCaption(fontWeight: FontWeight.w500),
      ]
          .toColumn(
            mainAxisAlignment: MainAxisAlignment.center,
          )
          .toContainer(alignment: Alignment.bottomCenter, height: 100),
      10.toSizedBox,
    ].toColumn().makeScrollable().toSafeArea;
  }

  void openUpdateBottomSheet(
      SettingEntity settingEntity, UpdateSettingEnum updateSettingEnum) {
    showModalBottomSheet(
        // enableDrag: true,
        isScrollControlled: true,
        shape: 10.0.toRoundRectTop,
        // clipBehavior: Clip.hardEdge,
        context: context,
        builder: (c) => BlocProvider.value(
              value: userSettingCubit!,
              child: UpdateUserProfile(
                updateSettingEnum: updateSettingEnum,
                onTapSave: () {
                  switch (updateSettingEnum) {
                    case UpdateSettingEnum.USERNAME:
                      if (userSettingCubit!.firstNameValidator.text.isEmpty) {
                        context.router.root.pop();
                        userSettingCubit!.firstNameValidator
                            .changeData(settingEntity.firstName);
                        userSettingCubit!.firstNameValidator.textController
                            .text = settingEntity.firstName!;
                        context.showSnackBar(
                          message: "First name must not be empty",
                          isError: true,
                        );
                      } else if (userSettingCubit!
                          .lastNameValidator.text.isEmpty) {
                        context.router.root.pop();
                        userSettingCubit!.lastNameValidator.textController
                            .text = settingEntity.lastName!;
                        userSettingCubit!.lastNameValidator
                            .changeData(settingEntity.lastName);
                        context.showSnackBar(
                            message: "Last name must not be empty",
                            isError: true);
                      } else if (userSettingCubit!
                          .userNameValidator.text.isEmpty) {
                        context.router.root.pop();
                        userSettingCubit!.userNameValidator
                            .changeData(settingEntity.userName);
                        userSettingCubit!.userNameValidator.textController
                            .text = settingEntity.userName;
                        context.showSnackBar(
                            message: "Username must not be empty",
                            isError: true);
                      } else {
                        userSettingCubit!.updateUserSettings(updateSettingEnum);
                        context.router.root.pop();
                      }
                      break;
                    case UpdateSettingEnum.EMAIL:
                      if (userSettingCubit!.emailValidator.text.isEmpty) {
                        context.router.root.pop();
                        userSettingCubit!.emailValidator
                            .changeData(settingEntity.email);
                        userSettingCubit!.emailValidator.textController.text =
                            settingEntity.email!;
                        context.showSnackBar(
                            message: "Email must not be empty", isError: true);
                      } else {
                        userSettingCubit!.updateUserSettings(updateSettingEnum);
                        context.router.root.pop();
                      }
                      break;
                    case UpdateSettingEnum.WEBSITE:
                      if (userSettingCubit!.websiteValidators.text.isEmpty) {
                        userSettingCubit!
                            .websiteValidators.textController.text = '';
                        userSettingCubit!.updateUserSettings(updateSettingEnum);
                        context.router.root.pop();
                      } else {
                        if (!userSettingCubit!
                            .websiteValidators.text.isValidUrl) {
                          userSettingCubit!.websiteValidators
                              .changeData(settingEntity.website);
                          userSettingCubit!.websiteValidators.textController
                              .text = settingEntity.website!;
                          context.router.root.pop();
                          context.showSnackBar(
                            message: "Website address is not valid",
                            isError: true,
                          );
                        } else {
                          userSettingCubit!
                              .updateUserSettings(updateSettingEnum);
                          context.router.root.pop();
                        }
                      }
                      break;
                    case UpdateSettingEnum.ABOUT_YOU:
                      userSettingCubit!.updateUserSettings(updateSettingEnum);
                      context.router.root.pop();

                      break;
                    case UpdateSettingEnum.GENDER:
                      userSettingCubit!.updateUserSettings(updateSettingEnum);
                      context.router.root.pop();
                      break;
                    case UpdateSettingEnum.COUNTRY:
                      userSettingCubit!.updateUserSettings(updateSettingEnum);
                      context.router.root.pop();
                      break;
                    case UpdateSettingEnum.PASSWORD:
                      if (userSettingCubit!
                          .oldPasswordValidator!.text.isEmpty) {
                        context.showSnackBar(
                            message: "Old Password you must not be empty",
                            isError: true);
                      } else if (userSettingCubit!
                          .newPasswordValidator!.text.isEmpty) {
                        context.showSnackBar(
                            message: "New Password you must not be empty",
                            isError: true);
                      } else if (userSettingCubit!
                              .newPasswordValidator!.text.isEmpty ||
                          userSettingCubit!
                              .confirmPasswordValidator!.text.isEmpty ||
                          userSettingCubit!.newPasswordValidator!.text !=
                              userSettingCubit!
                                  .confirmPasswordValidator!.text) {
                        context.showSnackBar(
                            message: "Please make sure password match",
                            isError: true);
                      } else {
                        // userSettingCubit.oldPasswordValidator.addError("dummy");
                        userSettingCubit!.updateUserSettings(updateSettingEnum);
                        // context.router.root.pop();
                      }
                      break;
                    case UpdateSettingEnum.VERIFY_MY_ACCOUNT:
                      userSettingCubit!.verifyUserAccount();
                      context.router.root.pop();
                      break;
                    case UpdateSettingEnum.DELETE_ACCOUNT:
                      if (userSettingCubit!
                          .deleteAccountValidator.text.isValidPass)
                        userSettingCubit!.deleteAccount(context);
                      else
                        context.showSnackBar(
                            message:
                                userSettingCubit!.deleteAccountValidator.text);
                      context.router.root.pop();
                      break;
                    case UpdateSettingEnum.CHANGE_LANGUAGE:
                      userSettingCubit!.changeUserLanguage(context);
                      context.router.root.pop();
                      break;
                  }
                },
              ),
            ));
  }

  void listenCompressions() {
    VideoCompress.compressProgress$.subscribe(
      (progress) {
        if (progress < 99.99)
          EasyLoading.showProgress(
            (progress / 100),
            status: 'Compressing ${progress.toInt()}%',
          );
        else
          EasyLoading.dismiss();
      },
    );
  }
}

Widget header(String name, BuildContext context) {
  return [
    name.toCaption(
      fontWeight: FontWeight.bold,
      textAlign: context.isArabic() ? TextAlign.right : TextAlign.left,
    )
  ]
      .toColumn(crossAxisAlignment: CrossAxisAlignment.stretch)
      .toHorizontalPadding(12)
      .toPadding(12)
      .onTapWidget(() {})
      .toContainer(color: AppColors.lightSky.withOpacity(.5))
      .makeBottomBorder;
}

Widget profileItem(String title, String value, BuildContext context,
    {VoidCallback? onTap}) {
  return [
    title.toSubTitle2(
      fontWeight: FontWeight.bold,
      align: context.isArabic() ? TextAlign.right : TextAlign.left,
    ),
    5.toSizedBox,
    value.toSubTitle2(
      align: context.isArabic() ? TextAlign.right : TextAlign.left,
    )
  ]
      .toColumn(crossAxisAlignment: CrossAxisAlignment.stretch)
      .toPadding(12)
      .toContainer()
      .makeBottomBorder
      .toFlatButton(
    () {
      onTap?.call();
    },
  );
}

String _translateGenderString(String s) {
  if (s == 'Male' || s == LocaleKeys.male.tr()) return LocaleKeys.male.tr();
  return LocaleKeys.female.tr();
}

class PrivacyWidgetModel {
  final String value;
  final PrivacyOptionEnum privacyOptionEnum;
  final bool isSelected;
  PrivacyWidgetModel._(this.value, this.privacyOptionEnum,
      {this.isSelected = false});

  static List<PrivacyWidgetModel> getPrivacyModels(
      {required AccountPrivacyEntity accountPrivacyEntity}) {
    return [
      PrivacyWidgetModel._(
        LocaleKeys.yes.tr(),
        PrivacyOptionEnum.SEARCH_VISIBILITY,
        isSelected: accountPrivacyEntity.showProfileInSearchEngine ==
            Strings.privacyYes,
      ),
      PrivacyWidgetModel._(
        LocaleKeys.no.tr(),
        PrivacyOptionEnum.SEARCH_VISIBILITY,
        isSelected:
            accountPrivacyEntity.showProfileInSearchEngine == Strings.privacyNo,
      ),
      PrivacyWidgetModel._(
        LocaleKeys.everyone.tr(),
        PrivacyOptionEnum.CONTACT_PRIVACY,
        isSelected: accountPrivacyEntity.canDMMe == Strings.privacyEveryOne,
      ),
      PrivacyWidgetModel._(
        LocaleKeys.the_people_i_follow.tr(),
        PrivacyOptionEnum.CONTACT_PRIVACY,
        isSelected:
            accountPrivacyEntity.canDMMe == Strings.privacyPeopleIFollow,
      ),
      PrivacyWidgetModel._(
        LocaleKeys.everyone.tr(),
        PrivacyOptionEnum.PROFILE_VISIBILITY,
        isSelected:
            accountPrivacyEntity.canSeeMyPosts == Strings.privacyEveryOne,
      ),
      PrivacyWidgetModel._(
        LocaleKeys.my_followers.tr(),
        PrivacyOptionEnum.PROFILE_VISIBILITY,
        isSelected:
            accountPrivacyEntity.canSeeMyPosts == Strings.privacyMyFollowers,
      ),
    ];
  }

  static String getEnumValue(PrivacyOptionEnum privacyOptionEnum) {
    String text = '';
    switch (privacyOptionEnum) {
      case PrivacyOptionEnum.PROFILE_VISIBILITY:
        text = LocaleKeys.who_can_see_my_profile_posts.tr();
        break;
      case PrivacyOptionEnum.CONTACT_PRIVACY:
        text = LocaleKeys.who_can_direct_message_me.tr();
        break;
      case PrivacyOptionEnum.SEARCH_VISIBILITY:
        text = LocaleKeys.show_your_profile_in_search_engines.tr();
        break;
    }
    return text;
  }

  PrivacyWidgetModel copyWith(
      {String? value, PrivacyOptionEnum? privacyOptionEnum, bool? isSelected}) {
    return PrivacyWidgetModel._(
        value ?? this.value, privacyOptionEnum ?? this.privacyOptionEnum,
        isSelected: isSelected ?? this.isSelected);
  }
}

enum PrivacyOptionEnum {
  PROFILE_VISIBILITY,
  CONTACT_PRIVACY,
  SEARCH_VISIBILITY
}
