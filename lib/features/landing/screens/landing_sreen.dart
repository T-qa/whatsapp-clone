import 'package:chat_app/common/utils/color.dart';
import 'package:chat_app/common/widgets/custom_button.dart';
import 'package:chat_app/features/auth/screens/login_screen.dart';
import 'package:flutter/material.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  void navigateToLoginScreen(BuildContext context) {
    Navigator.pushNamed(context, LoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Padding(
            padding: EdgeInsets.all(15.0),
            child: Text(
              'Welcome to Whatsapp',
              style: TextStyle(fontSize: 33, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 10),
          Image.asset('assets/bg.png',
              color: tabColor, width: 350, height: 350),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.only(left: 15, right: 15, top: 15),
            child: Text(
              'Read our Privacy Policy. Tap "Agree and continue" to accept the Terms of Service',
              textAlign: TextAlign.center,
              style: TextStyle(color: greyColor),
            ),
          ),
          SizedBox(
            width: 280,
            child: CustomButton(
              onPressed: () => navigateToLoginScreen(context), buttonText: 'AGEE AND CONTINUE',
            ),
          )
        ],
      )),
    );
  }
}
