import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithNavbar extends StatelessWidget {
  const ScaffoldWithNavbar({super.key, required this.child});

  final Widget child;

  static const Map<String, String> titles = {
    "home": "Home",
    "settings": "Settings",
  };

  @override
  Widget build(BuildContext context) {
    final routeName = GoRouterState.of(context).topRoute?.name;

    final title = titles[routeName] ?? "MESSless";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF96d1fb),
        foregroundColor: Colors.black,

        leading: routeName == "settings"
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  context.go("/");
                },
              )
            : null,

        title: Text(title),

        actions: [
          if (routeName == "home")
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: "Settings",
              onPressed: () {
                context.push("/settings");
              },
            ),
        ],
      ),
      body: SafeArea(top: true, child: child),
    );
  }
}
