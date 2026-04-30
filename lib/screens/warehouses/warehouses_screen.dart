import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'warehouse_ws.dart';

class WarehousesScreen extends StatefulWidget {
  const WarehousesScreen({super.key});

  @override
  State<WarehousesScreen> createState() => _WarehousesScreenState();
}

class _WarehousesScreenState extends State<WarehousesScreen> {
  int? _selectedCompanyId;
  late Future<List<Map<String, dynamic>>> _warehousesFuture;

  bool get _isAdminSelectingCompany =>
      WarehouseWs.isAdmin && _selectedCompanyId == null;

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
            if (WarehouseWs.isAdmin && _selectedCompanyId == null) {
              context.pop();
            } else if (WarehouseWs.isAdmin) {
              setState(() {
                _selectedCompanyId = null;
                WarehouseWs.clearActiveCompanyId();
              });
            } else {
              context.pop();
            }
          },
        ),
      ),

      body: _isAdminSelectingCompany ? _buildCompanies() : _buildWarehouses(),

      floatingActionButton:
          !_isAdminSelectingCompany && WarehouseWs.isManagerOrHigher
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
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: WarehouseWs.findCompanies(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final companies = snapshot.data!;

        return ListView.separated(
          itemCount: companies.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final c = companies[index];
            final id = c['id'];
            final name = c['label'] ?? 'Company #$id';

            return ListTile(
              title: Text(name),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                setState(() {
                  _selectedCompanyId = id;
                  WarehouseWs.setActiveCompanyId(id);
                  _warehousesFuture = WarehouseWs.findAll();
                });
              },
            );
          },
        );
      },
    );
  }

  Widget _buildWarehouses() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _warehousesFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final all = snapshot.data!;
        final companyId = WarehouseWs.activeCompanyId;

        final warehouses = all.where((w) {
          return WarehouseWs.companyIdOf(w) == companyId;
        }).toList();

        if (warehouses.isEmpty) {
          return const Center(child: Text('Keine Warehouses gefunden.'));
        }

        return ListView.separated(
          itemCount: warehouses.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final w = warehouses[index];

            return ListTile(
              title: Text(WarehouseWs.titleOf(w)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final result = await context.push(
                  '/warehouses/${WarehouseWs.idOf(w)}',
                );

                if (result == true) {
                  _reloadWarehouses();
                }
              },
            );
          },
        );
      },
    );
  }
}
