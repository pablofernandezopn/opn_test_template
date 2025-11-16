import 'package:flutter/material.dart';
import 'package:opn_test_guardia_civil_cms/app/authentification/auth/model/user.dart';

class TutorFormDialog extends StatefulWidget {
  final int academyId;
  final CmsUser? tutor;
  final Function(Map<String, dynamic>) onSave;

  const TutorFormDialog({
    required this.academyId,
    this.tutor,
    required this.onSave,
  });

  @override
  State<TutorFormDialog> createState() => TutorFormDialogState();
}

class TutorFormDialogState extends State<TutorFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  UserRole _selectedRole = UserRole.admin;

  bool get isEditing => widget.tutor != null;

  @override
  void initState() {
    super.initState();
    _usernameController =
        TextEditingController(text: widget.tutor?.username ?? '');
    _emailController = TextEditingController(text: widget.tutor?.email ?? '');
    _passwordController = TextEditingController();
    _nameController = TextEditingController(text: widget.tutor?.name ?? '');
    _surnameController =
        TextEditingController(text: widget.tutor?.lastName ?? '');
    _selectedRole = widget.tutor?.role ?? UserRole.admin;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(isEditing ? 'Editar Tutor' : 'Nuevo Tutor'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Usuario',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El usuario es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El email es requerido';
                    }
                    if (!value.contains('@')) {
                      return 'Email inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                if (!isEditing)
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (!isEditing && (value == null || value.isEmpty)) {
                        return 'La contraseña es requerida';
                      }
                      if (!isEditing && value!.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                if (!isEditing) const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.badge),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _surnameController,
                  decoration: const InputDecoration(
                    labelText: 'Surname',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Surname is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<UserRole>(
                  value: [UserRole.superAdmin, UserRole.admin, UserRole.tutor]
                          .contains(_selectedRole)
                      ? _selectedRole
                      : null, // Si el rol actual no está en la lista, usa null
                  decoration: const InputDecoration(
                    labelText: 'Rol',
                    prefixIcon: Icon(Icons.shield),
                  ),
                  items: [
                    UserRole.superAdmin,
                    UserRole.admin,
                    UserRole.tutor,
                  ].map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(_getRoleName(role)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedRole = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final data = <String, dynamic>{
                'username': _usernameController.text,
                'email': _emailController.text,
                'name': _nameController.text,
                'surname': _surnameController.text,
                'role': _selectedRole,
              };

              if (!isEditing) {
                data['password'] = _passwordController.text;
              }

              widget.onSave(data);
            }
          },
          child: Text(isEditing ? 'Actualizar' : 'Crear'),
        ),
      ],
    );
  }

  String _getRoleName(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.admin:
        return 'Admin';
      case UserRole.tutor:
        return 'Tutor';
      case UserRole.user:
        return 'Usuario';
    }
  }
}
