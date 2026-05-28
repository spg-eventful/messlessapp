import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:messless/widgets/msls_appbar.dart';
import 'package:messless/ws/helper.dart';

import '../../ws/schema/user/user.dart';
import 'user_ws.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  late Future<List<User>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = UserWs.find();
  }

  void _refreshUsers() {
    setState(() {
      _usersFuture = UserWs.find();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MslsAppbar(),
      body: FutureBuilder<List<User>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Fehler: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Keine User gefunden.'));
          }

          final allUsers = snapshot.data!;

          final activeCompanyId = HelperWs.activeCompanyId;
          final users = allUsers
              .where((u) => u.company == activeCompanyId)
              .toList();

          if (users.isEmpty) {
            return const Center(
              child: Text('Keine Mitarbeiter für dieses Unternehmen gefunden.'),
            );
          }

          users.sort(
            (a, b) => (a.lastName ?? '').toLowerCase().compareTo(
              (b.lastName ?? '').toLowerCase(),
            ),
          );

          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: users.length,
            separatorBuilder: (context, index) => const SizedBox(height: 2),
            itemBuilder: (context, index) {
              final user = users[index];

              final fullName = '${user.firstName ?? ''} ${user.lastName ?? ''}'
                  .trim();
              final roleName = user.role;
              final userId = user.id;

              return Card(
                clipBehavior: Clip.hardEdge,
                child: InkWell(
                  onTap: () {
                    context.pushNamed(
                      "User Details",
                      pathParameters: {"id": userId.toString()},
                      extra: user,
                    );
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.secondaryContainer,
                      child: Icon(
                        Icons.person_rounded,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSecondaryContainer,
                      ),
                    ),
                    title: Text(
                      fullName.isEmpty ? 'Unbekannter User' : fullName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Rolle: $roleName'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_note_rounded),
                      onPressed: () async {
                        final dynamic refreshed = await context.pushNamed(
                          "User Details",
                          pathParameters: {"id": userId.toString()},
                        );
                        if (refreshed == true && mounted) {
                          _refreshUsers();
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
      floatingActionButton: HelperWs.isManagerOrHigher
          ? FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              onPressed: () async {
                final dynamic refreshed = await context.pushNamed('Add User');
                if (refreshed == true && mounted) {
                  _refreshUsers();
                }
              },
              child: const Icon(Icons.person_add_rounded),
            )
          : null,
    );
  }
}
