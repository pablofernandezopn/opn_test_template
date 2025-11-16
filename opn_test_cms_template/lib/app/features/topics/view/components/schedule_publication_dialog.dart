import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../cubit/cubit.dart';
import '../../model/topic_model.dart';

enum PublicationStatus {
  published,
  scheduled,
  draft,
  hidden;

  String get label {
    switch (this) {
      case PublicationStatus.published:
        return 'Publicado';
      case PublicationStatus.scheduled:
        return 'Programado';
      case PublicationStatus.draft:
        return 'Borrador';
      case PublicationStatus.hidden:
        return 'Oculto';
    }
  }

  Color get color {
    switch (this) {
      case PublicationStatus.published:
        return Colors.green;
      case PublicationStatus.scheduled:
        return Colors.blue;
      case PublicationStatus.draft:
        return Colors.orange;
      case PublicationStatus.hidden:
        return Colors.grey;
    }
  }

  IconData get icon {
    switch (this) {
      case PublicationStatus.published:
        return Icons.check_circle;
      case PublicationStatus.scheduled:
        return Icons.schedule;
      case PublicationStatus.draft:
        return Icons.edit_note;
      case PublicationStatus.hidden:
        return Icons.visibility_off;
    }
  }

  static PublicationStatus fromTopic(Topic topic) {
    // Si está oculto
    if (!topic.enabled || topic.isHiddenButPremium) {
      return PublicationStatus.hidden;
    }

    // Si tiene fecha de publicación en el futuro
    if (topic.publishedAt != null &&
        topic.publishedAt!.isAfter(DateTime.now())) {
      return PublicationStatus.scheduled;
    }

    // Si no tiene fecha de publicación
    if (topic.publishedAt == null) {
      return PublicationStatus.draft;
    }

    // Si tiene fecha de publicación en el pasado
    return PublicationStatus.published;
  }
}

class SchedulePublicationDialog extends StatefulWidget {
  final Topic topic;

  const SchedulePublicationDialog({
    super.key,
    required this.topic,
  });

  @override
  State<SchedulePublicationDialog> createState() =>
      _SchedulePublicationDialogState();
}

class _SchedulePublicationDialogState extends State<SchedulePublicationDialog> {
  late PublicationStatus _selectedStatus;
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;

  @override
  void initState() {
    super.initState();
    _selectedStatus = PublicationStatus.fromTopic(widget.topic);
    _scheduledDate = widget.topic.publishedAt;
    if (_scheduledDate != null) {
      _scheduledTime = TimeOfDay(
        hour: _scheduledDate!.hour,
        minute: _scheduledDate!.minute,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return AlertDialog(
      title: const Text('Programar publicación'),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test: ${widget.topic.topicName}',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Estado de publicación',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: PublicationStatus.values
                  .where((status) => status != PublicationStatus.scheduled)
                  .map((status) {
                final isSelected = _selectedStatus == status ||
                    (status == PublicationStatus.draft &&
                        _selectedStatus == PublicationStatus.scheduled);
                return FilterChip(
                  selected: isSelected,
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        status.icon,
                        size: 16,
                        color: isSelected
                            ? Colors.white
                            : status.color.withAlpha((0.8 * 255).round()),
                      ),
                      const SizedBox(width: 6),
                      Text(status.label),
                    ],
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedStatus = status;
                        // Si cambia a publicado y no hay fecha, usar la fecha actual
                        if (status == PublicationStatus.published &&
                            _scheduledDate == null) {
                          _scheduledDate = DateTime.now();
                          _scheduledTime = TimeOfDay.now();
                        }
                      });
                    }
                  },
                  backgroundColor: status.color.withAlpha((0.1 * 255).round()),
                  selectedColor: status.color,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : status.color,
                  ),
                );
              }).toList(),
            ),
            if (_selectedStatus == PublicationStatus.published ||
                _selectedStatus == PublicationStatus.scheduled ||
                _selectedStatus == PublicationStatus.draft) ...[
              const SizedBox(height: 24),
              Text(
                _selectedStatus == PublicationStatus.published
                    ? 'Fecha de publicación'
                    : 'Programar publicación para',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _scheduledDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setState(() {
                            _scheduledDate = date;
                            // Si está en borrador y selecciona una fecha futura, cambiar a programado
                            if (_selectedStatus == PublicationStatus.draft &&
                                _isFutureDate(date, _scheduledTime)) {
                              _selectedStatus = PublicationStatus.scheduled;
                            }
                          });
                        }
                      },
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text(
                        _scheduledDate != null
                            ? dateFormat.format(_scheduledDate!)
                            : 'Seleccionar fecha',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _scheduledTime ?? TimeOfDay.now(),
                        );
                        if (time != null) {
                          setState(() {
                            _scheduledTime = time;
                            // Si está en borrador y selecciona una hora futura, cambiar a programado
                            if (_selectedStatus == PublicationStatus.draft &&
                                _isFutureDate(_scheduledDate, time)) {
                              _selectedStatus = PublicationStatus.scheduled;
                            }
                          });
                        }
                      },
                      icon: const Icon(Icons.access_time, size: 18),
                      label: Text(
                        _scheduledTime != null
                            ? _scheduledTime!.format(context)
                            : 'Seleccionar hora',
                      ),
                    ),
                  ),
                ],
              ),
              if (_selectedStatus == PublicationStatus.draft)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _scheduledDate == null
                        ? 'Opcional: Programa una fecha futura para publicar automáticamente'
                        : 'Cuando llegue la fecha, el test se publicará automáticamente',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              if (_selectedStatus == PublicationStatus.scheduled)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withAlpha((0.1 * 255).round()),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.blue.withAlpha((0.3 * 255).round()),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue[700],
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'El test se publicará automáticamente en la fecha programada',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
            if (_selectedStatus == PublicationStatus.hidden) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.withAlpha((0.3 * 255).round()),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange[700],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'El test estará oculto para todos los usuarios',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.orange[700],
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
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _canSave ? () => _saveChanges(context) : null,
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  bool get _canSave {
    // Si es publicado o programado, debe tener fecha y hora
    if (_selectedStatus == PublicationStatus.published ||
        _selectedStatus == PublicationStatus.scheduled) {
      return _scheduledDate != null && _scheduledTime != null;
    }
    // Para borrador con fecha, también debe tener hora
    if (_selectedStatus == PublicationStatus.draft && _scheduledDate != null) {
      return _scheduledTime != null;
    }
    // Para otros estados, siempre se puede guardar
    return true;
  }

  void _saveChanges(BuildContext context) {
    DateTime? publishedAt;

    if (_scheduledDate != null && _scheduledTime != null) {
      publishedAt = DateTime(
        _scheduledDate!.year,
        _scheduledDate!.month,
        _scheduledDate!.day,
        _scheduledTime!.hour,
        _scheduledTime!.minute,
      );
    }

    final updatedTopic = widget.topic.copyWith(
      publishedAt: publishedAt,
      enabled: _selectedStatus != PublicationStatus.hidden,
      isHiddenButPremium: _selectedStatus == PublicationStatus.hidden,
    );

    context.read<TopicCubit>().updateTopic(widget.topic.id!, updatedTopic);
    Navigator.of(context).pop();
  }

  bool _isFutureDate(DateTime? date, TimeOfDay? time) {
    if (date == null || time == null) return false;

    final scheduledDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    return scheduledDateTime.isAfter(DateTime.now());
  }
}
