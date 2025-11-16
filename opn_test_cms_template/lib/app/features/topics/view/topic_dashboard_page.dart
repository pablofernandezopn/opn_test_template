import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/cubit/cubit.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/cubit/state.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/model/topic_model.dart';

class TopicDashboardPage extends StatefulWidget {
  final int topicId;

  const TopicDashboardPage({
    super.key,
    required this.topicId,
  });

  @override
  State<TopicDashboardPage> createState() => _TopicDashboardPageState();
}

class _TopicDashboardPageState extends State<TopicDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Cargar datos del topic si es necesario
      context.read<TopicCubit>().fetchTopics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TopicCubit, TopicState>(
      builder: (context, state) {
        final topic = state.topics
            .where((t) => t.id == widget.topicId)
            .firstOrNull;

        if (topic == null) {
          return _buildErrorScreen(context);
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Dashboard - ${topic.topicName}'),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Actualizar',
                  onPressed: () => context.read<TopicCubit>().fetchTopics(),
                ),
              ),
            ],
          ),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, topic),
                      const SizedBox(height: 24),
                      _buildKpis(context, topic),
                      const SizedBox(height: 24),
                      _buildAdditionalInfo(context, topic),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, Topic topic) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic.topicName,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (topic.description != null && topic.description!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          topic.description!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: topic.enabled ? Colors.green[100] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    topic.enabled ? 'Activo' : 'Inactivo',
                    style: TextStyle(
                      color: topic.enabled ? Colors.green[800] : Colors.grey[800],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpis(BuildContext context, Topic topic) {
    final colorScheme = Theme.of(context).colorScheme;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: _getCrossAxisCount(context),
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildKpiCard(
          context: context,
          title: 'Total Participantes',
          value: topic.totalParticipants.toString(),
          icon: Icons.people_alt_outlined,
          color: colorScheme.primary,
        ),
        _buildKpiCard(
          context: context,
          title: 'Total Preguntas',
          value: topic.totalQuestions.toString(),
          icon: Icons.quiz_outlined,
          color: colorScheme.secondary,
        ),
        _buildKpiCard(
          context: context,
          title: 'Nota Media',
          value: topic.averageScore?.toStringAsFixed(2) ?? '0.00',
          icon: Icons.bar_chart,
          color: colorScheme.tertiary,
        ),
        _buildKpiCard(
          context: context,
          title: 'Nota Máxima',
          value: (topic.maxScore ?? 0).toString(),
          icon: Icons.trending_up,
          color: Colors.green,
        ),
        _buildKpiCard(
          context: context,
          title: 'Nota Mínima',
          value: (topic.minScore ?? 0).toString(),
          icon: Icons.trending_down,
          color: Colors.red,
        ),
        _buildKpiCard(
          context: context,
          title: 'Duración',
          value: '${topic.durationMinutes} min',
          icon: Icons.timer_outlined,
          color: colorScheme.primary,
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo(BuildContext context, Topic topic) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información Adicional',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              context: context,
              icon: Icons.calendar_today,
              label: 'Creado',
              value: topic.createdAt != null
                  ? _formatDate(topic.createdAt!)
                  : 'N/A',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context: context,
              icon: Icons.update,
              label: 'Última actualización',
              value: topic.updatedAt != null
                  ? _formatDate(topic.updatedAt!)
                  : 'N/A',
            ),
            if (topic.publishedAt != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                context: context,
                icon: Icons.publish,
                label: 'Publicado',
                value: _formatDate(topic.publishedAt!),
              ),
            ],
            const SizedBox(height: 12),
            _buildInfoRow(
              context: context,
              icon: Icons.diamond_outlined,
              label: 'Premium',
              value: topic.isPremium ? 'Sí' : 'No',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context: context,
              icon: Icons.settings,
              label: 'Opciones',
              value: topic.options.toString(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }

  Widget _buildErrorScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: const Center(
        child: Text(
          'No se pudo cargar el test. Vuelve atrás e inténtalo de nuevo.',
        ),
      ),
    );
  }
}
