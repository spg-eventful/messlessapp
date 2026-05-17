import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:messless/screens/equipment/utils/fetch_equipment_details.dart';
import 'package:messless/widgets/msls_appbar.dart';
import 'package:messless/ws/schema/warehouse/warehouse.dart';
import '../../ws/backend_client.dart';

class AddEquipmentScreen extends StatefulWidget {
  final int? equipmentId;

  const AddEquipmentScreen({super.key, this.equipmentId});

  @override
  State<AddEquipmentScreen> createState() => _AddEquipmentScreenState();
}

class _AddEquipmentScreenState extends State<AddEquipmentScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _labelController = TextEditingController();
  bool isEquipmentStorage = false;
  int? _belongsTo;
  late Future<List<Warehouse>> _warehouses;

  @override
  void initState() {
    super.initState();
    _warehouses = getWarehouses();
    if (widget.equipmentId != null) {
      _loadEquipmentData();
    }
  }

  Future<void> _loadEquipmentData() async {
    try {
      final equipment = await EquipmentDetailsData.getEquipment(
        widget.equipmentId!,
      );
      if (mounted) {
        setState(() {
          _labelController.text = equipment.label;
          _belongsTo = equipment.belongsToWarehouse;
          isEquipmentStorage = equipment.storage == null ? false : true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Fehler beim Laden: $e')));
      }
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditMode = widget.equipmentId != null;

    return Scaffold(
      appBar: const MslsAppbar(),
      body: SingleChildScrollView(
        child: FutureBuilder<List<Warehouse>>(
          future: _warehouses,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return Center(child: Text('Fehler: ${snapshot.error}'));
            }

            final warehouses = snapshot.data ?? [];

            return Form(
              key: _formKey,
              onChanged: () => setState(() {}),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextFormField(
                      controller: _labelController,
                      decoration: const InputDecoration(
                        labelText: "Bezeichnung / Label",
                        hintText: 'z.B. Mischpult Yamaha QL5',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.label_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Bitte geben Sie ein Label ein!';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<int>(
                      initialValue: _belongsTo,
                      decoration: const InputDecoration(
                        labelText: 'Standard-Lagerort',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.warehouse_outlined),
                      ),
                      items: warehouses.map((Warehouse warehouse) {
                        return DropdownMenuItem<int>(
                          value: warehouse.id,
                          child: Text(warehouse.label),
                        );
                      }).toList(),
                      onChanged: (int? newId) {
                        setState(() => _belongsTo = newId);
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Bitte wählen Sie ein Lager aus!';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),
                    if (!isEditMode)
                      Column(
                        children: [
                          Material(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                            child: SwitchListTile(
                              title: const Text('Als Equipment-Lager markieren'),
                              subtitle: const Text(
                                'Kann dieses Equipment selbst andere Gegenstände beinhalten? (z.B. ein Case oder Rack)',
                              ),
                              secondary: Icon(
                                isEquipmentStorage
                                    ? Icons.inventory_2
                                    : Icons.inventory_2_outlined,
                                color: isEquipmentStorage
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                              ),
                              value: isEquipmentStorage,
                              onChanged: (bool value) {
                                setState(() {
                                  isEquipmentStorage = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),

                    FilledButton.icon(
                      onPressed: (_formKey.currentState?.validate() ?? false)
                          ? submitEquipment
                          : null,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.all(16.0),
                      ),
                      icon: Icon(isEditMode ? Icons.update : Icons.save),
                      label: Text(
                        isEditMode
                            ? "Equipment Aktualisieren"
                            : "Equipment Speichern",
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<List<Warehouse>> getWarehouses() async {
    final response = await BackendClient.service("warehouses").find();
    if (response.body == null) return [];

    final List<dynamic> jsonList = jsonDecode(response.body.toString());
    return jsonList.map((json) => Warehouse.fromJson(json)).toList();
  }

  void submitEquipment() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final body = {
        "label": _labelController.text,
        "belongsToWarehouse": _belongsTo,
      };

      if (widget.equipmentId == null) {
        body["isStorage"] = isEquipmentStorage;
        await BackendClient.service("equipments").create(jsonEncode(body));
      } else {
        body["\$id"] = widget.equipmentId;
        await BackendClient.service("equipments").update(jsonEncode(body));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.equipmentId == null
                  ? 'Equipment erfolgreich erstellt'
                  : 'Equipment erfolgreich aktualisiert',
            ),
          ),
        );
        context.go("/equipment");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Speichern: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
