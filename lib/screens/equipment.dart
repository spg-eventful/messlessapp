import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:messless/widgets/msls_appbar.dart';
import 'package:messless/ws/schema/equipment/equipment.dart';

import '../router.dart';
import '../ws/backend_client.dart';

class EquipmentScreen extends StatefulWidget {
  const EquipmentScreen({super.key});

  @override
  State<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends State<EquipmentScreen> {
  late Future<List<Equipment>> equipmentFuture;

  @override
  void initState() {
    super.initState();
    equipmentFuture = getEquipment();
  }

  final List<int> colorCodes = <int>[600, 500, 100];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MslsAppbar(),
      body: FutureBuilder<List<Equipment>>(
        future: equipmentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (!snapshot.hasData) {
            return const Text('No data');
          }

          final equipmentList = snapshot.data!;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: equipmentList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      clipBehavior: Clip.hardEdge,
                      child: InkWell(
                        onTap: () => context.pushNamed(
                          "Equipment Details",
                          pathParameters: {"id": equipmentList[index].id.toString()}
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(equipmentList[index].label),
                              subtitle: Text(
                                "Location: ${equipmentList[index].longitude}, ${equipmentList[index].latitude}",
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) =>
                      const SizedBox(height: 2),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    child:  FloatingActionButton(
                        child: Icon(Icons.add),
                        onPressed: () => context.push(RouterDestinations.addEquipment.url)
                    )
                  ),
                  Padding(padding: EdgeInsets.all(10))
                ]
              ),
              Padding(padding: EdgeInsets.all(10))
            ],
          );
        },
      ),
    );
  }

  Future<List<Equipment>> getEquipment() async {
    var equipmentResponse = await BackendClient.service("equipments").find();

    if (equipmentResponse.body == null ||
        equipmentResponse.body.toString().isEmpty) {
      return [];
    }

    List<dynamic> jsonList = jsonDecode(equipmentResponse.body.toString());

    List<Equipment> equipment = jsonList
        .map((json) => Equipment.fromJson(json))
        .toList();

    return equipment;
  }
}
