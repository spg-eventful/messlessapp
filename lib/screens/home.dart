import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:messless/router.dart';
import 'package:messless/services/history_service.dart';
import 'package:messless/widgets/msls_appbar.dart';
import 'package:messless/ws/schema/event/event.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MslsAppbar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: _buildHistorySection(context)),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  children: [
                    _buildBigThomasButton(
                      context,
                      label: "Warehouses",
                      icon: Icons.warehouse_rounded,
                      color: const Color(0xFF96d1fb),
                      onPressed: () =>
                          context.push(RouterDestinations.warehouses.url),
                    ),
                    const SizedBox(height: 16),
                    _buildBigThomasButton(
                      context,
                      label: "Events",
                      icon: Icons.festival_rounded,
                      color: const Color(0xFF96d1fb),
                      onPressed: () =>
                          context.push(RouterDestinations.events.url),
                    ),
                    const SizedBox(height: 16),
                    _buildBigThomasButton(
                      context,
                      label: "Equipment",
                      icon: Icons.inventory_2_rounded,
                      color: const Color(0xFF96d1fb),
                      onPressed: () =>
                          context.push(RouterDestinations.equipment.url),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistorySection(BuildContext context) {
    return FutureBuilder<List<Event>>(
      future: HistoryService().getHistory(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No recently accessed events"));
        }

        final recentEvents = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Text(
                "Recently Accessed",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(4),
                itemCount: recentEvents.length,
                separatorBuilder: (context, index) => const SizedBox(height: 2),
                itemBuilder: (context, index) {
                  final item = recentEvents[index];
                  return Card(
                    clipBehavior: Clip.hardEdge,
                    child: InkWell(
                      onTap: () => context.pushNamed(
                        "Event Details",
                        pathParameters: {"id": item.id.toString()},
                      ),
                      child: ListTile(
                        title: Text(
                          item.label,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Position: ${item.latitude.toStringAsFixed(2)}, ${item.longitude.toStringAsFixed(2)}",
                        ),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBigThomasButton(
    BuildContext context, {
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
}
