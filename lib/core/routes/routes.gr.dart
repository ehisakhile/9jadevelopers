// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

import 'package:auto_route/auto_route.dart' as _i15;
import 'package:flutter/material.dart' as _i16;

import '../../features/authentication/presentation/pages/login_screen.dart'
    as _i3;
import '../../features/authentication/presentation/pages/reset_password_screen.dart'
    as _i4;
import '../../features/authentication/presentation/pages/signup_screen.dart'
    as _i2;
import '../../features/feed/domain/entity/post_entity.dart' as _i19;
import '../../features/feed/presentation/pages/feed_screen.dart' as _i7;
import '../../features/messages/domain/entity/message_entity.dart' as _i18;
import '../../features/messages/presentation/pages/chat_screen.dart' as _i10;
import '../../features/posts/domain/entiity/reply_entity.dart' as _i17;
import '../../features/posts/presentation/pages/create_post.dart' as _i9;
import '../../features/posts/presentation/pages/view_post_screen.dart' as _i11;
import '../../features/profile/presentation/pages/followers_following_screen.dart'
    as _i12;
import '../../features/profile/presentation/pages/profile_screen.dart' as _i8;
import '../../features/profile/presentation/pages/settings_page.dart' as _i14;
import '../../features/search/presentation/pages/searh_screen.dart' as _i13;
import '../../features/welcome/welcome_screen.dart' as _i1;
import '../common/error_screen.dart' as _i6;
import '../common/widget/web_view_screen.dart' as _i5;

class MyRouter extends _i15.RootStackRouter {
  MyRouter([_i16.GlobalKey<_i16.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i15.PageFactory> pagesMap = {
    WelcomeScreenRoute.name: (routeData) {
      return _i15.CupertinoPageX<dynamic>(
          routeData: routeData, child: _i1.WelcomeScreen());
    },
    SignUpScreenRoute.name: (routeData) {
      return _i15.CupertinoPageX<dynamic>(
          routeData: routeData, child: _i2.SignUpScreen());
    },
    LoginScreenRoute.name: (routeData) {
      return _i15.CupertinoPageX<dynamic>(
          routeData: routeData, child: _i3.LoginScreen());
    },
    ResetPasswordScreenRoute.name: (routeData) {
      return _i15.CupertinoPageX<dynamic>(
          routeData: routeData, child: _i4.ResetPasswordScreen());
    },
    WebViewScreenRoute.name: (routeData) {
      final args = routeData.argsAs<WebViewScreenRouteArgs>(
          orElse: () => const WebViewScreenRouteArgs());
      return _i15.MaterialPageX<dynamic>(
          routeData: routeData,
          child:
              _i5.WebViewScreen(key: args.key, url: args.url, name: args.name));
    },
    ErrorScreenRoute.name: (routeData) {
      final args = routeData.argsAs<ErrorScreenRouteArgs>(
          orElse: () => const ErrorScreenRouteArgs());
      return _i15.CupertinoPageX<dynamic>(
          routeData: routeData,
          child: _i6.ErrorScreen(key: args.key, error: args.error));
    },
    FeedScreenRoute.name: (routeData) {
      return _i15.CupertinoPageX<dynamic>(
          routeData: routeData, child: _i7.FeedScreen());
    },
    ProfileScreenRoute.name: (routeData) {
      final args = routeData.argsAs<ProfileScreenRouteArgs>(
          orElse: () => const ProfileScreenRouteArgs());
      return _i15.CupertinoPageX<dynamic>(
          routeData: routeData,
          child: _i8.ProfileScreen(
              key: args.key,
              otherUserId: args.otherUserId,
              profileUrl: args.profileUrl,
              coverUrl: args.coverUrl,
              profileNavigationEnum: args.profileNavigationEnum));
    },
    CreatePostRoute.name: (routeData) {
      final args = routeData.argsAs<CreatePostRouteArgs>(
          orElse: () => const CreatePostRouteArgs());
      return _i15.MaterialPageX<dynamic>(
          routeData: routeData,
          child: _i9.CreatePost(
              key: args.key,
              isCreatePost: true,
              title: args.title,
              replyTo: args.replyTo,
              threadId: args.threadId,
              replyEntity: args.replyEntity,
              backData: args.backData),
          fullscreenDialog: true);
    },
    ChatScreenRoute.name: (routeData) {
      final args = routeData.argsAs<ChatScreenRouteArgs>(
          orElse: () => const ChatScreenRouteArgs());
      return _i15.CupertinoPageX<dynamic>(
          routeData: routeData,
          child: _i10.ChatScreen(
              key: args.key,
              otherPersonUserId: args.otherPersonUserId,
              otherUserFullName: args.otherUserFullName,
              otherPersonProfileUrl: args.otherPersonProfileUrl,
              entity: args.entity));
    },
    ViewPostScreenRoute.name: (routeData) {
      final args = routeData.argsAs<ViewPostScreenRouteArgs>();
      return _i15.CupertinoPageX<dynamic>(
          routeData: routeData,
          child: _i11.ViewPostScreen(
              key: args.key,
              threadID: args.threadID,
              postEntity: args.postEntity));
    },
    FollowingFollowersScreenRoute.name: (routeData) {
      final args = routeData.argsAs<FollowingFollowersScreenRouteArgs>(
          orElse: () => const FollowingFollowersScreenRouteArgs());
      return _i15.MaterialPageX<dynamic>(
          routeData: routeData,
          child: _i12.FollowingFollowersScreen(
              key: args.key,
              followScreenEnum: args.followScreenEnum,
              userId: args.userId),
          fullscreenDialog: true);
    },
    SearchScreenRoute.name: (routeData) {
      final args = routeData.argsAs<SearchScreenRouteArgs>(
          orElse: () => const SearchScreenRouteArgs());
      return _i15.MaterialPageX<dynamic>(
          routeData: routeData,
          child: _i13.SearchScreen(
              key: args.key, searchedText: args.searchedText));
    },
    SettingsScreenRoute.name: (routeData) {
      final args = routeData.argsAs<SettingsScreenRouteArgs>(
          orElse: () => const SettingsScreenRouteArgs());
      return _i15.MaterialPageX<dynamic>(
          routeData: routeData,
          child: _i14.SettingsScreen(
              key: args.key, fromProfile: args.fromProfile));
    }
  };

  @override
  List<_i15.RouteConfig> get routes => [
        _i15.RouteConfig(WelcomeScreenRoute.name, path: '/welcome-screen'),
        _i15.RouteConfig(SignUpScreenRoute.name, path: '/sign-up-screen'),
        _i15.RouteConfig(LoginScreenRoute.name, path: '/login-screen'),
        _i15.RouteConfig(ResetPasswordScreenRoute.name,
            path: '/reset-password-screen'),
        _i15.RouteConfig(WebViewScreenRoute.name, path: '/web-view-screen'),
        _i15.RouteConfig(ErrorScreenRoute.name, path: '/error-screen'),
        _i15.RouteConfig(FeedScreenRoute.name, path: '/feed-screen'),
        _i15.RouteConfig(ProfileScreenRoute.name, path: '/profile-screen'),
        _i15.RouteConfig(CreatePostRoute.name, path: '/create-post'),
        _i15.RouteConfig(ChatScreenRoute.name, path: '/chat-screen'),
        _i15.RouteConfig(ViewPostScreenRoute.name, path: '/view-post-screen'),
        _i15.RouteConfig(FollowingFollowersScreenRoute.name,
            path: '/following-followers-screen'),
        _i15.RouteConfig(SearchScreenRoute.name, path: '/search-screen'),
        _i15.RouteConfig(SettingsScreenRoute.name, path: '/settings-screen')
      ];
}

/// generated route for [_i1.WelcomeScreen]
class WelcomeScreenRoute extends _i15.PageRouteInfo<void> {
  const WelcomeScreenRoute() : super(name, path: '/welcome-screen');

  static const String name = 'WelcomeScreenRoute';
}

/// generated route for [_i2.SignUpScreen]
class SignUpScreenRoute extends _i15.PageRouteInfo<void> {
  const SignUpScreenRoute() : super(name, path: '/sign-up-screen');

  static const String name = 'SignUpScreenRoute';
}

/// generated route for [_i3.LoginScreen]
class LoginScreenRoute extends _i15.PageRouteInfo<void> {
  const LoginScreenRoute() : super(name, path: '/login-screen');

  static const String name = 'LoginScreenRoute';
}

/// generated route for [_i4.ResetPasswordScreen]
class ResetPasswordScreenRoute extends _i15.PageRouteInfo<void> {
  const ResetPasswordScreenRoute()
      : super(name, path: '/reset-password-screen');

  static const String name = 'ResetPasswordScreenRoute';
}

/// generated route for [_i5.WebViewScreen]
class WebViewScreenRoute extends _i15.PageRouteInfo<WebViewScreenRouteArgs> {
  WebViewScreenRoute({_i16.Key? key, String? url, String? name0})
      : super(name,
            path: '/web-view-screen',
            args: WebViewScreenRouteArgs(key: key, url: url, name: name0));

  static const String name = 'WebViewScreenRoute';
}

class WebViewScreenRouteArgs {
  const WebViewScreenRouteArgs({this.key, this.url, this.name});

  final _i16.Key? key;

  final String? url;

  final String? name;
}

/// generated route for [_i6.ErrorScreen]
class ErrorScreenRoute extends _i15.PageRouteInfo<ErrorScreenRouteArgs> {
  ErrorScreenRoute({_i16.Key? key, String? error})
      : super(name,
            path: '/error-screen',
            args: ErrorScreenRouteArgs(key: key, error: error));

  static const String name = 'ErrorScreenRoute';
}

class ErrorScreenRouteArgs {
  const ErrorScreenRouteArgs({this.key, this.error});

  final _i16.Key? key;

  final String? error;
}

/// generated route for [_i7.FeedScreen]
class FeedScreenRoute extends _i15.PageRouteInfo<void> {
  const FeedScreenRoute() : super(name, path: '/feed-screen');

  static const String name = 'FeedScreenRoute';
}

/// generated route for [_i8.ProfileScreen]
class ProfileScreenRoute extends _i15.PageRouteInfo<ProfileScreenRouteArgs> {
  ProfileScreenRoute(
      {_i16.Key? key,
      String? otherUserId,
      String? profileUrl,
      String? coverUrl,
      _i8.ProfileNavigationEnum profileNavigationEnum =
          _i8.ProfileNavigationEnum.FROM_FEED})
      : super(name,
            path: '/profile-screen',
            args: ProfileScreenRouteArgs(
                key: key,
                otherUserId: otherUserId,
                profileUrl: profileUrl,
                coverUrl: coverUrl,
                profileNavigationEnum: profileNavigationEnum));

  static const String name = 'ProfileScreenRoute';
}

class ProfileScreenRouteArgs {
  const ProfileScreenRouteArgs(
      {this.key,
      this.otherUserId,
      this.profileUrl,
      this.coverUrl,
      this.profileNavigationEnum = _i8.ProfileNavigationEnum.FROM_FEED});

  final _i16.Key? key;

  final String? otherUserId;

  final String? profileUrl;

  final String? coverUrl;

  final _i8.ProfileNavigationEnum profileNavigationEnum;
}

/// generated route for [_i9.CreatePost]
class CreatePostRoute extends _i15.PageRouteInfo<CreatePostRouteArgs> {
  CreatePostRoute(
      {_i16.Key? key,
      String title = "Create Post",
      String? replyTo = "",
      String? threadId,
      _i17.ReplyEntity? replyEntity,
      Function? backData})
      : super(name,
            path: '/create-post',
            args: CreatePostRouteArgs(
                key: key,
                title: title,
                replyTo: replyTo,
                threadId: threadId,
                replyEntity: replyEntity,
                backData: backData));

  static const String name = 'CreatePostRoute';
}

class CreatePostRouteArgs {
  const CreatePostRouteArgs(
      {this.key,
      this.title = "Create Post",
      this.replyTo = "",
      this.threadId,
      this.replyEntity,
      this.backData});

  final _i16.Key? key;

  final String title;

  final String? replyTo;

  final String? threadId;

  final _i17.ReplyEntity? replyEntity;

  final Function? backData;
}

/// generated route for [_i10.ChatScreen]
class ChatScreenRoute extends _i15.PageRouteInfo<ChatScreenRouteArgs> {
  ChatScreenRoute(
      {_i16.Key? key,
      String? otherPersonUserId,
      String? otherUserFullName,
      String? otherPersonProfileUrl,
      _i18.MessageEntity? entity})
      : super(name,
            path: '/chat-screen',
            args: ChatScreenRouteArgs(
                key: key,
                otherPersonUserId: otherPersonUserId,
                otherUserFullName: otherUserFullName,
                otherPersonProfileUrl: otherPersonProfileUrl,
                entity: entity));

  static const String name = 'ChatScreenRoute';
}

class ChatScreenRouteArgs {
  const ChatScreenRouteArgs(
      {this.key,
      this.otherPersonUserId,
      this.otherUserFullName,
      this.otherPersonProfileUrl,
      this.entity});

  final _i16.Key? key;

  final String? otherPersonUserId;

  final String? otherUserFullName;

  final String? otherPersonProfileUrl;

  final _i18.MessageEntity? entity;
}

/// generated route for [_i11.ViewPostScreen]
class ViewPostScreenRoute extends _i15.PageRouteInfo<ViewPostScreenRouteArgs> {
  ViewPostScreenRoute(
      {_i16.Key? key, int? threadID, required _i19.PostEntity? postEntity})
      : super(name,
            path: '/view-post-screen',
            args: ViewPostScreenRouteArgs(
                key: key, threadID: threadID, postEntity: postEntity));

  static const String name = 'ViewPostScreenRoute';
}

class ViewPostScreenRouteArgs {
  const ViewPostScreenRouteArgs(
      {this.key, this.threadID, required this.postEntity});

  final _i16.Key? key;

  final int? threadID;

  final _i19.PostEntity? postEntity;
}

/// generated route for [_i12.FollowingFollowersScreen]
class FollowingFollowersScreenRoute
    extends _i15.PageRouteInfo<FollowingFollowersScreenRouteArgs> {
  FollowingFollowersScreenRoute(
      {_i16.Key? key,
      _i12.FollowUnFollowScreenEnum followScreenEnum =
          _i12.FollowUnFollowScreenEnum.FOLLOWERS,
      String? userId})
      : super(name,
            path: '/following-followers-screen',
            args: FollowingFollowersScreenRouteArgs(
                key: key, followScreenEnum: followScreenEnum, userId: userId));

  static const String name = 'FollowingFollowersScreenRoute';
}

class FollowingFollowersScreenRouteArgs {
  const FollowingFollowersScreenRouteArgs(
      {this.key,
      this.followScreenEnum = _i12.FollowUnFollowScreenEnum.FOLLOWERS,
      this.userId});

  final _i16.Key? key;

  final _i12.FollowUnFollowScreenEnum followScreenEnum;

  final String? userId;
}

/// generated route for [_i13.SearchScreen]
class SearchScreenRoute extends _i15.PageRouteInfo<SearchScreenRouteArgs> {
  SearchScreenRoute({_i16.Key? key, String? searchedText})
      : super(name,
            path: '/search-screen',
            args: SearchScreenRouteArgs(key: key, searchedText: searchedText));

  static const String name = 'SearchScreenRoute';
}

class SearchScreenRouteArgs {
  const SearchScreenRouteArgs({this.key, this.searchedText});

  final _i16.Key? key;

  final String? searchedText;
}

/// generated route for [_i14.SettingsScreen]
class SettingsScreenRoute extends _i15.PageRouteInfo<SettingsScreenRouteArgs> {
  SettingsScreenRoute({_i16.Key? key, bool fromProfile = false})
      : super(name,
            path: '/settings-screen',
            args: SettingsScreenRouteArgs(key: key, fromProfile: fromProfile));

  static const String name = 'SettingsScreenRoute';
}

class SettingsScreenRouteArgs {
  const SettingsScreenRouteArgs({this.key, this.fromProfile = false});

  final _i16.Key? key;

  final bool fromProfile;
}
