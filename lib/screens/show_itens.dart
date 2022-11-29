import 'package:catalog/constants.dart';
import 'package:catalog/screens/cripto_auth.dart';
import 'package:catalog/screens/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:catalog/screens/sidebar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';

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
  late dynamic snapshotLoad;

  List<dynamic> refs = [];
  List<String> images = [];
  List<String> files = [];
  List<String> element = [];
  List<dynamic> dataList = [];

  bool loading = true;
  bool? hasDataOnDb;

  @override
  void initState() {
    super.initState();
    setSnapshot();
    loadImages();
    loadFiles();
    validQrCode();
  }

//FUNÇÃO RESPONSÁVEL POR INICIAR O SNAPSHOT
  Future setSnapshot() async {
    snapshotLoad = await db.collection('data').doc(widget.scannedData).get();
  }

//FUNÇÃO RESPONSÁVEL POR VALIDAR O QR CODE E VERIFICAR SE O USUÁRIO TEM PERMISSÃO PARA ACESSAR O CONTEÚDO
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

//FUNÇÃO RESPONSÁVEL POR CARREGAR AS IMAGENS DO FIREBASE STORAGE
  loadImages() {
    var resultAwaitImages = db.collection('data').snapshots();
    resultAwaitImages.forEach((element) {
      element.docs.forEach((element) async {
        if (element['id'] == widget.scannedData) {
          for (var ref in element['storageRefImages']) {
            images.add(await storage.ref(ref['ref']).getDownloadURL());
          }
          setState(() {
            loading = false;
          });
        }
      });
    });
  }

//FUNÇÃO RESPONSÁVEL POR CARREGAR OS ARQUIVOS DO FIREBASE STORAGE
  loadFiles() {
    var resultAwaitFiles = db.collection('data').snapshots();
    resultAwaitFiles.forEach((element) {
      element.docs.forEach((element) async {
        if (element['id'] == widget.scannedData) {
          for (var ref in element['storageRefFiles']) {
            files.add(await storage.ref(ref['ref']).getDownloadURL());
          }
          setState(() {
            loading = false;
          });
        }
      });
    });
  }

//FUNÇÃO RESPONSÁVEL POR EXCLUIR OS ARQUIVOS DO FIREBASE STORAGE
  deleteItens(int index) async {
    await storage.ref(refs[index].fullPath).delete();
    images.removeAt(index);
    refs.removeAt(index);
    setState(() {});
  }

//FUNÇÃO RESPONSÁVEL POR BAIXAR OS ARQUIVOS DO FIREBASE STORAGE
  downloadFile(x) async {
    FileDownloader.downloadFile(
      url: x,
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
      },
    );
  }

//FUNÇÃO RESPONSÁVEL POR GERAR O STREAMBUILDER
  listStreamBuilder() {
    return StreamBuilder(
      stream: db
          .collection('data')
          .where('id', isEqualTo: widget.scannedData)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return SingleChildScrollView(
          child: Column(
            children: [
              listDescription(snapshot),
              images.isEmpty
                  ? const Center(
                      child: Text('Não há images'),
                    )
                  : listImages(),
              files.isEmpty
                  ? const Center(
                      child: Text('Não há arquivos'),
                    )
                  : listFile(),
            ],
          ),
        );
      },
    );
  }

//FUNÇÃO RESPONSÁVEL POR LISTAR A DESCRIÇÃO DO QR CODE
  listDescription(AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
    return ListView(
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
    );
  }

//FUNÇÃO RESPONSÁVEL POR LISTAR AS IMAGENS NO LISTVIEW
  listImages() {
    return SizedBox(
      height: 320,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: images.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(6),
              child: SizedBox(
                width: 230,
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 10 / 7,
                        child: Image.network(
                          images[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.image),
                        title: Text('Imagem ${index + 1}'),
                        subtitle: Text(
                          'Cloud Catalog ',
                          style:
                              TextStyle(color: Colors.black.withOpacity(0.6)),
                        ),
                      ),
                      ButtonBar(
                        alignment: MainAxisAlignment.start,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              downloadFile(images[index]);
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
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('Excluir'),
                                        content: const Text(
                                            'Tem certeza que deseja excluir esse arquivo?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Não'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              deleteItens(index);
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Sim'),
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
          }),
    );
  }

//FUNÇÃO RESPONSÁVEL POR LISTAR OS ARQUIVOS NO LISTVIEW
  listFile() {
    return SizedBox(
      height: 320,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: files.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(6),
              child: SizedBox(
                width: 230,
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Icon(
                          Icons.attach_file,
                          size: 80,
                          color: Colors.grey,
                        ),
                      ),

                      /* AspectRatio(
                        aspectRatio: 10 / 7,
                        child: Image.network(
                          images[index],
                          fit: BoxFit.cover,
                        ),
                      ),*/
                      ListTile(
                        leading: const Icon(Icons.file_open),
                        title: Text(
                          snapshotLoad.data()!['storageRefFiles'][index]
                              ['name'],
                        ),
                        subtitle: Text(
                          'Cloud Catalog ',
                          style:
                              TextStyle(color: Colors.black.withOpacity(0.6)),
                        ),
                      ),
                      ButtonBar(
                        alignment: MainAxisAlignment.start,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              downloadFile(files[index]);
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
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('Excluir'),
                                        content: const Text(
                                            'Tem certeza que deseja excluir esse arquivo?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Não'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              deleteItens(index);
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Sim'),
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
          }),
    );
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
            aplicationName,
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
                    : listStreamBuilder(),
              ),
      ),
    );
  }
}
