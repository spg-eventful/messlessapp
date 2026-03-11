import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router.dart';

class MslsAppbar extends StatelessWidget implements PreferredSizeWidget {
  const MslsAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    final route = GoRouterState.of(context).topRoute;
    final routeName = route?.name ?? "MESSless";

    return AppBar(
      backgroundColor: const Color(0xFF96d1fb),
      foregroundColor: Colors.black,
      title: Text(routeName),

      actions: [
        if (route?.path == RouterDestinations.home.url) ... [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: "Settings",
            onPressed: () {
              context.push("/settings");
            },
          ),
        ]
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
