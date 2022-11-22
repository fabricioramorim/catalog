import 'dart:io';
import 'package:catalog/screens/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:catalog/screens/sidebar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

class ShowItens extends StatefulWidget {
  const ShowItens({Key? key, required this.scannedData}) : super(key: key);
  final String? scannedData;
  @override
  State<ShowItens> createState() => _ShowItensState();
}

class _ShowItensState extends State<ShowItens> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  final userInfo = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore db = FirebaseFirestore.instance;

  List<dynamic> refs = [];
  List<String> arquivos = [];
  List<String> element = [];

  bool loading = true;
  bool? hasDataOnDb;

  @override
  void initState() {
    super.initState();
    loadImages();
    validQrCode();
  }

  validQrCode() async {
    final data = await db.collection('data').doc(widget.scannedData).get();
    if (data.exists) {
      setState(() {
        hasDataOnDb = true;
        if (kDebugMode) {
          print("AE PORRA ESSE EXISTE");
        }
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Este QR Code é protegido por senha"),
            content: const Text(
                "Por favor, digite a senha para visualizar o conteúdo"),
            actions: <Widget>[
              TextButton(
                onPressed: () {},
                child: Column(
                  children: [
                    const TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Senha',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: ButtonTheme.of(context).colorScheme?.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: const Text(
                        "Confirmar",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      });
    } else {
      setState(() {
        hasDataOnDb = false;
        loading = false;
        if (kDebugMode) {
          print("FUDEU ESSE NAO EXISTE");
        }
      });
    }
    return data;
  }

  loadImages() {
    var resultAwait = db.collection('data').snapshots();
    resultAwait.forEach((element) {
      element.docs.forEach((element) async {
        if (element['id'] == widget.scannedData) {
          for (var ref in element['storageRefImages']) {
            arquivos.add(await storage.ref(ref['ref']).getDownloadURL());
          }
          setState(() {
            loading = false;
          });
        }
      });
    });
  }

  deleteItens(int index) async {
    await storage.ref(refs[index].fullPath).delete();
    arquivos.removeAt(index);
    refs.removeAt(index);
    setState(() {});
  }

  Future downloadFile(Reference refs) async {
    final dir = await getApplicationDocumentsDirectory();
    final arquivo = File('${dir.path}/${refs.name}');

    try {
      await refs.writeToFile(arquivo);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Baixado ${refs.name}'),
        ),
      );
    } on FirebaseException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível baixar'),
        ),
      );
    }
  }

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
        body: loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.all(15),
                child: hasDataOnDb == false
                    ? const Center(
                        child: Text('Não há dados, escaneie um QR Code válido'),
                      )
                    : StreamBuilder(
                        stream: db
                            .collection('data')
                            .where('id', isEqualTo: widget.scannedData)
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (!snapshot.hasData) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          return ListView(
                            children: snapshot.data!.docs.map((document) {
                              return Container(
                                child: Center(child: Text(document['title'])),
                              );
                            }).toList(),
                          );
                        },
                      ),
              ),
      ),
    );
  }
}
