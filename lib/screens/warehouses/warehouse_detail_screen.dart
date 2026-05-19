import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import 'package:messless/widgets/msls_location_picker.dart';
import 'package:messless/ws/schema/warehouse/warehouse.dart';

import '../../services/user_role.dart';
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
    final latText = _latController.text.replaceAll(',', '.');
    final lngText = _lngController.text.replaceAll(',', '.');

    final lat = double.parse(latText);
    final lng = double.parse(lngText);

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
        title: const Text('warehouse Details'),
        actions: [
          if (UserRole.isManagerOrHigher)
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
      body: FutureBuilder<Warehouse>(
        future: WarehouseWs.getById(widget.warehouseId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final warehouse = snapshot.data!;
          final id = warehouse.id;
          final name = warehouse.label;
          final lat = warehouse.latitude;
          final lng = warehouse.longitude;

          const hasCoordinates = true;

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
                        "warehouse #$id",
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
                        initialCenter: LatLng(lat, lng),
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
                              point: LatLng(lat, lng),
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

                const SizedBox(height: 16),
                if (UserRole.isManagerOrHigher)
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
                          decoration: const InputDecoration(
                            labelText: "Name",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        MslsLocationPicker(
                          latitudeController: _latController,
                          longitudeController: _lngController,
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
