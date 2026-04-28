import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:messless/screens/equipment/utils/fetch_equipment_details.dart';
import 'package:messless/widgets/msls_appbar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class EquipmentDetailsScreen extends StatefulWidget {
  final int equipmentId;

  const EquipmentDetailsScreen({super.key, required this.equipmentId});

  @override
  State<EquipmentDetailsScreen> createState() => _EquipmentDetailsScreenState();
}

class _EquipmentDetailsScreenState extends State<EquipmentDetailsScreen> {
  final MapController mapController = MapController();
  late Future<EquipmentDetailsData> _dataFuture;
  LatLng? _markerLocation;

  @override
  void initState() {
    super.initState();
    _dataFuture = EquipmentDetailsData.loadData(widget.equipmentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MslsAppbar(
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'show_qr') {
                _showQRDialog(context, widget.equipmentId);
              } else if (value == 'share_qr') {
                _exportQrCode(context, widget.equipmentId);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'show_qr',
                child: ListTile(
                  leading: Icon(Icons.qr_code),
                  title: Text('QR-Code anzeigen'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'share_qr',
                child: ListTile(
                  leading: Icon(Icons.share),
                  title: Text('QR-Code teilen'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<EquipmentDetailsData>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No data'));
          }

          final equipment = snapshot.data!.equipment;
          final warehouse = snapshot.data!.warehouse;
          final technicalLogEntries = snapshot.data!.technicalLogEntries ?? [];

          final displayLocation =
              _markerLocation ??
              LatLng(equipment.latitude, equipment.longitude);

          return Column(
            children: [
              SizedBox(
                height: 250,
                child: FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: displayLocation,
                    initialZoom: 13.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      userAgentPackageName:
                          'at.ilja_busch.pre.eventful.messless',
                    ),
                    MarkerLayer(
                      key: ValueKey(displayLocation),
                      markers: [
                        Marker(
                          point: displayLocation,
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

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      equipment.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _CompactInfo(
                          label: 'Lat',
                          value: equipment.latitude.toStringAsFixed(4),
                        ),
                        const SizedBox(width: 12),
                        _CompactInfo(
                          label: 'Lon',
                          value: equipment.longitude.toStringAsFixed(4),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _CompactInfo(
                            label: 'Warehouse',
                            value: warehouse.label,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
                  itemCount: technicalLogEntries.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    final log = technicalLogEntries[index];
                    return Card(
                      elevation: 1,
                      margin: EdgeInsets.zero,
                      clipBehavior: Clip.hardEdge,
                      child: InkWell(
                        onTap: () {
                          final newLoc = LatLng(log.latitude, log.longitude);
                          mapController.move(newLoc, 15.0);
                          setState(() => _markerLocation = newLoc);
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: log.isCheckIn
                                ? Colors.green.withAlpha(40)
                                : Colors.orange.withAlpha(40),
                            child: Icon(
                              log.isCheckIn ? Icons.login : Icons.logout,
                              color: log.isCheckIn
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                          title: Text(
                            log.userFullName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(log.isCheckIn ? 'Check-In' : 'Check-Out'),
                              Text(
                                DateFormat(
                                  'dd.MM.yyyy, HH:mm',
                                ).format(DateTime.parse(log.createdAt)),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.chevron_right, size: 20),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          context.pushNamed(
                            "Add Technical Log Entry",
                            pathParameters: {
                              "id": widget.equipmentId.toString(),
                            },
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Neuer Log'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      onPressed: () {
                        context.pushNamed(
                          "Edit Equipment",
                          pathParameters: {"id": widget.equipmentId.toString()},
                        );
                      },
                      icon: const Icon(Icons.edit),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showQRDialog(BuildContext context, int equipmentId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Equipment QR-Code",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: QrImageView(
                  data: equipmentId.toString(),
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Schließen"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportQrCode(BuildContext context, int equipmentId) async {
    try {
      final qrValidationResult = QrValidator.validate(
        data: equipmentId.toString(),
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );

      if (qrValidationResult.status == QrValidationStatus.valid) {
        final qrCode = qrValidationResult.qrCode!;
        final painter = QrPainter.withQr(
          qr: qrCode,
          eyeStyle: const QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: ui.Color(0xFF000000),
          ),
          dataModuleStyle: const QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: ui.Color(0xFF000000),
          ),
          gapless: true,
        );

        final imageData = await painter.toImageData(1024);
        if (imageData == null) return;

        // Erstelle ein Bild mit weißem Hintergrund, um Transparenz-Probleme (z.B. in WhatsApp) zu vermeiden
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        final paint = Paint()..color = Colors.white;
        canvas.drawRect(const Rect.fromLTWH(0, 0, 1024, 1024), paint);

        final codec = await ui.instantiateImageCodec(imageData.buffer.asUint8List());
        final frame = await codec.getNextFrame();
        canvas.drawImage(frame.image, Offset.zero, Paint());

        final finalImage = await recorder.endRecording().toImage(1024, 1024);
        final finalByteData = await finalImage.toByteData(format: ui.ImageByteFormat.png);
        if (finalByteData == null) return;

        final tempDir = await getTemporaryDirectory();
        final file = await File('${tempDir.path}/qr_$equipmentId.png').create();
        await file.writeAsBytes(finalByteData.buffer.asUint8List());

        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path)],
            text: 'QR-Code für Equipment ID: $equipmentId',
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Export: $e')),
        );
      }
    }
  }
}

class _CompactInfo extends StatelessWidget {
  final String label;
  final String value;

  const _CompactInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
