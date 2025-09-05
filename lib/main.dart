import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:messless/router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      supportedLocales: [/*Locale('en'), */ Locale('de', 'AT')],
      // TODO: add your application's localizations delegates.
      localizationsDelegates: const [],
      builder: (ctx, child) {
        print(ctx);
        return MaterialApp(home: child!);
      },
      routerConfig: goRouter,
    );
  }
}

