import 'package:flutter/material.dart';
import 'package:catalog/constants.dart';
import 'package:catalog/screens/sidebar.dart';
import 'package:catalog/screens/home.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

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
                  if (scannedData != null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ShowScannedData(
                          scannedData: scannedData,
                        ),
                      ),
                    );
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ShowScannedData(
                          scannedData:
                              "QR Code | Barcode não possui nenhuma informação.",
                        ),
                      ),
                    );
                  }
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
                label: Text("Procure na galeria")),
            Text(versionApp)
          ],
        ),
      ),
    );
  }
}

class ShowScannedData extends StatefulWidget {
  const ShowScannedData({Key? key, required this.scannedData})
      : super(key: key);

  final String scannedData;

  @override
  State<ShowScannedData> createState() => _ShowScannedDataState();
}

class _ShowScannedDataState extends State<ShowScannedData> {
  bool isUrl = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    bool tempData = Uri.parse(widget.scannedData).host == '' ? false : true;
    if (tempData == true) {
      setState(() {
        isUrl = true;
      });
    } else {}
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: const Sidebar(),
      appBar: AppBar(
        title: const Text(
          aplicationName,
          style: TextStyle(
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.menu_open_sharp,
              size: 30.0,
            ),
            onPressed: () {
              _scaffoldKey.currentState!.openEndDrawer();
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(15),
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Column(
                  children: [
                    Image.asset(
                      "assets/logo.png",
                      height: 120,
                      width: 120,
                    ),
                    const Text(
                      "Scanned Successfully",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1.0,
                    ),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(
                        5.0,
                      ),
                    ),
                  ),
                  child: SelectableText(
                    widget.scannedData,
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (isUrl == true)
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        width: 1.0,
                        color: buttonColor,
                      ),
                    ),
                    onPressed: () {
                      launch(widget.scannedData);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        "Launch Url",
                        style: TextStyle(
                          fontSize: 20,
                          color: buttonColor,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      width: 1.0,
                      color: buttonColor,
                    ),
                  ),
                  onPressed: () {
                    Share.share(widget.scannedData);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      "Share Text",
                      style: TextStyle(
                        fontSize: 20,
                        color: buttonColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          width: 1.0,
                          color: buttonColor,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ScanScreen(),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          "Scan",
                          style: TextStyle(
                            fontSize: 20,
                            color: buttonColor,
                          ),
                        ),
                      ),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          width: 1.0,
                          color: buttonColor,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          "Back",
                          style: TextStyle(
                            fontSize: 20,
                            color: buttonColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
