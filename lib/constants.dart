import 'package:flutter/material.dart';

const String aplicationName = "Catalog";
const String versionApp = "V1.0.0";
Color buttonColor = const Color(0xff345c72);

class Utils {
  static final GlobalKey<ScaffoldMessengerState> messengerkey = GlobalKey<ScaffoldMessengerState>();

  static showSnackBar(String? text) {
    if(text == null) return;

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
  TextFieldC({Key? key, this.keyboardType, this.maxLines, this.labelText, this.Icon, required StateSet}) : super(key: key);

  final keyboardType;
  final maxLines;
  final labelText;
  final Icon;
  String? StateSet;

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
          widget.Icon,
        ),
      ),
      onChanged: (value) {
        setState(() {
          widget.StateSet = value;
        });
      },
    );
  }
}

