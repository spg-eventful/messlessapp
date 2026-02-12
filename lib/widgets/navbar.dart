import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:messless/screens/home.dart';

class ScaffoldWithNavbar extends StatelessWidget {
  const ScaffoldWithNavbar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    var routeName = GoRouterState.of(context).topRoute?.name;

    Widget? header;
    // if (routeName != null) {
    //   if (!context.canPop()) {
    //     header = FHeader(title: Text(routeName));
    //   } else {
    //     header = FHeader.nested(
    //       title: Text(routeName),
    //       prefixes: [FHeaderAction.back(onPress: () {
    //         context.pop();
    //       })],
    //     );
    //   }
    // }

    return Scaffold(
      // header: header,
      body: SafeArea(top: true, child: child),
    );
  }
}
