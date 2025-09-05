import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:slotterapp/screens/home.dart';
import 'package:slotterapp/screens/login.dart';
import 'package:slotterapp/widgets/scaffold_with_navbar.dart';

enum RouterDestinations {
  home(url: '/'),
  login(url: '/login');

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
          name: "Anmelden",
          builder: (context, state) => LoginScreen(),
        ),
        GoRoute(
          path: RouterDestinations.home.url,
          name: "Die Hugos",
          builder: (context, state) => HomeScreen(),
        ),
        //    GoRoute(
        //      path: RouterDestinations.cashpoolOverview.url,
        //      name: "Gruppenkassen",
        //      builder: (context, state) => CashpoolOverviewScreen(),
        //    ),
        //    GoRoute(
        //      path: RouterDestinations.cashpoolCreate.url,
        //      name: "Gruppenkassa erstellen",
        //      builder: (context, state) => CashpoolCreateScreen(),
        //    ),
        //    GoRoute(
        //      path: RouterDestinations.cashpoolDetail.url,
        //      name: "Gruppenkassa",
        //      builder: (context, state) => CashpoolDetailScreen(),
        //    ),
      ],
    ),
  ],
);
