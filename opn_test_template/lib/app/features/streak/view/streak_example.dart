import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/streak_cubit.dart';
import '../cubit/streak_state.dart';
import '../repository/streak_repository.dart';
import 'components/streak_widget.dart';
import 'components/streak_loading_widget.dart';
import 'components/streak_error_widget.dart';

/// Ejemplo de cómo usar el widget de racha en la home
///
/// Para usar este widget en tu home, simplemente añádelo así:
///
/// ```dart
/// StreakExample(userId: currentUserId)
/// ```
class StreakExample extends StatelessWidget {
  final int userId;

  const StreakExample({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StreakCubit(
        repository: StreakRepository(),
        userId: userId,
      )..loadStreakData(),
      child: BlocBuilder<StreakCubit, StreakState>(
        builder: (context, state) {
          return state.when(
            initial: () => const StreakLoadingWidget(),
            loading: () => const StreakLoadingWidget(),
            loaded: (streakData) => StreakWidget(
              streakData: streakData,
              onTap: () {
                // Aquí puedes navegar a una página de detalles de racha
                // o mostrar un diálogo con más información
                _showStreakDetails(context, streakData);
              },
            ),
            error: (message) => StreakErrorWidget(
              errorMessage: message,
              onRetry: () {
                context.read<StreakCubit>().loadStreakData();
              },
            ),
          );
        },
      ),
    );
  }

  void _showStreakDetails(BuildContext context, streakData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalles de Racha'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Racha actual: ${streakData.currentStreak} días'),
            const SizedBox(height: 8),
            Text('Récord personal: ${streakData.longestStreak} días'),
            const SizedBox(height: 8),
            Text('Badge: ${streakData.badge.emoji} ${streakData.badge.name}'),
            const SizedBox(height: 8),
            Text('Días completados esta semana: ${streakData.weekCompletedDays}/7'),
            const SizedBox(height: 16),
            Text(
              streakData.motivationalMessage,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
