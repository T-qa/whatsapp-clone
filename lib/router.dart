import 'dart:io';

import 'package:chat_app/features/auth/screens/otp_screen.dart';
import 'package:chat_app/features/auth/screens/user_information_screen.dart';
import 'package:chat_app/features/contacts/screens/contacts_screen.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/features/auth/screens/login_screen.dart';
import 'package:chat_app/screens/error_screen.dart';

import 'features/chat/screens/mobile_chat_screen.dart';
import 'features/status/screens/confirm_status_screen.dart';
import 'features/status/screens/status_screen.dart';
import 'models/status.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case LoginScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      );

    case OTPScreen.routeName:
      final verificationId = settings.arguments as String;
      return MaterialPageRoute(
        builder: (context) => OTPScreen(
          verificationId: verificationId,
        ),
      );

    case UserInformationScreen.routeName:
      return MaterialPageRoute(
          builder: (context) => const UserInformationScreen());

    case ContactScreen.routeName:
      return MaterialPageRoute(builder: (context) => const ContactScreen());

    case MobileChatScreen.routeName:
      final arguments = settings.arguments as Map<String, dynamic>;
      final name = arguments['name'];
      final uid = arguments['uid'];
      return MaterialPageRoute(
          builder: (context) => MobileChatScreen(
                name: name,
                uid: uid,
              ));
    case ConfirmStatusScreen.routeName:
      final file = settings.arguments as File;
      return MaterialPageRoute(
        builder: (context) => ConfirmStatusScreen(
          file: file,
        ),
      );
    case StatusScreen.routeName:
      final status = settings.arguments as Status;
      return MaterialPageRoute(
        builder: (context) => StatusScreen(
          status: status,
        ),
      );
    default:
      return MaterialPageRoute(
          builder: (context) => const Scaffold(
              body: ErrorScreen(error: 'This page doesn\'t exist')));
  }
}
