import 'package:catalog/access/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({Key? key}) : super(key: key);

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Drawer(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(),
              child: Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.close),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.home,
                color: Colors.black,
              ),
              title: const Text(
                'Home',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              onTap: () => {},
            ),
            ListTile(
              leading: const Icon(
                Icons.search,
                color: Colors.black,
              ),
              title: const Text(
                'Buscar códigos',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              onTap: () => {},
            ),
            ListTile(
              leading: const Icon(
                Icons.qr_code_2,
                color: Colors.black,
              ),
              title: const Text(
                'Gerar QR code',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              onTap: () {},
            ),
            ListTile(
              leading: SizedBox(
                width: 25,
                child: Image.asset('assets/icons/barcode.png'),
              ),
              title: const Text(
                'Gerar Código de Barras',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(
                Icons.android,
                color: Colors.black,
              ),
              title: const Text(
                'Sobre nós',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              onTap: () {},
            ),
            ListTile(
                leading: const Icon(
                  Icons.exit_to_app,
                  color: Colors.black,
                ),
                title: const Text(
                  'Sair',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                onTap: () {
                  final provider = Provider.of<GoogleSignInProvider>(
                    context,
                    listen: false,
                  );
                  provider.logout();
                }),
          ],
        ),
      ),
    );
  }
}
