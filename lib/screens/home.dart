import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:messless/router.dart';
import 'package:messless/screens/warehouse/warehouse_ws.dart';
import 'package:messless/widgets/msls_appbar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final role = WarehouseWs.roleAsInt();
    final isAdmin = role >= 5;
    return Scaffold(
      appBar: MslsAppbar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: isAdmin
              ? _buildAdminDashboard(context)
              : _buildDefaultView(context),
        ),
      ),
    );
  }

  Widget _buildBigButton(BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 70,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF96d1fb),
          foregroundColor: Colors.black,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 28),
        label: Text(label),
      ),
    );
  }

  Widget _buildDefaultView(BuildContext context) {
    return Column(
      children: <Widget>[
        const Spacer(),

        _buildBigButton(
          context,
          label: "Warehouses",
          icon: Icons.warehouse_rounded,
          color: const Color(0xFF96d1fb),
          onPressed: () =>
              context.push(
                RouterDestinations.warehouses.url,
              ),
        ),

        const SizedBox(height: 16),

        _buildBigButton(
          context,
          label: "Events",
          icon: Icons.event_note_rounded,
          color: const Color(0xFF96d1fb),
          onPressed: () =>
              context.push(
                RouterDestinations.events.url,
              ),
        ),

        const SizedBox(height: 16),

        _buildBigButton(
          context,
          label: "Equipment",
          icon: Icons.precision_manufacturing_rounded,
          color: const Color(0xFF96d1fb),
          onPressed: () =>
              context.push(
                RouterDestinations.equipment.url,
              ),
        ),
      ],
    );
  }

  Widget _buildDashboardCard(BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    Color iconColor = Colors.white,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(24),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 42,
                color: iconColor,
              ),

              const SizedBox(height: 16),

              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminDashboard(BuildContext context) {
    return Column(
      children: [
        const Spacer(),

        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildDashboardCard(
              context,
              label: "Warehouses",
              icon: Icons.warehouse_rounded,
              color: const Color(0xFF3B82F6),
              onPressed: () =>
                  context.push(
                    RouterDestinations.warehouses.url,
                  ),
            ),

            _buildDashboardCard(
              context,
              label: "Events",
              icon: Icons.event_note_rounded,
              color: const Color(0xFF06B6D4),
              onPressed: () =>
                  context.push(
                    RouterDestinations.events.url,
                  ),
            ),

            _buildDashboardCard(
              context,
              label: "Equipment",
              icon: Icons.precision_manufacturing_rounded,
              color: const Color(0xFF0EA5E9),
              onPressed: () =>
                  context.push(
                    RouterDestinations.equipment.url,
                  ),
            ),

            _buildDashboardCard(
              context,
              label: "Admin",
              icon: Icons.admin_panel_settings_rounded,
              color: const Color(0xFF1E293B),
              iconColor: Colors.orangeAccent,
              onPressed: () =>
                  context.push(
                    RouterDestinations.companies.url,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
