// ignore_for_file: use_build_context_synchronously

import 'package:catalog/constants.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ForgotPasswd extends StatefulWidget {
  const ForgotPasswd({Key? key}) : super(key: key);

  @override
  State<ForgotPasswd> createState() => _ForgotPasswdState();
}

class _ForgotPasswdState extends State<ForgotPasswd> {
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
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
                flex: 3,
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
            const Text(
              "Insira seu e-mail para recuperar sua senha",
              style: TextStyle(
                decoration: TextDecoration.none,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            Flexible(
                flex: 2,
                child: Container(
                  color: Colors.transparent,
                )),
            Column(
              children: [
                const SizedBox(width: 20), // give it width
                TextFormField(
                  validator: (email) =>
                      email!.isEmpty && !EmailValidator.validate(email)
                          ? 'Insira um e-mail válido'
                          : null,
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
                const SizedBox(width: 10), // give it width
              ],
            ),
            Flexible(
                flex: 1,
                child: Container(
                  color: Colors.transparent,
                )),
            FloatingActionButton.extended(
              icon: const Icon(Icons.arrow_forward),
              elevation: 1,
              onPressed: resetPassword,
              label: const Text("Resetar senha"),
            ),
            Flexible(
                flex: 2,
                child: Container(
                  color: Colors.transparent,
                )),
            Column(children: [
              const SizedBox(height: 20),
              RichText(
                text: TextSpan(
                    text: 'Ainda não possui uma conta? ',
                    style: TextStyle(
                      decoration: TextDecoration.none,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    children: [
                      TextSpan(
                          recognizer: TapGestureRecognizer()..onTap = () {},
                          text: 'Crie agora mesmo!',
                          style: TextStyle(
                            decoration: TextDecoration.none,
                            color: Theme.of(context).colorScheme.primary,
                          ))
                    ]),
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                    text: 'Ja possui uma conta? ',
                    style: TextStyle(
                      decoration: TextDecoration.none,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    children: [
                      TextSpan(
                          recognizer: TapGestureRecognizer()..onTap = () {},
                          text: 'Entre aqui!',
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

  Future resetPassword() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());
      Utils.showSnackBar(
          'Um e-mail de recuperação de senha foi enviado! Verifique seu lixo eletrônico e spam.',
          context,
          Colors.green);
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      Utils.showSnackBar(e.message, context, Colors.red);
      Navigator.of(context).pop();
    }
  }
}
