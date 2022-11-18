import 'package:catalog/screens/scanner.dart';
import 'package:flutter/material.dart';
import 'package:catalog/constants.dart';
import 'package:catalog/screens/sidebar.dart';
import 'package:catalog/screens/qrcode.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
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
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "btn1",
        label: const Text('Escanear'),
        icon: const Icon(Icons.qr_code_scanner),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const ScanScreen(),
            ),
          );
        },
      ),
      body: Container(
        padding: const EdgeInsets.all(15),
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
                flex: 1,
                child: Container(
                  color: Colors.transparent,
                )),
            Column(
              children: [
                Image.asset(
                  "assets/logo/logo_catalog_full.png",
                  width: 250,
                ),
                const SizedBox(
                  height: 20,
                ),
                const Center(
                  child: Text(
                    "Vamos lá! você é livre.",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
            Flexible(
                flex: 1,
                child: Container(
                  color: Colors.transparent,
                )),
            Column(
              children: [
                FloatingActionButton.extended(
                  heroTag: "btn2",
                  elevation: 1,
                  label: const Text('Gerar QR Code'),
                  icon: const Icon(Icons.qr_code_2),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QrCodeGenerationScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                FloatingActionButton.extended(
                  heroTag: "btn3",
                  elevation: 1,
                  label: const Text('Gerar Código de Barras'),
                  icon: SizedBox(
                    width: 30,
                    child: Image.asset('assets/icons/barcode.png'),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BarcodeGenerationScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            Flexible(
                flex: 3,
                child: Container(
                  color: Colors.transparent,
                )),
            const Text(versionApp),
          ],
        ),
      ),
    );
  }
}
