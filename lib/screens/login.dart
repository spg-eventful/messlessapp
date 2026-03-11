import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:messless/widgets/msls_appbar.dart';
import 'package:messless/ws/backend_client.dart';
import 'package:messless/ws/schema/auth/request/basic_auth.dart';

import '../ws/exceptions/auth_exception.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
                        label: Text("Email"),
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

                          try {
                            await BackendClient.authenticate(
                              BasicAuth(
                                _emailController.text,
                                _passwordController.text,
                              ),
                            );
                          } catch (e) {
                            Logger.root.warning(e);
                            if (e is AuthException) {
                              final snackBar = SnackBar(
                                content: const Text('Ungültiger Login!'),
                              );

                              if (context.mounted) {
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(snackBar);
                              }
                              return;
                            }
                            // TODO: Handle
                          }
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
