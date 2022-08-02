import 'package:colibri/app_theme_data.dart';
import 'package:colibri/core/config/colors.dart';
import 'package:colibri/core/extensions/context_exrensions.dart';
import 'package:colibri/features/feed/presentation/bloc/feed_cubit.dart';
import 'package:colibri/features/messages/presentation/bloc/chat_cubit.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'features/authentication/presentation/bloc/login_cubit.dart';
import 'features/authentication/presentation/bloc/sign_up_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/posts/presentation/bloc/createpost_cubit.dart';
import 'features/profile/presentation/bloc/profile_cubit.dart';
import 'features/profile/presentation/bloc/settings/user_setting_cubit.dart';
import 'translations/codegen_loader.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'core/common/push_notification/push_notification_helper.dart';
import 'core/constants/appconstants.dart';
import 'core/datasource/local_data_source.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:rxdart/rxdart.dart';
import 'core/di/injection.dart';
import 'core/routes/routes.gr.dart';
import 'core/theme/app_theme.dart';


typedef F<T, R> = T Function(R);
String versionNumber = '';
const supportedLocales = const [
  Locale('en'),
  Locale('ar'),
  Locale('fr'),
  Locale('de'),
  Locale('it'),
  Locale('ru'),
  Locale('pt'),
  Locale('es'),
  Locale('tr'),
  Locale('nl'),
  Locale('uk'),
];
final appRouter = MyRouter();

final appThemeConstroller = BehaviorSubject<TextTheme>.seeded(appTextTheme);

Function(TextTheme) get changeAppTheme => appThemeConstroller.sink.add;
// insert_link_outlined
Stream<TextTheme> get appTheme => appThemeConstroller.stream;
LocalDataSource? localDataSource;
var isUserLoggedIn = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();
  AC.getInstance();
  await NativeDeviceOrientationCommunicator().orientation(useSensor: false);
  await PackageInfo.fromPlatform()
      .then((value) => versionNumber = value.version);
  await configureDependencies();
  localDataSource = getIt<LocalDataSource>();
  isUserLoggedIn = await localDataSource!.isUserLoggedIn();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((value) async {
    await Future.delayed(const Duration(milliseconds: 500));
    runApp(
      EasyLocalization(
        assetLoader: CodegenLoader(),
        supportedLocales: supportedLocales,
        fallbackLocale: supportedLocales.first,
        path: 'assets/translations',
        child: MyApp(),
      ),
    );
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    PushNotificationHelper.configurePush();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        EasyLoading.instance
          ..displayDuration = const Duration(milliseconds: 2000)
          ..indicatorType = EasyLoadingIndicatorType.chasingDots
          ..loadingStyle = EasyLoadingStyle.custom
          ..indicatorSize = 45.0
          ..radius = 10.0
          ..maskType = EasyLoadingMaskType.custom
          ..maskColor = AppColors.colorPrimary.withOpacity(.2)
          ..indicatorColor = AppColors.colorPrimary
          ..progressColor = AppColors.colorPrimary
          ..textColor = AppColors.colorPrimary
          ..backgroundColor = Colors.transparent
          ..userInteractions = false;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginCubit>(
          create: (BuildContext context) => getIt<LoginCubit>(),
        ),
        BlocProvider<SignUpCubit>(
          create: (BuildContext context) => getIt<SignUpCubit>(),
        ),
        BlocProvider<FeedCubit>(
          create: (BuildContext context) => getIt<FeedCubit>(),
        ),
        BlocProvider<ProfileCubit>(
          create: (BuildContext context) => getIt<ProfileCubit>(),
        ),
        BlocProvider<CreatePostCubit>(
          create: (BuildContext context) => getIt<CreatePostCubit>(),
        ),
        BlocProvider<ChatCubit>(
          create: (BuildContext context) => getIt<ChatCubit>(),
        ),
        BlocProvider<UserSettingCubit>(
          create: (BuildContext context) => getIt<UserSettingCubit>(),
        ),
      ],
      child: MediaQuery(
        data: MediaQueryData(size: Size(400, 400)),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (constraints.maxWidth != 0) {
              final size = context.getScreenSize;
              ScreenUtil.init(context, designSize: size);
            }

            return MaterialApp.router(
              title: 'Colibri',
              debugShowCheckedModeBanner: false,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              theme: AppThemeData.appThemeData(context),
              localeResolutionCallback: (locale, supportedLocales) {
                for (var supportedLocale in supportedLocales) {
                  if (supportedLocale.languageCode == locale!.languageCode &&
                      supportedLocale.countryCode == locale.countryCode) {
                    return supportedLocale;
                  }
                }
                return supportedLocales.first;
              },
              routerDelegate: appRouter.delegate(initialRoutes: [
                if (isUserLoggedIn) FeedScreenRoute(),
                if (!isUserLoggedIn) WelcomeScreenRoute(),
              ]),
              routeInformationParser: appRouter.defaultRouteParser(),
              builder: EasyLoading.init(),
            );
          },
        ),
      ),
    );
  }
}
