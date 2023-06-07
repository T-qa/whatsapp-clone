// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:chat_app/features/auth/controller/auth_controller.dart';
import 'package:chat_app/models/chat_contact.dart';
import 'package:chat_app/models/message.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/features/chat/repositories/chat_repository.dart';

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
    ref
        .read(userDataAuthProvider)
        .whenData((value) => chatRepository.sendTextMessage(
              context: context,
              textMessage: textMessage,
              receiverUserId: receiverUserId,
              senderUser: value!, // Current User
            ));
  }
}
