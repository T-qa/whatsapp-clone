import 'package:chat_app/features/auth/screens/otp_screen.dart';
import 'package:chat_app/features/auth/screens/user_information_screen.dart';
import 'package:chat_app/features/contacts/screens/contacts_screen.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/features/auth/screens/login_screen.dart';
import 'package:chat_app/screens/error_screen.dart';

import 'screens/mobile_chat_screen.dart';

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
      return MaterialPageRoute(builder: (context) => const MobileChatScreen());
    default:
      return MaterialPageRoute(
          builder: (context) => const Scaffold(
              body: ErrorScreen(error: 'This page doesn\'t exist')));
  }
}
