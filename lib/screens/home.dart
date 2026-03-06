import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:messless/widgets/msls_appbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MslsAppbar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your email',
                        border: OutlineInputBorder(),
                        label: const Text("Email"),
                      ),
                      validator: (String? value) {
                        if (value == null || !value.contains("@")) {
                          return 'Please enter an email!';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'Enter your password',
                        border: OutlineInputBorder(),
                        label: Text("Password"),
                      ),
                      validator: (String? value) {
                        if (value == null || value.length < 3) {
                          return 'Password must be longer than 3 chars';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;

                          final url = Uri.http(
                            "10.0.2.2:8055",
                            "/users/register",
                          );

                          final response = await http.post(
                            url,
                            body: jsonEncode({
                              "email": _emailController.text,
                              "password": _emailController.text,
                            }),
                            headers: {"Content-Type": "application/json"},
                          );

                          print(response.statusCode);
                        },
                        child: const Text('Registrieren'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
