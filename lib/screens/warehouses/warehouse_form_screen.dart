import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'warehouse_ws.dart';

class WarehouseFormScreen extends StatefulWidget {
  final int? warehouseId;

  const WarehouseFormScreen({super.key, this.warehouseId});

  @override
  State<WarehouseFormScreen> createState() => _WarehouseFormScreenState();
}

class _WarehouseFormScreenState extends State<WarehouseFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  int? _selectedCompanyId;
  late final Future<List<Map<String, dynamic>>> _companiesFuture;

  late final Future<void> _initFuture;

  bool get isEditMode => widget.warehouseId != null;

  @override
  void initState() {
    super.initState();

    _companiesFuture = _loadCompanies();
    _initFuture = _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (!isEditMode) return;

    final warehouse = await WarehouseWs.getById(widget.warehouseId!);

    _nameController.text = WarehouseWs.titleOf(warehouse);

    _latController.text = (warehouse['latitude'] ?? '').toString();
    _lngController.text = (warehouse['longitude'] ?? '').toString();
  }

  Future<List<Map<String, dynamic>>> _loadCompanies() {
    return WarehouseWs.findCompanies();
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
    final lat = double.tryParse(_latController.text.trim());
    final lng = double.tryParse(_lngController.text.trim());

    if (lat == null || lng == null) {
      throw StateError("Invalid coordinates");
    }

    final companyId = WarehouseWs.activeCompanyId;

    if (companyId == null) {
      throw StateError('Keine Company ausgewählt');
    }

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

    if (mounted) context.pop();
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

                  TextFormField(
                    controller: _latController,
                    decoration: const InputDecoration(
                      labelText: 'Latitude',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Latitude erforderlich';
                      }

                      final parsed = double.tryParse(value);
                      if (parsed == null) return 'Ungültige Zahl';

                      if (parsed < -90 || parsed > 90) {
                        return 'Muss zwischen -90 und 90 sein';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _lngController,
                    decoration: const InputDecoration(
                      labelText: 'Longitude',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Longitude erforderlich';
                      }

                      final parsed = double.tryParse(value);
                      if (parsed == null) return 'Ungültige Zahl';

                      if (parsed < -180 || parsed > 180) {
                        return 'Muss zwischen -180 und 180 sein';
                      }

                      return null;
                    },
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
