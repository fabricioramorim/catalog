// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

const String aplicationName = "Catalog";
const String versionApp = "V1.0.0";
Color buttonColor = const Color(0xff345c72);

class Utils {
  static final GlobalKey<ScaffoldMessengerState> messengerkey =
      GlobalKey<ScaffoldMessengerState>();

  static showSnackBar(
      String? text, BuildContext context, Color colorSnackBar) async {
    if (text == null) return;

    final snackBar = SnackBar(
      content: Text(text),
      backgroundColor: colorSnackBar,
    );

    messengerkey.currentState!
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
