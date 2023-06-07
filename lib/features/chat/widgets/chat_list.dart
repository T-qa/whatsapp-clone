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

class ChatList extends ConsumerStatefulWidget {
  final String receiverUserId;
  const ChatList({
    required this.receiverUserId,
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
        stream:
            ref.watch(chatControllerProvider).chatStream(widget.receiverUserId),
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
              if (message.senderId == FirebaseAuth.instance.currentUser!.uid) {
                return MessageCard(
                  message: message.text,
                  date: DateFormat.Hm().format(message.timeSent),
                );
              }
              return SenderMessageCard(
                message: message.text,
                date: DateFormat.Hm().format(message.timeSent),
              );
            },
          );
        });
  }
}
