import 'dart:io';

import 'package:chat_app/common/repositories/common_firebase.dart';
import 'package:chat_app/features/auth/screens/otp_screen.dart';
import 'package:chat_app/features/auth/screens/user_information_screen.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/screens/mobile_layout_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/common/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository(
    auth: FirebaseAuth.instance, firestore: FirebaseFirestore.instance));

class AuthRepository {
  FirebaseAuth auth;
  final FirebaseFirestore firestore;
  AuthRepository({required this.auth, required this.firestore});

  Future<UserModel?> getCurrentUserData() async {
    var userData =
        await firestore.collection('users').doc(auth.currentUser?.uid).get();
    UserModel? user;

    if (userData.data() != null) {
      user = UserModel.fromMap(userData.data()!);
    }
    return user;
  }

  void signInWithPhone(BuildContext context, String phoneNumber) async {
    try {
      await auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          timeout: const Duration(seconds: 120),
          verificationCompleted: (PhoneAuthCredential credential) async {
           // await auth.signInWithCredential(credential);
          },
          verificationFailed: (FirebaseAuthException error) {
            throw Exception(error.message);
          },
          codeSent: (String verificationId, int? resendToken) {
            Navigator.pushNamed(context, OTPScreen.routeName,
                arguments: verificationId);
          },
          codeAutoRetrievalTimeout: (String verificationId) {});
    } on FirebaseAuthException catch (error) {
      showSnackBar(context: context, content: error.message!);
    }
  }

  void verifyOTP({
    required BuildContext context,
    required String verificationId,
    required String userOTP,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: userOTP,
      );
      await auth.signInWithCredential(credential);
      Navigator.pushNamedAndRemoveUntil(
        (context),
        UserInformationScreen.routeName,
        (route) => false,
      );
    } on FirebaseAuthException catch (error) {
      showSnackBar(context: context, content: error.message!);
    }
  }

  void saveUserDatatoFirestore({
    required String name,
    required File? profilePic,
    required ProviderRef ref,
    required BuildContext context,
  }) async {
    try {
      String uid = auth.currentUser!.uid;
      String photoUrl = 'https://www.w3schools.com/howto/img_avatar.png';
      if (profilePic != null) {
        photoUrl = await ref
            .read(commonFirebaseStorageRepositoryProvider)
            .storeFileToFirebase(
              'profilePic/$uid',
              profilePic,
            );
      }
      var user = UserModel(
          name: name,
          uid: uid,
          profilePic: photoUrl,
          isOnline: true,
          phoneNumber: auth.currentUser!.phoneNumber!,
          groupId: []);

      await firestore.collection('users').doc(uid).set(user.toMap());
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MobileLayoutScreen()),
        (route) => false,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  Stream<UserModel> userData(String userId) {
    // Return a stream that listens to changes in the 'users' collection and document with the given userId
    return firestore.collection('users').doc(userId).snapshots().map(
          (event) => UserModel.fromMap(
            event
                .data()!, // Convert the document snapshot data into a UserModel object
          ),
        );
  }

  void setUserState(bool isOnline) async {
    // Update the 'isOnline' field of the current user's document in the 'users' collection
    await firestore.collection('users').doc(auth.currentUser!.uid).update({
      'isOnline': isOnline,
    });
  }
}
