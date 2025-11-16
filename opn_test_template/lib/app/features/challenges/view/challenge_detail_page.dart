import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../model/challenge_model.dart';
import '../model/challenge_detail_model.dart';
import '../repository/challenge_repository.dart';

class ChallengeDetailPage extends StatefulWidget {
  const ChallengeDetailPage({
    super.key,
    required this.challengeId,
  });

  final int challengeId;

  @override
  State<ChallengeDetailPage> createState() => _ChallengeDetailPageState();
}

class _ChallengeDetailPageState extends State<ChallengeDetailPage> {
  final ChallengeRepository _repository = ChallengeRepository();
  bool _isLoading = true;
  ChallengeDetail? _detail;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadChallengeDetails();
  }

  Future<void> _loadChallengeDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _repository.fetchChallengeDetails(widget.challengeId);
      if (data != null) {
        setState(() {
          _detail = ChallengeDetail.fromMap(data);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'No se pudo cargar la información del challenge';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error al cargar: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Impugnación'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline,
                            size: 64, color: colors.error),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _loadChallengeDetails,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                )
              : _detail == null
                  ? const Center(child: Text('No hay datos'))
                  : RefreshIndicator(
                      onRefresh: _loadChallengeDetails,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Estado y fecha
                            _buildStatusSection(colors, textTheme),
                            const SizedBox(height: 24),

                            // Información del Topic
                            _buildTopicSection(colors, textTheme),
                            const SizedBox(height: 24),

                            // Pregunta completa
                            _buildQuestionSection(colors, textTheme),
                            const SizedBox(height: 24),

                            // Motivo de la impugnación
                            _buildReasonSection(colors, textTheme),
                            const SizedBox(height: 24),

                            // Respuesta del tutor
                            if (_detail!.challenge.reply.isNotEmpty)
                              _buildTutorReplySection(colors, textTheme),
                          ],
                        ),
                      ),
                    ),
    );
  }

  Widget _buildStatusSection(ColorScheme colors, TextTheme textTheme) {
    final challenge = _detail!.challenge;
    Color stateColor;
    Color stateBackgroundColor;
    IconData stateIcon;

    switch (challenge.state) {
      case ChallengeStatus.pendiente:
        stateColor = colors.tertiary;
        stateBackgroundColor = colors.tertiary.withValues(alpha: 0.1);
        stateIcon = Icons.pending_outlined;
        break;
      case ChallengeStatus.aceptada:
        stateColor = const Color(0xFF4CAF50);
        stateBackgroundColor = const Color(0xFF4CAF50).withValues(alpha: 0.1);
        stateIcon = Icons.check_circle_outline;
        break;
      case ChallengeStatus.rechazada:
        stateColor = colors.error;
        stateBackgroundColor = colors.error.withValues(alpha: 0.1);
        stateIcon = Icons.cancel_outlined;
        break;
    }

    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final createdAtText = challenge.createdAt != null
        ? dateFormat.format(challenge.createdAt!)
        : 'Fecha desconocida';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: stateBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(stateIcon, size: 20, color: stateColor),
                    const SizedBox(width: 8),
                    Text(
                      challenge.state.displayName,
                      style: textTheme.titleSmall?.copyWith(
                        color: stateColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today,
                  size: 16, color: colors.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                'Creada el: $createdAtText',
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (challenge.updatedAt != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.update, size: 16, color: colors.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  'Actualizada el: ${dateFormat.format(challenge.updatedAt!)}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTopicSection(ColorScheme colors, TextTheme textTheme) {
    final topic = _detail!.topic;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.topic, color: colors.primary, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Información del Tema',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.label,
            label: 'Tema',
            value: topic.topicName,
            colors: colors,
            textTheme: textTheme,
          ),
          if (topic.description != null && topic.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.description,
              label: 'Descripción',
              value: topic.description!,
              colors: colors,
              textTheme: textTheme,
            ),
          ],
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.quiz,
            label: 'Total de Preguntas',
            value: '${topic.totalQuestions} preguntas',
            colors: colors,
            textTheme: textTheme,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionSection(ColorScheme colors, TextTheme textTheme) {
    final question = _detail!.question;
    final options = _detail!.options;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.help_outline, color: colors.primary, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Pregunta Impugnada',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Texto de la pregunta
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              question.question,
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: colors.onSurface,
              ),
            ),
          ),

          // Imagen de la pregunta (si existe)
          if (question.questionImageUrl.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                question.questionImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ),
          ],

          const SizedBox(height: 16),
          Text(
            'Opciones de Respuesta:',
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 12),

          // Opciones de respuesta
          ...options.map((option) {
            final isCorrect = option.isCorrect;
            final optionColor =
                isCorrect ? const Color(0xFF4CAF50) : colors.onSurfaceVariant;
            final backgroundColor = isCorrect
                ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                : colors.surfaceContainerHigh;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCorrect
                        ? const Color(0xFF4CAF50)
                        : colors.outlineVariant,
                    width: isCorrect ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: backgroundColor,
                        border: Border.all(color: optionColor, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          String.fromCharCode(64 + option.optionOrder),
                          style: textTheme.labelSmall?.copyWith(
                            color: optionColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        option.answer,
                        style: textTheme.bodyMedium?.copyWith(
                          color: isCorrect ? optionColor : colors.onSurface,
                          fontWeight:
                              isCorrect ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isCorrect) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.check_circle,
                        color: optionColor,
                        size: 20,
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),

          // Tip si existe
          if (question.tip != null && question.tip!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.tertiaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline,
                      color: colors.onTertiaryContainer, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tip:',
                          style: textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.onTertiaryContainer,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          question.tip!,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colors.onTertiaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReasonSection(ColorScheme colors, TextTheme textTheme) {
    final reason = _detail!.challenge.reason;

    if (reason == null || reason.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.gavel, color: colors.error, size: 24),
              const SizedBox(width: 12),
              Text(
                'Motivo de la Impugnación',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            reason,
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorReplySection(ColorScheme colors, TextTheme textTheme) {
    final reply = _detail!.challenge.reply;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.support_agent, color: colors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                'Respuesta del Tutor',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            reply,
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme colors,
    required TextTheme textTheme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: colors.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
