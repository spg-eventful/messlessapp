import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:messless/screens/company/company_ws.dart';
import 'package:messless/widgets/msls_location_picker.dart';
import 'package:messless/ws/helper.dart';
import 'package:messless/ws/schema/company/company.dart';

class CompanyDetailScreen extends StatefulWidget {
  final int companyId;

  const CompanyDetailScreen({super.key, required this.companyId});

  @override
  State<CompanyDetailScreen> createState() => _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends State<CompanyDetailScreen> {
  bool _isEditing = false;
  bool _isDataChanged = false;

  late Future<Company> _companyFuture;

  final _nameController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  final MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    _companyFuture = CompanyWs.getById(widget.companyId);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _save(int id) async {
    final name = _nameController.text.trim();
    final latText = _latController.text.replaceAll(',', '.');
    final lngText = _lngController.text.replaceAll(',', '.');

    final lat = double.parse(latText);
    final lng = double.parse(lngText);

    await CompanyWs.update(
      id: id,
      name: name,
      latitude: lat,
      longitude: lng,
    );

    setState(() {
      _isEditing = false;
      _isDataChanged = true;
      _companyFuture = CompanyWs.getById(widget.companyId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop(_isDataChanged);
          },
        ),
        actions: [
          if (HelperWs.isManagerOrHigher)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final id = widget.companyId;

                await CompanyWs.delete(id);

                if (context.mounted) {
                  context.pop(true);
                }
              },
            ),
        ],
      ),
      body: FutureBuilder<Company>(
        future: _companyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Fehler beim Laden der Details'));
          }

          final company = snapshot.data!;
          final id = company.id;
          final name = company.label;
          final lat = company.latitude;
          final lng = company.longitude;

          if (!_isEditing) {
            _nameController.text = name;
            _latController.text = lat.toString();
            _lngController.text = lng.toString();
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme
                            .of(context)
                            .textTheme
                            .headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Company #$id",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: 250,
                  child: FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      initialCenter: LatLng(lat, lng),
                      initialZoom: 13,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                        userAgentPackageName: 'at.ilja_busch.pre.eventful.messless',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(lat, lng),
                            width: 48,
                            height: 48,
                            alignment: Alignment.topCenter,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 48.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                if (HelperWs.isManagerOrHigher)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          setState(() => _isEditing = !_isEditing);
                        },
                        child: Text(_isEditing ? "Abbrechen" : "Bearbeiten"),
                      ),
                    ),
                  ),

                if (_isEditing)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: "Company Name",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        MslsLocationPicker(
                          latitudeController: _latController,
                          longitudeController: _lngController,
                          targetLocation: LatLng(lat, lng),
                        ),
                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () => _save(id),
                            child: const Text("Speichern"),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}