import 'dart:collection';

import 'package:colibri/core/config/strings.dart';
import 'package:equatable/equatable.dart';

import '../../data/models/response/privacy_response.dart';
import 'profile_entity.dart';

class SettingEntity extends Equatable {
  final String userName;
  final String? firstName;
  final String? lastName;
  final String name;
  final String? email;
  final String? website;
  final String? about;
  final String gender;
  final String? displayLanguage;
  final String? country;
  final bool? isVerified;
  final bool socialLogin;
  final AccountPrivacyEntity accountPrivacyEntity;

  SettingEntity._({
    required this.userName,
    required this.email,
    required this.website,
    required this.about,
    required this.gender,
    required this.displayLanguage,
    required this.country,
    required this.accountPrivacyEntity,
    required this.name,
    required this.firstName,
    required this.lastName,
    required this.isVerified,
    this.socialLogin = false,
  });

  factory SettingEntity.fromSettingResponse(
    ProfileEntity user,
    AccountPrivacyEntity accountPrivacyEntity,
  ) =>
      SettingEntity._(
        userName: user.userName,
        email: user.email,
        website: user.website != null && user.website!.isNotEmpty
            ? user.website
            : Strings.emptyWebsite,
        about: user.about != null && user.about!.isNotEmpty
            ? user.about
            : Strings.emptyAbout,
        gender: user.gender,
        displayLanguage: user.language,
        country: user.country,
        name: user.fullName,
        accountPrivacyEntity: accountPrivacyEntity,
        firstName: user.firstName,
        lastName: user.lastName,
        isVerified: user.isVerified,
      );

  SettingEntity copyWith({
    bool? didSocialLogin,
    String? updatedGender,
    String? country,
    AccountPrivacyEntity? accountPrivacyEntity,
    String? displayLang,
  }) =>
      SettingEntity._(
          userName: userName,
          email: email,
          website: website != null && website!.isNotEmpty
              ? website
              : "You have not yet determined the URL of your site",
          about: about != null && about!.isNotEmpty
              ? about
              : "The field with information about you is still empty",
          gender: updatedGender ?? gender,
          displayLanguage: displayLang ?? this.displayLanguage,
          country: country ?? this.country,
          accountPrivacyEntity:
              accountPrivacyEntity ?? this.accountPrivacyEntity,
          name: name,
          firstName: firstName,
          lastName: lastName,
          socialLogin: didSocialLogin ?? socialLogin,
          isVerified: isVerified);

  @override
  List<Object?> get props => [
        this.userName,
        this.email,
        this.website,
        this.about,
        this.gender,
        this.displayLanguage,
        this.country,
        this.accountPrivacyEntity,
        this.name,
        this.firstName,
        this.lastName,
        this.isVerified,
        this.socialLogin,
      ];
}

class AccountPrivacyEntity extends Equatable {
  final String canSeeMyPosts;
  final String? canFollowMe;
  final String? canDMMe;
  final String showProfileInSearchEngine;

  AccountPrivacyEntity._(
      {required this.canSeeMyPosts,
      required this.canFollowMe,
      required this.canDMMe,
      required this.showProfileInSearchEngine});

  factory AccountPrivacyEntity.fromResponse(PrivacyModel model) =>
      AccountPrivacyEntity._(
          canSeeMyPosts: model.profileVisibility == "followers"
              ? Strings.privacyMyFollowers
              : Strings.privacyEveryOne,
          canFollowMe: null,
          canDMMe: model.contactPrivacy == "followed"
              ? Strings.privacyPeopleIFollow
              : Strings.privacyEveryOne,
          showProfileInSearchEngine:
              model.searchVisibility! ? Strings.privacyYes : Strings.privacyNo);
  HashMap<String, String> toModelJson() => HashMap.from({
        "profile_visibility": canSeeMyPosts == Strings.privacyMyFollowers
            ? "followers"
            : "everyone",
        "contact_privacy":
            canDMMe == Strings.privacyEveryOne ? "everyone" : "followed",
        "follow_privacy": "everyone",
        "search_visibility":
            showProfileInSearchEngine == Strings.privacyYes ? "Y" : "N",
      });

  AccountPrivacyEntity copyWith(
          {String? canSeeMyPosts,
          String? canFollowMe,
          String? showProfileInSearchEngine}) =>
      AccountPrivacyEntity._(
          canSeeMyPosts: canSeeMyPosts ?? this.canSeeMyPosts,
          canFollowMe: null,
          canDMMe: canFollowMe ?? this.canFollowMe,
          showProfileInSearchEngine:
              showProfileInSearchEngine ?? this.showProfileInSearchEngine);

  @override
  List<Object?> get props => [
        this.canSeeMyPosts,
        this.canFollowMe,
        this.canDMMe,
        this.showProfileInSearchEngine,
      ];
}
