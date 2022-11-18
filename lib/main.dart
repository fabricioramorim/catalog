import 'package:catalog/access/auth.dart';
import 'package:catalog/access/google_sign_in.dart';
import 'package:catalog/screens/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:catalog/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const CatalogApp());
}

final navigatorKey = GlobalKey<NavigatorState>();

class CatalogApp extends StatelessWidget {
  const CatalogApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => GoogleSignInProvider(),
        child: MaterialApp(
          scaffoldMessengerKey: Utils.messengerkey,
          navigatorKey: navigatorKey,
          title: aplicationName,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: "Open-sans",
            useMaterial3: true,
            colorSchemeSeed: Colors.blue,
          ),
          home: const CatalogRoute(),
        ));
  }
}

class CatalogRoute extends StatelessWidget {
  const CatalogRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: const [
                        /*Image.asset(
                            "assets/logo.png",
                            height: 300,
                            width: 300,
                          ),*/
                        SizedBox(height: 15),
                        Text(
                          aplicationName,
                          style: TextStyle(
                            decoration: TextDecoration.none,
                            fontSize: 42,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Organizando a facilidade.",
                          style: TextStyle(
                            decoration: TextDecoration.none,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    LoadingAnimationWidget.stretchedDots(
                      color: Colors.black,
                      size: 50,
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: const [
                        /*Image.asset(
                            "assets/logo.png",
                            height: 300,
                            width: 300,
                          ),*/
                        SizedBox(height: 15),
                        Text(
                          aplicationName,
                          style: TextStyle(
                            decoration: TextDecoration.none,
                            fontSize: 42,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Ocorreu um erro enquanto iniciavamos, por gentileza tente novamente.",
                          style: TextStyle(
                            decoration: TextDecoration.none,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasData) {
              return const HomeScreen();
            } else {
              return const AuthPage();
            }
          },
        ),
      );
}
