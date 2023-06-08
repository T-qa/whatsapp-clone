import 'package:chat_app/common/widgets/loader.dart';
import 'package:chat_app/features/chat/widgets/message_card.dart';
import 'package:chat_app/features/chat/widgets/sender_message_card.dart';
import 'package:chat_app/features/chat/controller/chat_controller.dart';
import 'package:chat_app/models/message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../common/enums/message_enum.dart';
import '../../../common/providers/message_reply_provider.dart';

class ChatList extends ConsumerStatefulWidget {
  final String receiverUserId;
  final bool isGroupChat;
  const ChatList({
    required this.receiverUserId,
    required this.isGroupChat,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<ChatList> createState() => _ChatListState();
}

class _ChatListState extends ConsumerState<ChatList> {
  final ScrollController messageController = ScrollController();

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  void onMessageSwipe(
    String message,
    bool isMe,
    MessageEnum messageEnum,
  ) {
    ref.read(messageReplyProvider.notifier).update(
          (state) => MessageReply(
            message,
            isMe,
            messageEnum,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
        stream: widget.isGroupChat
            ? ref
                .read(chatControllerProvider)
                .groupChatStream(widget.receiverUserId)
            : ref
                .watch(chatControllerProvider)
                .chatStream(widget.receiverUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }
          SchedulerBinding.instance.addPostFrameCallback((_) {
            messageController
                .jumpTo(messageController.position.maxScrollExtent);
          });
          return ListView.builder(
            controller: messageController,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final message = snapshot.data![index];
              if (!message.isSeen &&
                  message.receiverId ==
                      FirebaseAuth.instance.currentUser!.uid) {
                ref.read(chatControllerProvider).setChatMessageSeen(
                      context,
                      widget.receiverUserId,
                      message.messageId,
                    );
              }
              if (message.senderId == FirebaseAuth.instance.currentUser!.uid) {
                return MessageCard(
                  msgType: message.messageType,
                  message: message.text,
                  date: DateFormat.Hm().format(message.timeSent),
                  repliedTextMessage: message.repliedMessage,
                  repliedMessageType: message.repliedMessageType,
                  username: message.repliedTo,
                  onLeftSwipe: () => onMessageSwipe(
                    message.text,
                    true,
                    message.messageType,
                  ),
                  isSeen: message.isSeen,
                );
              }
              return SenderMessageCard(
                msgType: message.messageType,
                message: message.text,
                date: DateFormat.Hm().format(message.timeSent),
                repliedTextMessage: message.repliedMessage,
                repliedMessageType: message.repliedMessageType,
                username: message.repliedTo,
                onRightSwipe: () => onMessageSwipe(
                  message.text,
                  false,
                  message.messageType,
                ),
              );
            },
          );
        });
  }
}
