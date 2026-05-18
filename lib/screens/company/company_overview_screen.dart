import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:messless/widgets/msls_appbar.dart';

import '../../ws/schema/company/company.dart';
import 'company_ws.dart';

class CompanyScreen extends StatefulWidget {
  const CompanyScreen({super.key});

  @override
  State<CompanyScreen> createState() => _CompanyScreenState();
}

class _CompanyScreenState extends State<CompanyScreen> {
  late Future<List<Company>> _companiesFuture;

  @override
  void initState() {
    super.initState();
    _companiesFuture = CompanyWs.find();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MslsAppbar(),
      body: FutureBuilder<List<Company>>(
        future: _companiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Fehler: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Keine Companies gefunden.'));
          }

          final companies = snapshot.data!;

          companies.sort((a, b) =>
              a.label.toLowerCase().compareTo(b.label.toLowerCase()));

          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: companies.length,
            separatorBuilder: (context, index) => const SizedBox(height: 2),
            itemBuilder: (context, index) {
              final company = companies[index];
              final name = company.label;
              final employeesCount = '0';
              final companyId = company.id;

              return Card(
                clipBehavior: Clip.hardEdge,
                child: InkWell(
                  onTap: () {
                    context.pushNamed("Company Users", extra: company);
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      child: Icon(
                        Icons.business_rounded,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('$employeesCount Employees'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_note_rounded),
                      onPressed: () async {
                        final dynamic refreshed = await context.pushNamed(
                          "Company Details",
                          pathParameters: {"id": companyId.toString()},
                        );
                        if (refreshed == true && mounted) {
                          setState(() {
                            _companiesFuture = CompanyWs.find();
                          });
                        }
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        onPressed: () async {
          await context.pushNamed('Add Company');
          if (mounted) {
            setState(() {
              _companiesFuture = CompanyWs.find();
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}