import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../bootstrap.dart';
import '../../../config/service_locator.dart';
import '../../../authentification/auth/cubit/auth_cubit.dart';
import '../model/topic_model.dart';
import '../model/topic_group_model.dart';
import '../repository/topic_repository.dart';
import 'preview_topic_page.dart';

/// Wrapper que carga un Topic o TopicGroup por ID y muestra PreviewTopicPage
/// Usado para navegación desde notificaciones push que solo tienen el ID
class PreviewTopicByIdPage extends StatelessWidget {
  const PreviewTopicByIdPage({
    super.key,
    this.topicId,
    this.topicGroupId,
  }) : assert(
          (topicId != null && topicGroupId == null) ||
          (topicId == null && topicGroupId != null),
          'Must provide either topicId OR topicGroupId, not both',
        );

  final int? topicId;
  final int? topicGroupId;

  bool get isGroup => topicGroupId != null;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: isGroup ? _loadTopicGroup() : _loadTopic(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando test...'),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          logger.error('Error cargando ${isGroup ? 'grupo' : 'topic'}: ${snapshot.error}');
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar el test',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No se pudo cargar la información del test. Intenta nuevamente.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Volver'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Test no encontrado',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'El test que buscas no existe o fue eliminado.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Volver'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Mostrar PreviewTopicPage con los datos cargados
        if (isGroup) {
          final topicGroup = snapshot.data as TopicGroup;
          logger.info('✅ TopicGroup cargado: ${topicGroup.name} (ID: ${topicGroup.id})');
          return PreviewTopicPage(topicGroup: topicGroup);
        } else {
          final topic = snapshot.data as Topic;
          logger.info('✅ Topic cargado: ${topic.topicName} (ID: ${topic.id})');
          return PreviewTopicPage(topic: topic);
        }
      },
    );
  }

  Future<Topic> _loadTopic(BuildContext context) async {
    try {
      logger.info('📥 Cargando topic con ID: $topicId');
      final user = context.read<AuthCubit>().state.user;

      final topics = await getIt<TopicRepository>().fetchTopics(
        academyId: user.academyId,
      );

      final topic = topics.firstWhere(
        (t) => t.id == topicId,
        orElse: () => throw Exception('Topic $topicId no encontrado'),
      );

      return topic;
    } catch (e) {
      logger.error('Error cargando topic $topicId: $e');
      rethrow;
    }
  }

  Future<TopicGroup> _loadTopicGroup() async {
    try {
      logger.info('📥 Cargando topic group con ID: $topicGroupId');

      final groups = await getIt<TopicRepository>().fetchTopicGroups();

      final group = groups.firstWhere(
        (g) => g.id == topicGroupId,
        orElse: () => throw Exception('TopicGroup $topicGroupId no encontrado'),
      );

      return group;
    } catch (e) {
      logger.error('Error cargando topic group $topicGroupId: $e');
      rethrow;
    }
  }
}