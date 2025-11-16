import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/model/topic_group_model.dart';
import '../../cubit/cubit.dart';
import '../../cubit/state.dart';

// Enums para gestionar las acciones de los menús de forma segura
enum _PublicationAction { publishNow, schedule, unpublish }

enum _PremiumStatus { freemium, premium }

class TopicGroupHeader extends StatelessWidget {
  final TopicGroup topicGroup;

  const TopicGroupHeader({
    super.key,
    required this.topicGroup,
  });

  Widget _buildManagementSection(BuildContext context) {
    return BlocBuilder<TopicCubit, TopicState>(
      builder: (context, topicState) {
        // Aseguramos que usamos el topic group actualizado desde el estado
        final updatedGroup = topicState.topicGroups.firstWhere(
          (g) => g.id == topicGroup.id,
          orElse: () => topicGroup,
        );

        final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
        final now = DateTime.now();

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withAlpha((0.5 * 255).round()),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withAlpha((0.2 * 255).round()),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.settings_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Gestión del Grupo',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildPublicationMenu(
                        context, updatedGroup, dateFormat, now),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPremiumMenu(context, updatedGroup),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildEnabledMenu(context, updatedGroup),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper genérico para menús
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: currentColor.withAlpha((0.15 * 255).round()),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: currentColor, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(currentIcon, size: 18, color: currentColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      currentLabel,
                      style: TextStyle(
                        color: currentColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down, color: currentColor),
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
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 12),
          Text(text),
          if (isSelected) const Spacer(),
          if (isSelected) Icon(Icons.check, size: 16, color: color),
        ],
      ),
    );
  }

  // Menú de Publicación
  Widget _buildPublicationMenu(
    BuildContext context,
    TopicGroup group,
    DateFormat dateFormat,
    DateTime now,
  ) {
    final publishedAt = group.publishedAt;
    final colorScheme = Theme.of(context).colorScheme;

    String currentLabel;
    Color currentColor;
    IconData currentIcon;

    if (publishedAt == null) {
      currentLabel = 'Despublicado';
      currentColor = colorScheme.error;
      currentIcon = Icons.public_off;
    } else if (now.isBefore(publishedAt)) {
      currentLabel = 'Se publicará: ${dateFormat.format(publishedAt)}';
      currentColor = colorScheme.secondary;
      currentIcon = Icons.schedule;
    } else {
      currentLabel = 'Publicado: ${dateFormat.format(publishedAt)}';
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
            await _publishNow(context, group);
            break;
          case _PublicationAction.schedule:
            await _schedulePublication(context, group);
            break;
          case _PublicationAction.unpublish:
            await _unpublish(context, group);
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

  // Menú de Premium
  Widget _buildPremiumMenu(BuildContext context, TopicGroup group) {
    final status = group.isPremium
        ? _PremiumStatus.premium
        : _PremiumStatus.freemium;

    String currentLabel;
    Color currentColor;
    IconData currentIcon;

    switch (status) {
      case _PremiumStatus.freemium:
        currentLabel = 'Gratuito';
        currentColor = Colors.green;
        currentIcon = Icons.star_border;
        break;
      case _PremiumStatus.premium:
        currentLabel = 'Premium';
        currentColor = Colors.amber;
        currentIcon = Icons.star;
        break;
    }

    return _buildManagementMenu<_PremiumStatus>(
      context: context,
      currentLabel: currentLabel,
      currentIcon: currentIcon,
      currentColor: currentColor,
      onSelected: (value) => _onPremiumSelected(context, group, value),
      items: [
        _buildPopupMenuItem(
          value: _PremiumStatus.freemium,
          icon: Icons.star_border,
          color: Colors.green.shade700,
          text: 'Gratuito',
          isSelected: status == _PremiumStatus.freemium,
        ),
        _buildPopupMenuItem(
          value: _PremiumStatus.premium,
          icon: Icons.star,
          color: Colors.amber.shade700,
          text: 'Premium',
          isSelected: status == _PremiumStatus.premium,
        ),
      ],
    );
  }

  // Menú de Enabled/Disabled
  Widget _buildEnabledMenu(BuildContext context, TopicGroup group) {
    final isEnabled = group.enabled;

    final currentLabel = isEnabled ? 'Activo' : 'Inactivo';
    final currentColor = isEnabled ? Colors.green : Colors.grey;
    final currentIcon = isEnabled ? Icons.check_circle : Icons.cancel;

    return PopupMenuButton<bool>(
      onSelected: (value) => _onEnabledSelected(context, group, value),
      itemBuilder: (context) => [
        _buildPopupMenuItem(
          value: true,
          icon: Icons.check_circle,
          color: Colors.green.shade700,
          text: 'Activo',
          isSelected: isEnabled,
        ),
        _buildPopupMenuItem(
          value: false,
          icon: Icons.cancel,
          color: Colors.grey.shade700,
          text: 'Inactivo',
          isSelected: !isEnabled,
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: currentColor.withAlpha((0.15 * 255).round()),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: currentColor, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(currentIcon, size: 18, color: currentColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      currentLabel,
                      style: TextStyle(
                        color: currentColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down, color: currentColor),
          ],
        ),
      ),
    );
  }

  // --- Lógica de acciones ---

  // Publicar ahora
  Future<void> _publishNow(BuildContext context, TopicGroup group) async {
    final updatedGroup = group.copyWith(publishedAt: DateTime.now().toUtc());
    await context
        .read<TopicCubit>()
        .updateTopicGroup(group.id!, updatedGroup);
  }

  // Despublicar
  Future<void> _unpublish(BuildContext context, TopicGroup group) async {
    final updatedGroup = group.copyWith(publishedAt: null);
    await context
        .read<TopicCubit>()
        .updateTopicGroup(group.id!, updatedGroup);
  }

  // Programar publicación
  Future<void> _schedulePublication(
      BuildContext context, TopicGroup group) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: group.publishedAt ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (selectedDate == null || !context.mounted) return;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(group.publishedAt ?? DateTime.now()),
    );
    if (selectedTime == null || !context.mounted) return;

    final scheduledDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    final updatedGroup = group.copyWith(publishedAt: scheduledDateTime);
    await context
        .read<TopicCubit>()
        .updateTopicGroup(group.id!, updatedGroup);
  }

  void _onPremiumSelected(
      BuildContext context, TopicGroup group, _PremiumStatus value) {
    final isPremium = value == _PremiumStatus.premium;

    final updatedGroup = group.copyWith(isPremium: isPremium);

    context.read<TopicCubit>().updateTopicGroup(group.id!, updatedGroup);
  }

  void _onEnabledSelected(BuildContext context, TopicGroup group, bool value) {
    final updatedGroup = group.copyWith(enabled: value);

    context.read<TopicCubit>().updateTopicGroup(group.id!, updatedGroup);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: _buildManagementSection(context),
    );
  }
}
