import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import 'warehouse_ws.dart';

class WarehouseDetailScreen extends StatefulWidget {
  final int warehouseId;

  const WarehouseDetailScreen({super.key, required this.warehouseId});

  @override
  State<WarehouseDetailScreen> createState() => _WarehouseDetailScreenState();
}

class _WarehouseDetailScreenState extends State<WarehouseDetailScreen> {
  bool _isEditing = false;

  final _nameController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  final MapController mapController = MapController();

  @override
  void dispose() {
    _nameController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _save(int id) async {
    final name = _nameController.text.trim();
    final lat = double.parse(_latController.text);
    final lng = double.parse(_lngController.text);

    await WarehouseWs.update(
      id: id,
      name: name,
      latitude: lat,
      longitude: lng,
      companyId: WarehouseWs.activeCompanyId,
    );

    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Warehouse Details'),
        actions: [
          if (WarehouseWs.isManagerOrHigher)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final id = widget.warehouseId;

                await WarehouseWs.delete(id);

                if (context.mounted) {
                  context.pop(true);
                }
              },
            ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: WarehouseWs.getById(widget.warehouseId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final w = snapshot.data!;
          final id = WarehouseWs.idOf(w);
          final name = WarehouseWs.titleOf(w);
          final latRaw = w['latitude'];
          final lngRaw = w['longitude'];

          final lat = (latRaw is num) ? latRaw.toDouble() : null;
          final lng = (lngRaw is num) ? lngRaw.toDouble() : null;

          final hasCoordinates = lat != null && lng != null;

          if (!_isEditing) {
            _nameController.text = name;
            _latController.text = lat.toString();
            _lngController.text = lng.toString();
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Warehouse #$id",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                if (hasCoordinates)
                  SizedBox(
                    height: 250,
                    child: FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        initialCenter: LatLng(lat!, lng!),
                        initialZoom: 13,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                          userAgentPackageName:
                              'at.ilja_busch.pre.eventful.messless',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(lat!, lng!),
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
                  )
                else
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text("Kein Standort verfügbar"),
                  ),

                const SizedBox(height: 16),
                if (WarehouseWs.isManagerOrHigher)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          setState(() => _isEditing = !_isEditing);
                        },
                        child: Text(_isEditing ? "Abbrechen" : "Bearbeiten"),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                if (_isEditing)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: "Name"),
                        ),
                        TextField(
                          controller: _latController,
                          decoration: const InputDecoration(
                            labelText: "Latitude",
                          ),
                        ),
                        TextField(
                          controller: _lngController,
                          decoration: const InputDecoration(
                            labelText: "Longitude",
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () => _save(id),
                            child: const Text("Speichern"),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
