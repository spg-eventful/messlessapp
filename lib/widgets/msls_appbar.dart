import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router.dart';

class MslsAppbar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  final Widget? title;

  const MslsAppbar({super.key, this.actions, this.title});

  @override
  Widget build(BuildContext context) {
    final route = GoRouterState.of(context).topRoute;
    final routeName = route?.name ?? "MESSless";

    return AppBar(
      title: title ?? Text(routeName),
      actions: [
        if (actions != null) ...actions!,
        if (route?.path == RouterDestinations.home.url) ...[
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: "Settings",
            onPressed: () => context.push("/settings"),
          ),
        ],
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
