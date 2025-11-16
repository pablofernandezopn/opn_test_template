import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:opn_test_guardia_civil_cms/app/config/theme/color_scheme_extensions.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/model/topic_model.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/model/topic_type_model.dart';
import 'package:opn_test_guardia_civil_cms/app/features/questions/model/question_model.dart';
import 'package:opn_test_guardia_civil_cms/bootstrap.dart';
import '../../../topics/cubit/cubit.dart';
import '../../../topics/cubit/state.dart';
import '../../../topics/model/topic_level.dart';
import '../../cubit/cubit.dart';
import '../../cubit/state.dart';
import 'generate_ai_questions_dialog.dart';
import 'validation_bar_widget.dart';

enum _PublicationAction { publishNow, schedule, unpublish }

enum _PremiumStatus { freemium, premium, hidden }

class QuestionHeader extends StatelessWidget {
  final Topic currentTopic;
  final TopicType currentTopicType;
  final TextEditingController _bulkCreateController =
      TextEditingController(text: '1');

  QuestionHeader({
    super.key,
    required this.currentTopic,
    required this.currentTopicType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color:
                Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Botón volver minimalista
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            onPressed: () => context.pop(),
            tooltip: 'Volver',
            style: IconButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          const SizedBox(width: 24),

          // Información del topic
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentTopicType.topicTypeName.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentTopic.topicName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Gestión de publicación y premium
          BlocBuilder<TopicCubit, TopicState>(
            builder: (context, topicState) {
              final updatedTopic = topicState.topics.firstWhere(
                (t) => t.id == currentTopic.id,
                orElse: () => currentTopic,
              );

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPublicationMenu(context, updatedTopic),
                  const SizedBox(width: 8),
                  _buildPremiumMenu(context, updatedTopic),
                ],
              );
            },
          ),

          // const SizedBox(width: 24),

          // ValidationBar

          // const SizedBox(width: 24),

          // Divisor sutil
          Container(
            height: 40,
            width: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.outlineVariant.withOpacity(0),
                  Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
                  Theme.of(context).colorScheme.outlineVariant.withOpacity(0),
                ],
              ),
            ),
          ),

          const SizedBox(width: 24),

          // Botones de creación minimalistas
          _buildCreateMultipleButton(context),

          const SizedBox(width: 12),
          _buildAIButton(context),
          const SizedBox(width: 12),

          const ValidationBarWidget(),
        ],
      ),
    );
  }

  // Botón crear múltiples
  Widget _buildCreateMultipleButton(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 80,
            child: TextField(
              controller: _bulkCreateController,
              decoration: InputDecoration(
                hintText: 'Cant.',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withOpacity(0.5),
                ),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            height: 24,
            width: 1,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
          InkWell(
            onTap: () => _bulkCreateQuestions(context),
            borderRadius:
                const BorderRadius.horizontal(right: Radius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Crear',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Botón IA
  Widget _buildAIButton(BuildContext context) {
    return FilledButton.icon(
      onPressed: () => showGenerateAIQuestionsDialog(
        context,
        topicId: currentTopic.id!,
        topicName: currentTopic.topicName,
      ),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        minimumSize: const Size(0, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 0,
      ),
      icon: const Icon(Icons.auto_awesome, size: 16),
      label: const Text(
        'Generar IA',
        style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.2),
      ),
    );
  }

  // Menú genérico minimalista
  Widget _buildManagementMenu<T>({
    required BuildContext context,
    required String currentLabel,
    required IconData currentIcon,
    required Color currentColor,
    required List<PopupMenuEntry<T>> items,
    required void Function(T) onSelected,
  }) {
    return PopupMenuButton<T>(
      onSelected: onSelected,
      itemBuilder: (context) => items,
      tooltip: '',
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: currentColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: currentColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(currentIcon, size: 14, color: currentColor),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 100),
              child: Text(
                currentLabel,
                style: TextStyle(
                  color: currentColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  letterSpacing: 0.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 2),
            Icon(Icons.arrow_drop_down, size: 16, color: currentColor),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<T> _buildPopupMenuItem<T>({
    required T value,
    required IconData icon,
    required Color color,
    required String text,
    bool isSelected = false,
  }) {
    return PopupMenuItem<T>(
      value: value,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          if (isSelected) const Spacer(),
          if (isSelected) Icon(Icons.check, size: 16, color: color),
        ],
      ),
    );
  }

  Widget _buildPublicationMenu(BuildContext context, Topic topic) {
    final publishedAt = topic.publishedAt;
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('dd/MM/yy HH:mm');
    final now = DateTime.now();

    String currentLabel;
    Color currentColor;
    IconData currentIcon;

    if (publishedAt == null) {
      currentLabel = 'Despublicado';
      currentColor = colorScheme.error;
      currentIcon = Icons.public_off;
    } else if (now.isBefore(publishedAt)) {
      currentLabel = dateFormat.format(publishedAt);
      currentColor = colorScheme.secondary;
      currentIcon = Icons.schedule;
    } else {
      currentLabel = dateFormat.format(publishedAt);
      currentColor = colorScheme.primary;
      currentIcon = Icons.publish;
    }

    return _buildManagementMenu<_PublicationAction>(
      context: context,
      currentLabel: currentLabel,
      currentIcon: currentIcon,
      currentColor: currentColor,
      onSelected: (value) async {
        switch (value) {
          case _PublicationAction.publishNow:
            await _publishNow(context);
            break;
          case _PublicationAction.schedule:
            await _schedulePublication(context);
            break;
          case _PublicationAction.unpublish:
            await _unpublish(context);
            break;
        }
      },
      items: [
        if (publishedAt == null || now.isBefore(publishedAt))
          _buildPopupMenuItem(
            value: _PublicationAction.publishNow,
            icon: Icons.publish,
            color: colorScheme.primary,
            text: 'Publicar Ahora',
          ),
        _buildPopupMenuItem(
          value: _PublicationAction.schedule,
          icon: Icons.calendar_today,
          color: colorScheme.secondary,
          text: publishedAt != null && now.isAfter(publishedAt)
              ? 'Reprogramar'
              : 'Programar',
        ),
        if (publishedAt != null && now.isAfter(publishedAt))
          _buildPopupMenuItem(
            value: _PublicationAction.unpublish,
            icon: Icons.public_off,
            color: colorScheme.error,
            text: 'Despublicar',
          ),
      ],
    );
  }

  Widget _buildPremiumMenu(BuildContext context, Topic topic) {
    final status = _getPremiumStatus(topic);

    String currentLabel;
    Color currentColor;
    IconData currentIcon;

    final colorScheme = Theme.of(context).colorScheme;

    switch (status) {
      case _PremiumStatus.freemium:
        currentLabel = 'Freemium';
        currentColor = colorScheme.freemium;
        currentIcon = Icons.star_border;
        break;
      case _PremiumStatus.premium:
        currentLabel = 'Premium';
        currentColor = colorScheme.premium;
        currentIcon = Icons.star;
        break;
      case _PremiumStatus.hidden:
        currentLabel = 'Oculto';
        currentColor = colorScheme.hiddenButPremium;
        currentIcon = Icons.visibility_off;
        break;
    }

    return _buildManagementMenu<_PremiumStatus>(
      context: context,
      currentLabel: currentLabel,
      currentIcon: currentIcon,
      currentColor: currentColor,
      onSelected: (value) => _onPremiumSelected(context, value),
      items: [
        _buildPopupMenuItem(
          value: _PremiumStatus.freemium,
          icon: Icons.star_border,
          color: colorScheme.freemium,
          text: 'Freemium (Gratis)',
          isSelected: status == _PremiumStatus.freemium,
        ),
        _buildPopupMenuItem(
          value: _PremiumStatus.premium,
          icon: Icons.star,
          color: colorScheme.premium,
          text: 'Premium (Visible)',
          isSelected: status == _PremiumStatus.premium,
        ),
        _buildPopupMenuItem(
          value: _PremiumStatus.hidden,
          icon: Icons.visibility_off,
          color: colorScheme.hiddenButPremium,
          text: 'Oculto (Premium)',
          isSelected: status == _PremiumStatus.hidden,
        ),
      ],
    );
  }

  // --- Lógica de acciones ---
  Future<void> _createNewQuestion(BuildContext context,
      {int? overrideOrder}) async {
    final isMockType = currentTopicType.level == TopicLevel.Mock;
    final defaultPublished = isMockType;
    final defaultShuffled = !isMockType;

    final nextOrder = overrideOrder ??
        (context.read<QuestionCubit>().state.questions.isNotEmpty
            ? context
                    .read<QuestionCubit>()
                    .state
                    .questions
                    .map((q) => q.order)
                    .reduce((a, b) => a > b ? a : b) +
                1
            : 1);

    if (currentTopic.id == null) throw Exception('Current topic ID is null');

    final newQuestion = Question(
      question: '',
      topic: currentTopic.id!,
      createdBy: null,
      published: defaultPublished,
      tip: '',
      article: '',
      questionImageUrl: '',
      retroImageUrl: '',
      retroAudioEnable: false,
      retroAudioText: '',
      shuffled: defaultShuffled,
      numAnswered: 0,
      numFails: 0,
      numEmpty: 0,
      order: nextOrder,
      challengeByTutor: false,
    );

    await context.read<QuestionCubit>().createQuestion(newQuestion);
  }

  Future<void> _bulkCreateQuestions(BuildContext context) async {
    final count = int.tryParse(_bulkCreateController.text) ?? 0;
    if (count <= 0) return;

    final startOrder = context.read<QuestionCubit>().state.questions.isNotEmpty
        ? context
                .read<QuestionCubit>()
                .state
                .questions
                .map((q) => q.order)
                .reduce((a, b) => a > b ? a : b) +
            1
        : 1;

    for (int i = 0; i < count; i++) {
      await _createNewQuestion(context, overrideOrder: startOrder + i);
    }

    _bulkCreateController.clear();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$count pregunta${count > 1 ? 's' : ''} creada${count > 1 ? 's' : ''} correctamente',
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _publishNow(BuildContext context) async {
    // Verificar que todas las validaciones estén completadas
    if (!_areAllValidationsComplete(context)) {
      _showValidationErrorDialog(context);
      return;
    }

    final updatedTopic =
        currentTopic.copyWith(publishedAt: DateTime.now().toUtc());
    await context
        .read<TopicCubit>()
        .updateTopic(currentTopic.id!, updatedTopic);
  }

  Future<void> _unpublish(BuildContext context) async {
    final updatedTopic = currentTopic.copyWith(publishedAt: null);
    logger.info(updatedTopic.publishedAt);
    await context
        .read<TopicCubit>()
        .updateTopic(currentTopic.id!, updatedTopic);
  }

  Future<void> _schedulePublication(BuildContext context) async {
    // Verificar que todas las validaciones estén completadas
    if (!_areAllValidationsComplete(context)) {
      _showValidationErrorDialog(context);
      return;
    }

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: currentTopic.publishedAt ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (selectedDate == null || !context.mounted) return;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay.fromDateTime(currentTopic.publishedAt ?? DateTime.now()),
    );
    if (selectedTime == null || !context.mounted) return;

    final scheduledDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    final updatedTopic = currentTopic.copyWith(publishedAt: scheduledDateTime);
    await context
        .read<TopicCubit>()
        .updateTopic(currentTopic.id!, updatedTopic);
  }

  _PremiumStatus _getPremiumStatus(Topic topic) {
    if (topic.isHiddenButPremium) return _PremiumStatus.hidden;
    if (topic.isPremium) return _PremiumStatus.premium;
    return _PremiumStatus.freemium;
  }

  void _onPremiumSelected(BuildContext context, _PremiumStatus value) {
    final bool isPremium;
    final bool isHiddenButPremium;

    switch (value) {
      case _PremiumStatus.freemium:
        isPremium = false;
        isHiddenButPremium = false;
        break;
      case _PremiumStatus.premium:
        isPremium = true;
        isHiddenButPremium = false;
        break;
      case _PremiumStatus.hidden:
        isPremium = true;
        isHiddenButPremium = true;
        break;
    }

    final updatedTopic = currentTopic.copyWith(
      isPremium: isPremium,
      isHiddenButPremium: isHiddenButPremium,
    );

    context.read<TopicCubit>().updateTopic(currentTopic.id!, updatedTopic);
  }

  /// Verifica si todas las validaciones están completadas
  bool _areAllValidationsComplete(BuildContext context) {
    final questionState = context.read<QuestionCubit>().state;
    final validationItems = _getValidationItems(questionState);
    return validationItems.every((item) => item.isValid);
  }

  /// Muestra un diálogo de error cuando las validaciones no están completadas
  void _showValidationErrorDialog(BuildContext context) {
    final questionState = context.read<QuestionCubit>().state;
    final validationItems = _getValidationItems(questionState);
    final failedValidations =
        validationItems.where((item) => !item.isValid).toList();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('No se puede publicar'),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'El topic no puede publicarse porque hay ${failedValidations.length} validación${failedValidations.length > 1 ? 'es' : ''} pendiente${failedValidations.length > 1 ? 's' : ''}:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ...failedValidations.take(5).map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.close,
                        size: 16,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.title,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                )),
            if (failedValidations.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Y ${failedValidations.length - 5} validación${failedValidations.length - 5 > 1 ? 'es' : ''} más...',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              'Por favor, completa todas las validaciones antes de publicar.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cerrar'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // Mostrar el diálogo de validación
              _showValidationDialogFromHeader(context);
            },
            icon: const Icon(Icons.checklist, size: 18),
            label: const Text('Ver Validaciones'),
          ),
        ],
      ),
    );
  }

  /// Muestra el diálogo de validaciones del ValidationBarWidget
  void _showValidationDialogFromHeader(BuildContext context) {
    final questionState = context.read<QuestionCubit>().state;
    final validationItems = _getValidationItems(questionState);
    final totalChecks = validationItems.length;
    final passedChecks = validationItems.where((item) => item.isValid).length;
    final percentage = totalChecks > 0 ? (passedChecks / totalChecks) : 0.0;

    final questionCubit = context.read<QuestionCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider<QuestionCubit>.value(
        value: questionCubit,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SizedBox(
              width: 520,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header minimalista
                  Container(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        // Icono y título
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: (percentage == 1.0
                                        ? Theme.of(context)
                                            .colorScheme
                                            .completed
                                        : Theme.of(context)
                                            .colorScheme
                                            .notCompleted)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.checklist_rounded,
                                color: percentage == 1.0
                                    ? Theme.of(context).colorScheme.completed
                                    : Theme.of(context)
                                        .colorScheme
                                        .notCompleted,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Validación',
                                    style: Theme.of(dialogContext)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: -0.5,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$passedChecks de $totalChecks completados',
                                    style:
                                        Theme.of(dialogContext).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Progress bar minimalista
                        Stack(
                          children: [
                            Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .progressBarBackground,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: percentage,
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: percentage == 1.0
                                      ? Theme.of(context).colorScheme.completed
                                      : Theme.of(context)
                                          .colorScheme
                                          .notCompleted,
                                  borderRadius: BorderRadius.circular(3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (percentage == 1.0
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .completed
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .notCompleted)
                                          .withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Divider sutil
                  Container(
                    height: 1,
                    color: Colors.grey.shade100,
                  ),
                  // Lista de validaciones
                  Container(
                    constraints: const BoxConstraints(maxHeight: 420),
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: validationItems.length,
                      itemBuilder: (context, index) {
                        final item = validationItems[index];
                        return _buildValidationItemInDialog(
                            dialogContext, item, questionState);
                      },
                    ),
                  ),
                  // Footer con botón
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cerrar',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildValidationItemInDialog(
    BuildContext context,
    ValidationItem item,
    QuestionState state,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: item.isValid
                ? Theme.of(context).colorScheme.success.withValues(alpha: 0.1)
                : Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            item.isValid ? Icons.check_rounded : Icons.close_rounded,
            color: item.isValid
                ? Theme.of(context).colorScheme.success
                : Theme.of(context).colorScheme.error,
            size: 20,
          ),
        ),
        title: Text(
          item.title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
        ),
        trailing: !item.isValid && item.invalidQuestions.isNotEmpty
            ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${item.invalidQuestions.length}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onError,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  /// Obtiene los items de validación (copiado del ValidationBarWidget)
  List<ValidationItem> _getValidationItems(QuestionState state) {
    return [
      ValidationItem(
        title: 'Todas las preguntas tienen solución válida',
        isValid: _allQuestionsHaveCorrectOption(state),
        invalidQuestions: _getQuestionsWithoutCorrectOption(state),
        getDetailText: (question) {
          final options = state.questionOptions
              .where((opt) => opt.questionId == question.id)
              .toList();
          final correctCount = options.where((opt) => opt.isCorrect).length;
          return 'Opciones correctas: $correctCount';
        },
      ),
      ValidationItem(
        title: 'Todas las preguntas tienen texto',
        isValid: _allQuestionsHaveText(state),
        invalidQuestions:
            state.questions.where((q) => q.question.trim().isEmpty).toList(),
        getDetailText: (question) => 'Texto de pregunta vacío',
      ),
      ValidationItem(
        title: 'Todas las preguntas tienen suficientes opciones',
        isValid: _allQuestionsHaveEnoughOptions(state),
        invalidQuestions: _getQuestionsWithInsufficientOptions(state),
        getDetailText: (question) {
          final options = state.questionOptions
              .where((opt) => opt.questionId == question.id)
              .length;
          return 'Opciones: $options (mínimo 3)';
        },
      ),
      ValidationItem(
        title: 'Todas las opciones tienen texto válido',
        isValid: _allOptionsHaveValidText(state),
        invalidQuestions: _getQuestionsWithInvalidOptions(state),
        getDetailText: (question) {
          final invalidOptions = state.questionOptions
              .where((opt) => opt.questionId == question.id && !opt.isValid)
              .length;
          return 'Opciones inválidas: $invalidOptions';
        },
      ),
      ValidationItem(
        title: 'Todas las preguntas tienen tip',
        isValid: _allQuestionsHaveTip(state),
        invalidQuestions: state.questions
            .where((q) => q.tip == null || q.tip!.trim().isEmpty)
            .toList(),
        getDetailText: (question) => 'Tip vacío',
      ),
      ValidationItem(
        title: 'Todas las preguntas tienen audio de retroalimentación',
        isValid: _allQuestionsHaveAudio(state),
        invalidQuestions: state.questions
            .where((q) => q.retroAudioUrl.trim().isEmpty)
            .toList(),
        getDetailText: (question) {
          if (!question.retroAudioEnable) {
            return 'Audio deshabilitado';
          }
          return 'Texto de audio vacío';
        },
      ),
      ValidationItem(
        title: 'Todas las preguntas tienen texto para el retro audio',
        isValid: _allQuestionsHaveAudioText(state),
        invalidQuestions: _getQuestionsWithoutAudioText(state),
        getDetailText: (question) {
          final options = state.questionOptions
              .where((opt) => opt.questionId == question.id)
              .toList();
          final correctCount = options.where((opt) => opt.isCorrect).length;
          return 'Opciones correctas: $correctCount';
        },
      ),
      ValidationItem(
        title: 'Todas las preguntas tienen artículo de referencia',
        isValid: _allQuestionsHaveArticle(state),
        invalidQuestions: state.questions
            .where((q) => q.article == null || q.article!.trim().isEmpty)
            .toList(),
        getDetailText: (question) => 'Sin artículo de referencia',
      ),
    ];
  }

  bool _allQuestionsHaveAudioText(QuestionState state) {
    return state.questions.every(
        (q) => !q.retroAudioEnable && (q.retroAudioText.trim().isNotEmpty));
  }

  List<Question> _getQuestionsWithoutAudioText(QuestionState state) {
    return state.questions
        .where((q) => q.retroAudioText.trim().isEmpty)
        .toList();
  }

  bool _allQuestionsHaveCorrectOption(QuestionState state) {
    return state.questions.every((question) {
      final options = state.questionOptions
          .where((opt) => opt.questionId == question.id)
          .toList();
      return options.any((opt) => opt.isCorrect);
    });
  }

  List<Question> _getQuestionsWithoutCorrectOption(QuestionState state) {
    return state.questions.where((question) {
      final options = state.questionOptions
          .where((opt) => opt.questionId == question.id)
          .toList();
      return !options.any((opt) => opt.isCorrect);
    }).toList();
  }

  bool _allQuestionsHaveText(QuestionState state) {
    return state.questions.every((q) => q.question.trim().isNotEmpty);
  }

  bool _allQuestionsHaveEnoughOptions(QuestionState state) {
    return state.questions.every((question) {
      final options = state.questionOptions
          .where((opt) => opt.questionId == question.id)
          .length;
      return options >= 3;
    });
  }

  List<Question> _getQuestionsWithInsufficientOptions(QuestionState state) {
    return state.questions.where((question) {
      final options = state.questionOptions
          .where((opt) => opt.questionId == question.id)
          .length;
      return options < 3;
    }).toList();
  }

  bool _allOptionsHaveValidText(QuestionState state) {
    return state.questionOptions.every((opt) => opt.isValid);
  }

  List<Question> _getQuestionsWithInvalidOptions(QuestionState state) {
    final invalidQuestionIds = state.questionOptions
        .where((opt) => !opt.isValid)
        .map((opt) => opt.questionId)
        .toSet();

    return state.questions
        .where((q) => invalidQuestionIds.contains(q.id))
        .toList();
  }

  bool _allQuestionsHaveTip(QuestionState state) {
    return state.questions
        .every((q) => q.tip != null && q.tip!.trim().isNotEmpty);
  }

  bool _allQuestionsHaveAudio(QuestionState state) {
    return state.questions
        .every((q) => q.retroAudioEnable && q.retroAudioText.trim().isNotEmpty);
  }

  bool _allQuestionsHaveArticle(QuestionState state) {
    return state.questions
        .every((q) => q.article != null && q.article!.trim().isNotEmpty);
  }
}
