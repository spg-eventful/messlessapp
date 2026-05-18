import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

enum MslsLocationMode { map, currentLocation, manual, target }

class MslsLocationPicker extends StatefulWidget {
  final TextEditingController latitudeController;
  final TextEditingController longitudeController;
  final bool isLocked;
  final LatLng? targetLocation;
  final String? targetLabel;

  const MslsLocationPicker({
    super.key,
    required this.latitudeController,
    required this.longitudeController,
    this.isLocked = false,
    this.targetLocation,
    this.targetLabel,
  });

  @override
  State<MslsLocationPicker> createState() => _MslsLocationPickerState();
}

class _MslsLocationPickerState extends State<MslsLocationPicker> {
  late MslsLocationMode _selectedMode;
  final MapController _mapController = MapController();
  bool _isLocationLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.isLocked
        ? MslsLocationMode.target
        : (widget.latitudeController.text.isNotEmpty
              ? MslsLocationMode.manual
              : MslsLocationMode.currentLocation);

    if (_selectedMode == MslsLocationMode.currentLocation) {
      _fetchAndSetLocation();
    }
  }

  Future<void> _fetchAndSetLocation() async {
    setState(() => _isLocationLoading = true);
    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        widget.latitudeController.text = position.latitude.toString();
        widget.longitudeController.text = position.longitude.toString();
      });
      if (_selectedMode == MslsLocationMode.map ||
          _selectedMode == MslsLocationMode.target) {
        _moveMapToCurrent();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Standort konnte nicht abgerufen werden: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLocationLoading = false);
    }
  }

  void _moveMapToCurrent() {
    final latStr = widget.latitudeController.text.replaceAll(',', '.');
    final lngStr = widget.longitudeController.text.replaceAll(',', '.');
    final lat = double.tryParse(latStr);
    final lng = double.tryParse(lngStr);

    if (lat != null && lng != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        try {
          _mapController.move(LatLng(lat, lng), 13.0);
        } catch (e) {
          debugPrint("MapController noch nicht bereit: $e");
        }
      });
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    if (widget.isLocked) return;
    setState(() {
      widget.latitudeController.text = point.latitude.toString();
      widget.longitudeController.text = point.longitude.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLocked) {
      return _buildLockedView();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<MslsLocationMode>(
          segments: [
            if (widget.targetLocation != null)
              const ButtonSegment(
                value: MslsLocationMode.target,
                label: Text("Ziel"),
                icon: Icon(Icons.location_on),
              ),
            const ButtonSegment(
              value: MslsLocationMode.map,
              label: Text("Karte"),
              icon: Icon(Icons.map),
            ),
            const ButtonSegment(
              value: MslsLocationMode.currentLocation,
              label: Text("GPS"),
              icon: Icon(Icons.my_location),
            ),
            const ButtonSegment(
              value: MslsLocationMode.manual,
              label: Text("Manuell"),
              icon: Icon(Icons.edit_location_alt),
            ),
          ],
          selected: {_selectedMode},
          onSelectionChanged: (Set<MslsLocationMode> val) {
            setState(() {
              _selectedMode = val.first;
              if (_selectedMode == MslsLocationMode.target &&
                  widget.targetLocation != null) {
                widget.latitudeController.text = widget.targetLocation!.latitude
                    .toString();
                widget.longitudeController.text = widget
                    .targetLocation!
                    .longitude
                    .toString();
              } else if (_selectedMode == MslsLocationMode.currentLocation) {
                _fetchAndSetLocation();
              }
            });
          },
        ),
        const SizedBox(height: 16),
        _buildActiveModeWidget(),
      ],
    );
  }

  Widget _buildActiveModeWidget() {
    switch (_selectedMode) {
      case MslsLocationMode.map:
      case MslsLocationMode.target:
        return _buildMapView();
      case MslsLocationMode.currentLocation:
        return _buildGPSView();
      case MslsLocationMode.manual:
        return _buildManualView();
    }
  }

  Widget _buildLockedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.targetLabel != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              "Standort fixiert auf: ${widget.targetLabel}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        _buildMapView(interactive: false),
      ],
    );
  }

  Widget _buildMapView({bool interactive = true}) {
    final latStr = widget.latitudeController.text.replaceAll(',', '.');
    final lngStr = widget.longitudeController.text.replaceAll(',', '.');
    final lat = double.tryParse(latStr) ?? widget.targetLocation!.latitude;
    final lng = double.tryParse(lngStr) ?? widget.targetLocation!.longitude;
    final point = LatLng(lat, lng);

    return SizedBox(
      height: 250,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: point,
            initialZoom: 15.0,
            onTap: interactive ? _onMapTap : null,
          ),
          children: [
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              userAgentPackageName: 'at.ilja_busch.pre.eventful.messless',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: point,
                  width: 40,
                  height: 40,
                  alignment: Alignment.topCenter,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGPSView() {
    return Column(
      children: [
        if (_isLocationLoading)
          const Center(child: CircularProgressIndicator())
        else
          OutlinedButton.icon(
            onPressed: _fetchAndSetLocation,
            icon: const Icon(Icons.refresh),
            label: const Text("Aktuellen Standort abrufen"),
          ),
        if (widget.latitudeController.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              "Lat: ${widget.latitudeController.text}, Lng: ${widget.longitudeController.text}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
      ],
    );
  }

  Widget _buildManualView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextFormField(
            controller: widget.latitudeController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Latitude',
              border: OutlineInputBorder(),
              hintText: 'z.B. 48.2',
            ),
            onChanged: (val) => setState(() {}),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Pflichtfeld';
              final clean = value.replaceAll(',', '.');
              final parsed = double.tryParse(clean);
              if (parsed == null) return 'Ungültig';
              if (parsed < -90 || parsed > 90) return '±90° max';
              return null;
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            controller: widget.longitudeController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Longitude',
              border: OutlineInputBorder(),
              hintText: 'z.B. 16.3',
            ),
            onChanged: (val) => setState(() {}),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Pflichtfeld';
              final clean = value.replaceAll(',', '.');
              final parsed = double.tryParse(clean);
              if (parsed == null) return 'Ungültig';
              if (parsed < -180 || parsed > 180) return '±180° max';
              return null;
            },
          ),
        ),
      ],
    );
  }
}
