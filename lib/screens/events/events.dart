import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:messless/widgets/msls_appbar.dart';

import '../../ws/backend_client.dart';
import '../../ws/schema/event/event.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  late Future<List<Event>> equipmentFuture;

  @override
  void initState() {
    super.initState();
    equipmentFuture = getEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MslsAppbar(),
      body: FutureBuilder<List<Event>>(
        future: equipmentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Keine Events gefunden'));
          }

          final equipmentList = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: equipmentList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 2),
            itemBuilder: (context, index) {
              final item = equipmentList[index];
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/events/add'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<List<Event>> getEvents() async {
    var response = await BackendClient.service("events").find();

    if (response.body == null || response.body.toString().isEmpty) return [];

    List<dynamic> jsonList = jsonDecode(response.body.toString());
    return jsonList.map((json) => Event.fromJson(json)).toList();
  }
}
