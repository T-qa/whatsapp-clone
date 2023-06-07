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

  Stream<List<ChatContact>> getChatContacts() {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .snapshots()
        .asyncMap((event) async {
      List<ChatContact> contacts = [];
      for (var document in event.docs) {
        var chatContact = ChatContact.fromMap(document.data());
        var userData = await firestore
            .collection('users')
            .doc(chatContact.contactId)
            .get();
        var user = UserModel.fromMap(userData.data()!);

        contacts.add(
          ChatContact(
            name: user.name,
            profilePic: user.profilePic,
            contactId: chatContact.contactId,
            timeSent: chatContact.timeSent,
            lastMessage: chatContact.lastMessage,
          ),
        );
      }
      return contacts;
    });
  }

  Stream<List<Message>> getChatStream(String receiverUserId) {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(receiverUserId)
        .collection('messages')
        .orderBy('timesent')
        .snapshots()
        .map((event) {
      List<Message> messages = [];
      for (var document in event.docs) {
        messages.add(Message.fromMap(document.data()));
      }
      return messages;
    });
  }

  void _saveDataToContactsSubcollection(
    UserModel senderUser,
    UserModel? receiverUser,
    String textMessage,
    DateTime timeSent,
    String receiverUserId,
  ) async {
    // Create a ChatContact object containing the chat contact information of the sender
    var receiverChatContact = ChatContact(
      name: senderUser.name,
      profilePic: senderUser.profilePic,
      contactId: senderUser.uid,
      timeSent: timeSent,
      lastMessage: textMessage,
    );

    // users -> reciever user id => chats -> current user id -> set data
    // Access the Firestore collection 'users', then the document with the receiver's user ID,
    // and the 'chats' subcollection within that document. Set the chat contact information of the sender.
    await firestore
        .collection('users')
        .doc(receiverUserId)
        .collection('chats')
        .doc(senderUser.uid)
        .set(
          receiverChatContact.toMap(),
        );

    // Create a ChatContact object containing the chat contact information of the receiver
    var senderChatContact = ChatContact(
      name: receiverUser!.name,
      profilePic: receiverUser.profilePic,
      contactId: receiverUser.uid,
      timeSent: timeSent,
      lastMessage: textMessage,
    );

    // users -> current user id  => chats -> reciever user id -> set data
    // Access the Firestore collection 'users', then the document with the receiver's user ID,
    // and the 'chats' subcollection within that document. Set the chat contact information of the sender.
    await firestore
        .collection('users')
        .doc(senderUser.uid)
        .collection('chats')
        .doc(receiverUserId)
        .set(
          senderChatContact.toMap(),
        );
  }

  void _saveMessageToMessageSubcollection({
    required String messageId,
    required String receiverUserId,
    required String senderUsername,
    required String? receiverUserName,
    required MessageEnum messageType,
    required String textMessage,
    required DateTime timeSent,
  }) async {
    // Create a Message object with the necessary details
    final message = Message(
      messageId: messageId,
      senderId: auth.currentUser!.uid,
      receiverId: receiverUserId,
      text: textMessage,
      type: messageType,
      timeSent: timeSent,
      isSeen: false,
    );

    // Save the message in the sender's Firestore under the receiver's chat
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

    // Save the message in the receiver's Firestore under the sender's chat
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
    required UserModel senderUser,
  }) async {
    try {
      var timeSent = DateTime.now();
      UserModel receiverUser;
      var receiverUserData =
          await firestore.collection('users').doc(receiverUserId).get();
      receiverUser = UserModel.fromMap(receiverUserData.data()!);

      // Generate a unique message ID using Uuid
      var messageId = const Uuid().v1();

      _saveDataToContactsSubcollection(
        senderUser,
        receiverUser,
        textMessage,
        timeSent,
        receiverUserId,
      );

      _saveMessageToMessageSubcollection(
        messageId: messageId,
        receiverUserId: receiverUserId,
        senderUsername: senderUser.name,
        receiverUserName: receiverUser.name,
        messageType: MessageEnum.text,
        textMessage: textMessage,
        timeSent: timeSent,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }
}
