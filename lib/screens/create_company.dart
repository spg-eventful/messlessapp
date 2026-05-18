import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:messless/screens/warehouse/warehouse_ws.dart';

import '../widgets/msls_appbar.dart';

class CreateCompanyScreen extends StatefulWidget {
  const CreateCompanyScreen({super.key});

  @override
  State<CreateCompanyScreen> createState() => _CreateCompanyScreenState();
}

class _CreateCompanyScreenState extends State<CreateCompanyScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _latController = TextEditingController();
  final _lonController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final name = _nameController.text.trim();
      final lat = double.parse(_latController.text.trim());
      final lon = double.parse(_lonController.text.trim());
      final companyid = WarehouseWs.activeCompanyId;

      await WarehouseWs.create(
        name: name,
        latitude: lat,
        longitude: lon,
        companyId: companyid,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erfolgreich erstellt!'),
            backgroundColor: Colors.green,
          ),
        );

        context.pop(context);
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
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: MslsAppbar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name / Label',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Bitte einen Namen eingeben';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _latController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Latitude',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.map_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Darf nicht leer sein';
                  }
                  if (double.tryParse(value.trim()) == null) {
                    return 'Muss eine gültige Zahl sein';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lonController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Longitude',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.map_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Darf nicht leer sein';
                  }
                  if (double.tryParse(value.trim()) == null) {
                    return 'Muss eine gültige Zahl sein';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _submitForm,
                child: const Text(
                  'Speichern',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}