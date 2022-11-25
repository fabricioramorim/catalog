import 'dart:async';
import 'dart:convert';

import 'package:catalog/screens/show_itens.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

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
