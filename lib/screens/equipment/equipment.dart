import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:messless/screens/equipment/utils/export_qr_codes.dart';
import 'package:messless/widgets/msls_appbar.dart';
import 'package:messless/ws/schema/equipment/equipment.dart';

import '../../router.dart';
import '../../ws/backend_client.dart';

class EquipmentScreen extends StatefulWidget {
  const EquipmentScreen({super.key});

  @override
  State<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends State<EquipmentScreen> {
  final TextEditingController _searchController = TextEditingController();

  late Future<List<Equipment>> equipmentFuture;
  bool selectState = false;
  bool isSearching = false;
  Set<Equipment> selectedItems = {};

  @override
  void initState() {
    super.initState();
    equipmentFuture = getEquipment();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MslsAppbar(
        title: isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Suchen...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {});
                },
              )
            : selectState
            ? Text('${selectedItems.length} ausgewählt')
            : Text("Equipment"),
        actions: [
          if (selectState)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                ExportQrCodes.exportEquipmentQrCodes(
                  context,
                  selectedItems.toList(),
                );
              },
              tooltip: "QR-Codes exportieren",
            ),
          if (selectState)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  selectedItems.clear();
                  selectState = false;
                });
              },
            ),
          if (!selectState)
            if (!isSearching)
              IconButton(
                onPressed: () {
                  setState(() {
                    isSearching = true;
                  });
                },
                icon: const Icon(Icons.search),
              ),
          if (!selectState)
            if (isSearching)
              IconButton(
                onPressed: () {
                  setState(() {
                    isSearching = false;
                  });
                },
                icon: const Icon(Icons.close),
              ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (selectState) {
            setState(() {
              selectedItems.clear();
              selectState = false;
            });
          }
          if (isSearching) {
            setState(() {
              isSearching = false;
              _searchController.clear();
              FocusScope.of(context).unfocus();
            });
          }
        },
        child: FutureBuilder<List<Equipment>>(
          future: equipmentFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Kein Equipment gefunden'));
            }

            final allItems = snapshot.data!;

            final query = _searchController.text.toLowerCase();
            final equipmentList = isSearching
                ? allItems.where((item) {
                    return item.label.toLowerCase().contains(query);
                  }).toList()
                : allItems;
            if (equipmentList.isEmpty && isSearching) {
              return const Center(
                child: Text("Keine passenden Ergebnisse gefunden"),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: equipmentList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 2),
              itemBuilder: (context, index) {
                final Equipment item = equipmentList[index];
                final bool isSelected = selectedItems.contains(item);
                return Card(
                  clipBehavior: Clip.hardEdge,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                  elevation: isSelected ? 4 : 1,
                  child: InkWell(
                    onTap: () {
                      if (selectState) {
                        setState(() {
                          if (selectedItems.contains(item)) {
                            selectedItems.remove(item);
                            if (selectedItems.isEmpty) selectState = false;
                          } else {
                            selectedItems.add(item);
                          }
                        });
                      } else {
                        context.pushNamed(
                          "Equipment Details",
                          pathParameters: {"id": item.id.toString()},
                        );
                      }
                    },
                    onLongPress: () => setState(() {
                      selectState = true;
                      selectedItems.add(item);
                    }),
                    child: ListTile(
                      selected: isSelected,
                      title: Text(
                        item.label,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "Position: ${item.latitude.toStringAsFixed(2)}, ${item.longitude.toStringAsFixed(2)}",
                      ),
                      trailing: selectState
                          ? (isSelected
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  )
                                : const Icon(Icons.circle_outlined))
                          : const Icon(Icons.chevron_right),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: speedDial(),
    );
  }

  Future<List<Equipment>> getEquipment() async {
    var response = await BackendClient.service(
      "equipments",
    ).findWithBody(jsonEncode({"isEquipmentStorage": false}));

    if (response.body == null || response.body.toString().isEmpty) return [];

    List<dynamic> jsonList = jsonDecode(response.body.toString());
    return jsonList.map((json) => Equipment.fromJson(json)).toList();
  }

  SpeedDial speedDial() {
    final colorScheme = Theme.of(context).colorScheme;

    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      overlayColor: Colors.black,
      overlayOpacity: 0.0,
      spacing: 12,
      spaceBetweenChildren: 12,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.qr_code_scanner),
          backgroundColor: colorScheme.secondaryContainer,
          foregroundColor: colorScheme.onSecondaryContainer,
          label: 'Scannen',
          labelStyle: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface.withValues(alpha: 0.8),
          ),
          labelBackgroundColor: Colors.transparent,
          labelShadow: [],
          shape: const CircleBorder(),
          onTap: () async {
            final String? scannedId = await context.push<String>(
              RouterDestinations.qrScanner.url,
            );
            if (scannedId != null && mounted) {
              context.pushNamed(
                "Equipment Details",
                pathParameters: {"id": scannedId},
              );
            }
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.add),
          backgroundColor: colorScheme.secondaryContainer,
          foregroundColor: colorScheme.onSecondaryContainer,
          label: 'Hinzufügen',
          labelStyle: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface.withValues(alpha: 0.8),
          ),
          labelBackgroundColor: Colors.transparent,
          labelShadow: [],
          shape: const CircleBorder(),
          onTap: () => context.push('/equipment/add'),
        ),
      ],
    );
  }
}
