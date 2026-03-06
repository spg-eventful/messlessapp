import 'package:flutter/material.dart';
import 'package:messless/widgets/msls_appbar.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MslsAppbar(),
      body: const Text("this is the login screen"),
    );
  }
}
