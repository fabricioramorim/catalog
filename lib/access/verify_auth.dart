import 'dart:async';

import 'package:catalog/constants.dart';
import 'package:catalog/screens/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class VerifyAuth extends StatefulWidget {
  const VerifyAuth({super.key});

  @override
  State<VerifyAuth> createState() => _VerifyAuthState();
}

class _VerifyAuthState extends State<VerifyAuth> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    if (isEmailVerified == false) {
      sendVerificationEmail();

      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) timer?.cancel();
  }

  Future sendVerificationEmail() async {
    try {
      await FirebaseAuth.instance.currentUser!.sendEmailVerification();
    } catch (e) {
      Utils.showSnackBar(
          e.toString() ==
                  "[firebase_auth/too-many-requests] We have blocked all requests from this device due to unusual activity. Try again later."
              ? "Muitas tentativas de envio de e-mail de verificação. Tente novamente mais tarde."
              : "Erro ao enviar e-mail de verificação",
          context,
          Colors.red);
    }
  }

  Future resendVerificationEmail() async {
    try {
      setState(() => canResendEmail = false);
      await Future.delayed(const Duration(seconds: 10));
      setState(() => canResendEmail = true);

      await FirebaseAuth.instance.currentUser!.sendEmailVerification();

      setState(() {
        Utils.showSnackBar(
          "E-mail de verificação enviado",
          context,
          Colors.green,
        );
      });
    } catch (e) {
      Utils.showSnackBar(
          e.toString() ==
                  "[firebase_auth/too-many-requests] We have blocked all requests from this device due to unusual activity. Try again later."
              ? "Muitas tentativas de envio de e-mail de verificação. Tente novamente mais tarde."
              : "Erro ao enviar e-mail de verificação",
          context,
          Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) => isEmailVerified
      ? const HomeScreen()
      : Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Por favor, verifique seu e-mail",
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                  FloatingActionButton.extended(
                    elevation: 1,
                    onPressed: canResendEmail
                        ? () => resendVerificationEmail()
                        : () {
                            Utils.showSnackBar(
                              "Você só pode enviar um e-mail de verificação a cada 10 segundos\nVerifique seu Spam e Lixo Eletrônico",
                              context,
                              Colors.red,
                            );
                          },
                    label: const Text("Reenviar e-mail"),
                    icon: const Icon(Icons.email),
                  ),
                  const SizedBox(height: 20),
                  FloatingActionButton.extended(
                    elevation: 1,
                    onPressed: () => FirebaseAuth.instance.signOut(),
                    label: const Text("Cancelar"),
                    icon: const Icon(Icons.logout),
                  ),
                ],
              ),
            ),
          ),
        );
}
