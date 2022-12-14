import 'dart:io';
import 'package:catalog/data/input.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:catalog/constants.dart';
import 'package:catalog/screens/sidebar.dart';
import 'package:catalog/screens/home.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';
import 'package:share_files_and_screenshot_widgets/share_files_and_screenshot_widgets.dart';

class QrCodeGenerationScreen extends StatefulWidget {
  const QrCodeGenerationScreen({Key? key}) : super(key: key);

  @override
  State<QrCodeGenerationScreen> createState() => _QrCodeGenerationScreenState();
}

class _QrCodeGenerationScreenState extends State<QrCodeGenerationScreen> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  final userInfo = FirebaseAuth.instance.currentUser;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final criptoController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    criptoController.dispose();

    super.dispose();
  }

  bool uploading = false;
  bool uploadingFiles = false;
  bool uploadingError = false;
  double total = 0;

  List<Map<String, String>> storageRefImages = [];
  List<Map<String, String>> storageRefFiles = [];
  List<XFile>? imageList = [];
  List<XFile>? fileList = [];

  Future<XFile?> getImageAndUpload() async {
    final ImagePicker picker = ImagePicker();
    final uploadName = 'file-${DateTime.now()}.jpg';
    Reference ref =
        storage.ref().child('files/${userInfo?.uid}/images/$uploadName');
    XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        imageList!.add(image);
        storageRefImages.add({
          'ref': ref.fullPath,
          'name': image.name,
          'uploadName': uploadName,
          'date': DateTime.now().toString(),
        });
      });
    }
    for (var i = 0; i < imageList!.length; i++) {
      UploadTask uploadTask = ref.putFile(File(imageList![i].path));

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) async {
        if (snapshot.state == TaskState.running) {
          setState(() {
            uploading = true;
            total = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
          });
        } else if (snapshot.state == TaskState.success) {
          setState(() {
            uploading = false;
          });
        } else if (snapshot.state == TaskState.error ||
            snapshot.state == TaskState.canceled) {
          setState(() {
            uploadingError = true;
          });
        }
      });
    }
    return image;
  }

  Future getFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );
    return result;
  }

  pickAndUploadImage() async {
    getImageAndUpload();
    imageList!.clear();
    if (uploadingError == true) {
      return const ScaffoldMessenger(child: Text('Erro ao fazer upload'));
    }
  }

  pickAndUploadFle() async {
    var fileBefore = await getFile();
    XFile? file = XFile(fileBefore!.files.single.path!);
    if (fileBefore != null) {
      String ref =
          'files/${userInfo?.uid}/files/file-${fileBefore.files.single.name}';

      if (fileBefore != null) {
        setState(() {
          fileList!.add(file);
          storageRefFiles.add({
            'ref': ref,
            'name': fileBefore.files.single.name,
            'date': DateTime.now().toString()
          });
        });
      }

      for (var i = 0; i < fileList!.length; i++) {
        UploadTask task = await uploadFile(fileBefore.files.single.path!, ref);

        task.snapshotEvents.listen((TaskSnapshot snapshot) async {
          if (snapshot.state == TaskState.running) {
            setState(() {
              uploadingFiles = true;
              total = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
            });
          } else if (snapshot.state == TaskState.success) {
            setState(() {
              uploadingFiles = false;
            });
          }
        });
      }
    }
    return file;
  }

  Future<UploadTask> upload(String path, String ref) async {
    File file = File(path);
    try {
      return storage.ref(ref).putFile(file);
    } on FirebaseException catch (e) {
      throw Exception('Erro ao carregar arquivo: ${e.code}');
    }
  }

  Future<UploadTask> uploadFile(String path, String ref) async {
    File file = File(path);
    try {
      return storage.ref(ref).putFile(file);
    } on FirebaseException catch (e) {
      throw Exception('Erro ao carregar arquivo: ${e.code}');
    }
  }

  final String qrDataTitle = "";
  final String qrDataDescription = "";
  final String qrData = "";
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
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
          padding: const EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/logo/logo_catalog_full.png",
                  height: 120,
                ),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    "Preencha as informa????es abaixo",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: titleController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    labelText: 'T??tulo',
                    prefixIcon: const Icon(
                      Icons.text_fields,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: descriptionController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    labelText: 'Descri????o',
                    prefixIcon: const Icon(
                      Icons.description,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: criptoController,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    labelText: 'Criptografia',
                    prefixIcon: const Icon(
                      Icons.lock,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment
                      .spaceEvenly, // use whichever suits your need
                  children: [
                    FloatingActionButton.extended(
                      heroTag: "btn1",
                      elevation: 1,
                      label: uploading
                          ? Text('${total.round()}% enviado')
                          : const Text('Capturar Imagem'),
                      icon: uploading
                          ? const Padding(
                              padding: EdgeInsets.only(right: 12),
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                  ),
                                ),
                              ))
                          : const Icon(Icons.photo_camera),
                      onPressed: pickAndUploadImage,
                    ),
                    const SizedBox(height: 15),
                    FloatingActionButton.extended(
                      heroTag: "btn2",
                      elevation: 1,
                      label: uploadingFiles
                          ? Text('${total.round()}% enviado')
                          : const Text('Anexar arquivo'),
                      icon: uploadingFiles
                          ? const Padding(
                              padding: EdgeInsets.only(right: 12),
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                  ),
                                ),
                              ))
                          : const Icon(Icons.file_upload),
                      onPressed: () => pickAndUploadFle(),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                FloatingActionButton.extended(
                  heroTag: "btn3",
                  elevation: 1,
                  label: const Text('Gerar QR Code'),
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InputData(
                          storageRefFiles: storageRefFiles,
                          storageRefImages: storageRefImages,
                          title: titleController.text.trim(),
                          description: descriptionController.text.trim(),
                          cripto: criptoController.text.trim(),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GeneratedBarCode extends StatefulWidget {
  const GeneratedBarCode({Key? key, required this.barDataToGenerate})
      : super(key: key);
  final String barDataToGenerate;

  @override
  State<GeneratedBarCode> createState() => _GeneratedBarCodeState();
}

class _GeneratedBarCodeState extends State<GeneratedBarCode> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey _barImage = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
        return false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text(
            "Catalog",
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
            )
          ],
        ),
        endDrawer: const Sidebar(),
        body: Container(
          padding: const EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Icon(
                            Icons.view_column,
                            size: 50,
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Barcode Generated",
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(
                    indent: 20,
                    endIndent: 20,
                    thickness: 1.0,
                    height: 1,
                  ),
                  const SizedBox(height: 20),
                  RepaintBoundary(
                    key: _barImage,
                    child: SizedBox(
                      height: 120,
                      width: MediaQuery.of(context).size.width - 55,
                      child: SfBarcodeGenerator(
                        value: widget.barDataToGenerate,
                        symbology: Code128C(),
                        showValue: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(
                    indent: 20,
                    endIndent: 20,
                    thickness: 1.0,
                    height: 1,
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        width: 1.0,
                        color: buttonColor,
                      ),
                    ),
                    onPressed: () {
                      ShareFilesAndScreenshotWidgets().shareScreenshot(
                        _barImage,
                        300,
                        "Barcode",
                        "Catalog.png",
                        "image/png",
                        text: "Gerado por Catalog App.",
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        "Share Barcode",
                        style: TextStyle(fontSize: 20, color: buttonColor),
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
                        onPressed: () {},
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            "More",
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
      ),
    );
  }
}

class BarcodeGenerationScreen extends StatefulWidget {
  const BarcodeGenerationScreen({Key? key}) : super(key: key);

  @override
  State<BarcodeGenerationScreen> createState() =>
      _BarcodeGenerationScreenState();
}

class _BarcodeGenerationScreenState extends State<BarcodeGenerationScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String _barDataToBeGenerated = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
          )
        ],
      ),
      endDrawer: const Sidebar(),
      body: Container(
        padding: const EdgeInsets.all(15),
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: [
              Column(
                children: const [
                  Icon(
                    Icons.view_column,
                    size: 100,
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Barcode Generator",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  labelText: "Enter any text",
                  labelStyle: TextStyle(),
                  prefixIcon: Icon(
                    Icons.view_column,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 2.0,
                    ),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _barDataToBeGenerated = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              Column(
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
                          builder: (context) => GeneratedBarCode(
                            barDataToGenerate: _barDataToBeGenerated,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        "Generate Barcode",
                        style: TextStyle(
                          fontSize: 20,
                          color: buttonColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
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
                        "Home",
                        style: TextStyle(
                          fontSize: 18,
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
    );
  }
}
