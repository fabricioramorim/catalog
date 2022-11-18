import 'dart:io';
import 'package:catalog/screens/qrcode.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:catalog/constants.dart';
import 'package:catalog/screens/sidebar.dart';
import 'package:catalog/screens/home.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';
import 'package:share_files_and_screenshot_widgets/share_files_and_screenshot_widgets.dart';

class GeneratedQRCode extends StatefulWidget {
  const GeneratedQRCode({Key? key, required this.qrDataToGenerate})
      : super(key: key);
  final String qrDataToGenerate;
  @override
  State<GeneratedQRCode> createState() => _GeneratedQRCodeState();
}

class _GeneratedQRCodeState extends State<GeneratedQRCode> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  final userInfo = FirebaseAuth.instance.currentUser;

  List<Reference> refs = [];
  List<String> arquivos = [];
  bool loading = true;

  void initState() {
    super.initState();
    loadImages();
  }

  loadImages() async {
    refs = (await storage.ref('files/${userInfo?.email}').listAll()).items;
    for (var ref in refs) {
      arquivos.add(await ref.getDownloadURL());
    }
    setState(() {
      loading = false;
    });
  }

  final GlobalKey _qrImage = GlobalKey();
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
                      value: widget.qrDataToGenerate,
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
                      "Catalog.png",
                      "image/png",
                      text: "Gerado por Catalog App.",
                    );
                  },
                ),
                loading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(24),
                        child: arquivos.isEmpty
                            ? const Center(
                                child: Text("Não há imagens"),
                              )
                            : ListView.builder(
                                itemBuilder: (BuildContext context, int index) {
                                  return ListTile(
                                    leading: SizedBox(
                                      width: 60,
                                      height: 40,
                                      child: Image.network(
                                        arquivos[index],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    title: Text(
                                      refs[index].fullPath,
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  );
                                },
                                itemCount: arquivos.length,
                              ),
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
