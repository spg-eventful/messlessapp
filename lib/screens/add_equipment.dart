import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:messless/widgets/msls_appbar.dart';
import 'package:messless/ws/schema/warehouse/warehouse.dart';

import '../ws/backend_client.dart';

enum LocationMode { warehouse, currentLocation, manual }

class AddEquipmentScreen extends StatefulWidget {
  const AddEquipmentScreen({super.key});

  @override
  State<AddEquipmentScreen> createState() => _AddEquipmentScreenState();
}

class _AddEquipmentScreenState extends State<AddEquipmentScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  int? _belongsTo;
  bool isFormValid = false;
  bool _isLocationLoading = false;
  LocationMode _selectedMode = LocationMode.warehouse;
  late Future<List<Warehouse>> _warehouses;

  @override
  void initState() {
    super.initState();
    _labelController.addListener(updateFormValidState);
    _latitudeController.addListener(updateFormValidState);
    _longitudeController.addListener(updateFormValidState);
    _warehouses = getWarehouses();
  }

  void updateFormValidState() => setState(() {
    isFormValid = _formKey.currentState!.validate();
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MslsAppbar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FutureBuilder<List<Warehouse>>(
              future: _warehouses,
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

                final warehouses = snapshot.data!;

                return Form(
                  key: _formKey,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextFormField(
                          controller: _labelController,
                          decoration: InputDecoration(
                            hintText: 'Name eingeben',
                            border: OutlineInputBorder(),
                            label: Text("Label"),
                          ),
                          validator: (String? value) {
                            if (value == null) {
                              return 'Bitte geben Sie einen Label ein!';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 8),
                        const Text(
                          "Standort",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),

                        SegmentedButton(
                          segments: const [
                            ButtonSegment(
                              value: LocationMode.warehouse,
                              label: Text("Lager"),
                              icon: Icon(Icons.warehouse_rounded),
                            ),
                            ButtonSegment(
                              value: LocationMode.currentLocation,
                              label: Text("Aktueller Standort"),
                              icon: Icon(Icons.location_searching),
                            ),
                            ButtonSegment(
                              value: LocationMode.manual,
                              label: Text("Manuell"),
                              icon: Icon(Icons.edit),
                            ),
                          ],
                          selected: {_selectedMode},
                          onSelectionChanged: (Set<LocationMode> newSelection) {
                            setState(() {
                              _selectedMode = newSelection.first;
                              if (_selectedMode == LocationMode.warehouse) {
                                _updateControllersWithWarehouseLocation();
                              } else if (_selectedMode == LocationMode.manual) {
                                _latitudeController.clear();
                                _longitudeController.clear();
                              }
                            });
                          },
                        ),
                        SizedBox(height: 8),
                        _buildDynamicLocationUI(),
                        SizedBox(height: 8),

                        DropdownButtonFormField<int>(
                          initialValue: _belongsTo,
                          decoration: InputDecoration(
                            labelText: 'Lager auswählen',
                            border: OutlineInputBorder(),
                          ),
                          items: warehouses.map((Warehouse warehouse) {
                            return DropdownMenuItem<int>(
                              value: warehouse.id,
                              child: Text(warehouse.label),
                            );
                          }).toList(),
                          onChanged: (int? newId) {
                            setState(() {
                              _belongsTo = newId;
                            });
                            if (_selectedMode == LocationMode.warehouse) {
                              _updateControllersWithWarehouseLocation();
                            }
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Bitte wählen Sie einen Lager aus!';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isFormValid
                                    ? () {
                                  submitEquipment();
                                }
                                    : null,
                                child: const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text("Equipment Speichern"),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicLocationUI() {
    switch (_selectedMode) {
      case LocationMode.warehouse:
        return Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text("Das Equipment übernimmt die Daten des Warehouse"),
        );
      case LocationMode.currentLocation:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OutlinedButton.icon(
              onPressed: _isLocationLoading ? null : fetchAndSetLocation,
              icon: _isLocationLoading
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.location_searching),
              label: Text(
                _isLocationLoading
                    ? "Standort wird bestimmt"
                    : "Standort jetzt bestimmen",
              ),
            ),
            if (_latitudeController.text.isNotEmpty &&
                _longitudeController.text.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  "Gefunden: Lat ${_latitudeController.text}, Lng ${_longitudeController.text}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        );
      case LocationMode.manual:
        return Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _latitudeController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Latitude',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _longitudeController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Longitude',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        );
    }
  }

  Future<void> fetchAndSetLocation() async {
    setState(() => _isLocationLoading = true);

    try {
      Position position = await _determinePosition();

      _latitudeController.text = position.latitude.toString();
      _longitudeController.text = position.longitude.toString();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isLocationLoading = false);
      }
    }
  }

  Future<List<Warehouse>> getWarehouses() async {
    var equipmentResponse = await BackendClient.service("warehouse").find();
    if (equipmentResponse.body == null ||
        equipmentResponse.body.toString().isEmpty) {
      return [];
    }

    List<dynamic> jsonList = jsonDecode(equipmentResponse.body.toString());

    List<Warehouse> equipment = jsonList
        .map((json) => Warehouse.fromJson(json))
        .toList();

    return equipment;
  }

  void submitEquipment() async {
    if (!_formKey.currentState!.validate()) return;
    double latitude = double.parse(_latitudeController.text);
    double longitude = double.parse(_longitudeController.text);
    try {
      await BackendClient.service("equipments").create(
        jsonEncode({
          "label": _labelController.text,
          "longitude": longitude,
          "latitude": latitude,
          "belongsToWarehouse": _belongsTo,
          "equipmentStorage": null,
        }),
      );
      if (mounted) {
        context.go("/equipment");
      }
    } catch (e) {
      final snackBar = SnackBar(content: const Text('Ungültiges Equipment'));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      return;
    }
  }

  Future<void> _updateControllersWithWarehouseLocation() async {
    if (_belongsTo != null) {
      try {
        final resolvedWarehouses = await _warehouses;

        final selectedWarehouse = resolvedWarehouses.firstWhere(
              (w) => w.id == _belongsTo,
        );

        _latitudeController.text = selectedWarehouse.latitude.toString();
        _longitudeController.text = selectedWarehouse.longitude.toString();
      } catch (e) {
        _latitudeController.clear();
        _longitudeController.clear();
      }
    } else {
      _latitudeController.clear();
      _longitudeController.clear();
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    return await Geolocator.getCurrentPosition();
  }
}