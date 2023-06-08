// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:chat_app/common/providers/message_reply_provider.dart';
import 'package:chat_app/common/repositories/common_firebase.dart';
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

  void _saveDataToContactsSubcollection({
    required UserModel senderUser,
    required UserModel? receiverUser,
    required String textMessage,
    required DateTime timeSent,
    required String receiverUserId,
  }) async {
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
    required MessageReply? messageReply,
  }) async {
    // Create a Message object with the necessary details
    final message = Message(
      messageId: messageId,
      senderId: auth.currentUser!.uid,
      receiverId: receiverUserId,
      text: textMessage,
      messageType: messageType,
      timeSent: timeSent,
      isSeen: false,
      repliedMessage: messageReply == null ? '' : messageReply.message,
      repliedTo: messageReply == null
          ? ''
          : messageReply.isMe
              ? senderUsername
              : receiverUserName ?? '',
      repliedMessageType:
          messageReply == null ? MessageEnum.text : messageReply.messageEnum,
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
    required MessageReply? messageReply,
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
        senderUser: senderUser,
        receiverUser: receiverUser,
        textMessage: textMessage,
        timeSent: timeSent,
        receiverUserId: receiverUserId,
      );

      _saveMessageToMessageSubcollection(
        messageId: messageId,
        receiverUserId: receiverUserId,
        senderUsername: senderUser.name,
        receiverUserName: receiverUser.name,
        messageType: MessageEnum.text,
        textMessage: textMessage,
        timeSent: timeSent,
        messageReply: messageReply,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void sendFileMessage({
    required BuildContext context,
    required File file,
    required String receiverUserId,
    required UserModel senderUser,
    required ProviderRef ref,
    required MessageEnum messageEnum,
    required MessageReply? messageReply,
  }) async {
    try {
      var timeSent = DateTime.now();
      var messageId = const Uuid().v1();

      String imageUrl = await ref
          .read(commonFirebaseStorageRepositoryProvider)
          .storeFileToFirebase(
            'chat/${messageEnum.type}/${senderUser.uid}/$receiverUserId/$messageId',
            file,
          );

      UserModel? receiverUser;
      var receiverUserData =
          await firestore.collection('users').doc(receiverUserId).get();
      receiverUser = UserModel.fromMap(receiverUserData.data()!);
      String contactMsgType;
      switch (messageEnum) {
        case MessageEnum.image:
          contactMsgType = '📷 Photo';
          break;
        case MessageEnum.video:
          contactMsgType = '📸 Video';
          break;
        case MessageEnum.audio:
          contactMsgType = '🎵 Audio';
          break;
        case MessageEnum.gif:
          contactMsgType = 'GIF';
          break;
        default:
          contactMsgType = 'GIF';
      }
      _saveDataToContactsSubcollection(
        senderUser: senderUser,
        receiverUser: receiverUser,
        textMessage: contactMsgType,
        timeSent: timeSent,
        receiverUserId: receiverUserId,
      );

      _saveMessageToMessageSubcollection(
        messageId: messageId,
        receiverUserId: receiverUserId,
        senderUsername: senderUser.name,
        receiverUserName: receiverUser.name,
        messageType: messageEnum,
        textMessage: imageUrl,
        timeSent: timeSent,
        messageReply: messageReply,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void sendGIFMessage({
    required BuildContext context,
    required String gifUrl,
    required String recieverUserId,
    required UserModel senderUser,
    required MessageReply? messageReply,
  }) async {
    try {
      var timeSent = DateTime.now();
      UserModel? receiverUser;
      var receiverUserData =
          await firestore.collection('users').doc(recieverUserId).get();
      receiverUser = UserModel.fromMap(receiverUserData.data()!);
      var messageId = const Uuid().v1();

      _saveDataToContactsSubcollection(
        senderUser: senderUser,
        receiverUser: receiverUser,
        receiverUserId: receiverUser.uid,
        textMessage: 'GIF',
        timeSent: timeSent,
      );

      _saveMessageToMessageSubcollection(
        messageId: messageId,
        messageType: MessageEnum.gif,
        senderUsername: senderUser.name,
        receiverUserName: receiverUser.name,
        receiverUserId: recieverUserId,
        textMessage: gifUrl,
        timeSent: timeSent,
        messageReply: messageReply,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }
}
