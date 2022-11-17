import 'package:catalog/access/login.dart';
import 'package:catalog/access/signUp.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;

  @override
  Widget build(BuildContext context) => isLogin
      ? LoginScreen(onClickSignUp: toggle)
      : SignUpScreen(onClickSignIn: toggle);

  void toggle() => setState(() => isLogin = !isLogin);
}
