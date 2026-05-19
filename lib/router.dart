import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:messless/screens/company/company_create_screen.dart';
import 'package:messless/screens/company/company_detail_screen.dart';
import 'package:messless/screens/company/company_overview_screen.dart';
import 'package:messless/screens/equipment/add_equipment.dart';
import 'package:messless/screens/equipment/equipment.dart';
import 'package:messless/screens/equipment/equipment_details.dart';
import 'package:messless/screens/events/add_events.dart';
import 'package:messless/screens/events/event_details.dart';
import 'package:messless/screens/events/events.dart';
import 'package:messless/screens/home.dart';
import 'package:messless/screens/login.dart';
import 'package:messless/screens/settings.dart';
import 'package:messless/screens/technical_log/add_technical_log_entry.dart';
import 'package:messless/screens/technical_log/qr_scanner_screen.dart';
import 'package:messless/screens/user/user_create_screen.dart';
import 'package:messless/screens/user/user_detail_screen.dart';
import 'package:messless/screens/user/user_overview_screen.dart';
import 'package:messless/screens/warehouse/warehouse_create_screen.dart';
import 'package:messless/screens/warehouse/warehouse_detail_screen.dart';
import 'package:messless/screens/warehouse/warehouse_overview_screen.dart';
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
  addEvents(url: '/addEvents'),
  addTechnicalLogEntry(url: '/addTechnicalLogEntry/:id'),
  eventDetails(url: '/eventDetails/:id'),
  companies(url: '/companies'),
  addCompany(url: '/add'),
  detailsCompany(url: '/:id'),
  users(url: '/users'),
  addUser(url: '/add'),
  detailsUser(url: '/:id');

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
          builder: (context, state) => const EventsScreen(),
        ),
        GoRoute(
          path: RouterDestinations.addEvents.withoutLeadingSlash(),
          name: "Events hinzufügen",
          builder: (context, state) => const AddEventsScreen(),
        ),
        GoRoute(
          path: RouterDestinations.eventDetails.withoutLeadingSlash(),
          name: "Event Details",
          builder: (context, state) {
            final String idString = state.pathParameters['id']!;
            final int id = int.parse(idString);
            return EventDetailsScreen(eventId: id);
          },
        ),

        GoRoute(
            path: RouterDestinations.companies.withoutLeadingSlash(),
            name: "Companies",
            builder: (context, state) => const CompanyScreen(),
            routes: [
              GoRoute(
                path: RouterDestinations.addCompany.withoutLeadingSlash(),
                name: "Add Company",
                builder: (context, state) => const CreateCompanyScreen(),
              ),
              GoRoute(
                path: RouterDestinations.detailsCompany.withoutLeadingSlash(),
                name: "Company Details",
                builder: (context, state) =>
                    CompanyDetailScreen(
                        companyId: int.parse(state.pathParameters['id']!)),
              ),
            ]
        ),
        GoRoute(
            path: RouterDestinations.users.withoutLeadingSlash(),
          name: "Users",
          builder: (context, state) =>
              UserScreen(),
            routes: [
              GoRoute(
                path: RouterDestinations.addUser.withoutLeadingSlash(),
                name: "Add User",
                builder: (context, state) => const CreateUserScreen(),
              ),
              GoRoute(
                path: RouterDestinations.detailsUser.withoutLeadingSlash(),
                name: "User Details",
                builder: (context, state) =>
                    UserDetailScreen(
                        userId: int.parse(state.pathParameters['id']!)),
              ),
            ]
        ),
          builder: (context, state) => const EventsScreen(),
          routes: [
            GoRoute(
              path: 'add',
              name: "Event hinzufügen",
              builder: (context, state) => const AddEventsScreen(),
            ),
            GoRoute(
              path: ':id',
              name: "Event Details",
              builder: (context, state) {
                final String idString = state.pathParameters['id']!;
                final int id = int.parse(idString);
                return EventDetailsScreen(eventId: id);
              },
              routes: [
                GoRoute(
                  path: 'edit',
                  name: "Event Edit",
                  builder: (context, state) {
                    final String idString = state.pathParameters['id']!;
                    final int id = int.parse(idString);
                    return AddEventsScreen(eventId: id);
                  },
                ),
              ],
            ),
          ],
        ),

        GoRoute(
          path: RouterDestinations.warehouses.withoutLeadingSlash(),
          name: "Warehouses",
          builder: (context, state) => const WarehousesScreen(),
          routes: [
            GoRoute(
              path: 'new',
              name: "Warehouse Create",
              builder: (context, state) => const CreateWarehouseScreen(),
            ),
            GoRoute(
              path: ':id',
              name: "Warehouse Detail",
              builder: (context, state) =>
                  WarehouseDetailScreen(
                      warehouseId: int.parse(state.pathParameters['id']!)),
              routes: [
                GoRoute(
                  path: 'edit',
                  name: "Warehouse Edit",
                    builder: (context, state) =>
                        CreateWarehouseScreen(
                            warehouseId: int.parse(state.pathParameters['id']!))
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: RouterDestinations.equipment.withoutLeadingSlash(),
          name: "Equipment",
          builder: (context, state) => const EquipmentScreen(),
          routes: [
            GoRoute(
              path: 'add',
              name: "Equipment hinzufügen",
              builder: (context, state) => const AddEquipmentScreen(),
            ),
            GoRoute(
              path: ':id',
              name: "Equipment Details",
              builder: (context, state) {
                final String idString = state.pathParameters['id']!;
                final int id = int.parse(idString);
                return EquipmentDetailsScreen(equipmentId: id);
              },
              routes: [
                GoRoute(
                  path: 'edit',
                  name: "Equipment Edit",
                  builder: (context, state) {
                    final String idString = state.pathParameters['id']!;
                    final int id = int.parse(idString);
                    return AddEquipmentScreen(equipmentId: id);
                  },
                ),
              ],
            ),
          ],
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
