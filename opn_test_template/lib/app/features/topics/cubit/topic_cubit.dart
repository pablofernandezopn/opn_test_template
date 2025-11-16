import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opn_test_template/app/features/topics/cubit/topic_state.dart';
import '../../../../bootstrap.dart';
import '../../../authentification/auth/cubit/auth_cubit.dart';
import '../../../authentification/auth/cubit/auth_state.dart';
import '../../../config/service_locator.dart';
import '../../loading/cubit/loading_cubit.dart';
import '../model/category_model.dart';
import '../model/topic_type_model.dart';
import '../model/topic_group_model.dart';
import '../model/user_completed_topic_group_model.dart';
import '../repository/topic_repository.dart';

class TopicCubit extends Cubit<TopicState> {
  final TopicRepository _topicRepository;
  final AuthCubit _authCubit;
  StreamSubscription<AuthState>? _authSubscription;

  // Bandera para evitar que el listener automático interfiera con refresh manual
  bool _isManualRefreshing = false;

  // Bandera para evitar cargar datos múltiples veces cuando el listener se dispara consecutivamente
  bool _isLoadingData = false;

  TopicCubit(this._topicRepository, this._authCubit) : super(TopicState.initial()) {
    // NO llamar a initialFetch() aquí - se cargará todo cuando el usuario se autentique
    _listenToAuthChanges();
  }

  /// Escucha los cambios en el estado de autenticación
  void _listenToAuthChanges() {
    _authSubscription = _authCubit.stream.listen((authState) {
      print('🔄 [TOPIC_CUBIT] Auth state changed: ${authState.status}');

      // No recargar automáticamente si estamos haciendo un refresh manual
      if (_isManualRefreshing) {
        print('⏸️ [TOPIC_CUBIT] Manual refresh en progreso, ignorando listener de auth');
        return;
      }

      // No cargar si ya estamos cargando datos
      if (_isLoadingData) {
        print('⏸️ [TOPIC_CUBIT] Ya estamos cargando datos, ignorando listener de auth');
        return;
      }

      if (authState.status == AuthStatus.authenticated) {
        print('✅ [TOPIC_CUBIT] Usuario autenticado, cargando TODOS los datos...');
        // Cuando el usuario se autentica, cargar TODO
        _loadAllData();
      }
    });


  }

  /// Carga todos los datos necesarios cuando el usuario se autentica
  /// Esto incluye: topicTypes, categories, topicGroups y topics
  Future<void> _loadAllData() async {
    // Activar bandera para evitar dobles cargas
    _isLoadingData = true;

    try {
      print('📦 [TOPIC_CUBIT] ========================================');
      print('📦 [TOPIC_CUBIT] Cargando TODOS los datos...');
      print('📦 [TOPIC_CUBIT] Usuario:');
      print('   - ID: ${_authCubit.state.user.id}');
      print('   - academyId: $_currentAcademyId');
      print('   - specialtyId: $_currentSpecialtyId');

      emit(state.copyWith(
        fetchTopicTypesStatus: Status.loading(),
        fetchCategoriesStatus: Status.loading(),
        fetchTopicGroupsStatus: Status.loading(),
        fetchTopicsStatus: Status.loading(),
      ));

      // Cargar todo en paralelo
      final results = await Future.wait([
        _topicRepository.fetchTopicTypes(),
        _topicRepository.fetchCategories(),
        _topicRepository.fetchTopicGroups(academyId: _currentAcademyId),
      ]);

      final topicTypes = results[0] as List<TopicType>;
      final categories = results[1] as List<Category>;
      final topicGroups = results[2] as List<TopicGroup>;

      print('✅ [TOPIC_CUBIT] TopicTypes cargados: ${topicTypes.length}');
      print('✅ [TOPIC_CUBIT] Categories cargadas: ${categories.length}');
      print('✅ [TOPIC_CUBIT] TopicGroups cargados: ${topicGroups.length}');

      // Construir mapas de topic_group_id -> topic_type_id y topic_group_id -> count
      await _buildTopicGroupMaps(topicGroups);

      emit(state.copyWith(
        topicTypes: topicTypes,
        categories: categories,
        topicGroups: topicGroups,
        fetchTopicTypesStatus: Status.done(),
        fetchCategoriesStatus: Status.done(),
        fetchTopicGroupsStatus: Status.done(),
        error: null,
      ));

      // Ahora cargar los topics filtrados por especialidad
      print('📦 [TOPIC_CUBIT] Cargando topics filtrados por specialtyId: $_currentSpecialtyId');
      await fetchTopics();

      print('📦 [TOPIC_CUBIT] TODOS los datos cargados exitosamente');
      print('📦 [TOPIC_CUBIT] Estado final:');
      print('   - topicTypes: ${state.topicTypes.length}');
      print('   - topics: ${state.topics.length}');
      print('   - topicGroups: ${state.topicGroups.length}');
      print('📦 [TOPIC_CUBIT] ========================================');
    } catch (e) {
      print('❌ [TOPIC_CUBIT] Error cargando datos: $e');
      emit(state.copyWith(
        fetchTopicTypesStatus: Status.error('Error: ${e.toString()}'),
        fetchCategoriesStatus: Status.error('Error: ${e.toString()}'),
        fetchTopicGroupsStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      getIt<LoadingCubit>().markReady();
    } finally {
      // Desactivar bandera al terminar (éxito o error)
      _isLoadingData = false;
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }

  /// Obtiene el academy_id del usuario autenticado
  int? get _currentAcademyId => _authCubit.state.user.academyId;

  /// Obtiene el specialty_id del usuario autenticado
  int? get _currentSpecialtyId => _authCubit.state.user.specialtyId;

  /// Construye los mapas topicGroupTypeMap y topicGroupCountMap
  Future<void> _buildTopicGroupMaps(List<TopicGroup> topicGroups) async {
    final typeMap = <int, int>{};
    final countMap = <int, int>{};

    for (final group in topicGroups) {
      if (group.id == null) continue;

      // Obtener los topics del grupo
      final groupTopics = await _topicRepository.fetchTopicsInGroup(group.id!);

      if (groupTopics.isEmpty) continue;

      // Asumimos que todos los topics del grupo tienen el mismo topic_type_id
      // (validado por el trigger en la BD)
      final topicTypeId = groupTopics.first.topicTypeId;

      typeMap[group.id!] = topicTypeId;
      countMap[group.id!] = groupTopics.length;
    }

    emit(state.copyWith(
      topicGroupTypeMap: typeMap,
      topicGroupCountMap: countMap,
    ));
  }

  /// Obtiene todos los topics filtrados por academy_id y specialty_id del usuario
  Future<void> fetchTopics() async {
    try {
      print('🎯 [TOPIC_CUBIT] ========================================');
      print('🎯 [TOPIC_CUBIT] fetchTopics INICIADO');

      emit(state.copyWith(fetchTopicsStatus: Status.loading()));

      final academyId = _currentAcademyId;
      final specialtyId = _currentSpecialtyId;

      print('🎯 [TOPIC_CUBIT] Parámetros:');
      print('🎯 [TOPIC_CUBIT] ├─ academyId: $academyId');
      print('🎯 [TOPIC_CUBIT] ├─ specialtyId: $specialtyId');
      print('🎯 [TOPIC_CUBIT] └─ userId: ${_authCubit.state.user.id}');

      // Filtrar topics por academy_id y specialty_id del usuario autenticado
      final topics = await _topicRepository.fetchTopics(
        academyId: academyId,
        specialtyId: specialtyId,
      );

      print('🎯 [TOPIC_CUBIT] Resultados:');
      print('🎯 [TOPIC_CUBIT] Total topics: ${topics.length}');

      if (topics.isEmpty) {
        print('⚠️ [TOPIC_CUBIT] ADVERTENCIA: No se encontraron topics');
      } else {
        print('✅ [TOPIC_CUBIT] Topics encontrados:');
        print('📋 [TOPIC_CUBIT] Distribución por especialidad:');
        final general = topics.where((t) => t.specialtyId == null).length;
        final specific = topics.where((t) => t.specialtyId == specialtyId).length;
        final others = topics.where((t) => t.specialtyId != null && t.specialtyId != specialtyId).length;
        print('   - Topics generales (specialty_id = null): $general');
        print('   - Topics de especialidad $specialtyId: $specific');
        print('   - Topics de OTRAS especialidades: $others');

        if (others > 0) {
          print('⚠️⚠️⚠️ [TOPIC_CUBIT] PROBLEMA: Se están cargando topics de otras especialidades!');
          print('📋 [TOPIC_CUBIT] Topics de otras especialidades:');
          for (final topic in topics.where((t) => t.specialtyId != null && t.specialtyId != specialtyId)) {
            print('   - ID: ${topic.id}, Name: ${topic.topicName}, specialty_id: ${topic.specialtyId}');
          }
        }
      }

      logger.debug('✅ [TOPIC_CUBIT] Fetched ${topics.length} topics for academy_id=$academyId, specialty_id=$specialtyId');
      if (topics.isNotEmpty) {
        logger.debug('First topic: ${topics.first.topicName} (id=${topics.first.id}, categoryId=${topics.first.categoryId}, specialtyId=${topics.first.specialtyId})');
      }

      emit(state.copyWith(
        topics: topics,
        fetchTopicsStatus: Status.done(),
        error: null,
      ));

      print('🎯 [TOPIC_CUBIT] fetchTopics COMPLETADO');
      print('🎯 [TOPIC_CUBIT] ========================================');

      // Cargar topics completados después de cargar los topics
      await fetchCompletedTopics();

      getIt<LoadingCubit>().markReady();
    } catch (e) {
      print('❌ [TOPIC_CUBIT] Error fetching topics: $e');
      emit(state.copyWith(
        fetchTopicsStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      getIt<LoadingCubit>().markReady();
    }
  }

  /// Obtiene los IDs de topics completados por el usuario
  Future<void> fetchCompletedTopics() async {
    final userId = _authCubit.state.user.id;
    if (userId == null) {
      logger.debug('⚠️ [TOPIC_CUBIT] No user ID, skipping completed topics fetch');
      return;
    }

    try {
      emit(state.copyWith(fetchCompletedTopicsStatus: Status.loading()));

      // Obtener la lista completa de topics completados con ranking
      final completedTopics = await _topicRepository.fetchUserCompletedTopics(
        userId: userId,
      );

      // Obtener solo los IDs para mantener compatibilidad
      final completedIds = completedTopics.map((topic) => topic.topicId).toSet();

      logger.debug('✅ [TOPIC_CUBIT] Fetched ${completedIds.length} completed topics for user_id=$userId');

      // Obtener rankings de topic groups (no bloquear si falla)
      List<UserCompletedTopicGroup> completedTopicGroups = [];
      try {
        // Fetch topic groups directly from repository to ensure we have the latest data
        // This is more reliable than using state.topicGroups which might be stale or empty
        final topicGroups = await _topicRepository.fetchTopicGroups(academyId: _currentAcademyId);

        final groupIds = topicGroups
            .where((g) => g.id != null)
            .map((g) => g.id!)
            .toList();

        if (groupIds.isNotEmpty) {
          completedTopicGroups = await _topicRepository.fetchUserCompletedTopicGroups(
            userId: userId,
            topicGroupIds: groupIds,
          );

          logger.debug('✅ [TOPIC_CUBIT] Fetched ${completedTopicGroups.length} completed topic groups for user_id=$userId');
        } else {
          logger.debug('⚠️ [TOPIC_CUBIT] No topic groups found for academy_id=$_currentAcademyId');
        }
      } catch (e) {
        logger.error('⚠️ [TOPIC_CUBIT] Error fetching topic group rankings (non-fatal): $e');
        // Continuar sin rankings de grupos
      }

      emit(state.copyWith(
        completedTopicIds: completedIds,
        completedTopics: completedTopics,
        completedTopicGroups: completedTopicGroups,
        fetchCompletedTopicsStatus: Status.done(),
      ));
    } catch (e) {
      logger.error('❌ [TOPIC_CUBIT] Error fetching completed topics: $e');
      emit(state.copyWith(
        fetchCompletedTopicsStatus: Status.error('Error: ${e.toString()}'),
      ));
    }
  }

  /// Obtiene topics filtrados por tipo, academy_id y specialty_id del usuario
  Future<void> fetchTopicsByType(int topicTypeId) async {
    try {
      emit(state.copyWith(fetchTopicsByTypeStatus: Status.loading()));

      // Filtrar topics por academy_id y specialty_id del usuario autenticado
      final topics = await _topicRepository.fetchTopicsByType(
        topicTypeId,
        academyId: _currentAcademyId,
        specialtyId: _currentSpecialtyId,
        user: _authCubit.state.user,
      );

      logger.debug('✅ [TOPIC_CUBIT] Fetched ${topics.length} topics for topicType=$topicTypeId, academy_id=$_currentAcademyId, specialty_id=$_currentSpecialtyId');

      emit(state.copyWith(
        topics: topics,
        selectedTopicTypeId: topicTypeId,
        fetchTopicsByTypeStatus: Status.done(),
        error: null,
      ));
    } catch (e) {
      print('❌ [TOPIC_CUBIT] ERROR en fetchTopicsByType');
      print('❌ [TOPIC_CUBIT] Error: $e');
      print('❌ [TOPIC_CUBIT] StackTrace: ${StackTrace.current}');

      logger.error('❌ [TOPIC_CUBIT] Error fetching topics by type: $e');
      emit(state.copyWith(
        fetchTopicsByTypeStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
    }
  }

  /// Selecciona un topic por ID
  void selectTopic(int? id) {
    emit(state.copyWith(selectedTopicId: id));
  }

  /// Selecciona un tipo de topic por ID
  void selectTopicType(int? id) {
    emit(state.copyWith(selectedTopicTypeId: id));
  }

  /// Obtiene las categorías filtradas por el topic_type actualmente seleccionado
  List<Category> getCategoriesBySelectedTopicType() {
    if (state.selectedTopicTypeId == null) {
      return state.categories;
    }
    return state.categories
        .where((category) => category.topicType == state.selectedTopicTypeId)
        .toList();
  }

  // ============================================================================
  // TOPIC GROUPS - Grupos de examen secuenciales
  // ============================================================================

  /// Obtiene todos los topic_groups habilitados y publicados
  Future<void> fetchTopicGroups() async {
    try {
      emit(state.copyWith(fetchTopicGroupsStatus: Status.loading()));

      // Filtrar topic_groups por academy_id del usuario autenticado
      final topicGroups = await _topicRepository.fetchTopicGroups(
        academyId: _currentAcademyId,
      );

      logger.debug('✅ [TOPIC_CUBIT] Fetched ${topicGroups.length} topic groups for academy_id=$_currentAcademyId');

      emit(state.copyWith(
        topicGroups: topicGroups,
        fetchTopicGroupsStatus: Status.done(),
        error: null,
      ));
    } catch (e) {
      logger.error('❌ [TOPIC_CUBIT] Error fetching topic groups: $e');
      emit(state.copyWith(
        fetchTopicGroupsStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
    }
  }

  /// Obtiene los topic_groups que pertenecen a un topic_type específico
  /// (filtrando por el topic_type de sus topics)
  Future<List<TopicGroup>> getTopicGroupsByType(int topicTypeId) async {
    final groups = <TopicGroup>[];

    for (final group in state.topicGroups) {
      if (group.id == null) continue;

      // Obtener los topics del grupo
      final groupTopics = await _topicRepository.fetchTopicsInGroup(group.id!);

      // Si algún topic del grupo pertenece a este topic_type, incluir el grupo
      if (groupTopics.any((t) => t.topicTypeId == topicTypeId)) {
        groups.add(group);
      }
    }

    return groups;
  }

  // ============================================================================
  // REFRESH - Recarga completa de datos
  // ============================================================================

  /// Limpia el estado de topics y groups, pero mantiene topicTypes y categories
  /// ya que estos son independientes de la especialidad
  void _clearState() {
    logger.info('🧹 [TOPIC_CUBIT] Clearing topics and groups state (keeping topicTypes and categories)...');
    print('🧹 [TOPIC_CUBIT] topicTypes ANTES de limpiar: ${state.topicTypes.length}');
    print('🧹 [TOPIC_CUBIT] categories ANTES de limpiar: ${state.categories.length}');

    emit(state.copyWith(
      // Limpiar topics y datos relacionados
      topics: [],
      completedTopics: [],
      completedTopicIds: {},
      fetchTopicsStatus: Status.done(),
      fetchCompletedTopicsStatus: Status.done(),

      // Limpiar topic groups y datos relacionados
      topicGroups: [],
      completedTopicGroups: [],
      topicGroupTypeMap: {},
      topicGroupCountMap: {},
      fetchTopicGroupsStatus: Status.done(),

      // Mantener topicTypes y categories (NO se limpian)
      // topicTypes: state.topicTypes, // Ya están en el estado
      // categories: state.categories, // Ya están en el estado

      // Resetear topic type seleccionado
      selectedTopicTypeId: null,
      error: null,
    ));

    print('✅ [TOPIC_CUBIT] topics limpiados: ${state.topics.length}');
    print('✅ [TOPIC_CUBIT] topicGroups limpiados: ${state.topicGroups.length}');
    print('✅ [TOPIC_CUBIT] topicTypes MANTENIDOS: ${state.topicTypes.length}');
    print('✅ [TOPIC_CUBIT] categories MANTENIDAS: ${state.categories.length}');
  }

  /// Prepara el cubit para un refresh manual
  /// Activa la bandera _isManualRefreshing para evitar que el listener de auth interfiera
  /// Debe llamarse ANTES de operaciones que cambien el AuthCubit (ej: refreshUser)
  void prepareManualRefresh() {
    logger.info('🛡️ [TOPIC_CUBIT] Preparing manual refresh - listener will be ignored');
    _isManualRefreshing = true;
  }

  /// Recarga todos los datos (topics, topic_groups, completed topics)
  /// Útil después de cambiar la especialidad del usuario
  Future<void> refresh() async {
    print('🔄 [TOPIC_CUBIT] ========================================');
    print('🔄 [TOPIC_CUBIT] REFRESH INICIADO');
    logger.info('🔄 [TOPIC_CUBIT] Refreshing all data...');

    // Activar bandera para evitar interferencia del listener
    _isManualRefreshing = true;
    print('🛡️ [TOPIC_CUBIT] Bandera _isManualRefreshing activada');

    try {
      // 1. Limpiar todo el estado primero
      print('🧹 [TOPIC_CUBIT] Limpiando estado...');
      _clearState();
      print('✅ [TOPIC_CUBIT] Estado limpiado');

      // 2. Esperar un momento para que el listener de auth se dispare y sea ignorado
      print('⏱️ [TOPIC_CUBIT] Esperando 100ms...');
      await Future.delayed(const Duration(milliseconds: 100));

      final academyId = _currentAcademyId;
      final specialtyId = _currentSpecialtyId;
      final userId = _authCubit.state.user.id;

      print('🔍 [TOPIC_CUBIT] Valores actuales:');
      print('   - academyId: $academyId');
      print('   - specialtyId: $specialtyId');
      print('   - userId: $userId');
      print('   - topicTypes en estado: ${state.topicTypes.length}');

      // 3. Recargar topics y topic_groups en paralelo con timeout
      // (topicTypes se mantienen del estado anterior ya que no cambian con la especialidad)
      print('⏳ [TOPIC_CUBIT] Recargando topics y topic_groups...');
      await Future.wait([
        fetchTopics(),
        fetchTopicGroups(),
      ]).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print('⚠️ [TOPIC_CUBIT] TIMEOUT después de 15 segundos');
          logger.error('⏱️ [TOPIC_CUBIT] Refresh timeout after 15 seconds');
          // Asegurar que se marca como ready incluso en timeout
          getIt<LoadingCubit>().markReady();
          throw TimeoutException('Refresh operation timed out');
        },
      );

      print('✅ [TOPIC_CUBIT] Topics y topic_groups recargados exitosamente');
      print('📊 [TOPIC_CUBIT] Estado final:');
      print('   - topicTypes: ${state.topicTypes.length}');
      print('   - topics: ${state.topics.length}');
      print('   - topicGroups: ${state.topicGroups.length}');
      logger.info('✅ [TOPIC_CUBIT] Refresh completed successfully');
      print('🔄 [TOPIC_CUBIT] REFRESH COMPLETADO');
      print('🔄 [TOPIC_CUBIT] ========================================');
    } catch (e) {
      print('❌ [TOPIC_CUBIT] ERROR en refresh: $e');
      logger.error('❌ [TOPIC_CUBIT] Error during refresh: $e');
      // Asegurar que se marca como ready incluso en error
      getIt<LoadingCubit>().markReady();
      rethrow;
    } finally {
      // Desactivar bandera al terminar
      _isManualRefreshing = false;
      print('🛡️ [TOPIC_CUBIT] Bandera _isManualRefreshing desactivada');
    }
  }
}
