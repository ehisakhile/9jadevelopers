import 'package:colibri/translations/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class Strings {
  static final welcome = LocaleKeys.welcome.tr();
  static final seeWhats = "See What's happening in the \n world now!";
  static final login = LocaleKeys.login.tr();
  static final signUp = LocaleKeys.sign_up.tr();
  static final signUpCaps = LocaleKeys.sign_up.tr().toUpperCase();
  static final fbLoginComing = "Facebook login coming soon!!";
  static final twitterComing = "Twitter login coming soon!!";
  static final googleComing = "Google login coming soon!!";
  static final userSiteUrl = LocaleKeys.user_site_url.tr();
  static final aboutYou = LocaleKeys.about_you.tr();
  static final currentPassword = LocaleKeys.current_password.tr();
  static final newPassword = LocaleKeys.new_password.tr();
  static final confirmNewPassword = LocaleKeys.confirm_new_password.tr();
  static final fullName = LocaleKeys.full_name.tr();
  static final messageToReceiver = LocaleKeys.message_to_reviewer.tr();

  static final firstName = LocaleKeys.first_name.tr();
  static final lastName = LocaleKeys.last_name.tr();
  static final userName = LocaleKeys.username.tr();
  static final emailAddress = LocaleKeys.email_address.tr();
  static final password = LocaleKeys.password.tr();
  static final confirmPassword = LocaleKeys.confirm_the_password.tr();
  static final byClickingAgree = LocaleKeys.by_continuing_you_agree_to
      .tr(namedArgs: {'@site_name@': 'Colibri'});
  static final termsOfUse = LocaleKeys.terms_of_use.tr();
  static final privacy = LocaleKeys.privacy_policy.tr();
  static final haveAlreadyAccount = LocaleKeys.already_have_an_account.tr();
  static final signIn = LocaleKeys.login.tr();
  static final dontHaveAnAccount = LocaleKeys.don_t_have_an_account.tr();
  static final affiliatesStr = LocaleKeys.affiliates.tr();
  static final ads = LocaleKeys.active_ads.tr();
  static final forgotPassword = LocaleKeys.forgot_your_password.tr();
  static final termsUrl = "https://www.csm-demo.ru/terms_of_use";
  static final privacyUrl = "https://www.csm-demo.ru/privacy_policy";
  static final aboutUs = "https://www.csm-demo.ru/about_us";
  static final cookiesPolicy = "https://www.csm-demo.ru/cookies_policy";
  static final affiliates = "https://www.csm-demo.ru/affiliates";
  static final adsShow = "https://www.csm-demo.ru/ads";

  static var giphyApiKey = 'FAbXVBBRFv47ENKctsjc0oz1fqdsq0Kl';

  static final bookmarkAdded = LocaleKeys.post_has_been_bookmarked.tr();
  static final removeBookmark =
      LocaleKeys.post_has_been_deleted_from_bookmarks.tr();
  static final privacyYes = LocaleKeys.yes.tr();
  static final privacyNo = LocaleKeys.no.tr();
  static final privacyEveryOne = LocaleKeys.everyone.tr();
  static final privacyMyFollowers = LocaleKeys.my_followers.tr();
  static final privacyPeopleIFollow = LocaleKeys.the_people_i_follow.tr();
  static final emptyWebsite =
      LocaleKeys.you_have_not_yet_determined_the_url_of_your_site.tr();
  static final emptyAbout =
      LocaleKeys.the_field_with_information_about_you_is_still_empty.tr();
  static final cookie = LocaleKeys.cookies.tr();
  static final about = LocaleKeys.about_us.tr();
}
