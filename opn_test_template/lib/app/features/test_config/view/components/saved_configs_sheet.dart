import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../authentification/auth/cubit/auth_cubit.dart';
import '../../cubit/test_config_cubit.dart';
import '../../cubit/test_config_state.dart';
import '../../model/saved_test_config.dart';

/// Bottom sheet que muestra las configuraciones guardadas
class SavedConfigsSheet extends StatefulWidget {
  const SavedConfigsSheet({super.key});

  @override
  State<SavedConfigsSheet> createState() => _SavedConfigsSheetState();
}

class _SavedConfigsSheetState extends State<SavedConfigsSheet> {
  @override
  void initState() {
    super.initState();
    // Cargar configuraciones al abrir
    final userId = context.read<AuthCubit>().state.user.id;
    context.read<TestConfigCubit>().loadSavedConfigs(userId);
  }

  Future<void> _loadConfig(SavedTestConfig config) async {
    // Cerrar el bottom sheet primero
    Navigator.of(context).pop();

    // Navegar a la página de configuración pasando la config como extra
    if (!mounted) return;
    context.pushNamed(
      '/test-config',
      extra: config,
    );
  }

  Future<void> _deleteConfig(SavedTestConfig config) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar configuración'),
        content: Text(
          '¿Estás seguro que deseas eliminar la configuración "${config.configName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final success = await context.read<TestConfigCubit>().deleteSavedConfig(config.id!);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Configuración "${config.configName}" eliminada'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocBuilder<TestConfigCubit, TestConfigState>(
      builder: (context, state) {
        return Container(
          height: screenHeight * 0.5, // Altura fija de la mitad de la pantalla
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.bookmark_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Configuraciones Guardadas',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Content
              Expanded(
                child: _buildContent(state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(TestConfigState state) {
    if (state.savedConfigsStatus.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.savedConfigs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bookmark_border,
                size: 64,
                color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No hay configuraciones guardadas',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Guarda tu configuración favorita para acceder rápidamente',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: state.savedConfigs.length,
      separatorBuilder: (context, index) => const Divider(height: 1, indent: 72),
      itemBuilder: (context, index) {
        final config = state.savedConfigs[index];
        return _SavedConfigTile(
          config: config,
          onTap: () => _loadConfig(config),
          onDelete: () => _deleteConfig(config),
        );
      },
    );
  }
}

class _SavedConfigTile extends StatelessWidget {
  final SavedTestConfig config;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SavedConfigTile({
    required this.config,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Parsear info para mostrar
    final numQuestions = config.numQuestions;
    final difficulties = config.difficulties;
    final testModes = config.testModes;
    final numTopics = config.selectedTopicIds.length;

    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.bookmark,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(
        config.configName,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            '$numQuestions preguntas • $numTopics tema(s)',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontSize: 13,
            ),
          ),
          if (difficulties.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'Dificultad: ${difficulties.join(", ")}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ],
          if (testModes.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'Modos: ${testModes.join(", ")}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
      trailing: IconButton(
        icon: Icon(
          Icons.delete_outline,
          color: Theme.of(context).colorScheme.error,
        ),
        onPressed: onDelete,
      ),
      onTap: onTap,
    );
  }
}