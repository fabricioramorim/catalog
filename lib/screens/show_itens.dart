import 'dart:io';
import 'package:catalog/screens/qrcode.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:catalog/screens/sidebar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

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

  @override
  void initState() {
    super.initState();
    loadImages();
  }

  loadImages() async {
    refs = (await storage.ref('files/${userInfo?.email}/').listAll()).items;
    for (var ref in refs) {
      arquivos.add(await ref.getDownloadURL());
    }
    setState(() => loading = false);
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
            body: loading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Padding(
                    padding: const EdgeInsets.all(15),
                    child: arquivos.isEmpty
                        ? const Center(
                            child: Text("Não há imagens"),
                          )
                        : ListView.builder(
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                leading: SizedBox(
                                  width: 120,
                                  child: Image.network(
                                    arquivos[index],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text(
                                                "Deseja realmente exluir este item?"),
                                            content: const Text(
                                                "Depois de excluído, não será possível recuperar"),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  deleteItens(index);
                                                  Navigator.of(ctx).pop();
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color:
                                                        ButtonTheme.of(context)
                                                            .colorScheme
                                                            ?.error,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.all(14),
                                                  child: const Text(
                                                    "Confirmar",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.download),
                                      onPressed: () =>
                                          downloadFile(refs[index]),
                                    ),
                                  ],
                                ),
                              );
                            },
                            itemCount: arquivos.length,
                          ),
                  )));
  }
}
