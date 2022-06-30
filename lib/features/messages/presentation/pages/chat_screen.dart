import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:colibri/core/root_widget.dart';
import 'package:colibri/features/messages/presentation/widgets/chat_screen_app_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../../core/common/push_notification/push_notification_helper.dart';
import '../../../../core/common/uistate/common_ui_state.dart';
import '../../../../extensions.dart';
import '../../../../translations/locale_keys.g.dart';
import '../../../feed/presentation/widgets/no_data_found_screen.dart';
import '../../data/models/request/delete_chat_request_model.dart';
import '../../domain/entity/chat_entity.dart';
import '../../domain/entity/message_entity.dart';
import '../bloc/chat_cubit.dart';
import '../widgets/reviever_chat_item.dart';
import '../widgets/send_message_row.dart';
import '../widgets/sender_chat_item.dart';

class ChatScreen extends StatefulWidget {
  final String? otherPersonUserId;
  final String? otherUserFullName;
  final String? otherPersonProfileUrl;
  final MessageEntity? entity;
  const ChatScreen({
    Key? key,
    this.otherPersonUserId,
    this.otherUserFullName,
    this.otherPersonProfileUrl,
    this.entity,
  }) : super(key: key);
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with AutomaticKeepAliveClientMixin {
  late final ChatCubit chatCubit;
  bool chatCleared = false;
  bool chatDeleted = false;
  @override
  void initState() {
    super.initState();
    chatCubit = BlocProvider.of<ChatCubit>(context)
      ..chatPagination!.userId = widget.otherPersonUserId;
    chatCubit.chatPagination!.searchChat = false;
    chatCubit.chatPagination!.onRefresh();
    PushNotificationHelper.listenNotificationOnChatScreen = (notificationItem) {
      chatCubit.changeMessageList(
        chatCubit.chatPagination!.pagingController.itemList!
          ..insert(0, notificationItem),
      );
      chatCubit.chatPagination!.pagingController;
    };
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return WillPopScope(
      onWillPop: () async {
        navigateToBackWithResult();
        return true;
      },
      child: IosSafeWidget(
        child: Scaffold(
          appBar: ChatScreenAppBar(
            deleteMethod: deleteMethod,
            entity: widget.entity,
            navigateToBackWithResult: navigateToBackWithResult,
            otherUserFullName: widget.otherUserFullName,
            imageUrl: widget.otherPersonProfileUrl!,
          ),

          body: Column(
            children: [
              BlocConsumer<ChatCubit, CommonUIState>(
                bloc: chatCubit,
                listener: (BuildContext context, state) {
                  state.maybeWhen(
                      orElse: () {},
                      success: (s) {
                        if (s is String) {
                          if (s
                              .toLowerCase()
                              .contains(LocaleKeys.clear_chat.tr()))
                            chatCleared = true;
                          else if (s
                              .toLowerCase()
                              .contains(LocaleKeys.delete_chat.tr())) {
                            chatDeleted = true;
                            navigateToBackWithResult();
                          }
                          context.showSnackBar(message: s);
                        }
                      },
                      error: (e) =>
                          context.showSnackBar(isError: true, message: e));
                },
                builder: (c, state) {
                  return state.maybeWhen(
                    orElse: () => buildRefreshIndicator().toExpanded(),
                    success: (s) => buildRefreshIndicator().toExpanded(),
                    error: (e) => buildRefreshIndicator().toExpanded(),
                  );
                },
              ),
              SendMessageRow(
                chatCubit: chatCubit,
                otherPersonUserId: widget.otherPersonUserId,
              ),
            ],
          ),

          //        MessagesFloatingSearchBar(chatCubit),
        ),
      ),
    );
  }

  Widget buildRefreshIndicator() {
    return RefreshIndicator(
      onRefresh: () {
        chatCubit.chatPagination!.searchChat = false;
        chatCubit.chatPagination!.onRefresh();
        return Future.value();
      },
      child: Column(
        children: [
          Expanded(
            child: PagedListView(
              reverse: true,
              pagingController: chatCubit.chatPagination!.pagingController,
              builderDelegate: PagedChildBuilderDelegate<ChatEntity>(
                noItemsFoundIndicatorBuilder: (i) => NoDataFoundScreen(
                  onTapButton: () {
                    // context.router.root.push(Routes.createPost);
                  },
                  title: LocaleKeys.no_messages.tr(),
                  buttonText: LocaleKeys.go_to_the_homepage.tr(),
                  message: "",
                  buttonVisibility: false,
                ),
                itemBuilder: (BuildContext context, item, int index) =>
                    Container(
                  width: context.getScreenWidth as double?,
                  child: item.isSender
                      ? SenderChatItem(chatEntity: item, chatCubit: chatCubit)
                      : ReceiverChatItem(
                          otherUserProfileUrl: widget.otherPersonProfileUrl,
                          chatEntity: item,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void navigateToBackWithResult() {
    if (chatDeleted) {
      context.router.root.pop("deleted");
    } else if (chatCleared) {
      context.router.root.pop("cleared");
    } else
      context.router.root.pop(chatCubit.getLastMessage());
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    PushNotificationHelper.listenNotificationOnChatScreen = null;
    super.dispose();
  }

  Future<void> deleteMethod(bool deleteAndClear) async {
    Navigator.pop(context);
    Navigator.pop(context);
    await chatCubit.deleteAllMessages(
      DeleteChatRequestModel(
        deleteChat: deleteAndClear,
        userId: widget.otherPersonUserId,
      ),
    );
    chatDeleted = deleteAndClear;
    navigateToBackWithResult();
  }
}
