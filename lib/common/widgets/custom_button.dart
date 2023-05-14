import 'package:flutter/material.dart';
import 'package:chat_app/common/utils/color.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({super.key, required this.onPressed, required this.buttonText});
  final VoidCallback onPressed;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: blackColor,
            shape:
                const BeveledRectangleBorder(borderRadius: BorderRadius.zero)),
        onPressed: onPressed,
        child: Text(buttonText));
  }
}
