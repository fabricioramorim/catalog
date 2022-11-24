import 'dart:convert';
import 'dart:io';
import 'package:catalog/constants.dart';
import 'package:catalog/screens/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:catalog/screens/sidebar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:path_provider/path_provider.dart';

class ShowItens extends StatefulWidget {
  const ShowItens(
      {Key? key, required this.scannedData, required this.passwordValid})
      : super(key: key);
  final String? scannedData;
  final bool? passwordValid;
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
    final password = await db
        .collection('data')
        .doc(widget.scannedData)
        .get()
        .then((value) => value['cripto']);
    if (data.exists && password == 'd41d8cd98f00b204e9800998ecf8427e') {
      setState(() {
        hasDataOnDb = true;
        if (kDebugMode) {
          print("AE PORRA ESSE EXISTE E NAO TA CRIPTOGRAFADO");
        }
      });
    } else if (data.exists && widget.passwordValid == true) {
      setState(() {
        if (kDebugMode) {
          print("AE PORRA ESSE EXISTE E FOI VALIDADO");
        }
        hasDataOnDb = true;
      });
    } else if (data.exists && password != 'd41d8cd98f00b204e9800998ecf8427e') {
      setState(() {
        if (kDebugMode) {
          print("AE PORRA ESSE EXISTE E TA CRIPTOGRAFADO");
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CriptoPageAuth(
                password: password, db: db, scannedData: widget.scannedData),
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

  downloadFile(arquivo) async {
    FileDownloader.downloadFile(
        url: arquivo,
        name: 'Catalog/' 'arquivo',
        onDownloadCompleted: (String path) {
          Utils.showSnackBar(
            'Arquivo baixado com sucesso na sua pasta de Downloads',
            context,
            Colors.green,
          );
        },
        onDownloadError: (String error) {
          Utils.showSnackBar(
            'Erro ao baixar o arquivo',
            context,
            Colors.red,
          );
        });
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
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return SingleChildScrollView(
                            child: Column(
                              children: [
                                ListView(
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  children: snapshot.data!.docs.map((document) {
                                    return Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        children: [
                                          Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              document['title'],
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              document['description'],
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          const Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              'Arquivos',
                                              style: TextStyle(
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                                arquivos.isEmpty
                                    ? const Center(
                                        child: Text('Não há arquivos'),
                                      )
                                    : ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: arquivos.length,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.all(2),
                                            child: Card(
                                              child: SizedBox(
                                                width: 300,
                                                height: 150,
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15),
                                                        child: Image.network(
                                                          arquivos[index],
                                                          height: 200,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    Column(
                                                      children: [
                                                        TextButton.icon(
                                                          onPressed: () {
                                                            downloadFile(
                                                                arquivos[
                                                                    index]);
                                                          },
                                                          icon: const Icon(
                                                            Icons.download,
                                                          ),
                                                          label: const Text(
                                                            'Baixar',
                                                          ),
                                                        ),
                                                        TextButton.icon(
                                                          onPressed: () {
                                                            setState(() {
                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) {
                                                                    return AlertDialog(
                                                                      title: const Text(
                                                                          'Excluir'),
                                                                      content:
                                                                          const Text(
                                                                              'Tem certeza que deseja excluir esse arquivo?'),
                                                                      actions: [
                                                                        TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.pop(context);
                                                                          },
                                                                          child:
                                                                              const Text('Não'),
                                                                        ),
                                                                        TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            deleteItens(index);
                                                                            Navigator.pop(context);
                                                                          },
                                                                          child:
                                                                              const Text('Sim'),
                                                                        ),
                                                                      ],
                                                                    );
                                                                  });
                                                            });
                                                          },
                                                          icon: const Icon(
                                                            Icons.delete,
                                                          ),
                                                          label: const Text(
                                                            'Excluir',
                                                            style: TextStyle(),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
      ),
    );
  }
}

class CriptoPageAuth extends StatefulWidget {
  const CriptoPageAuth(
      {super.key,
      required this.db,
      required this.password,
      required this.scannedData});

  final FirebaseFirestore db;
  final String? password;
  final String? scannedData;

  @override
  State<CriptoPageAuth> createState() => _CriptoPageAuthState();
}

class _CriptoPageAuthState extends State<CriptoPageAuth> {
  final passwordController = TextEditingController();

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Este QR Code \n está criptografado',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 15,
              ),
              const Text('Digite a senha no campo abaixo para acessar'),
              const SizedBox(
                height: 50,
              ),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  labelText: "Senha",
                  prefixIcon: const Icon(
                    Icons.lock,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              FloatingActionButton.extended(
                elevation: 1,
                label: const Text('Entrar'),
                icon: const Icon(Icons.login),
                onPressed: passwordCheck,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> passwordCheck() async {
    var passwordHash =
        md5.convert(utf8.encode(passwordController.text)).toString();
    if (widget.password == passwordHash) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ShowItens(
            passwordValid: true,
            scannedData: widget.scannedData,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Senha incorreta'),
        ),
      );
    }
  }
}
