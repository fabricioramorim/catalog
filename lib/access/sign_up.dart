import 'package:catalog/access/auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:catalog/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:email_validator/email_validator.dart';

import '../main.dart';

class SignUpScreen extends StatefulWidget {
  final Function() onClickSignIn;

  const SignUpScreen({Key? key, required this.onClickSignIn}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final signUpKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const AuthPage(),
            ),
          );
          return false;
        },
        child: Scaffold(
          body: Form(
            key: signUpKey,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: const [
                      /*Image.asset(
                  "assets/logo.png",
                  height: 180,
                  width: 180,
                ),*/
                      SizedBox(height: 10),
                      Text(
                        aplicationName,
                        style: TextStyle(
                          fontSize: 42,
                        ),
                      ),
                      SizedBox(height: 5),
                    ],
                  ),
                  Column(
                    children: [
                      const SizedBox(width: 10), // give it width
                      TextFormField(
                        controller: emailController,
                        textInputAction: TextInputAction.next,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (email) =>
                            email != null && !EmailValidator.validate(email)
                                ? 'Insira um e-mail válido'
                                : null,
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
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) => value != null && value.length < 6
                            ? 'A senha deve conter 6 caracteres'
                            : null,
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
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: passwordConfirmController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) =>
                            value != null && value != passwordController.text
                                ? 'As senhas não conferem'
                                : null,
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          labelText: "Confirme a senha",
                          prefixIcon: const Icon(
                            Icons.lock,
                          ),
                        ),
                      ),
                    ],
                  ),
                  FloatingActionButton.extended(
                    icon: const Icon(Icons.arrow_forward),
                    elevation: 1,
                    onPressed: signUp,
                    label: const Text("Cadastre-se"),
                  ),
                  const SizedBox(height: 10),
                  RichText(
                    text: TextSpan(
                        text: 'Já possui uma conta? ',
                        style: TextStyle(
                          decoration: TextDecoration.none,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        children: [
                          TextSpan(
                              recognizer: TapGestureRecognizer()
                                ..onTap = widget.onClickSignIn,
                              text: 'Entre aqui',
                              style: TextStyle(
                                decoration: TextDecoration.none,
                                color: Theme.of(context).colorScheme.primary,
                              ))
                        ]),
                  ),
                  const Text(versionApp),
                ],
              ),
            ),
          ),
        ));
  }

  Future signUp() async {
    final isValid = signUpKey.currentState!.validate();
    if (!isValid) return;

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
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordConfirmController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      Utils.showSnackBar(e.message, context, Colors.red);
    }
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }
}
