import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:messless/widgets/msls_appbar.dart';

import '../../ws/helper.dart';
import '../../ws/schema/company/company.dart';
import '../../ws/schema/user/user.dart';
import '../user/user_ws.dart';
import 'company_ws.dart';

class CompanyScreen extends StatefulWidget {
  const CompanyScreen({super.key});

  @override
  State<CompanyScreen> createState() => _CompanyScreenState();
}

class _CompanyScreenState extends State<CompanyScreen> {
  late Future<Map<String, dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _dataFuture = Future.wait([
        CompanyWs.find(),
        UserWs.find(),
      ]).then((results) {
        return {
          'companies': results[0] as List<Company>,
          'users': results[1] as List<User>,
        };
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MslsAppbar(),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Fehler: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Keine Daten gefunden.'));
          }

          final companies = snapshot.data!['companies'] as List<Company>;
          final allUsers = snapshot.data!['users'] as List<User>;

          if (companies.isEmpty) {
            return const Center(child: Text('Keine Companies gefunden.'));
          }

          companies.sort((a, b) =>
              a.label.toLowerCase().compareTo(b.label.toLowerCase()));

          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: companies.length,
            separatorBuilder: (context, index) => const SizedBox(height: 2),
            itemBuilder: (context, index) {
              final company = companies[index];
              final name = company.label;
              final companyId = company.id;

              final employeesCount = allUsers
                  .where((u) => u.company == companyId)
                  .length;

              return Card(
                clipBehavior: Clip.hardEdge,
                child: InkWell(
                  onTap: () {
                    HelperWs.setActiveCompanyId(companyId);
                    context.pushNamed("Users", extra: company);
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
                          _loadData();
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
            _loadData();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}