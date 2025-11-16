import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../authentification/auth/cubit/auth_cubit.dart';
import '../../cubit/test_config_cubit.dart';
import '../../cubit/test_config_state.dart';

/// Diálogo para guardar la configuración actual con un nombre personalizado
class SaveConfigDialog extends StatefulWidget {
  const SaveConfigDialog({super.key});

  @override
  State<SaveConfigDialog> createState() => _SaveConfigDialogState();
}

class _SaveConfigDialogState extends State<SaveConfigDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveConfig() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final userId = context.read<AuthCubit>().state.user.id;
    final configName = _nameController.text.trim();

    final success = await context.read<TestConfigCubit>().saveCurrentConfig(
      userId: userId,
      configName: configName,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Configuración "$configName" guardada'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 1.5,
            ),
          ),
        ),
      );
    } else {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TestConfigCubit, TestConfigState>(
      builder: (context, configState) {
        // Verificar si la configuración es válida
        final config = configState.config;
        final isConfigValid = config.isValid;

        // Mensaje de error si no es válida
        final validationError = config.validationError;

        return BlocListener<TestConfigCubit, TestConfigState>(
          listenWhen: (previous, current) =>
              previous.savedConfigsStatus.status != current.savedConfigsStatus.status,
          listener: (context, state) {
            if (state.savedConfigsStatus.isError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.savedConfigsStatus.message),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          },
          child: AlertDialog(
            title: const Text('Guardar Configuración'),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dale un nombre a esta configuración para poder usarla rápidamente más tarde desde la Home.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    autofocus: true,
                    enabled: !_isSaving,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de la configuración',
                      hintText: 'Ej: Repaso Rápido, Test Completo...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.label_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor ingresa un nombre';
                      }
                      if (value.trim().length < 3) {
                        return 'El nombre debe tener al menos 3 caracteres';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => isConfigValid ? _saveConfig() : null,
                  ),
                  // Mostrar mensaje de error si la configuración no es válida
                  if (!isConfigValid && validationError != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_rounded,
                            size: 20,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              validationError,
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              FilledButton.icon(
                onPressed: (_isSaving || !isConfigValid) ? null : _saveConfig,
                icon: _isSaving
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : const Icon(Icons.save),
                label: Text(_isSaving ? 'Guardando...' : 'Guardar'),
              ),
            ],
          ),
        );
      },
    );
  }
}