import 'package:catalog/screens/show_itens.dart';
import 'package:flutter/material.dart';
import 'package:catalog/constants.dart';
import 'package:catalog/screens/sidebar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ImagePicker _picker = ImagePicker();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  MobileScannerController cameraController = MobileScannerController();
  Future pickImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage == null) {
    } else {
      cameraController.analyzeImage(pickedImage.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const Sidebar(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          aplicationName,
          style: TextStyle(
            fontSize: 24,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      body: Container(
        padding: const EdgeInsets.all(15),
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    LoadingAnimationWidget.horizontalRotatingDots(
                      size: 35,
                      color: Colors.white,
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.qr_code_scanner_sharp,
                      size: 35,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 320,
              width: 320,
              child: MobileScanner(
                allowDuplicates: false,
                controller: cameraController,
                onDetect: (barcode, args) {
                  final String? scannedData = barcode.rawValue;

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShowItens(
                          passwordValid: false, scannedData: scannedData),
                    ),
                  );
                },
              ),
            ),
            const Text(
              "Escanear",
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            FloatingActionButton.extended(
                elevation: 1,
                onPressed: () {
                  pickImage();
                },
                label: const Text("Procure na galeria")),
            const Text(versionApp)
          ],
        ),
      ),
    );
  }
}
