import 'dart:convert';
import 'package:catalog/screens/qrcode.dart';
import 'package:catalog/screens/sidebar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:share_files_and_screenshot_widgets/share_files_and_screenshot_widgets.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';
import 'package:crypto/crypto.dart';

class InputData extends StatefulWidget {
  const InputData(
      {super.key,
      required this.storageRef,
      required this.title,
      required this.description,
      required this.cripto});

  final dynamic storageRef;
  final dynamic title;
  final dynamic description;
  final dynamic cripto;

  @override
  State<InputData> createState() => _InputDataState();
}

class _InputDataState extends State<InputData> {
  final data = FirebaseFirestore.instance.collection('data').doc();
  final FirebaseStorage storage = FirebaseStorage.instance;
  final userInfo = FirebaseAuth.instance.currentUser;
  final GlobalKey _qrImage = GlobalKey();

  String? idGenerated;

  @override
  void initState() {
    super.initState();
    inputDataToFirebase();
  }

  inputDataToFirebase() async {
    data.set({
      'user': userInfo!.uid,
      'user-mail': userInfo!.email,
      'cripto': md5.convert(utf8.encode(widget.cripto)).toString(),
      'id': data.id,
      'downloadUrl': widget.storageRef,
      'title': widget.title,
      'description': widget.description,
    });
    return idGenerated = data.id;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const QrCodeGenerationScreen(),
          ),
        );
        return false;
      },
      child: Scaffold(
        drawer: const Sidebar(),
        appBar: AppBar(
          title: const Text(
            "Catalog",
            style: TextStyle(
              fontSize: 22,
            ),
          ),
        ),
        body: Container(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.qr_code_scanner_sharp,
                          size: 30,
                        ),
                        SizedBox(height: 5),
                        Text(
                          "QR Code Gerado",
                          style: TextStyle(
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(
                  indent: 20,
                  endIndent: 20,
                  thickness: 1.0,
                  height: 1,
                ),
                const SizedBox(height: 15),
                RepaintBoundary(
                  key: _qrImage,
                  child: SizedBox(
                    height: 200,
                    width: MediaQuery.of(context).size.width - 55,
                    child: SfBarcodeGenerator(
                      backgroundColor: Colors.white,
                      value: data.id,
                      symbology: QRCode(),
                      // showValue: true,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                const Divider(
                  indent: 20,
                  endIndent: 20,
                  thickness: 1.0,
                  height: 1,
                ),
                const SizedBox(height: 20),
                FloatingActionButton.extended(
                  elevation: 1,
                  label: const Text('Download'),
                  icon: const Icon(Icons.download),
                  onPressed: () {
                    ShareFilesAndScreenshotWidgets().shareScreenshot(
                      _qrImage,
                      1200,
                      "QR Code",
                      "Catalog_qr_code.png",
                      "image/png",
                      text: "Gerado por Catalog App.",
                    );
                  },
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
