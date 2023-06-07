// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:chat_app/common/utils/utils.dart';
import 'package:chat_app/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../common/enums/message_enum.dart';
import '../../../models/chat_contact.dart';
import '../../../models/user_model.dart';

final chatRepositoryProvider = Provider((ref) => ChatRepository(
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
    ));

class ChatRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ChatRepository({
    required this.firestore,
    required this.auth,
  });

  void _saveDataToContactsSubcollection(
    UserModel senderUserData,
    UserModel? receiverUserData,
    String text,
    DateTime timeSent,
    String recieverUserId,
  ) async {
    // users -> reciever user id => chats -> current user id -> set data
    var receiverChatContact = ChatContact(
      name: senderUserData.name,
      profilePic: senderUserData.profilePic,
      contactId: senderUserData.uid,
      timeSent: timeSent,
      lastMessage: text,
    );
    await firestore
        .collection('users')
        .doc(recieverUserId)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .set(
          receiverChatContact.toMap(),
        );

    // users -> current user id  => chats -> reciever user id -> set data
    var senderChatContact = ChatContact(
      name: receiverUserData!.name,
      profilePic: receiverUserData.profilePic,
      contactId: receiverUserData.uid,
      timeSent: timeSent,
      lastMessage: text,
    );
    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(recieverUserId)
        .set(
          senderChatContact.toMap(),
        );
  }

  void _saveMessageToMessageSubcollection({
    required String receiverUserId,
    required String text,
    required DateTime timeSent,
    required String messageId,
    required String username,
    required String? receiverUserName,
    required MessageEnum messageType,
  }) async {
    final message = Message(
      senderId: auth.currentUser!.uid,
      receiverId: receiverUserId,
      text: text,
      type: messageType,
      timeSent: timeSent,
      messageId: messageId,
      isSeen: false,
    );
    // users -> sender id -> receiver id -> messages -> message id -> store message
    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(receiverUserId)
        .collection('messages')
        .doc(messageId)
        .set(
          message.toMap(),
        );
    // users -> receiver id  -> sender id -> messages -> message id -> store message
    await firestore
        .collection('users')
        .doc(receiverUserId)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .collection('messages')
        .doc(messageId)
        .set(
          message.toMap(),
        );
  }

  void sendTextMessage({
    required BuildContext context,
    required String textMessage,
    required String receiverUserId,
    required UserModel senderUserData,
  }) async {
    try {
      var timeSent = DateTime.now();
      UserModel receiverUserData;
      var receiverUserDataMap =
          await firestore.collection('users').doc(receiverUserId).get();
      receiverUserData = UserModel.fromMap(receiverUserDataMap.data()!);

      var messageId = const Uuid().v1();

      _saveDataToContactsSubcollection(
        senderUserData,
        receiverUserData,
        textMessage,
        timeSent,
        receiverUserId,
      );

      _saveMessageToMessageSubcollection(
        receiverUserId: receiverUserId,
        text: textMessage,
        timeSent: timeSent,
        messageId: messageId,
        username: senderUserData.name,
        messageType: MessageEnum.text,
        receiverUserName: receiverUserData.name,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }
}
