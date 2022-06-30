import 'package:auto_route/annotations.dart';
import '../common/error_screen.dart';
import '../common/widget/web_view_screen.dart';
import '../../features/authentication/presentation/pages/login_screen.dart';
import '../../features/authentication/presentation/pages/reset_password_screen.dart';
import '../../features/authentication/presentation/pages/signup_screen.dart';
import '../../features/posts/presentation/pages/create_post.dart';
import '../../features/feed/presentation/pages/feed_screen.dart';
import '../../features/messages/presentation/pages/chat_screen.dart';
import '../../features/posts/presentation/pages/view_post_screen.dart';
import '../../features/profile/presentation/pages/followers_following_screen.dart';
import '../../features/profile/presentation/pages/profile_screen.dart';
import '../../features/profile/presentation/pages/settings_page.dart';
import '../../features/search/presentation/pages/searh_screen.dart';
import '../../features/welcome/welcome_screen.dart';

// we didnt use part because it does not need anything from the class to be a part from it
@CupertinoAutoRouter(
  routes: <AutoRoute>[
    // initial route is named "/"
    CupertinoRoute(
      page: WelcomeScreen,
    ),
    CupertinoRoute(
      page: SignUpScreen,
    ),
    CupertinoRoute(
      page: LoginScreen,
    ),
    CupertinoRoute(
      page: ResetPasswordScreen,
    ),
    MaterialRoute(
      page: WebViewScreen,
    ),
    CupertinoRoute(
      page: ErrorScreen,
    ),
    CupertinoRoute(
      page: FeedScreen,
    ),
    CupertinoRoute(
      page: ProfileScreen,
    ),
    MaterialRoute(page: CreatePost, fullscreenDialog: true),
    CupertinoRoute(
      page: ChatScreen,
    ),
    CupertinoRoute(
      page: ViewPostScreen,
    ),
    MaterialRoute(page: FollowingFollowersScreen, fullscreenDialog: true),
    MaterialRoute(
      page: SearchScreen,
    ),
    MaterialRoute(
      page: SettingsScreen,
    ),
  ],
)
class $MyRouter {}
