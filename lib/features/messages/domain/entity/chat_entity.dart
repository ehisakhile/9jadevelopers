import '../../../../core/common/api/response_models/chat_notification_response.dart';
import '../../data/models/response/chats_response.dart';
import '../../../../extensions.dart';

class ChatEntity {
  final String? time;
  final String? message;
  final bool isSender;
  final ChatMediaType chatMediaType;
  final String? profileUrl;
  final String? messageId;
  final String? senderUserId;
  final String? offSetId;
  final String? name;

  const ChatEntity(
      {required this.time,
      required this.message,
      required this.messageId,
      this.isSender = false,
      this.chatMediaType = ChatMediaType.TEXT,
      this.profileUrl,
      this.senderUserId,
      this.offSetId,
      this.name});

  factory ChatEntity.fromResponse(ChatResponseModel model) {
    return ChatEntity(
        chatMediaType: model.mediaType == "image"
            ? ChatMediaType.IMAGE
            : ChatMediaType.TEXT,
        time: model.time,
        profileUrl: model.mediaFile,
        message: model.message,
        isSender: model.side == "right",
        messageId: model.id.toString(),
        offSetId: model.id.toString());
  }

  factory ChatEntity.fromDummy() {
    return ChatEntity(
        time: DateTime.now().getCurrentFormattedTime(),
        message: "dummy message",
        messageId: 123.toString(),
        isSender: false);
  }

  ChatEntity copyWith({String? time, String? id}) {
    return ChatEntity(
        time: time ?? this.time,
        message: this.message,
        messageId: id ?? this.messageId,
        isSender: this.isSender,
        profileUrl: this.profileUrl,
        chatMediaType: this.chatMediaType,
        offSetId: offSetId);
  }

  factory ChatEntity.fromNotification(ChatMessage chatMessage) {
    final notification = chatMessage;
    return ChatEntity(
        time: DateTime.now().getCurrentFormattedTime(),
        message: notification.data,
        isSender: false,
        profileUrl: notification.avatar,
        chatMediaType: notification.messageType!.contains("text")
            ? ChatMediaType.TEXT
            : ChatMediaType.IMAGE,
        senderUserId: notification.userId.toString(),
        messageId: notification.messageId.toString(),
        offSetId: notification.messageId.toString(),
        name: chatMessage.name.toString());
  }
}

enum ChatMediaType { IMAGE, TEXT }
