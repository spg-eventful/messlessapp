import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:messless/widgets/msls_appbar.dart';
import 'package:messless/ws/backend_client.dart';
import 'package:messless/ws/exceptions/jwt_auth_exception.dart';
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
  bool isFormValid = false;
  late Future<bool> authJwtFuture;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(updateFormValidState);
    _passwordController.addListener(updateFormValidState);
    authJwtFuture = authenticateReturning();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MslsAppbar(),
      body: Center(
        child: FutureBuilder(
          future: authJwtFuture,
          builder: (context, asyncSnapshot) {
            if (!asyncSnapshot.hasData) {
              return CircularProgressIndicator();
            }

            if (asyncSnapshot.data == true) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => context.go("/"),
              );
            }

            return Column(
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
                            hintText: 'E-Mail eingeben',
                            border: OutlineInputBorder(),
                            label: Text("E-Mail"),
                          ),
                          validator: (String? value) {
                            if (value == null || !value.contains("@")) {
                              return 'Bitte geben Sie eine gültige E-Mail ein!';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            hintText: 'Passwort eingeben',
                            border: OutlineInputBorder(),
                            label: Text("Passwort"),
                          ),
                          validator: (String? value) {
                            if (value == null || value.length < 3) {
                              return 'Muss länger als drei Zeichen sein!';
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: isFormValid ? submitLogin : null,
                            child: const Text('Anmelden'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void updateFormValidState() => setState(() {
    isFormValid = _formKey.currentState!.validate();
  });

  Future<bool> authenticateReturning() async {
    try {
      await BackendClient.authenticate(null);
      return true;
    } catch (e) {
      Logger.root.warning(e);
      if (e is JwtAuthException) {
        return false;
      }
      rethrow;
    }
  }

  void submitLogin() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await BackendClient.authenticate(
        BasicAuth(_emailController.text, _passwordController.text),
      );
      if (mounted) context.go("/");
    } catch (e) {
      Logger.root.warning(e);
      if (e is AuthException) {
        final snackBar = SnackBar(content: const Text('Ungültiger Login!'));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
        return;
      }
      rethrow;
    }
  }
}
