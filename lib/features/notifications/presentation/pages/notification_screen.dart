import 'package:colibri/features/messages/presentation/widgets/messages_app_bar_row.dart';

import '../../../../translations/locale_keys.g.dart';

import '../../../../core/di/injection.dart';
import '../../../../extensions.dart';
import '../bloc/notification_cubit.dart';
import 'mentions_page.dart';
import 'notification_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  NotificationCubit? _notificationCubit;

  @override
  void initState() {
    super.initState();
    _notificationCubit = getIt<NotificationCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (c) => _notificationCubit!,
      child: DefaultTabController(
        length: 2,
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  elevation: 5.0,
                  expandedHeight: 100.toHeight as double?,
                  floating: true,
                  pinned: true,
                  backgroundColor: Colors.white,
                  flexibleSpace: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: MessagesAppBarRow(LocaleKeys.notifications.tr()),
                  ),
                  bottom: PreferredSize(
                    preferredSize: Size(
                      context.getScreenWidth as double,
                      56.toHeight as double,
                    ),
                    child: Stack(
                      children: [
                        Container(
                          color: Colors.white,
                          child: TabBar(
                            tabs: [
                              Tab(text: 'All'),
                              Tab(text: LocaleKeys.mentions.tr()),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverFillRemaining(
                  child: TabBarView(
                    children: [NotificationPage(), MentionsPage()],
                  ),
                )
              ],
            ).toSafeArea,
          ],
        ),
      ),
    );
  }
}
