import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:messless/widgets/msls_location_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:messless/widgets/msls_appbar.dart';
import 'package:messless/ws/schema/equipment_storage/equipment_storage.dart';
import 'package:messless/ws/schema/event/event.dart';
import 'package:messless/ws/schema/warehouse/warehouse.dart';

import '../../../ws/backend_client.dart';

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
  bool isCheckIn = true;

  int? _belongsTo;
  bool isFormValid = false;

  late Future<Map<LoggableType, List<dynamic>>> _dataFuture;

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
                      initialValue: _belongsTo,
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
                          if (newId != null) {
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
                    const SizedBox(height: 12),
                    if (_belongsTo != null)
                      Builder(
                        builder: (context) {
                          final item = currentList.firstWhere(
                            (e) => e.id == _belongsTo,
                          );
                          final isLocked =
                              _selectedType == LoggableType.warehouse ||
                              _selectedType == LoggableType.equipmentStorage;

                          return MslsLocationPicker(
                            latitudeController: _latitudeController,
                            longitudeController: _longitudeController,
                            isLocked: isLocked,
                            targetLocation: LatLng(
                              item.latitude,
                              item.longitude,
                            ),
                            targetLabel: item.label,
                          );
                        },
                      )
                    else
                      const Center(
                        child: Text("Bitte zuerst ein Ziel auswählen."),
                      ),

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
      final latText = _latitudeController.text.replaceAll(',', '.');
      final lngText = _longitudeController.text.replaceAll(',', '.');

      await BackendClient.service("technical-log-entries").create(
        jsonEncode({
          "attachedTo": widget.equipmentId,
          "isCheckIn": isCheckIn,
          "loggable": _belongsTo,
          "latitude": double.tryParse(latText),
          "longitude": double.tryParse(lngText),
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
}
