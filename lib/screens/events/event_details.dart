import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:messless/screens/events/utils/fetch_event_details.dart';
import 'package:messless/services/history_service.dart';
import 'package:messless/widgets/msls_appbar.dart';

import '../../ws/schema/event/event.dart';

class EventDetailsScreen extends StatefulWidget {
  final int eventId;

  const EventDetailsScreen({super.key, required this.eventId});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  final MapController mapController = MapController();
  late Future<Event> _dataFuture;
  LatLng? _markerLocation;

  @override
  void initState() {
    super.initState();
    _dataFuture = FetchEventDetails.fetchEvent(widget.eventId).then((event) {
      HistoryService().addToHistory(event);
      return event;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MslsAppbar(),
      body: FutureBuilder<Event>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No data'));
          }

          final event = snapshot.data!;

          final displayLocation =
              _markerLocation ??
                  LatLng(event.latitude, event.longitude);

          return Column(
            children: [
              SizedBox(
                height: 250,
                child: FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: displayLocation,
                    initialZoom: 13.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                      "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      userAgentPackageName:
                      'at.ilja_busch.pre.eventful.messless',
                    ),
                    MarkerLayer(
                      key: ValueKey(displayLocation),
                      markers: [
                        Marker(
                          point: displayLocation,
                          width: 48,
                          height: 48,
                          alignment: Alignment.topCenter,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 48.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Theme
                      .of(context)
                      .scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _CompactInfo(
                          label: 'Lat',
                          value: event.latitude.toStringAsFixed(4),
                        ),
                        const SizedBox(width: 12),
                        _CompactInfo(
                          label: 'Lon',
                          value: event.longitude.toStringAsFixed(4),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          context.pushNamed(
                            "Event Edit",
                            pathParameters: {
                              "id": widget.eventId.toString(),
                            },
                          );
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Event bearbeiten'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CompactInfo extends StatelessWidget {
  final String label;
  final String value;

  const _CompactInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
