import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:messless/screens/warehouse/warehouse_ws.dart';

class CompanyDetailScreen extends StatefulWidget {
  final int companyId;

  const CompanyDetailScreen({super.key, required this.companyId});

  @override
  State<CompanyDetailScreen> createState() => _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends State<CompanyDetailScreen> {
  bool _isEditing = false;
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save(int id) async {
    final name = _nameController.text.trim();
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Details'),
        actions: [
          if (WarehouseWs.isManagerOrHigher)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                if (context.mounted) {
                  context.pop(true);
                }
              },
            ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: WarehouseWs.get(widget.companyId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Fehler beim Laden der Details'));
          }

          final company = snapshot.data!;
          final id = company['id'] ?? widget.companyId;
          final name = company['name'] ?? 'Unbekannt';

          if (!_isEditing) {
            _nameController.text = name;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Company #$id",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                if (WarehouseWs.isManagerOrHigher)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        setState(() => _isEditing = !_isEditing);
                      },
                      child: Text(_isEditing ? "Abbrechen" : "Bearbeiten"),
                    ),
                  ),

                if (_isEditing) ...[
                  const SizedBox(height: 24),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "Company Name",
                      border: OutlineInputBorder(),
                    ),
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
              ],
            ),
          );
        },
      ),
    );
  }
}