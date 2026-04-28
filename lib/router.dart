import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:messless/screens/technicalLog/qr_scanner_screen.dart';
import 'package:messless/screens/technicalLog/add_technical_log_entry.dart';
import 'package:messless/screens/equipment/add_equipment.dart';
import 'package:messless/screens/equipment/equipment.dart';
import 'package:messless/screens/equipment/equipment_details.dart';
import 'package:messless/screens/events.dart';
import 'package:messless/screens/home.dart';
import 'package:messless/screens/login.dart';
import 'package:messless/screens/settings.dart';
import 'package:messless/screens/warehouses.dart';
import 'package:messless/screens/ws.dart';

enum RouterDestinations {
  home(url: '/'),
  login(url: '/login'),
  settings(url: '/settings'),
  events(url: '/events'),
  warehouses(url: '/warehouses'),
  equipment(url: '/equipment'),
  addEquipment(url: '/addEquipment'),
  equipmentDetails(url: '/equipmentDetails/:id'),
  editEquipment(url: '/editEquipment/:id'),
  wsTesting(url: '/wsTesting'),
  qrScanner(url: '/qrScanner'),
  addTechnicalLogEntry(url: '/addTechnicalLogEntry/:id');

  final String url;

  const RouterDestinations({required this.url});

  String withoutLeadingSlash() => url.substring(1);
}

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: RouterDestinations.login.url,
  routes: [
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
          path: RouterDestinations.settings.withoutLeadingSlash(),
          name: "Einstellungen",
          builder: (context, state) => const SettingsScreen(),
          routes: [
            GoRoute(
              path: RouterDestinations.wsTesting.withoutLeadingSlash(),
              name: "WS TEST",
              builder: (context, state) => WebSocketTestingScreen(),
            ),
          ],
        ),
        GoRoute(
          path: RouterDestinations.events.withoutLeadingSlash(),
          name: "Events",
          builder: (context, state) => const EventsScreens(),
        ),
        GoRoute(
          path: RouterDestinations.warehouses.withoutLeadingSlash(),
          name: "Warehouses",
          builder: (context, state) => const WarehousesScreen(),
        ),
        GoRoute(
          path: RouterDestinations.equipment.withoutLeadingSlash(),
          name: "Equipment",
          builder: (context, state) => const EquipmentScreen(),
        ),
        GoRoute(
          path: RouterDestinations.addEquipment.withoutLeadingSlash(),
          name: "Add Equipment",
          builder: (context, state) => const AddEquipmentScreen(),
        ),
        GoRoute(
          path: RouterDestinations.equipmentDetails.withoutLeadingSlash(),
          name: "Equipment Details",
          builder: (context, state) {
            final String idString = state.pathParameters['id']!;
            final int id = int.parse(idString);
            return EquipmentDetailsScreen(equipmentId: id);
          },
        ),
        GoRoute(
          path: RouterDestinations.qrScanner.withoutLeadingSlash(),
          name: "QR Scanner",
          builder: (context, state) => const QrScannerScreen(),
        ),
        GoRoute(
          path: RouterDestinations.addTechnicalLogEntry.withoutLeadingSlash(),
          name: "Add Technical Log Entry",
          builder: (context, state) {
            final String idString = state.pathParameters['id']!;
            final int id = int.parse(idString);
            return AddTechnicalLogEntry(equipmentId: id);
          },
        ),
      ],
    ),
  ],
);

