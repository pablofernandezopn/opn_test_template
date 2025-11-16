import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opn_test_guardia_civil_cms/app/config/theme/color_scheme_extensions.dart';
import 'package:opn_test_guardia_civil_cms/app/features/users/cubit/cubit.dart';
import 'package:opn_test_guardia_civil_cms/app/features/users/model/user.dart';
import 'package:opn_test_guardia_civil_cms/app/features/users/model/user_test.dart';
import 'package:opn_test_guardia_civil_cms/app/features/users/repository/user_repository.dart';
import 'package:opn_test_guardia_civil_cms/bootstrap.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

enum TimePeriod {
  daily,
  monthly,
}

extension TimePeriodExtension on TimePeriod {
  String get label {
    switch (this) {
      case TimePeriod.daily:
        return 'Todo';
      case TimePeriod.monthly:
        return 'Este Mes';
    }
  }

  IconData get icon {
    switch (this) {
      case TimePeriod.daily:
        return Icons.all_inclusive;
      case TimePeriod.monthly:
        return Icons.calendar_month;
    }
  }
}

class UserStatsPage extends StatefulWidget {
  static const String route = '/students/:id/stats';
  final String userId;

  const UserStatsPage({
    super.key,
    required this.userId,
  });

  @override
  State<UserStatsPage> createState() => _UserStatsPageState();
}

class _UserStatsPageState extends State<UserStatsPage> {
  User? _user;
  String _selectedTab = '';
  bool _loading = false;
  List<Map<String, dynamic>> _mockTopicTypes = [];
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  final UserRepository _userRepository = UserRepository();
  List<UserTest> _userTests = [];
  bool _loadingTests = false;
  TimePeriod _selectedPeriod = TimePeriod.daily;

  // Metrics display flags
  bool _showErrorRate = false;
  bool _showEmptyRate = false;
  bool _showSuccessRate = false;

  // Track which cards are showing buttons
  final Map<int, bool> _showButtonsMap = {};

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadMockTopicTypes();
  }

  void _loadUser() {
    setState(() {
      _loading = true;
    });

    final userState = context.read<UserCubit>().state;
    final userId = int.tryParse(widget.userId);

    if (userId != null) {
      _user = userState.users.firstWhere(
        (user) => user.id == userId,
        orElse: () => User.empty,
      );
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> _loadMockTopicTypes() async {
    try {
      final response = await _supabaseClient
          .from('topic_type')
          .select('id, topic_type_name, description')
          .eq('level', 'Mock')
          .order('order_of_appearance', ascending: true);

      setState(() {
        _mockTopicTypes = List<Map<String, dynamic>>.from(response);

        // logger.debug('esqure', _mockTopicTypes);
        // Establecer la primera pestaña como seleccionada por defecto
        if (_mockTopicTypes.isNotEmpty && _selectedTab.isEmpty) {
          _selectedTab = _mockTopicTypes.first['topic_type_name'];
          // Cargar los tests para la primera pestaña
          _loadUserTests(_mockTopicTypes.first['id']);
        }
      });
    } catch (e) {
      // Si hay error, continuar sin topic types
      setState(() {
        _mockTopicTypes = [];
      });
    }
  }

  Future<void> _loadUserTests(int topicTypeId) async {
    if (_user == null) return;

    setState(() {
      _loadingTests = true;
    });

    try {
      logger.info(
        'Loading tests for user ${_user!.id} and topic_type $topicTypeId',
      );

      final tests = await _userRepository.fetchUserTestsByTopicType(
        userId: _user!.id,
        topicTypeId: topicTypeId,
      );

      logger.info('Loaded ${tests.length} tests successfully');

      setState(() {
        _userTests = tests;
        _loadingTests = false;
      });
    } catch (e, stackTrace) {
      logger.error(
        'Error loading user tests',
        // error: e,
        // stackTrace: stackTrace,
      );

      setState(() {
        _userTests = [];
        _loadingTests = false;
      });
    }
  }

  Future<void> _refreshStatistics() async {
    setState(() {
      _loading = true;
    });

    try {
      final userId = int.tryParse(widget.userId);
      if (userId == null) {
        setState(() {
          _loading = false;
        });
        return;
      }

      // Hacer fetch real del usuario desde la base de datos para actualizar KPIs
      final updatedUser = await _userRepository.fetchUserById(userId);

      setState(() {
        _user = updatedUser;
      });

      // Recargar los topic types
      await _loadMockTopicTypes();

      // Recargar tests de la pestaña actualmente seleccionada
      if (_mockTopicTypes.isNotEmpty && _selectedTab.isNotEmpty) {
        final topicType = _mockTopicTypes.firstWhere(
          (type) => type['topic_type_name'] == _selectedTab,
          orElse: () => {},
        );

        if (topicType.isNotEmpty) {
          await _loadUserTests(topicType['id']);
        }
      }
    } catch (e) {
      logger.error('Error refreshing statistics');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _onTabChanged(String tabName, int topicTypeId) {
    setState(() {
      _selectedTab = tabName;
    });
    _loadUserTests(topicTypeId);
  }

  void _onPeriodChanged(TimePeriod period) {
    setState(() {
      _selectedPeriod = period;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Estadísticas de Usuario'),
          foregroundColor: colorScheme.onPrimary,
        ),
        backgroundColor: colorScheme.surfaceContainerLowest,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadowMedium,
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: colorScheme.primary,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Cargando estadísticas...',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Obteniendo datos del usuario',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_user == null || _user!.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Usuario no encontrado'),
          foregroundColor: colorScheme.onPrimary,
        ),
        backgroundColor: colorScheme.surfaceContainerLowest,
        body: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: colorScheme.outlineVariant,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadowLight,
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_off,
                    size: 64,
                    color: colorScheme.error,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Usuario no encontrado',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'No se pudo cargar la información del usuario.\nPor favor, verifica el ID e intenta nuevamente.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _loadUser(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                    const SizedBox(width: 16),
                    FilledButton.icon(
                      onPressed: () => context.go('/students'),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Volver a Usuarios'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 20,
              backgroundColor: colorScheme.primaryContainer,
              backgroundImage: _user!.profileImage != null
                  ? NetworkImage(_user!.profileImage!)
                  : null,
              child: _user!.profileImage == null
                  ? Text(
                      _user!.initials,
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // Información del usuario
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          _user!.fullName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            // color: colorScheme.onPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // const SizedBox(width: 8),
                      // Container(
                      //   padding: const EdgeInsets.symmetric(
                      //     horizontal: 8,
                      //     vertical: 4,
                      //   ),
                      //   decoration: BoxDecoration(
                      //     color: _getRoleColor(_user!.roleId, colorScheme),
                      //     borderRadius: BorderRadius.circular(8),
                      //   ),
                      //   child: Row(
                      //     mainAxisSize: MainAxisSize.min,
                      //     children: [
                      //       Icon(
                      //         _getRoleIcon(_user!.roleId),
                      //         size: 12,
                      //         color: Colors.white,
                      //       ),
                      //       const SizedBox(width: 4),
                      //       Text(
                      //         _user!.roleName,
                      //         style: const TextStyle(
                      //           color: Colors.white,
                      //           fontSize: 10,
                      //           fontWeight: FontWeight.w600,
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@${_user!.username}',
                    style: theme.textTheme.bodySmall?.copyWith(
                        // color: colorScheme.onPrimary.withOpacity(0.8),
                        fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Botón de refrescar estadísticas
          IconButton(
            onPressed: _refreshStatistics,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refrescar estadísticas',
          ),
        ],
        foregroundColor: colorScheme.onPrimary,
      ),
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            // KPIs del Usuario
            _buildImprovedKpisUser(theme, colorScheme),
            const SizedBox(height: 8),

            // Sistema de pestañas
            _buildTabSelector(theme, colorScheme),
            const SizedBox(height: 8),

            // Contenido según pestaña seleccionada
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _buildTabContent(theme, colorScheme),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ============================================
  // WIDGETS KPI - Estadísticas del Usuario
  // ============================================

  Widget _buildImprovedKpisUser(ThemeData theme, ColorScheme colorScheme) {
    if (_user == null) return const SizedBox.shrink();

    logger.info('User OPn index ${_user!.userOpnIndex}');

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildImprovedKpiBlock(
              title: 'Índice OPN',
              value: _user!.userOpnIndex != null
                  ? _user!.userOpnIndex!.opnIndex.toString()
                  : 'N/A',
              subtitle: _user!.userOpnIndex?.globalRank != null
                  ? 'Ranking global: #${_user!.userOpnIndex!.globalRank}'
                  : 'Sin ranking aún',
              indicator:
                  _getOpnIndexIndicator(_user!.userOpnIndex?.opnIndex ?? 0, colorScheme),
              progress: _user!.userOpnIndex != null
                  ? (_user!.userOpnIndex!.opnIndex / 1000)
                  : 0,
              colorScheme: colorScheme,
              theme: theme,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildImprovedKpiBlock(
              title: 'Actividad de Práctica',
              value: _formatNumber(_user!.totalQuestions),
              subtitle: 'preguntas contestadas',
              indicator: _getActivityIndicator(
                _user!.totalQuestions,
                _user!.createdAt ?? DateTime.now(),
                colorScheme,
              ),
              progress: _getActivityProgress(
                _user!.totalQuestions,
                _user!.createdAt ?? DateTime.now(),
              ),
              colorScheme: colorScheme,
              theme: theme,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildImprovedKpiBlock(
              title: 'Experiencia',
              value: _getTimeLabel(_user!.createdAt ?? DateTime.now()),
              subtitle: _getTimeDescription(
                _user!.createdAt ?? DateTime.now(),
                _user!.lastUsed,
              ),
              indicator: _getExperienceIndicator(
                _user!.createdAt ?? DateTime.now(),
                colorScheme,
              ),
              progress: _getExperienceProgress(
                _user!.createdAt ?? DateTime.now(),
              ),
              colorScheme: colorScheme,
              theme: theme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImprovedKpiBlock({
    required String title,
    required String value,
    required String subtitle,
    required Widget indicator,
    required double progress,
    required ColorScheme colorScheme,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              indicator,
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getProgressColorFromValue(progress, colorScheme),
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  //

  Widget _buildPerformanceCard(
    String title,
    String percentage,
    String description,
    double rate,
    Color color,
    IconData icon,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            percentage,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: color.withOpacity(0.2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: rate.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // HELPERS PARA LOS KPI
  // ============================================

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _formatPercentage(double rate) {
    return '${(rate * 100).toStringAsFixed(1)}%';
  }

  Widget _getOpnIndexIndicator(int opnIndex, ColorScheme colorScheme) {
    if (opnIndex >= 800) {
      return _buildBadge('Elite', colorScheme.badgeElite, Icons.emoji_events);
    } else if (opnIndex >= 600) {
      return _buildBadge('Excelente', colorScheme.badgeExcellent, Icons.star);
    } else if (opnIndex >= 400) {
      return _buildBadge('Bueno', colorScheme.badgeGood, Icons.thumb_up);
    } else if (opnIndex >= 200) {
      return _buildBadge('Regular', colorScheme.badgeRegular, Icons.trending_up);
    } else if (opnIndex > 0) {
      return _buildBadge('Inicial', colorScheme.badgeInitial, Icons.show_chart);
    } else {
      return _buildBadge('Sin datos', colorScheme.badgeInitial, Icons.help_outline);
    }
  }

  Widget _getGradeIndicator(double grade, ColorScheme colorScheme) {
    if (grade >= 7) {
      return _buildBadge('Excelente', colorScheme.badgeExcellent, Icons.star);
    } else if (grade >= 5) {
      return _buildBadge('Bueno', colorScheme.badgeGood, Icons.thumb_up);
    } else if (grade >= 4) {
      return _buildBadge('Regular', colorScheme.badgeRegular, Icons.trending_up);
    } else {
      return _buildBadge('Mejorar', colorScheme.badgeNeedsImprovement, Icons.trending_down);
    }
  }

  Widget _getActivityIndicator(int totalQuestions, DateTime createdAt, ColorScheme colorScheme) {
    final monthsActive = DateTime.now().difference(createdAt).inDays / 30;
    final questionsPerMonth = monthsActive > 0
        ? totalQuestions / monthsActive
        : totalQuestions.toDouble();

    if (questionsPerMonth >= 100) {
      return _buildBadge(
        'Muy Activo',
        colorScheme.badgeVeryActive,
        Icons.local_fire_department,
      );
    } else if (questionsPerMonth >= 50) {
      return _buildBadge('Activo', colorScheme.badgeActive, Icons.trending_up);
    } else {
      return _buildBadge('Poco Activo', colorScheme.badgeLowActivity, Icons.schedule);
    }
  }

  double _getActivityProgress(int totalQuestions, DateTime createdAt) {
    final monthsActive = DateTime.now().difference(createdAt).inDays / 30;
    final questionsPerMonth = monthsActive > 0
        ? totalQuestions / monthsActive
        : totalQuestions.toDouble();
    return (questionsPerMonth / 150).clamp(0.0, 1.0);
  }

  Widget _getExperienceIndicator(DateTime createdAt, ColorScheme colorScheme) {
    final months = DateTime.now().difference(createdAt).inDays / 30;

    if (months >= 6) {
      return _buildBadge('Veterano', colorScheme.badgeVeteran, Icons.military_tech);
    } else if (months >= 1) {
      return _buildBadge('Intermedio', colorScheme.badgeActive, Icons.trending_up);
    } else {
      return _buildBadge('Nuevo', colorScheme.badgeNew, Icons.new_releases);
    }
  }

  String _getTimeLabel(DateTime createdAt) {
    final months = DateTime.now().difference(createdAt).inDays / 30;

    if (months >= 12) {
      return '${(months / 12).floor()} año${(months / 12).floor() > 1 ? 's' : ''}';
    } else if (months >= 1) {
      return '${months.floor()} mes${months.floor() > 1 ? 'es' : ''}';
    } else {
      final days = DateTime.now().difference(createdAt).inDays;
      return '$days día${days > 1 ? 's' : ''}';
    }
  }

  String _getTimeDescription(DateTime createdAt, DateTime? lastUsed) {
    if (lastUsed == null) return 'Nunca ha usado la app';

    final daysSinceLastUse = DateTime.now().difference(lastUsed).inDays;
    if (daysSinceLastUse == 0) return 'Activo hoy';
    if (daysSinceLastUse == 1) return 'Activo ayer';
    if (daysSinceLastUse <= 7) return 'Activo esta semana';
    if (daysSinceLastUse <= 30) return 'Activo este mes';
    return 'Inactivo $daysSinceLastUse días';
  }

  double _getExperienceProgress(DateTime createdAt) {
    final months = DateTime.now().difference(createdAt).inDays / 30;
    return (months / 12).clamp(0.0, 1.0);
  }

  Widget _buildBadge(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColorFromValue(double progress, ColorScheme colorScheme) {
    if (progress >= 0.8) return colorScheme.progressHigh;
    if (progress >= 0.6) return colorScheme.progressMediumHigh;
    if (progress >= 0.4) return colorScheme.progressMediumLow;
    return colorScheme.progressLow;
  }

  Widget _getOverallPerformanceBadge(
    double successRate,
    ColorScheme colorScheme,
  ) {
    if (successRate >= 0.8) {
      return _buildStatusBadge('Excelente', colorScheme.badgeExcellent, Icons.emoji_events, colorScheme);
    } else if (successRate >= 0.6) {
      return _buildStatusBadge('Bueno', colorScheme.badgeGood, Icons.thumb_up, colorScheme);
    } else if (successRate >= 0.4) {
      return _buildStatusBadge(
        'En progreso',
        colorScheme.badgeRegular,
        Icons.trending_up,
        colorScheme,
      );
    } else {
      return _buildStatusBadge(
        'Necesita práctica',
        colorScheme.badgeNeedsImprovement,
        Icons.school,
        colorScheme,
      );
    }
  }

  Widget _buildStatusBadge(String text, Color color, IconData icon, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.chartDotStroke),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.chartDotStroke,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // FIN DE WIDGETS KPI
  // ============================================

  // ============================================
  // GRÁFICA DE TESTS
  // ============================================

  Widget _buildTestsChart(ThemeData theme, ColorScheme colorScheme) {
    if (_userTests.isEmpty) {
      return _buildEmptyTestsState(colorScheme);
    }

    // Usar tests filtrados para las estadísticas
    final filteredTests = _getFilteredTests();
    if (filteredTests.isEmpty) {
      return _buildEmptyTestsState(colorScheme);
    }

    final avgScore =
        filteredTests.map((t) => t.score ?? 0).reduce((a, b) => a + b) /
            filteredTests.length;
    final avgSuccessRate =
        filteredTests.map((t) => t.successRate * 100).reduce((a, b) => a + b) /
            filteredTests.length;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadowLight,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with statistics
          Row(
            children: [
              Icon(Icons.analytics, color: colorScheme.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                'Evolución de Rendimiento',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Summary cards
          SizedBox(
            height: 110,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildSummaryCard(
                  'Total Tests',
                  filteredTests.length.toString(),
                  Icons.quiz,
                  colorScheme.totalTests,
                  colorScheme,
                ),
                _buildSummaryCard(
                  'Nota Media',
                  avgScore.toStringAsFixed(1),
                  Icons.star,
                  colorScheme.mediumScores,
                  colorScheme,
                ),
                _buildSummaryCard(
                  'Tasa Acierto',
                  '${avgSuccessRate.toStringAsFixed(1)}%',
                  Icons.check_circle,
                  colorScheme.successRate,
                  colorScheme,
                ),
                _buildSummaryCard(
                  'Tasa Error',
                  '${(filteredTests.map((t) => t.errorRate * 100).reduce((a, b) => a + b) / filteredTests.length).toStringAsFixed(1)}%',
                  Icons.error,
                  colorScheme.errorRate,
                  colorScheme,
                ),
                _buildSummaryCard(
                  'Tasa Abandono',
                  '${(filteredTests.map((t) => t.emptyRate * 100).reduce((a, b) => a + b) / filteredTests.length).toStringAsFixed(1)}%',
                  Icons.remove_circle,
                  colorScheme.dropRate,
                  colorScheme,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Chart
          SizedBox(
            height: 400,
            child: _buildLineChart(colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
    ColorScheme colorScheme,
  ) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  List<UserTest> _getFilteredTests() {
    final now = DateTime.now();
    final sortedTests = List<UserTest>.from(_userTests)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    switch (_selectedPeriod) {
      case TimePeriod.daily:
        // Todo el historial
        return sortedTests;

      case TimePeriod.monthly:
        // Tests del mes actual
        final startOfMonth = DateTime(now.year, now.month, 1);
        return sortedTests
            .where((test) => test.createdAt.isAfter(startOfMonth))
            .toList();
    }
  }

  Widget _buildLineChart(ColorScheme colorScheme) {
    final filteredTests = _getFilteredTests();
    if (filteredTests.isEmpty) {
      return _buildEmptyTestsState(colorScheme);
    }

    return Padding(
      padding: const EdgeInsets.only(right: 24),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            drawVerticalLine: false,
            horizontalInterval: 20,
            getDrawingHorizontalLine: (value) => FlLine(
              color: colorScheme.outlineVariant,
              strokeWidth: 1,
              dashArray: [3, 3],
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 20,
                reservedSize: 50,
                getTitlesWidget: (value, meta) =>
                    _getScoreTitles(value, meta, colorScheme),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: math.max(1, filteredTests.length / 5).floorToDouble(),
                getTitlesWidget: (value, meta) => _getDateTitlesForPeriod(
                  value,
                  meta,
                  filteredTests,
                  colorScheme,
                ),
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (filteredTests.length - 1).toDouble(),
          minY: 0,
          maxY: 100,
          lineBarsData: [
            // Success Rate Line (default or when selected)
            if (_showSuccessRate || (!_showErrorRate && !_showEmptyRate))
              LineChartBarData(
                spots: filteredTests.asMap().entries.map((entry) {
                  return FlSpot(
                    entry.key.toDouble(),
                    (entry.value.successRate * 100).toDouble(),
                  );
                }).toList(),
                isCurved: true,
                curveSmoothness: 0.3,
                color: colorScheme.chartSuccessLine,
                barWidth: 3,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    final test = filteredTests[index];
                    final passed = test.successRate >= 0.8;
                    return FlDotCirclePainter(
                      radius: passed ? 6 : 4,
                      color: passed ? colorScheme.chartSuccessDot : colorScheme.chartSuccessLine,
                      strokeWidth: 2,
                      strokeColor: colorScheme.chartDotStroke,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: colorScheme.chartSuccessAreaLight,
                ),
              ),
            // Error Rate Line
            if (_showErrorRate)
              LineChartBarData(
                spots: filteredTests.asMap().entries.map((entry) {
                  return FlSpot(
                    entry.key.toDouble(),
                    (entry.value.errorRate * 100).toDouble(),
                  );
                }).toList(),
                isCurved: true,
                curveSmoothness: 0.3,
                color: colorScheme.chartErrorLine,
                barWidth: 3,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 5,
                      color: colorScheme.chartErrorLine,
                      strokeWidth: 2,
                      strokeColor: colorScheme.chartDotStroke,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: colorScheme.chartErrorAreaLight,
                ),
              ),
            // Empty Rate Line
            if (_showEmptyRate)
              LineChartBarData(
                spots: filteredTests.asMap().entries.map((entry) {
                  return FlSpot(
                    entry.key.toDouble(),
                    (entry.value.emptyRate * 100).toDouble(),
                  );
                }).toList(),
                isCurved: true,
                curveSmoothness: 0.3,
                color: colorScheme.chartEmptyLine,
                barWidth: 3,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 5,
                      color: colorScheme.chartEmptyLine,
                      strokeWidth: 2,
                      strokeColor: colorScheme.chartDotStroke,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: colorScheme.chartEmptyAreaLight,
                ),
              ),
          ],
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) {
                if (spots.isEmpty) return [];
                final idx = spots.first.spotIndex;
                final test = filteredTests[idx];

                String metricLine = '';
                if (_showSuccessRate) {
                  metricLine =
                      'Tasa Acierto: ${(test.successRate * 100).toStringAsFixed(1)}%';
                } else if (_showErrorRate) {
                  metricLine =
                      'Tasa Error: ${(test.errorRate * 100).toStringAsFixed(1)}%';
                } else if (_showEmptyRate) {
                  metricLine =
                      'Tasa Abandono: ${(test.emptyRate * 100).toStringAsFixed(1)}%';
                } else {
                  metricLine =
                      'Tasa Acierto: ${(test.successRate * 100).toStringAsFixed(1)}%';
                }

                return [
                  LineTooltipItem(
                    '${test.topics!.first.topicName}\n'
                    '---------------\n'
                    '$metricLine\n'
                    'Correctas: ${test.rightQuestions}/${test.questionCount}\n'
                    'Nota: ${test.score?.toStringAsFixed(1) ?? 'N/A'}\n'
                    'Fecha: ${_formatTestDate(test.createdAt)}',
                    TextStyle(
                      color: colorScheme.chartTooltipText,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ];
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _getScoreTitles(
      double value, TitleMeta meta, ColorScheme colorScheme) {
    if (value == 0 ||
        value == 20 ||
        value == 40 ||
        value == 60 ||
        value == 80 ||
        value == 100) {
      return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 8,
        child: Text(
          '${value.toInt()}%',
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _getDateTitlesForPeriod(
    double value,
    TitleMeta meta,
    List<UserTest> tests,
    ColorScheme colorScheme,
  ) {
    final index = value.toInt();
    if (index >= 0 && index < tests.length) {
      final test = tests[index];
      String label;

      switch (_selectedPeriod) {
        case TimePeriod.daily:
          // Mostrar día/mes
          label = '${test.createdAt.day}/${test.createdAt.month}';
          break;

        case TimePeriod.monthly:
          // Mostrar mes abreviado
          const months = [
            'Ene',
            'Feb',
            'Mar',
            'Abr',
            'May',
            'Jun',
            'Jul',
            'Ago',
            'Sep',
            'Oct',
            'Nov',
            'Dic'
          ];
          label = months[test.createdAt.month - 1];
          break;
      }

      return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 8,
        child: Text(
          label,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  String _formatTestDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildEmptyTestsState(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadowLight,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.quiz_outlined,
                  size: 64,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No hay tests disponibles',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'El usuario no ha realizado tests finalizados en este período.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Prueba cambiando el filtro de período arriba.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: TimePeriod.values.map((period) {
          final isSelected = _selectedPeriod == period;
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _onPeriodChanged(period),
                borderRadius: BorderRadius.circular(8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primaryContainer
                        : colorScheme.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        period.icon,
                        size: 16,
                        color: isSelected
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        period.label,
                        style: TextStyle(
                          color: isSelected
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMetricSelector(ThemeData theme, ColorScheme colorScheme) {
    final metrics = [
      {'label': 'Tasa de Acierto', 'icon': Icons.check_circle},
      {'label': 'Tasa de Error', 'icon': Icons.error},
      {'label': 'Tasa de Abandono', 'icon': Icons.remove_circle},
    ];

    String selectedMetric = _showSuccessRate
        ? 'Tasa de Acierto'
        : _showErrorRate
            ? 'Tasa de Error'
            : _showEmptyRate
                ? 'Tasa de Abandono'
                : 'Tasa de Acierto';

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: metrics.map((metric) {
        final label = metric['label'] as String;
        final icon = metric['icon'] as IconData;
        final isSelected = selectedMetric == label;

        return Material(
          color: colorScheme.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                _showSuccessRate = label == 'Tasa de Acierto';
                _showErrorRate = label == 'Tasa de Error';
                _showEmptyRate = label == 'Tasa de Abandono';
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.outlineVariant,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: isSelected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTabSelector(ThemeData theme, ColorScheme colorScheme) {
    final List<Map<String, dynamic>> tabs = [];

    // Añadir tabs dinámicas desde topic_type con level='Mock'
    for (final topicType in _mockTopicTypes) {
      tabs.add({
        'label': topicType['topic_type_name'],
        'icon': Icons.quiz,
        'isTopicType': true,
        'topicTypeId': topicType['id'],
      });
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs.map((tab) {
            final label = tab['label'] as String;
            final icon = tab['icon'] as IconData;
            final isSelected = _selectedTab == label;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Material(
                color: colorScheme.transparent,
                child: InkWell(
                  onTap: () {
                    _onTabChanged(label, tab['topicTypeId'] as int);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primaryContainer
                          : colorScheme.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          icon,
                          size: 18,
                          color: isSelected
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          label,
                          style: TextStyle(
                            color: isSelected
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onSurface,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTabContent(ThemeData theme, ColorScheme colorScheme) {
    // Buscar el topic_type seleccionado
    final topicType = _mockTopicTypes.firstWhere(
      (type) => type['topic_type_name'] == _selectedTab,
      orElse: () => {},
    );

    if (topicType.isEmpty) {
      return const SizedBox.shrink(key: ValueKey('empty'));
    }

    if (_loadingTests) {
      return Container(
        key: ValueKey(_selectedTab),
        padding: const EdgeInsets.all(48),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'Cargando estadísticas...',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      key: ValueKey(_selectedTab),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Period selector - always visible
          Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildPeriodSelector(theme, colorScheme),
              ],
            ),
          ),
          // Metric selector - always visible
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Text(
                  'Métricas:',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: _buildMetricSelector(theme, colorScheme)),
              ],
            ),
          ),
          // Chart content
          _buildTestsChart(theme, colorScheme),
          const SizedBox(height: 32),
          // Tests list grouped by month
          _buildTestsList(theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildTestsList(ThemeData theme, ColorScheme colorScheme) {
    final filteredTests = _getFilteredTests();

    if (filteredTests.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.quiz_outlined,
                size: 64,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No hay tests disponibles',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Agrupar por mes/año
    final Map<DateTime, List<UserTest>> grupos = {};
    for (var test in filteredTests) {
      final key = DateTime(test.createdAt.year, test.createdAt.month);
      grupos.putIfAbsent(key, () => []).add(test);
    }

    // Obtener claves ordenadas descendentes
    final mesesOrdenados = grupos.keys.toList()..sort((a, b) => b.compareTo(a));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con estadísticas generales
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withValues(alpha: 0.1),
                  colorScheme.primaryContainer.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tests agregados por mes y año',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    Text(
                      '${filteredTests.length} tests completados',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Para cada mes: header + Wrap de cards
          for (var mes in mesesOrdenados) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Text(
                    _formatMonthYear(mes),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${_getRelativeTime(mes)})',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var test
                    in grupos[mes]!
                      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)))
                  SizedBox(
                    width: 300,
                    child: _buildUserTestCard(test, theme, colorScheme),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserTestCard(
    UserTest test,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final correct = test.rightQuestions;
    final wrong = test.wrongQuestions;
    final blank = test.emptyQuestions;
    final total = test.questionCount.toDouble();
    final showButtons = _showButtonsMap[test.id] ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _showButtonsMap[test.id] = !showButtons;
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: colorScheme.surface,
                border: Border.all(color: colorScheme.outline),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Encabezado con ID y nota
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${test.topics!.first.topicName}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (test.score != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getScoreColor(test.score!, colorScheme)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            test.score!.toStringAsFixed(1),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _getScoreColor(test.score!, colorScheme),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Estadísticas básicas
                  Text(
                    'Nota: ${test.score?.toStringAsFixed(1) ?? 'N/A'}',
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    'Tasa de error: ${(test.errorRate * 100).toStringAsFixed(0)}%',
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    'Tasa de abandono: ${(test.emptyRate * 100).toStringAsFixed(0)}%',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  // Fecha y conteo de respuestas
                  Row(
                    children: [
                      Text(
                        _formatDate(test.createdAt),
                        style: theme.textTheme.bodySmall,
                      ),
                      const Spacer(),
                      _iconWithCount(Icons.check_circle, correct, colorScheme.successRate),
                      const SizedBox(width: 8),
                      _iconWithCount(Icons.cancel, wrong, colorScheme.errorRate),
                      const SizedBox(width: 8),
                      _iconWithCount(
                        Icons.remove_circle_outline,
                        blank,
                        colorScheme.dropRate,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Barra segmentada
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: colorScheme.surfaceContainerHighest,
                    ),
                    child: Stack(
                      children: [
                        // Capa roja: correct + wrong
                        if (correct + wrong > 0)
                          FractionallySizedBox(
                            widthFactor: (correct + wrong) / total,
                            child: Container(
                              decoration: BoxDecoration(
                                color: colorScheme.segmentedBarError,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(8)),
                              ),
                            ),
                          ),
                        // Capa verde: solo correct
                        if (correct > 0)
                          FractionallySizedBox(
                            widthFactor: correct / total,
                            child: Container(
                              decoration: BoxDecoration(
                                color: colorScheme.segmentedBarSuccess,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(8)),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Botones de acción
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: showButtons ? 50 : 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: showButtons ? 1.0 : 0.0,
              child: showButtons
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                _showDeleteConfirmation(context, test);
                              },
                              icon: const Icon(Icons.delete, size: 16),
                              label: const Text('Borrar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.error,
                                foregroundColor: colorScheme.onError,
                                minimumSize: const Size(0, 40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconWithCount(IconData icon, int count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          icon,
          size: 14,
          color: color,
        ),
      ],
    );
  }

  Color _getScoreColor(double score, ColorScheme colorScheme) {
    if (score >= 8.0) return colorScheme.scoreExcellent;
    if (score >= 5.0) return colorScheme.scoreGood;
    return colorScheme.scorePoor;
  }

  String _formatMonthYear(DateTime date) {
    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 30) {
      return 'Hace ${difference.inDays} días';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'Hace $months ${months == 1 ? 'mes' : 'meses'}';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'Hace $years ${years == 1 ? 'año' : 'años'}';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _showDeleteConfirmation(
      BuildContext context, UserTest test) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: colorScheme.error,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Confirmar eliminación',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Estás seguro de que deseas eliminar el test del usuario ${_user?.fullName ?? ''}?',
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.outlineVariant,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test #${test.id}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Fecha: ${_formatDate(test.createdAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      'Nota: ${test.score?.toStringAsFixed(1) ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Esta acción no se puede deshacer.',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.onSurfaceVariant,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Eliminar',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _deleteUserTest(test);
    }
  }

  Future<void> _deleteUserTest(UserTest test) async {
    try {
      // Eliminar de la base de datos
      await _supabaseClient.from('user_test').delete().eq('id', test.id);

      // Eliminar del estado local
      setState(() {
        _userTests.removeWhere((t) => t.id == test.id);
        _showButtonsMap.remove(test.id);
      });

      // Mostrar mensaje de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text('Test #${test.id} eliminado correctamente'),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.snackbarSuccess,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }

      // Refrescar estadísticas para actualizar KPIs
      await _refreshStatistics();
    } catch (e) {
      logger.error('Error deleting user test: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.error,
                  color: Theme.of(context).colorScheme.onError,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text('Error al eliminar el test'),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.snackbarError,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }
}
