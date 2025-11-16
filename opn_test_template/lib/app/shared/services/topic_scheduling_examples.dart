// EJEMPLOS DE USO DEL SERVICIO DE PROGRAMACIÓN DE TOPICS
// Este archivo contiene ejemplos de cómo usar TopicSchedulingService

import 'package:flutter/material.dart';
import 'topic_scheduling_service.dart';
import '../../../bootstrap.dart';

// ==========================================
// 📝 EJEMPLO 1: Programar para mañana
// ==========================================

Future<void> example1ScheduleForTomorrow() async {
  // Programar topic para mañana a las 10 AM
  final success = await TopicSchedulingService.scheduleTopicForTomorrow(
    topicId: 42,
    hour: 10,
    minute: 0,
  );

  if (success) {
    print('✅ Topic programado para mañana a las 10 AM');
  }
}

// ==========================================
// 📝 EJEMPLO 2: Programar para fecha específica
// ==========================================

Future<void> example2ScheduleForSpecificDate() async {
  // Programar para Navidad 2024 a las 9 AM
  final christmasDate = DateTime(2024, 12, 25, 9, 0);

  final success = await TopicSchedulingService.scheduleTopicPublication(
    topicId: 42,
    publishAt: christmasDate,
  );

  if (success) {
    print('✅ Topic programado para Navidad: $christmasDate');
  }
}

// ==========================================
// 📝 EJEMPLO 3: Programar para próximo lunes
// ==========================================

Future<void> example3ScheduleForNextMonday() async {
  // Programar para el próximo lunes a las 9 AM
  final success = await TopicSchedulingService.scheduleTopicForNextWeek(
    topicId: 42,
    weekday: DateTime.monday,
    hour: 9,
    minute: 0,
  );

  if (success) {
    print('✅ Topic programado para el próximo lunes');
  }
}

// ==========================================
// 📝 EJEMPLO 4: Programar para día específico del mes
// ==========================================

Future<void> example4ScheduleForDayOfMonth() async {
  // Programar para el día 15 del mes a las 10 AM
  final success = await TopicSchedulingService.scheduleTopicForDayOfMonth(
    topicId: 42,
    day: 15,
    hour: 10,
    minute: 0,
  );

  if (success) {
    print('✅ Topic programado para el día 15');
  }
}

// ==========================================
// 📝 EJEMPLO 5: Ver información de programación
// ==========================================

Future<void> example5GetScheduleInfo() async {
  final info = await TopicSchedulingService.getTopicScheduleInfo(42);

  if (info != null) {
    print('📊 Info del topic ${info.topicName}:');
    print('Estado: ${info.status}');
    print('Fecha de publicación: ${info.publishAt}');
    print('¿Ya notificado?: ${info.wasNotified}');

    if (info.timeUntilPublish != null) {
      final duration = info.timeUntilPublish!;
      print('Tiempo restante: ${duration.inHours} horas');
    }
  }
}

// ==========================================
// 📝 EJEMPLO 6: Ver topics pendientes
// ==========================================

Future<void> example6GetPendingTopics() async {
  final pending = await TopicSchedulingService.getPendingTopics();

  print('📋 Topics pendientes de publicar: ${pending.length}');

  for (final topic in pending) {
    final publishAt = DateTime.parse(topic['publish_at']);
    final timeUntil = publishAt.difference(DateTime.now());

    print('- ${topic['topic_name']}: en ${timeUntil.inHours} horas');
  }
}

// ==========================================
// 📝 EJEMPLO 7: Ver estadísticas
// ==========================================

Future<void> example7GetStatistics() async {
  final stats = await TopicSchedulingService.getScheduleStatistics();

  print('📊 Estadísticas:');
  print('Total programados: ${stats.totalScheduled}');
  print('Total publicados: ${stats.totalPublished}');
  print('Atrasados: ${stats.totalOverdue}');
  print('Pendientes: ${stats.totalPending}');
}

// ==========================================
// 📝 EJEMPLO 8: Cancelar programación
// ==========================================

Future<void> example8CancelSchedule() async {
  final success = await TopicSchedulingService.cancelTopicPublication(42);

  if (success) {
    print('🚫 Programación cancelada para el topic 42');
  }
}

// ==========================================
// 📝 EJEMPLO 9: Re-programar un topic
// ==========================================

Future<void> example9RescheduleTopicPublication() async {
  // Re-programar para dentro de 3 días
  final newDate = DateTime.now().add(Duration(days: 3));

  final success = await TopicSchedulingService.rescheduleTopicPublication(
    topicId: 42,
    newPublishAt: newDate,
  );

  if (success) {
    print('🔄 Topic re-programado para: $newDate');
  }
}

// ==========================================
// 📝 EJEMPLO 10: Widget de programación
// ==========================================

class ScheduleTopicDialog extends StatefulWidget {
  final int topicId;
  final String topicName;

  const ScheduleTopicDialog({
    Key? key,
    required this.topicId,
    required this.topicName,
  }) : super(key: key);

  @override
  State<ScheduleTopicDialog> createState() => _ScheduleTopicDialogState();
}

class _ScheduleTopicDialogState extends State<ScheduleTopicDialog> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isScheduling = false;
  String? _message;

  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 9, minute: 0),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  Future<void> _schedulePublication() async {
    if (_selectedDate == null || _selectedTime == null) {
      setState(() {
        _message = '⚠️ Selecciona fecha y hora';
      });
      return;
    }

    setState(() {
      _isScheduling = true;
      _message = null;
    });

    final publishAt = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final success = await TopicSchedulingService.scheduleTopicPublication(
      topicId: widget.topicId,
      publishAt: publishAt,
    );

    setState(() {
      _isScheduling = false;
      _message = success
          ? '✅ Programado para ${publishAt.toString()}'
          : '❌ Error al programar';
    });

    if (success) {
      await Future.delayed(Duration(seconds: 2));
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Programar: ${widget.topicName}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text(_selectedDate == null
                ? 'Seleccionar fecha'
                : 'Fecha: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
            onTap: () => _selectDate(context),
          ),
          ListTile(
            leading: Icon(Icons.access_time),
            title: Text(_selectedTime == null
                ? 'Seleccionar hora'
                : 'Hora: ${_selectedTime!.format(context)}'),
            onTap: () => _selectTime(context),
          ),
          if (_message != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _message!,
                style: TextStyle(
                  color: _message!.startsWith('✅')
                      ? Colors.green
                      : _message!.startsWith('❌')
                          ? Colors.red
                          : Colors.orange,
                ),
              ),
            ),
          if (_isScheduling)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isScheduling ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: _isScheduling ? null : _schedulePublication,
          icon: const Icon(Icons.schedule),
          label: const Text('Programar'),
        ),
      ],
    );
  }
}

// Uso del widget
void showScheduleDialog(BuildContext context, int topicId, String topicName) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => ScheduleTopicDialog(
      topicId: topicId,
      topicName: topicName,
    ),
  );

  if (result == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Topic programado exitosamente'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

// ==========================================
// 📝 EJEMPLO 11: Widget de lista de topics programados
// ==========================================

class ScheduledTopicsPage extends StatefulWidget {
  const ScheduledTopicsPage({Key? key}) : super(key: key);

  @override
  State<ScheduledTopicsPage> createState() => _ScheduledTopicsPageState();
}

class _ScheduledTopicsPageState extends State<ScheduledTopicsPage> {
  List<Map<String, dynamic>> _pendingTopics = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingTopics();
  }

  Future<void> _loadPendingTopics() async {
    setState(() {
      _isLoading = true;
    });

    final topics = await TopicSchedulingService.getPendingTopics();

    setState(() {
      _pendingTopics = topics;
      _isLoading = false;
    });
  }

  Future<void> _cancelSchedule(int topicId) async {
    final success = await TopicSchedulingService.cancelTopicPublication(topicId);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Programación cancelada')),
      );
      _loadPendingTopics();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Topics Programados'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPendingTopics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingTopics.isEmpty
              ? const Center(
                  child: Text('No hay topics programados'),
                )
              : ListView.builder(
                  itemCount: _pendingTopics.length,
                  itemBuilder: (context, index) {
                    final topic = _pendingTopics[index];
                    final publishAt = DateTime.parse(topic['publish_at']);
                    final timeUntil = publishAt.difference(DateTime.now());

                    return ListTile(
                      leading: Icon(
                        Icons.schedule,
                        color: timeUntil.isNegative
                            ? Colors.red
                            : Colors.blue,
                      ),
                      title: Text(topic['topic_name']),
                      subtitle: Text(
                        'Programado para: ${publishAt.toString()}\n'
                        '${timeUntil.isNegative ? "Atrasado" : "En ${timeUntil.inHours} horas"}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _cancelSchedule(topic['id']),
                      ),
                    );
                  },
                ),
    );
  }
}

// ==========================================
// 📝 EJEMPLO 12: Programar múltiples topics
// ==========================================

Future<void> example12ScheduleMultipleTopics() async {
  final topicIds = [42, 43, 44, 45];
  final baseDate = DateTime.now().add(Duration(days: 1));

  for (int i = 0; i < topicIds.length; i++) {
    // Programar cada topic con 1 día de diferencia
    final publishAt = baseDate.add(Duration(days: i));

    final success = await TopicSchedulingService.scheduleTopicPublication(
      topicId: topicIds[i],
      publishAt: publishAt,
    );

    print('Topic ${topicIds[i]}: ${success ? "✅" : "❌"} - $publishAt');

    // Pequeña pausa
    await Future.delayed(Duration(milliseconds: 100));
  }
}