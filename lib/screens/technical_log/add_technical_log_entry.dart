import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:messless/widgets/msls_appbar.dart';
import 'package:messless/ws/schema/equipment_storage/equipment_storage.dart';
import 'package:messless/ws/schema/event/event.dart';
import 'package:messless/ws/schema/warehouse/warehouse.dart';

import '../../../ws/backend_client.dart';

enum LocationMode { warehouse, currentLocation, manual }

enum LoggableType { warehouse, event, equipmentStorage }

class AddTechnicalLogEntry extends StatefulWidget {
  final int equipmentId;

  const AddTechnicalLogEntry({super.key, required this.equipmentId});

  @override
  State<AddTechnicalLogEntry> createState() =>
      _AddTechnicalLogEntryScreenState();
}

class _AddTechnicalLogEntryScreenState extends State<AddTechnicalLogEntry> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  LoggableType _selectedType = LoggableType.warehouse;
  LocationMode _selectedMode = LocationMode.currentLocation;
  bool isCheckIn = true;

  int? _belongsTo;
  bool isFormValid = false;

  late Future<Map<LoggableType, List<dynamic>>> _dataFuture;

  bool _isLocationLoading = false;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadAllData();
    WidgetsBinding.instance.addPostFrameCallback((_) => updateFormValidState());
  }

  Future<Map<LoggableType, List<dynamic>>> _loadAllData() async {
    final results = await Future.wait([
      getWarehouses(),
      getEvents(),
      getEquipmentStorages(),
    ]);
    return {
      LoggableType.warehouse: results[0],
      LoggableType.event: results[1],
      LoggableType.equipmentStorage: results[2],
    };
  }

  void updateFormValidState() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (isFormValid != isValid) {
      setState(() => isFormValid = isValid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MslsAppbar(),
      body: FutureBuilder<Map<LoggableType, List<dynamic>>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Fehler: ${snapshot.error}'));
          }

          final allData = snapshot.data!;
          final currentList = allData[_selectedType] ?? [];

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                onChanged: updateFormValidState,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const Text(
                      "Aktion",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: true,
                          label: Text("Check-In"),
                          icon: Icon(Icons.login),
                        ),
                        ButtonSegment(
                          value: false,
                          label: Text("Check-Out"),
                          icon: Icon(Icons.logout),
                        ),
                      ],
                      selected: {isCheckIn},
                      onSelectionChanged: (Set<bool> val) =>
                          setState(() => isCheckIn = val.first),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      "Ziel-Typ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<LoggableType>(
                      segments: const [
                        ButtonSegment(
                          value: LoggableType.warehouse,
                          label: Text("Lager"),
                          icon: Icon(Icons.warehouse),
                        ),
                        ButtonSegment(
                          value: LoggableType.event,
                          label: Text("Event"),
                          icon: Icon(Icons.event),
                        ),
                        ButtonSegment(
                          value: LoggableType.equipmentStorage,
                          label: Text("Depot"),
                          icon: Icon(Icons.inventory),
                        ),
                      ],
                      selected: {_selectedType},
                      onSelectionChanged: (Set<LoggableType> val) {
                        setState(() {
                          _selectedType = val.first;
                          _belongsTo = null;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<int>(
                      key: ValueKey(_selectedType),
                      // Wichtig für Reset bei Typ-Wechsel
                      value: _belongsTo,
                      decoration: InputDecoration(
                        labelText: switch (_selectedType) {
                          LoggableType.warehouse => "Lager auswählen",
                          LoggableType.event => "Event auswählen",
                          LoggableType.equipmentStorage => "Depot auswählen",
                        },
                        border: const OutlineInputBorder(),
                      ),
                      items: currentList.map((item) {
                        return DropdownMenuItem<int>(
                          value: item.id,
                          child: Text(item.label),
                        );
                      }).toList(),
                      onChanged: (int? newId) {
                        setState(() {
                          _belongsTo = newId;
                          if (_selectedMode == LocationMode.warehouse &&
                              newId != null) {
                            final item = currentList.firstWhere(
                              (e) => e.id == newId,
                            );
                            _latitudeController.text = item.latitude.toString();
                            _longitudeController.text = item.longitude
                                .toString();
                          }
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Bitte auswählen!' : null,
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      "Standort",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<LocationMode>(
                      segments: [
                        ButtonSegment(
                          value: LocationMode.warehouse,
                          label: const Text("Vom Ziel"),
                          icon: const Icon(Icons.copy),
                          enabled: _belongsTo != null,
                        ),
                        const ButtonSegment(
                          value: LocationMode.currentLocation,
                          label: Text("Aktuell"),
                          icon: Icon(Icons.my_location),
                        ),
                        const ButtonSegment(
                          value: LocationMode.manual,
                          label: Text("Manuell"),
                          icon: Icon(Icons.edit_location_alt),
                        ),
                      ],
                      selected: {_selectedMode},
                      onSelectionChanged: (Set<LocationMode> val) {
                        setState(() {
                          _selectedMode = val.first;
                          if (_selectedMode == LocationMode.warehouse &&
                              _belongsTo != null) {
                            final item = currentList.firstWhere(
                              (e) => e.id == _belongsTo,
                            );
                            _latitudeController.text = item.latitude.toString();
                            _longitudeController.text = item.longitude
                                .toString();
                          } else if (_selectedMode ==
                              LocationMode.currentLocation) {
                            fetchAndSetLocation();
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildLocationInput(),

                    const SizedBox(height: 40),
                    ElevatedButton.icon(
                      onPressed: isFormValid ? submitLogEntry : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                      ),
                      icon: const Icon(Icons.save),
                      label: Text(
                        isCheckIn
                            ? "Check-In abschließen"
                            : "Check-Out abschließen",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<List<Warehouse>> getWarehouses() async {
    var response = await BackendClient.service("warehouses").find();
    if (response.body == null || response.body.toString().isEmpty) return [];
    List<dynamic> jsonList = jsonDecode(response.body.toString());
    return jsonList.map((json) => Warehouse.fromJson(json)).toList();
  }

  Future<List<Event>> getEvents() async {
    var response = await BackendClient.service("events").find();
    if (response.body == null || response.body.toString().isEmpty) return [];
    List<dynamic> jsonList = jsonDecode(response.body.toString());
    return jsonList.map((json) => Event.fromJson(json)).toList();
  }

  Future<List<EquipmentStorage>> getEquipmentStorages() async {
    var response = await BackendClient.service(
      "equipments",
    ).findWithBody(jsonEncode({"isEquipmentStorage": true}));
    if (response.body == null || response.body.toString().isEmpty) return [];
    List<dynamic> jsonList = jsonDecode(response.body.toString());
    return jsonList.map((json) => EquipmentStorage.fromJson(json)).toList();
  }

  void submitLogEntry() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await BackendClient.service("technical-log-entries").create(
        jsonEncode({
          "attachedTo": widget.equipmentId,
          "isCheckIn": isCheckIn,
          "loggable": _belongsTo,
          "latitude": double.tryParse(_latitudeController.text),
          "longitude": double.tryParse(_longitudeController.text), // Backend-Key mit Tippfehler
        }),
      );
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Fehler beim Speichern')));
      }
    }
  }

  Future<void> fetchAndSetLocation() async {
    setState(() => _isLocationLoading = true);
    try {
      final position = await Geolocator.getCurrentPosition();
      _latitudeController.text = position.latitude.toString();
      _longitudeController.text = position.longitude.toString();
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLocationLoading = false);
    }
  }

  Widget _buildLocationInput() {
    if (_selectedMode == LocationMode.warehouse) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.withAlpha(30),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          "Koordinaten vom Ziel übernommen.",
          textAlign: TextAlign.center,
        ),
      );
    }
    if (_selectedMode == LocationMode.currentLocation) {
      return Column(
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
            label: Text(_isLocationLoading ? "Suche..." : "Standort abrufen"),
          ),
          if (_latitudeController.text.isNotEmpty)
            Text(
              "Lat: ${_latitudeController.text}, Lng: ${_longitudeController.text}",
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _latitudeController,
            decoration: const InputDecoration(
              labelText: 'Lat',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            controller: _longitudeController,
            decoration: const InputDecoration(
              labelText: 'Lng',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }
}
