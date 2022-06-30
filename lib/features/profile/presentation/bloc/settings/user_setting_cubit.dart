import 'dart:async';
import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:colibri/core/config/api_constants.dart';
import 'package:colibri/core/config/strings.dart';
import '../../../../../translations/locale_keys.g.dart';
import 'package:flutter/widgets.dart';
import '../../../../../core/common/static_data/all_countries.dart';
import '../../../../../core/common/stream_validators.dart';
import '../../../../../core/common/uistate/common_ui_state.dart';
import '../../../data/models/request/update_password_request.dart';
import '../../../data/models/request/update_setting_request_model.dart';
import '../../../data/models/request/verify_request_model.dart';
import '../../../domain/entity/setting_entity.dart';
import '../../../domain/usecase/change_language_use_case.dart';
import '../../../domain/usecase/delete_account_use_case.dart';
import '../../../domain/usecase/get_login_mode.dart';
import '../../../domain/usecase/get_user_settings.dart';
import '../../../domain/usecase/udpate_password_use_case.dart';
import '../../../domain/usecase/update_privacy_setting_use_case.dart';
import '../../../domain/usecase/update_profile_setting_use_case.dart';
import '../../../domain/usecase/verify_user_account_use_case.dart';
import '../../pages/settings/update_user_settings.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:easy_localization/easy_localization.dart';
part 'user_setting_state.dart';

@injectable
class UserSettingCubit extends Cubit<CommonUIState> {
  //settings
  final _settingEntityController = BehaviorSubject<SettingEntity>();

  Function(SettingEntity) get changeSettingEntity =>
      _settingEntityController.sink.add;

  Stream<SettingEntity> get settingEntity => _settingEntityController.stream;

  // all countries
  final _countriesListController =
      BehaviorSubject<List<String?>>.seeded(ApiConstants.allCountries);
  Function(List<String>) get changeCountries =>
      _countriesListController.sink.add;
  Stream<List<String?>> get countries => _countriesListController.stream;

  final _allLanguagesController =
      BehaviorSubject<List<String>>.seeded(ApiConstants.allLanguages);
  Function(List<String>) get changeLanguage => _allLanguagesController.sink.add;
  Stream<List<String>> get languages => _allLanguagesController.stream;

  // update user name and name
  late FieldValidators firstNameValidator;
  late FieldValidators userNameValidator;
  late FieldValidators lastNameValidator;

  // update email
  late FieldValidators emailValidator;

  // update website
  late FieldValidators websiteValidators;

  // update about you
  late FieldValidators aboutYouValidators;

  String gender = "M";

  FieldValidators? fullNameValidators;

  FieldValidators? messageToReceiverValidators;

  FieldValidators? oldPasswordValidator;

  FieldValidators? newPasswordValidator;

  FieldValidators? confirmPasswordValidator;

  late FieldValidators deleteAccountValidator;

  final _selectedLangController = BehaviorSubject<String?>();
  Function(String?) get changeSelectedLang => _selectedLangController.sink.add;
  Stream<String?> get selectedLang => _selectedLangController.stream;

  // verify Account
  late FieldValidators verifyFullNameValidator;
  late FieldValidators verifyMessageValidator;

  final _videoPathController = BehaviorSubject<String>();

  Function(String) get changeVideoPath => _videoPathController.sink.add;

  Stream<String> get videoPath => _videoPathController.stream;

  // use cases
  final UpdateUserSettingsUseCase? updateUserSettingsUseCase;

  final UpdatePasswordUseCase? updatePasswordUseCase;

  final UpdatePrivacyUseCase? updatePrivacyUseCase;

  final GetUserSettingsUseCase? getUserSettingsUseCase;

  final DeleteAccountUseCase? deleteAccountUseCase;

  final VerifyUserAccountUseCase? verifyUserAccountUseCase;

  final ChangeLanguageUseCase? changeLanguageUseCase;

  final GetLoginMode? loginMode;

  UserSettingCubit(
      this.getUserSettingsUseCase,
      this.updateUserSettingsUseCase,
      this.updatePasswordUseCase,
      this.updatePrivacyUseCase,
      this.deleteAccountUseCase,
      this.verifyUserAccountUseCase,
      this.changeLanguageUseCase,
      this.loginMode)
      : super(const CommonUIState.initial()) {
    initValidators();
  }

  Future<void> getUserSettings() async {
    emit(const CommonUIState.loading());
    var either = await getUserSettingsUseCase!(unit);
    either.fold(
      (l) => emit(CommonUIState.error(l.errorMessage)),
      (r) async {
        var mode = await getLoginMode();
        emit(CommonUIState.success(r.copyWith(didSocialLogin: mode)));
        setAllUserData(r.copyWith(didSocialLogin: mode));
      },
    );
  }

  Future<bool> getLoginMode() async {
    var mode = await loginMode!(unit);
    var m = false;
    mode.fold((l) {
      m = false;
    }, (r) {
      m = r;
    });
    return m;
  }

  updateUserSettings(UpdateSettingEnum updateSettingEnum) async {
    // print(updateSettingEnum.toString());
    emit(const CommonUIState.loading());
    if (updateSettingEnum == UpdateSettingEnum.PASSWORD) {
      final either = await updatePasswordUseCase!(UpdatePasswordRequest(
          newPassword: newPasswordValidator!.text,
          oldPassword: oldPasswordValidator!.text));
      either.fold(
        (l) {
          switch (updateSettingEnum) {
            case UpdateSettingEnum.USERNAME:
              userNameValidator.changeData("new value");
              userNameValidator.textController.text = "new value";
              break;
            case UpdateSettingEnum.EMAIL:
              break;
            case UpdateSettingEnum.WEBSITE:
              break;
            case UpdateSettingEnum.ABOUT_YOU:
              break;
            case UpdateSettingEnum.GENDER:
              break;
            case UpdateSettingEnum.COUNTRY:
              break;
            case UpdateSettingEnum.PASSWORD:
              oldPasswordValidator!.addError(l.errorMessage);
              break;
            case UpdateSettingEnum.VERIFY_MY_ACCOUNT:
              break;
            case UpdateSettingEnum.CHANGE_LANGUAGE:
              break;
            case UpdateSettingEnum.DELETE_ACCOUNT:
              break;
          }
          return emit(CommonUIState.error(l.errorMessage));
        },
        (r) => emit(
          const CommonUIState.success(
            "Password changed successfully",
          ),
        ),
      );
    } else {
      print(
        "c ${ApiConstants.allCountries.indexOf(_settingEntityController.value.country!).toString()}",
      );
      var either = await updateUserSettingsUseCase!(
        UpdateSettingsRequestModel(
          firstName: firstNameValidator.text,
          lastName: lastNameValidator.text,
          username: userNameValidator.text,
          email: emailValidator.text,
          gender: gender == LocaleKeys.male.tr() ? 'M' : 'F',
          countryId:
              HashMap.from(countryMap)[_settingEntityController.value.country],
          aboutYou: aboutYouValidators.text,
          website: websiteValidators.text,
        ),
      );
      either.fold((l) {
        emit(CommonUIState.error(l.errorMessage));
      }, (r) async {
        emit(
          const CommonUIState.success("Profile updated successfully"),
        );
        await getUserSettings();
      });
    }
    // emit(CommonUIState.initial());
  }

  updateUserPrivacy() async {
    emit(const CommonUIState.loading());
    var either = await updatePrivacyUseCase!(
        _settingEntityController.value.accountPrivacyEntity);
    either.fold((l) => emit(CommonUIState.error(l.errorMessage)), (r) async {
      emit(const CommonUIState.success("Privacy updated successfully"));
      await getUserSettings();
    });
  }

  void initValidators() {
    userNameValidator = FieldValidators(null, null);
    lastNameValidator = FieldValidators(null, userNameValidator.focusNode);
    firstNameValidator = FieldValidators(null, lastNameValidator.focusNode);
    emailValidator = FieldValidators(null, null);
    websiteValidators = FieldValidators(null, null);
    aboutYouValidators = FieldValidators(null, null);
    fullNameValidators = FieldValidators(null, null);
    messageToReceiverValidators = FieldValidators(null, null);

    confirmPasswordValidator = FieldValidators(
      null,
      null,
      obsecureTextBool: true,
      passwordField: true,
    );
    oldPasswordValidator = FieldValidators(null, null, obsecureTextBool: true);
    newPasswordValidator = FieldValidators(
      null,
      confirmPasswordValidator!.focusNode,
      obsecureTextBool: true,
      passwordField: true,
    );
    deleteAccountValidator =
        FieldValidators(null, null, obsecureTextBool: true);

    verifyFullNameValidator = FieldValidators(null, null);
    verifyMessageValidator = FieldValidators(null, null);
  }

  deleteAccount(BuildContext context) async {
    emit(const CommonUIState.loading());
    var either = await deleteAccountUseCase!(
        DeleteAccountParam(context, deleteAccountValidator.text));
    either.fold(
      (l) => emit(CommonUIState.error(l.errorMessage)),
      (r) => emit(
        const CommonUIState.success("Account Deleted Successfully"),
      ),
    );
  }

  verifyUserAccount() async {
    if (verifyFullNameValidator.text.isEmpty) {
      emit(const CommonUIState.error('First name is empty'));
    } else if (verifyMessageValidator.text.isEmpty) {
      emit(const CommonUIState.error('message is empty'));
    } else if (_videoPathController.value.isEmpty) {
      emit(const CommonUIState.error('Please choose video file'));
    } else {
      emit(const CommonUIState.loading());
      await verifyUserAccountUseCase!(
        VerifyRequestModel(
          fullName: verifyFullNameValidator.text,
          message: verifyMessageValidator.text,
          video: _videoPathController.value,
        ),
      )
        ..fold(
          (l) => emit(CommonUIState.error(l.errorMessage)),
          (r) {
            verifyFullNameValidator.clear;
            verifyMessageValidator.clear;
            changeVideoPath('');
            emit(const CommonUIState.success(
                'Verification request sent successfully'));
          },
        );
    }
  }

  changeUserLanguage(BuildContext context) async {
    emit(const CommonUIState.loading());
    final either =
        await (changeLanguageUseCase!(_selectedLangController.value!));
    either.fold(
      (l) => emit(CommonUIState.error(l.errorMessage)),
      (r) async {
        await context.setLocale(
          Locale(
            _mapCountryToLanguageCode(
              _selectedLangController.value,
            ),
          ),
        );

        return emit(CommonUIState.success(r));
      },
    );
  }

  String _mapCountryToLanguageCode(String? country) {
    switch (country) {
      case 'english':
        return 'en';

      case 'arabic':
        return 'ar';

      case 'french':
        return 'fr';

      case 'german':
        return 'de';

      case 'italian':
        return 'it';

      case 'russian':
        return 'ru';

      case 'portuguese':
        return 'pt';

      case 'spanish':
        return 'es';

      case 'turkish':
        return 'tr';

      case 'dutch':
        return 'nl';

      case 'ukraine':
        return 'uk';

      default:
        return 'en';
    }
  }

  resetAllData() {
    final value = _settingEntityController.value;
    // _videoPathController.addError(null);
    verifyMessageValidator.textController.clear();
    verifyFullNameValidator.textController.clear();
    changeVideoPath("Select a video appeal to the reviewer");

    newPasswordValidator!.onChange("");
    oldPasswordValidator!.onChange("");
    confirmPasswordValidator!.onChange("");
    firstNameValidator.onChange(value.firstName!);
    lastNameValidator.onChange(value.lastName!);
    userNameValidator.onChange(value.userName);
    emailValidator.onChange(value.email!);
    aboutYouValidators.onChange(value.about!);
    setAllUserData(_settingEntityController.value);
  }

  void setAllUserData(SettingEntity r) {
    userNameValidator.textController.text = r.userName.replaceAll("@", "");
    firstNameValidator.textController.text = r.firstName!;
    lastNameValidator.textController.text = r.lastName!;
    websiteValidators.textController.text =
        r.website == Strings.emptyWebsite ? "" : r.website!;
    aboutYouValidators.textController.text =
        r.about == Strings.emptyAbout ? "" : r.about!;
    emailValidator.textController.text = r.email!;
    gender = r.gender == "Female" ? "F" : "M";
    changeSettingEntity(r);
  }
}
