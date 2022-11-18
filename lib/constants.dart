// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

const String aplicationName = "Catalog";
const String versionApp = "V1.0.0";
Color buttonColor = const Color(0xff345c72);

class Utils {
  static final GlobalKey<ScaffoldMessengerState> messengerkey =
      GlobalKey<ScaffoldMessengerState>();

  static showSnackBar(String? text) {
    if (text == null) return;

    final snackBar = SnackBar(
      content: Text(text),
      backgroundColor: Colors.red,
    );

    messengerkey.currentState!
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
