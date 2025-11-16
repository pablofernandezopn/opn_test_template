// EJEMPLOS DE USO DEL SERVICIO DE COMPARTIR TESTS
// Este archivo contiene ejemplos de cómo usar TestSharingService

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'test_sharing_service.dart';
import '../../../bootstrap.dart';

// ==========================================
// 📝 EJEMPLO 1: Compartir con UN solo usuario
// ==========================================

Future<void> example1ShareWithOneUser() async {
  // Compartir test individual
  final success = await TestSharingService.shareTopicWithUser(
    userId: 123,
    topicId: 42,
    topicName: 'Constitución Española',
    totalQuestions: 50,
    durationMinutes: 60,
    imageUrl: 'https://cdn.example.com/constitucion.png',
  );

  if (success) {
    logger.info('✅ Test compartido exitosamente con el usuario 123');
  } else {
    logger.error('❌ Error al compartir test');
  }
}

// ==========================================
// 📝 EJEMPLO 2: Compartir con LISTA de usuarios
// ==========================================

Future<void> example2ShareWithList() async {
  // Lista de IDs de usuarios
  final userIds = [123, 456, 789, 101, 202];

  final result = await TestSharingService.shareTopicWithUsers(
    userIds: userIds,
    topicId: 42,
    topicName: 'Derecho Penal',
    totalQuestions: 30,
    durationMinutes: 45,
    imageUrl: 'https://cdn.example.com/derecho-penal.png',
  );

  logger.info('📊 Resultado: $result');
  logger.info('✅ Exitosos: ${result.successCount}/${result.totalSent}');
  logger.info('❌ Fallidos: ${result.failureCount}');

  // Ver detalles por usuario
  result.results.forEach((userId, success) {
    logger.info('Usuario $userId: ${success ? "✅" : "❌"}');
  });
}

// ==========================================
// 📝 EJEMPLO 3: Compartir con TODOS los usuarios
// ==========================================

Future<void> example3ShareWithAllUsers() async {
  // Compartir con TODOS los usuarios que tienen FCM token
  final result = await TestSharingService.shareTopicWithAllUsers(
    topicId: 42,
    topicName: 'Simulacro Oficial 2024',
    totalQuestions: 100,
    durationMinutes: 120,
    imageUrl: 'https://cdn.example.com/simulacro.png',
  );

  logger.info('📊 Compartido con todos los usuarios');
  logger.info('Total: ${result.totalSent} usuarios');
  logger.info('Exitosos: ${result.successCount}');
  logger.info('Fallidos: ${result.failureCount}');
  logger.info('Tasa de éxito: ${(result.successRate * 100).toStringAsFixed(1)}%');
}

// ==========================================
// 📝 EJEMPLO 4: Compartir test GRUPAL con todos
// ==========================================

Future<void> example4ShareGroupWithAllUsers() async {
  final result = await TestSharingService.shareTopicGroupWithAllUsers(
    topicGroupId: 15,
    groupName: 'Examen Completo Guardia Civil',
    totalParts: 3,
    totalQuestions: 100,
    imageUrl: 'https://cdn.example.com/examen-completo.png',
  );

  logger.info('📊 Test grupal compartido con ${result.totalSent} usuarios');
  logger.info('Tasa de éxito: ${(result.successRate * 100).toStringAsFixed(1)}%');
}

// ==========================================
// 📝 EJEMPLO 5: Compartir solo con usuarios PREMIUM
// ==========================================

Future<void> example5ShareWithPremiumUsers() async {
  final result = await TestSharingService.shareTopicWithPremiumUsers(
    topicId: 99,
    topicName: 'Test Premium - Casos Prácticos',
    totalQuestions: 40,
    durationMinutes: 80,
    imageUrl: 'https://cdn.example.com/premium.png',
  );

  logger.info('📊 Compartido con usuarios premium');
  logger.info('Total: ${result.totalSent} usuarios premium');
}

// ==========================================
// 📝 EJEMPLO 6: Compartir con usuarios de una academia
// ==========================================

Future<void> example6ShareWithAcademy() async {
  final academyId = 1; // ID de tu academia

  final result = await TestSharingService.shareTopicWithAcademyUsers(
    academyId: academyId,
    topicId: 42,
    topicName: 'Test Exclusivo Academia',
    totalQuestions: 50,
    durationMinutes: 60,
  );

  logger.info('📊 Compartido con usuarios de la academia $academyId');
  logger.info('Total: ${result.totalSent} usuarios');
}

// ==========================================
// 📝 EJEMPLO 7: Uso desde un botón en la UI
// ==========================================

// Ejemplo de cómo llamarlo desde un botón en tu UI
Future<void> example7FromButton({
  required int topicId,
  required String topicName,
  required Function(String) showMessage,
  required Function() showLoading,
  required Function() hideLoading,
}) async {
  showLoading();

  final result = await TestSharingService.shareTopicWithAllUsers(
    topicId: topicId,
    topicName: topicName,
  );

  hideLoading();

  if (result.allSuccess) {
    showMessage('✅ Test compartido con ${result.totalSent} usuarios');
  } else {
    showMessage('⚠️ Compartido con ${result.successCount}/${result.totalSent} usuarios. ${result.failureCount} fallidos.');
  }
}

// ==========================================
// 📝 EJEMPLO 8: Obtener IDs de usuarios con query personalizada
// ==========================================

Future<void> example8CustomQuery() async {
  // Ejemplo: Compartir solo con usuarios activos en los últimos 7 días
  final sevenDaysAgo = DateTime.now().subtract(Duration(days: 7));

  final response = await Supabase.instance.client
      .from('users')
      .select('id')
      .gte('last_activity', sevenDaysAgo.toIso8601String())
      .not('fcm_token', 'is', null);

  final users = response as List<dynamic>;
  final userIds = users.map((u) => u['id'] as int).toList();

  logger.info('📋 Usuarios activos últimos 7 días: ${userIds.length}');

  if (userIds.isNotEmpty) {
    final result = await TestSharingService.shareTopicWithUsers(
      userIds: userIds,
      topicId: 42,
      topicName: 'Test para usuarios activos',
    );

    logger.info('📊 Resultado: $result');
  }
}

// ==========================================
// 📝 EJEMPLO 9: Widget completo con botones
// ==========================================

class ShareTestDialog extends StatefulWidget {
  final int topicId;
  final String topicName;
  final bool isGroup;

  const ShareTestDialog({
    Key? key,
    required this.topicId,
    required this.topicName,
    this.isGroup = false,
  }) : super(key: key);

  @override
  State<ShareTestDialog> createState() => _ShareTestDialogState();
}

class _ShareTestDialogState extends State<ShareTestDialog> {
  bool _isSharing = false;
  String? _resultMessage;

  Future<void> _shareWithAll() async {
    setState(() {
      _isSharing = true;
      _resultMessage = null;
    });

    try {
      final result = widget.isGroup
          ? await TestSharingService.shareTopicGroupWithAllUsers(
              topicGroupId: widget.topicId,
              groupName: widget.topicName,
            )
          : await TestSharingService.shareTopicWithAllUsers(
              topicId: widget.topicId,
              topicName: widget.topicName,
            );

      setState(() {
        _resultMessage = '✅ Compartido con ${result.successCount}/${result.totalSent} usuarios';
      });
    } catch (e) {
      setState(() {
        _resultMessage = '❌ Error: $e';
      });
    } finally {
      setState(() {
        _isSharing = false;
      });
    }
  }

  Future<void> _shareWithPremium() async {
    setState(() {
      _isSharing = true;
      _resultMessage = null;
    });

    try {
      final result = await TestSharingService.shareTopicWithPremiumUsers(
        topicId: widget.topicId,
        topicName: widget.topicName,
      );

      setState(() {
        _resultMessage = '✅ Compartido con ${result.successCount} usuarios premium';
      });
    } catch (e) {
      setState(() {
        _resultMessage = '❌ Error: $e';
      });
    } finally {
      setState(() {
        _isSharing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Compartir: ${widget.topicName}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isSharing)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          if (_resultMessage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _resultMessage!,
                style: TextStyle(
                  color: _resultMessage!.startsWith('✅')
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSharing ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: _isSharing ? null : _shareWithAll,
          icon: const Icon(Icons.people),
          label: const Text('Todos los usuarios'),
        ),
        ElevatedButton.icon(
          onPressed: _isSharing ? null : _shareWithPremium,
          icon: const Icon(Icons.star),
          label: const Text('Solo Premium'),
        ),
      ],
    );
  }
}

// Uso del widget:
void showShareDialog(BuildContext context, int topicId, String topicName) {
  showDialog(
    context: context,
    builder: (context) => ShareTestDialog(
      topicId: topicId,
      topicName: topicName,
    ),
  );
}