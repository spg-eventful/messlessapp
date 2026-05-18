import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:messless/widgets/msls_appbar.dart';

import '../../ws/backend_client.dart';
import '../../ws/schema/company/company.dart';
import '../company/company_ws.dart';
import '../warehouse/warehouse_ws.dart';

enum LocationMode { currentLocation, manual }

class AddEventsScreen extends StatefulWidget {
  const AddEventsScreen({super.key});

  @override
  State<AddEventsScreen> createState() => _AddEventsScreenState();
}

class _AddEventsScreenState extends State<AddEventsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _companyIdController = TextEditingController();
  bool _isLocationLoading = false;

  late Future<List<Company>> _companies;

  LocationMode _selectedMode = LocationMode.currentLocation;

  @override
  void initState() {
    super.initState();
    _companies = CompanyWs.find();
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

                    const SizedBox(height: 32),

                    SegmentedButton<LocationMode>(
                      segments: [
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
                          if (_selectedMode == LocationMode.currentLocation) {
                            fetchAndSetLocation();
                          }
                        });
                      },
                    ),

                    const SizedBox(height: 16),
                    _buildLocationInput(),

                    const SizedBox(height: 16),

                    if (WarehouseWs.isAdmin)
                      DropdownButtonFormField(
                        items: companies.map((Company warehouse) {
                          return DropdownMenuItem<int>(
                            value: warehouse.id,
                            child: Text(warehouse.label),
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
                            return 'Bitte wählen Sie ein Lager aus!';
                          }
                          return null;
                        },
                      ),
                    const SizedBox(height: 16),

                    FilledButton.icon(
                      onPressed: (_formKey.currentState?.validate() ?? false)
                          ? submitEvent
                          : null,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.all(16.0),
                      ),
                      icon: const Icon(Icons.save),
                      label: const Text("Equipment Speichern"),
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
      await BackendClient.service("events").create(
        jsonEncode({
          "label": _labelController.text,
          "latitude": double.tryParse(_latitudeController.text),
          "longitude": double.tryParse(_longitudeController.text),
          "companyId": int.tryParse(_companyIdController.text),
        }),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event erfolgreich erstellt')),
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

  Future<void> fetchAndSetLocation() async {
    setState(() => _isLocationLoading = true);
    try {
      final position = await Geolocator.getCurrentPosition();
      _latitudeController.text = position.latitude.toString();
      _longitudeController.text = position.longitude.toString();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLocationLoading = false);
    }
  }

  Widget _buildLocationInput() {
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
