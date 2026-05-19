import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:messless/screens/events/utils/fetch_event_details.dart';
import 'package:messless/widgets/msls_appbar.dart';

import '../../services/user_role.dart';
import '../../widgets/msls_location_picker.dart';
import '../../ws/backend_client.dart';
import '../../ws/schema/company/company.dart';
import '../warehouses/warehouse_ws.dart';

class AddEventsScreen extends StatefulWidget {
  final int? eventId;

  const AddEventsScreen({super.key, this.eventId});

  @override
  State<AddEventsScreen> createState() => _AddEventsScreenState();
}

class _AddEventsScreenState extends State<AddEventsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _companyIdController = TextEditingController();

  late Future<List<Company>> _companies;

  LatLng? _initialTarget;

  @override
  void initState() {
    super.initState();
    _companies = WarehouseWs.findCompanies();
    if (widget.eventId != null) {
      _loadEventData();
    }
  }

  Future<void> _loadEventData() async {
    try {
      final fetchedEvent = await FetchEventDetails.fetchEvent(widget.eventId!);
      if (mounted) {
        setState(() {
          _labelController.text = fetchedEvent.label;
          _latitudeController.text = fetchedEvent.latitude.toString();
          _longitudeController.text = fetchedEvent.longitude.toString();
          _initialTarget = LatLng(
            fetchedEvent.latitude,
            fetchedEvent.longitude,
          );
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Laden des Events: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _companyIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditMode = widget.eventId != null;

    return Scaffold(
      appBar: const MslsAppbar(),
      body: SingleChildScrollView(
        child: FutureBuilder<List<Company>>(
          future: _companies,
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

            final companies = snapshot.data ?? [];

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
                        labelText: "Bezeichnung / Name",
                        hintText: 'z. B. Spenger Rave',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.label_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Bitte geben Sie einen Namen ein!';
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
                      latitudeController: _latitudeController,
                      longitudeController: _longitudeController,
                    ),
                    const SizedBox(height: 16),

                    if (UserRole.isAdmin)
                      DropdownButtonFormField<int>(
                        initialValue: int.tryParse(_companyIdController.text),
                        items: companies.map((Company company) {
                          return DropdownMenuItem<int>(
                            value: company.id,
                            child: Text(company.label),
                          );
                        }).toList(),
                        onChanged: (int? newId) {
                          setState(
                            () => _companyIdController.text = newId.toString(),
                          );
                        },
                        decoration: const InputDecoration(
                          labelText: 'Company',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.business),
                        ),
                        validator: (value) {
                          if (value == null) {
                            return 'Bitte wählen Sie eine Company aus!';
                          }
                          return null;
                        },
                      ),
                    const SizedBox(height: 32),

                    FilledButton.icon(
                      onPressed: (_formKey.currentState?.validate() ?? false)
                          ? submitEvent
                          : null,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.all(16.0),
                      ),
                      icon: Icon(isEditMode ? Icons.update : Icons.save),
                      label: Text(
                        isEditMode ? "Event Aktualisieren" : "Event Speichern",
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

  void submitEvent() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final latText = _latitudeController.text.replaceAll(',', '.');
      final lngText = _longitudeController.text.replaceAll(',', '.');

      final body = {
        "label": _labelController.text,
        "latitude": double.tryParse(latText),
        "longitude": double.tryParse(lngText),
        "companyId": int.tryParse(_companyIdController.text),
      };

      if (widget.eventId == null) {
        await BackendClient.service("events").create(jsonEncode(body));
      } else {
        body["\$id"] = widget.eventId;
        await BackendClient.service("events").update(jsonEncode(body));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.eventId == null
                  ? 'Event erfolgreich erstellt'
                  : 'Event erfolgreich aktualisiert',
            ),
          ),
        );
        context.go("/events");
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
