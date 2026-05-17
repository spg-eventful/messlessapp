import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:messless/screens/events/utils/fetch_event_details.dart';
import 'package:messless/widgets/msls_appbar.dart';

import '../../ws/backend_client.dart';
import '../../ws/schema/company/company.dart';
import '../warehouses/warehouse_ws.dart';

enum LocationMode { currentLocation, manual }

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
  bool _isLocationLoading = false;

  late Future<List<Company>> _companies;

  LocationMode _selectedMode = LocationMode.currentLocation;

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
          _selectedMode = LocationMode.manual;
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
      final body = {
        "label": _labelController.text,
        "latitude": double.tryParse(_latitudeController.text),
        "longitude": double.tryParse(_longitudeController.text),
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
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "Lat: ${_latitudeController.text}, Lng: ${_longitudeController.text}",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _latitudeController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Lat',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Pflichtfeld' : null,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            controller: _longitudeController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Lng',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Pflichtfeld' : null,
          ),
        ),
      ],
    );
  }
}
