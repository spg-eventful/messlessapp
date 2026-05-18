import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:messless/ws/helper.dart';

import '../../ws/schema/user/user.dart';
import 'user_ws.dart';

class UserDetailScreen extends StatefulWidget {
  final int userId;
  final String? initialName;

  const UserDetailScreen({super.key, required this.userId, this.initialName});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  bool _isEditing = false;
  bool _isDataChanged = false;
  bool _initialized = false;
  late Future<User> _userFuture;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedRole;
  final List<String> _roles = ['Manager', 'Worker', 'StageHand'];

  @override
  void initState() {
    super.initState();
    _userFuture = UserWs.getById(widget.userId);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save(User existingUser) async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    await UserWs.update(
      id: widget.userId,
      email: email,
      userRole: _selectedRole ?? existingUser.role,
      phone: phone,
      firstName: firstName,
      lastName: lastName,
      companyId: existingUser.company ?? HelperWs.activeCompanyId,
    );

    setState(() {
      _isEditing = false;
      _isDataChanged = true;
      _initialized = false;
      _userFuture = UserWs.getById(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: _userFuture,
      builder: (context, snapshot) {
        String appBarTitle = widget.initialName ?? 'User Details';

        if (snapshot.hasData) {
          final u = snapshot.data!;
          appBarTitle = '${u.firstName ?? ''} ${u.lastName ?? ''}'.trim();

          if (!_initialized) {
            _firstNameController.text = u.firstName ?? '';
            _lastNameController.text = u.lastName ?? '';
            _emailController.text = u.email ?? '';
            _phoneController.text = u.phone ?? '';
            if (_roles.contains(u.role)) {
              _selectedRole = u.role;
            }
            _initialized = true;
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(appBarTitle),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(_isDataChanged),
            ),
            actions: [
              if (HelperWs.isManagerOrHigher)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await UserWs.delete(widget.userId);
                    if (context.mounted) {
                      context.pop(true);
                    }
                  },
                ),
            ],
          ),
          body: () {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !_isDataChanged) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return const Center(child: Text('Fehler beim Laden des Profils'));
            }

            final user = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            child: Icon(
                              Icons.person,
                              size: 36,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${user.firstName} ${user.lastName}',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.email ?? '',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Rolle: ${user.role}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  if (HelperWs.isManagerOrHigher)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = !_isEditing;
                            if (!_isEditing) _initialized = false;
                          });
                        },
                        child: Text(
                          _isEditing ? "Abbrechen" : "Mitarbeiter Bearbeiten",
                        ),
                      ),
                    ),

                  if (_isEditing) ...[
                    const SizedBox(height: 24),
                    const Text(
                      "Stammdaten ändern",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: "Vorname",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: "Nachname",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: "E-Mail",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: "Telefonnummer",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: const InputDecoration(
                        labelText: "Rolle im Unternehmen",
                        border: OutlineInputBorder(),
                      ),
                      items: _roles.map((role) {
                        return DropdownMenuItem(value: role, child: Text(role));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        icon: const Icon(Icons.save_rounded),
                        onPressed: () => _save(user),
                        label: const Text("Änderungen speichern"),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }(),
        );
      },
    );
  }
}
