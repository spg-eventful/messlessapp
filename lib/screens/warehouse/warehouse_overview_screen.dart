import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:messless/screens/company/company_ws.dart';
import 'package:messless/ws/helper.dart';

import '../../ws/schema/company/company.dart';
import '../../ws/schema/warehouse/warehouse.dart';
import 'warehouse_ws.dart';

class WarehousesScreen extends StatefulWidget {
  const WarehousesScreen({super.key});

  @override
  State<WarehousesScreen> createState() => _WarehousesScreenState();
}

class _WarehousesScreenState extends State<WarehousesScreen> {
  int? _selectedCompanyId;
  late Future<List<Warehouse>> _warehousesFuture;

  bool get _isAdminSelectingCompany =>
      HelperWs.isAdmin && _selectedCompanyId == null;

  @override
  void initState() {
    super.initState();
    _warehousesFuture = WarehouseWs.findAll();
  }

  void _reloadWarehouses() {
    setState(() {
      _warehousesFuture = Future.value(null).then((_) => WarehouseWs.findAll());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isAdminSelectingCompany ? 'Select Company' : 'Warehouses'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (HelperWs.isAdmin && _selectedCompanyId == null) {
              context.pop();
            } else if (HelperWs.isAdmin) {
              setState(() {
                _selectedCompanyId = null;
                HelperWs.clearActiveCompanyId();
              });
            } else {
              context.pop();
            }
          },
        ),
      ),

      body: _isAdminSelectingCompany ? _buildCompanies() : _buildWarehouses(),

      floatingActionButton:
          !_isAdminSelectingCompany && HelperWs.isManagerOrHigher
          ? FloatingActionButton(
              onPressed: () async {
                final result = await context.push('/warehouses/new');

                if (result == true) {
                  _reloadWarehouses();
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildCompanies() {
    return FutureBuilder<List<Company>>(
      future: CompanyWs.find(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final companies = snapshot.data!;

        companies.sort((a, b) =>
            a.label.toLowerCase().compareTo(b.label.toLowerCase()));

        return ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: companies.length,
          separatorBuilder: (_, __) => const SizedBox(height: 2),
          itemBuilder: (context, index) {
            final c = companies[index];
            final id = c.id;
            final name = c.label ?? 'Company #$id';

            return Card(
              clipBehavior: Clip.hardEdge,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedCompanyId = id;
                    HelperWs.setActiveCompanyId(id);
                    _warehousesFuture = WarehouseWs.findAll();
                  });
                },
                child: ListTile(
                  title: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Position: ${c.latitude.toStringAsFixed(2)}, ${c.longitude.toStringAsFixed(2)}",
                  ),
                  trailing: const Icon(Icons.chevron_right),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWarehouses() {
    return FutureBuilder<List<Warehouse>>(
      future: _warehousesFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final all = snapshot.data!;
        final companyId = HelperWs.activeCompanyId;

        final warehouses = all.where((w) {
          return w.company == companyId;
        }).toList();

        if (warehouses.isEmpty) {
          return const Center(child: Text('Keine Warehouses gefunden.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: warehouses.length,
          separatorBuilder: (_, __) => const SizedBox(height: 2),
          itemBuilder: (context, index) {
            final w = warehouses[index];

            return Card(
              clipBehavior: Clip.hardEdge,
              child: InkWell(
                onTap: () async {
                  final result = await context.push('/warehouses/${w.id}');

                  if (result == true) {
                    _reloadWarehouses();
                  }
                },
                child: ListTile(
                  title: Text(
                    w.label,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Position: ${w.latitude.toStringAsFixed(2)}, ${w.longitude.toStringAsFixed(2)}",
                  ),
                  trailing: const Icon(Icons.chevron_right),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
