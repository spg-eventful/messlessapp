import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:messless/screens/home.dart';
import 'package:messless/screens/login.dart';
import 'package:messless/screens/settings.dart';
import 'package:messless/widgets/scaffold_with_navbar.dart';

enum RouterDestinations {
  home(url: '/'),
  login(url: '/login'),
  settings(url: '/settings');

  final String url;

  const RouterDestinations({required this.url});
}

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'shell',
);

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: RouterDestinations.login.url,
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return ScaffoldWithNavbar(child: child);
      },
      routes: [
        GoRoute(
          path: RouterDestinations.login.url,
          name: "login",
          builder: (context, state) => LoginScreen(),
        ),
        GoRoute(
          path: RouterDestinations.home.url,
          name: "home",
          builder: (context, state) => HomeScreen(),
        ),
        GoRoute(
          path: RouterDestinations.settings.url,
          name: "settings",
          builder: (context, state) => SettingsScreen(),
        ),
      ],
    ),
  ],
);
