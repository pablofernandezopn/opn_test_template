import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opn_test_guardia_civil_cms/app/authentification/auth/model/user.dart';
import 'package:opn_test_guardia_civil_cms/app/features/users/cubit/cubit.dart';
import 'package:opn_test_guardia_civil_cms/app/features/users/cubit/state.dart';
import 'package:opn_test_guardia_civil_cms/app/features/users/model/user.dart';

class AddUserPage extends StatefulWidget {
  static const String route = '/students/add';

  const AddUserPage({super.key});

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _enabled = true;
  bool _tester = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final newUser = User(
        id: 0, // Se asignará en el backend
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
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
        // roleId: 4, // User por defecto
        academyId: 1, // Se asignará según el usuario autenticado en el cubit
      );

      context.read<UserCubit>().createUser(newUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<UserCubit, UserState>(
      listener: (context, state) {
        if (state.createUserStatus.isDone) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Usuario creado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/students');
        } else if (state.createUserStatus.isError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error ?? 'Error al crear usuario'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con botón de regreso
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.go('/students'),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.person_add,
                    size: 32,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Añadir Nuevo Alumno',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Completa el formulario para registrar un nuevo usuario',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Formulario
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Información del Usuario',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Username
                            TextFormField(
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                labelText: 'Nombre de usuario',
                                prefixIcon: Icon(Icons.account_circle_outlined),
                                helperText:
                                    'Usado para iniciar sesión en la plataforma',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa un nombre de usuario';
                                }
                                if (value.length < 3) {
                                  return 'El nombre de usuario debe tener al menos 3 caracteres';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Nombre (opcional)
                            TextFormField(
                              controller: _firstNameController,
                              decoration: const InputDecoration(
                                labelText: 'Nombre (opcional)',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Apellido (opcional)
                            TextFormField(
                              controller: _lastNameController,
                              decoration: const InputDecoration(
                                labelText: 'Apellido (opcional)',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Email (opcional)
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email (opcional)',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  if (!RegExp(
                                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                      .hasMatch(value)) {
                                    return 'Por favor ingresa un email válido';
                                  }
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Teléfono (opcional)
                            TextFormField(
                              controller: _phoneController,
                              decoration: const InputDecoration(
                                labelText: 'Teléfono (opcional)',
                                prefixIcon: Icon(Icons.phone_outlined),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 24),

                            // Estado Activo
                            SwitchListTile(
                              title: const Text('Usuario Activo'),
                              subtitle: const Text(
                                  'El usuario podrá acceder a la aplicación'),
                              value: _enabled,
                              onChanged: (value) {
                                setState(() {
                                  _enabled = value;
                                });
                              },
                            ),
                            const SizedBox(height: 8),

                            // Tester
                            SwitchListTile(
                              title: const Text('Usuario Tester'),
                              subtitle: const Text(
                                  'Acceso a funcionalidades en prueba'),
                              value: _tester,
                              onChanged: (value) {
                                setState(() {
                                  _tester = value;
                                });
                              },
                            ),
                            const SizedBox(height: 32),

                            // Botones de acción
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => context.go('/students'),
                                  child: const Text('Cancelar'),
                                ),
                                const SizedBox(width: 16),
                                BlocBuilder<UserCubit, UserState>(
                                  builder: (context, state) {
                                    return FilledButton.icon(
                                      onPressed:
                                          state.createUserStatus.isLoading
                                              ? null
                                              : _handleSubmit,
                                      icon: state.createUserStatus.isLoading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Icon(Icons.add),
                                      label: const Text('Crear Usuario'),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
