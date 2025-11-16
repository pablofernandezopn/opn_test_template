import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opn_test_guardia_civil_cms/app/features/users/cubit/cubit.dart';
import 'package:opn_test_guardia_civil_cms/app/features/users/cubit/state.dart';
import 'package:opn_test_guardia_civil_cms/app/features/users/model/user.dart';

class EditUserDialog extends StatefulWidget {
  final User user;

  const EditUserDialog({
    super.key,
    required this.user,
  });

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  late final TextEditingController _usernameController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late bool _enabled;
  late bool _tester;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user.username);
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone);
    _enabled = true; // Por defecto activo
    _tester = false; // Por defecto no tester
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<UserCubit, UserState>(
      listener: (context, state) {
        if (state.updateUserStatus.isDone) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Usuario actualizado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state.updateUserStatus.isError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error ?? 'Error al actualizar usuario'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit, color: colorScheme.primary),
            const SizedBox(width: 12),
            const Text('Editar Usuario'),
          ],
        ),
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
                      labelText: 'Nombre de usuario',
                      prefixIcon: Icon(Icons.account_circle_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa un nombre de usuario';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Apellido',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Por favor ingresa un email válido';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono (opcional)',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Usuario Activo'),
                    value: _enabled,
                    onChanged: (value) {
                      setState(() {
                        _enabled = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Usuario Tester'),
                    value: _tester,
                    onChanged: (value) {
                      setState(() {
                        _tester = value;
                      });
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
          BlocBuilder<UserCubit, UserState>(
            builder: (context, state) {
              return FilledButton(
                onPressed: state.updateUserStatus.isLoading
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          final updatedUser = widget.user.copyWith(
                            username: _usernameController.text.trim(),
                            firstName: _firstNameController.text.trim().isEmpty
                                ? ''
                                : _firstNameController.text.trim(),
                            lastName: _lastNameController.text.trim().isEmpty
                                ? ''
                                : _lastNameController.text.trim(),
                            email: _emailController.text.trim().isEmpty
                                ? null
                                : _emailController.text.trim(),
                            phone: _phoneController.text.trim().isEmpty
                                ? null
                                : _phoneController.text.trim(),
                          );

                          context
                              .read<UserCubit>()
                              .updateUser(widget.user.id, updatedUser);
                        }
                      },
                child: state.updateUserStatus.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Guardar'),
              );
            },
          ),
        ],
      ),
    );
  }
}
