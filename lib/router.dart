import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:messless/screens/home.dart';
import 'package:messless/screens/login.dart';
import 'package:messless/screens/settings.dart';
import 'package:messless/screens/ws.dart';

enum RouterDestinations {
  home(url: '/'),
  login(url: '/login'),
  settings(url: 'settings'),
  wsTesting(url: '/wsTesting');

  final String url;

  const RouterDestinations({required this.url});
}

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: RouterDestinations.wsTesting.url,
  routes: [
    GoRoute(
      path: RouterDestinations.wsTesting.url,
      name: "WS TEST",
      builder: (context, state) => WebSocketTestingScreen(),
    ),
    GoRoute(
      path: RouterDestinations.login.url,
      name: "Anmelden",
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: RouterDestinations.home.url,
      name: "Home",
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: RouterDestinations.settings.url,
          name: "Einstellungen",
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
);
