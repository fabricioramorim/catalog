import 'package:catalog/access/googleSignIn.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:catalog/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import '../main.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onClickSignUp;

  const LoginScreen({Key? key, required this.onClickSignUp}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
                flex: 2,
                child: Container(
                  color: Colors.transparent,
                )),
            Image.asset(
              "assets/logo/logo_catalog_full.png",
              width: 250,
            ),
            Flexible(
                flex: 1,
                child: Container(
                  color: Colors.transparent,
                )),
            Column(
              children: [
                const SizedBox(width: 10), // give it width
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    labelText: "E-mail",
                    prefixIcon: const Icon(
                      Icons.person_rounded,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
              ],
            ),
            Flexible(
                flex: 1,
                child: Container(
                  color: Colors.transparent,
                )),
            ElevatedButton.icon(
              onPressed: () {
                final provider = Provider.of<GoogleSignInProvider>(
                  context,
                  listen: false,
                );
                provider.googleLogin();
              },
              label: const Text('Login com Google'),
              icon: const FaIcon(FontAwesomeIcons.google),
            ),
            Flexible(
                flex: 1,
                child: Container(
                  color: Colors.transparent,
                )),
            Column(children: [
              FloatingActionButton.extended(
                icon: const Icon(Icons.login),
                elevation: 1,
                onPressed: signIn,
                label: const Text("Entrar"),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                child: const Text('Esqueceu a senha?'),
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                    text: 'Ainda não possui uma conta? ',
                    style: TextStyle(
                      decoration: TextDecoration.none,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    children: [
                      TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = widget.onClickSignUp,
                          text: 'Crie agora mesmo!',
                          style: TextStyle(
                            decoration: TextDecoration.none,
                            color: Theme.of(context).colorScheme.primary,
                          ))
                    ]),
              ),
            ]),
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

  Future signIn() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Container(
            color: Colors.white,
            child: Center(
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
                        "Validando suas informações",
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
            )));
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      Utils.showSnackBar(e.message);
    }
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }
}
