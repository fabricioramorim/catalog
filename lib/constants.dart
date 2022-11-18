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

class TextFieldC extends StatefulWidget {
  TextFieldC(
      {Key? key,
      this.keyboardType,
      this.maxLines,
      this.labelText,
      this.icon,
      required stateSet})
      : super(key: key);

  dynamic keyboardType;
  dynamic maxLines;
  dynamic labelText;
  dynamic icon;
  String? stateSet;

  @override
  State<TextFieldC> createState() => _TextFieldCState();
}

class _TextFieldCState extends State<TextFieldC> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: widget.keyboardType,
      maxLines: widget.maxLines,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        labelText: widget.labelText,
        prefixIcon: Icon(
          widget.icon,
        ),
      ),
      onChanged: (value) {
        setState(() {
          widget.stateSet = value;
        });
      },
    );
  }
}
