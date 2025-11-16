import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opn_test_template/app/config/service_locator.dart';
import 'package:opn_test_template/app/config/widgets/app_bar/app_bar_menu.dart';
import 'package:opn_test_template/app/features/pomodoro/cubit/pomodoro_cubit.dart';
import 'package:opn_test_template/app/features/pomodoro/cubit/pomodoro_state.dart';
import '../model/pomodoro_config.dart';

class PomodoroPage extends StatelessWidget {
  const PomodoroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PomodoroCubit(getIt()),
      child: const _PomodoroView(),
    );
  }
}

class _PomodoroView extends StatelessWidget {
  const _PomodoroView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarMenu(
        title: 'Temporizador Pomodoro',
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.read<PomodoroCubit>().toggleSettings(),
          ),
        ],
      ),
      body: BlocBuilder<PomodoroCubit, PomodoroState>(
        builder: (context, state) {
          if (state.showingSettings) {
            return const _SettingsView();
          }
          return const _TimerView();
        },
      ),
    );
  }
}

class _TimerView extends StatelessWidget {
  const _TimerView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SessionInfo(),
          const SizedBox(height: 32),
          const _CircularTimer(),
          const SizedBox(height: 48),
          const _TimerControls(),
          const SizedBox(height: 32),
          const _SessionProgress(),
          const SizedBox(height: 24),
          const _DailyStats(),
        ],
      ),
    );
  }
}

class _SessionInfo extends StatelessWidget {
  const _SessionInfo();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<PomodoroCubit, PomodoroState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Text(
                state.sessionIcon,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.sessionName,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getSessionDescription(state),
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getSessionDescription(PomodoroState state) {
    if (state.isWorkSession) {
      final remaining = state.config.sessionsBeforeLongBreak - state.completedSessions;
      return '$remaining sesiones hasta descanso largo';
    } else {
      return 'Relájate y recarga energías';
    }
  }
}

class _CircularTimer extends StatelessWidget {
  const _CircularTimer();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return BlocBuilder<PomodoroCubit, PomodoroState>(
      builder: (context, state) {
        return Center(
          child: SizedBox(
            width: 280,
            height: 280,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Círculo de progreso
                CustomPaint(
                  size: const Size(280, 280),
                  painter: _CircularProgressPainter(
                    progress: state.progress,
                    backgroundColor: colors.surfaceContainerHighest,
                    progressColor: _getProgressColor(state, colors),
                  ),
                ),
                // Tiempo restante
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.formattedTime,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colors.onSurface,
                            fontSize: 56,
                            fontFeatures: [const FontFeature.tabularFigures()],
                          ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getProgressColor(state, colors).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getStatusText(state),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: _getProgressColor(state, colors),
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
      },
    );
  }

  Color _getProgressColor(PomodoroState state, ColorScheme colors) {
    if (state.isWorkSession) {
      return colors.primary;
    } else if (state.sessionType == PomodoroSessionType.shortBreak) {
      return colors.secondary;
    } else {
      return colors.tertiary;
    }
  }

  String _getStatusText(PomodoroState state) {
    switch (state.timerStatus) {
      case TimerStatus.initial:
        return 'Listo para comenzar';
      case TimerStatus.running:
        return 'En progreso';
      case TimerStatus.paused:
        return 'Pausado';
      case TimerStatus.completed:
        return 'Completado';
    }
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;

  _CircularProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Círculo de fondo
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - 6, backgroundPaint);

    // Círculo de progreso
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 6),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _TimerControls extends StatelessWidget {
  const _TimerControls();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return BlocBuilder<PomodoroCubit, PomodoroState>(
      builder: (context, state) {
        final cubit = context.read<PomodoroCubit>();

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Botón de reset
            if (state.timerStatus != TimerStatus.initial)
              _ControlButton(
                icon: Icons.refresh_rounded,
                onPressed: cubit.reset,
                backgroundColor: colors.surfaceContainerHighest,
                foregroundColor: colors.onSurfaceVariant,
              ),
            if (state.timerStatus != TimerStatus.initial) const SizedBox(width: 16),

            // Botón principal (play/pause)
            _ControlButton(
              icon: state.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
              onPressed: state.isRunning ? cubit.pause : cubit.start,
              backgroundColor: _getProgressColor(state, colors),
              foregroundColor: Colors.white,
              isLarge: true,
            ),

            if (state.timerStatus != TimerStatus.initial) const SizedBox(width: 16),
            // Botón de skip
            if (state.timerStatus != TimerStatus.initial)
              _ControlButton(
                icon: Icons.skip_next_rounded,
                onPressed: cubit.skipSession,
                backgroundColor: colors.surfaceContainerHighest,
                foregroundColor: colors.onSurfaceVariant,
              ),
          ],
        );
      },
    );
  }

  Color _getProgressColor(PomodoroState state, ColorScheme colors) {
    if (state.isWorkSession) {
      return colors.primary;
    } else if (state.sessionType == PomodoroSessionType.shortBreak) {
      return colors.secondary;
    } else {
      return colors.tertiary;
    }
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
    this.isLarge = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool isLarge;

  @override
  Widget build(BuildContext context) {
    final size = isLarge ? 72.0 : 56.0;
    final iconSize = isLarge ? 36.0 : 24.0;

    return SizedBox(
      width: size,
      height: size,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
          elevation: 4,
        ),
        child: Icon(icon, size: iconSize),
      ),
    );
  }
}

class _SessionProgress extends StatelessWidget {
  const _SessionProgress();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return BlocBuilder<PomodoroCubit, PomodoroState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.local_fire_department_outlined, color: colors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Progreso de la sesión',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.onSurface,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  state.config.sessionsBeforeLongBreak,
                  (index) => _SessionDot(
                    isCompleted: index < state.completedSessions,
                    isCurrent: index == state.completedSessions && state.isWorkSession,
                    colors: colors,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  '${state.completedSessions} de ${state.config.sessionsBeforeLongBreak} sesiones',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SessionDot extends StatelessWidget {
  const _SessionDot({
    required this.isCompleted,
    required this.isCurrent,
    required this.colors,
  });

  final bool isCompleted;
  final bool isCurrent;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isCompleted
            ? colors.primary
            : isCurrent
                ? colors.primary.withValues(alpha: 0.3)
                : colors.surfaceContainerHighest,
        shape: BoxShape.circle,
        border: isCurrent ? Border.all(color: colors.primary, width: 2) : null,
      ),
      child: isCompleted
          ? Icon(Icons.check, color: colors.onPrimary, size: 20)
          : null,
    );
  }
}

class _DailyStats extends StatelessWidget {
  const _DailyStats();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return BlocBuilder<PomodoroCubit, PomodoroState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, color: colors.secondary),
                  const SizedBox(width: 8),
                  Text(
                    'Estadísticas de hoy',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.onSurface,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.task_alt,
                      label: 'Sesiones',
                      value: '${state.totalSessionsToday}',
                      colors: colors,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.schedule,
                      label: 'Minutos',
                      value: '${state.totalMinutesToday}',
                      colors: colors,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.colors,
  });

  final IconData icon;
  final String label;
  final String value;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: colors.primary, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _SettingsView extends StatefulWidget {
  const _SettingsView();

  @override
  State<_SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<_SettingsView> {
  late PomodoroConfig _config;

  @override
  void initState() {
    super.initState();
    _config = context.read<PomodoroCubit>().state.config;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configuración',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
          ),
          const SizedBox(height: 24),
          _DurationSetting(
            title: 'Duración de trabajo',
            icon: Icons.work_outline,
            value: _config.workDuration,
            onChanged: (value) {
              setState(() {
                _config = _config.copyWith(workDuration: value);
              });
            },
          ),
          const SizedBox(height: 16),
          _DurationSetting(
            title: 'Descanso corto',
            icon: Icons.coffee_outlined,
            value: _config.shortBreakDuration,
            onChanged: (value) {
              setState(() {
                _config = _config.copyWith(shortBreakDuration: value);
              });
            },
          ),
          const SizedBox(height: 16),
          _DurationSetting(
            title: 'Descanso largo',
            icon: Icons.hotel_outlined,
            value: _config.longBreakDuration,
            onChanged: (value) {
              setState(() {
                _config = _config.copyWith(longBreakDuration: value);
              });
            },
          ),
          const SizedBox(height: 16),
          _DurationSetting(
            title: 'Sesiones hasta descanso largo',
            icon: Icons.repeat,
            value: _config.sessionsBeforeLongBreak,
            onChanged: (value) {
              setState(() {
                _config = _config.copyWith(sessionsBeforeLongBreak: value);
              });
            },
            max: 10,
          ),
          const SizedBox(height: 24),
          _SwitchSetting(
            title: 'Sonido',
            icon: Icons.volume_up_outlined,
            value: _config.soundEnabled,
            onChanged: (value) {
              setState(() {
                _config = _config.copyWith(soundEnabled: value);
              });
            },
          ),
          const SizedBox(height: 16),
          _SwitchSetting(
            title: 'Notificaciones',
            icon: Icons.notifications_outlined,
            value: _config.notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _config = _config.copyWith(notificationsEnabled: value);
              });
            },
          ),
          const SizedBox(height: 16),
          _SwitchSetting(
            title: 'Auto-iniciar descansos',
            icon: Icons.play_circle_outline,
            value: _config.autoStartBreaks,
            onChanged: (value) {
              setState(() {
                _config = _config.copyWith(autoStartBreaks: value);
              });
            },
          ),
          const SizedBox(height: 16),
          _SwitchSetting(
            title: 'Auto-iniciar trabajo',
            icon: Icons.play_circle_outline,
            value: _config.autoStartWork,
            onChanged: (value) {
              setState(() {
                _config = _config.copyWith(autoStartWork: value);
              });
            },
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.read<PomodoroCubit>().updateConfig(_config);
                context.read<PomodoroCubit>().toggleSettings();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Guardar cambios'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DurationSetting extends StatelessWidget {
  const _DurationSetting({
    required this.title,
    required this.icon,
    required this.value,
    required this.onChanged,
    this.max = 60,
  });

  final String title;
  final IconData icon;
  final int value;
  final ValueChanged<int> onChanged;
  final int max;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: colors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                ),
              ),
              Text(
                '$value min',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Slider(
            value: value.toDouble(),
            min: 1,
            max: max.toDouble(),
            divisions: max - 1,
            onChanged: (newValue) => onChanged(newValue.round()),
          ),
        ],
      ),
    );
  }
}

class _SwitchSetting extends StatelessWidget {
  const _SwitchSetting({
    required this.title,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}