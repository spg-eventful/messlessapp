import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:messless/widgets/msls_appbar.dart';

import '../ws/backend_client.dart';
import '../ws/schema/equipment/equipment.dart';

class EquipmentDetailsScreen extends StatefulWidget {
  final int equipmentId;

  const EquipmentDetailsScreen({super.key, required this.equipmentId});

  @override
  State<EquipmentDetailsScreen> createState() => _EquipmentDetailsScreenState();
}

class _EquipmentDetailsScreenState extends State<EquipmentDetailsScreen> {
  final MapController mapController = MapController();
  late Future<Equipment> equipmentFuture;

  @override
  void initState() {
    super.initState();
    equipmentFuture = getEquipment();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MslsAppbar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FutureBuilder<Equipment>(
              future: equipmentFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (!snapshot.hasData) {
                  return const Text('No data');
                }

                final equipment = snapshot.data!;

                return Expanded(
                  child: FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      initialCenter: LatLng(
                        equipment.latitude,
                        equipment.longitude,
                      ),
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
                            point: LatLng(equipment.latitude, equipment.longitude),
                            child: Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 48.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<Equipment> getEquipment() async {
    try {
      var equipmentResponse = await BackendClient.service(
        "equipments",
      ).get(widget.equipmentId);

      if (equipmentResponse.body == null ||
          equipmentResponse.body.toString().isEmpty) {
        throw Exception("No data");
      }

      final dynamic json = jsonDecode(equipmentResponse.body.toString()); ;

      final Equipment equipment = Equipment.fromJson(json);

      return equipment;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
      rethrow;
    }
  }
}
