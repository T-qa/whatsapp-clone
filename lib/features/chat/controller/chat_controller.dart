// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:chat_app/common/enums/message_enum.dart';
import 'package:chat_app/features/auth/controller/auth_controller.dart';
import 'package:chat_app/models/chat_contact.dart';
import 'package:chat_app/models/message.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/features/chat/repositories/chat_repository.dart';

import '../../../common/providers/message_reply_provider.dart';

final chatControllerProvider = Provider((ref) {
  final chatRepository = ref.watch(chatRepositoryProvider);
  return ChatController(
    chatRepository: chatRepository,
    ref: ref,
  );
});

class ChatController {
  final ChatRepository chatRepository;
  final ProviderRef ref;

  ChatController({
    required this.chatRepository,
    required this.ref,
  });

  Stream<List<ChatContact>> chatContacts() {
    return chatRepository.getChatContacts();
  }

  Stream<List<Message>> chatStream(String receiverUserId) {
    return chatRepository.getChatStream(receiverUserId);
  }

  //* The function retrieves the current user data using the [userDataAuthProvider] provider.
  //* Once the data becomes available, it invokes the [chatRepository.sendTextMessage] function
  //* to send the text message with the provided parameters.
  //* The [value] parameter represents the retrieved current user data, which is passed as the senderUser.
  void sendTextMessage(
    BuildContext context,
    String receiverUserId,
    String textMessage,
  ) {
    final messageReply = ref.read(messageReplyProvider);

    ref
        .read(userDataAuthProvider)
        .whenData((value) => chatRepository.sendTextMessage(
              context: context,
              textMessage: textMessage,
              receiverUserId: receiverUserId,
              senderUser: value!,
              messageReply: messageReply,
            ));
    ref.read(messageReplyProvider.notifier).update((state) => null);
  }

  void sendFileMessage(BuildContext context, File file, String receiverUserId,
      MessageEnum messageEnum) {
    final messageReply = ref.read(messageReplyProvider);
    ref
        .read(userDataAuthProvider)
        .whenData((value) => chatRepository.sendFileMessage(
              context: context,
              file: file,
              receiverUserId: receiverUserId,
              senderUser: value!, // Current User
              ref: ref,
              messageEnum: messageEnum,
              messageReply: messageReply,
            ));
    ref.read(messageReplyProvider.notifier).update((state) => null);
  }

  void sendGIFMessage(
    BuildContext context,
    String gifUrl,
    String recieverUserId,
  ) {
    final messageReply = ref.read(messageReplyProvider);

    int gifUrlPartIndex = gifUrl.lastIndexOf('-') + 1;
    String gifUrlPart = gifUrl.substring(gifUrlPartIndex);
    String newGifUrl = 'https://i.giphy.com/media/$gifUrlPart/200.gif';

    ref.read(userDataAuthProvider).whenData(
          (value) => chatRepository.sendGIFMessage(
            context: context,
            gifUrl: newGifUrl,
            recieverUserId: recieverUserId,
            senderUser: value!,
            messageReply: messageReply,
          ),
        );
    ref.read(messageReplyProvider.notifier).update((state) => null);
  }

  
}
