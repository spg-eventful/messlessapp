import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:messless/widgets/msls_location_picker.dart';
import 'package:messless/ws/helper.dart';

import 'warehouse_ws.dart';

class CreateWarehouseScreen extends StatefulWidget {
  final int? warehouseId;

  const CreateWarehouseScreen({super.key, this.warehouseId});

  @override
  State<CreateWarehouseScreen> createState() => _CreateWarehouseScreenState();
}

class _CreateWarehouseScreenState extends State<CreateWarehouseScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  LatLng? _initialTarget;
  late final Future<void> _initFuture;

  bool get isEditMode => widget.warehouseId != null;

  @override
  void initState() {
    super.initState();

    _initFuture = _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (!isEditMode) return;

    final warehouse = await WarehouseWs.getById(widget.warehouseId!);

    _nameController.text = warehouse.label;

    _latController.text = warehouse.latitude.toString();
    _lngController.text = warehouse.longitude.toString();
    _initialTarget = LatLng(warehouse.latitude, warehouse.longitude);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final latText = _latController.text.replaceAll(',', '.');
    final lngText = _lngController.text.replaceAll(',', '.');

    final lat = double.tryParse(latText);
    final lng = double.tryParse(lngText);

    if (lat == null || lng == null) {
      throw StateError("Invalid coordinates");
    }

    final companyId = HelperWs.activeCompanyId;

    if (isEditMode) {
      await WarehouseWs.update(
        id: widget.warehouseId!,
        name: name,
        latitude: lat,
        longitude: lng,
        companyId: companyId,
      );
    } else {
      await WarehouseWs.create(
        name: name,
        latitude: lat,
        longitude: lng,
        companyId: companyId,
      );
    }

    if (mounted) context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditMode ? 'Warehouse bearbeiten' : 'Warehouse erstellen',
        ),
      ),
      body: FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Fehler: ${snapshot.error}'));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Bitte einen Namen eingeben.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    "Standort",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  MslsLocationPicker(
                    latitudeController: _latController,
                    longitudeController: _lngController,
                    targetLocation: _initialTarget,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _save,
                      child: Text(isEditMode ? 'Speichern' : 'Erstellen'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}