import 'package:flutter/material.dart';
import 'package:finbuddy/shared/constants/style_constants.dart';

class CustomTextButton extends StatelessWidget {
  const CustomTextButton(
      {super.key, required this.title, required this.onPressed});
  final String title;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: onPressed,
        child: Text(
          title,
          style: kCaption2.copyWith(
              color: kTextButtonColor, fontFamily: 'Roboto'),
        ));
  }
}
