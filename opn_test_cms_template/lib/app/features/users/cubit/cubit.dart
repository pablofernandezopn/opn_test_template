import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opn_test_guardia_civil_cms/app/authentification/auth/cubit/auth_cubit.dart';
import 'package:opn_test_guardia_civil_cms/app/features/users/model/user.dart';
import 'package:opn_test_guardia_civil_cms/app/features/users/cubit/state.dart';
import 'package:opn_test_guardia_civil_cms/app/features/users/repository/user_repository.dart';
import '../../../../bootstrap.dart';

class UserCubit extends Cubit<UserState> {
  final UserRepository _userRepository;
  final AuthCubit _authCubit;

  UserCubit(this._userRepository, this._authCubit) : super(UserState.initial());

  /// Obtiene el academy_id del usuario autenticado
  int? get _currentAcademyId => _authCubit.state.user.academyId;

  /// Verifica si el usuario actual es Admin o superior
  bool get _isAdmin => _authCubit.state.user.isAdmin;

  /// Obtiene todos los usuarios (alumnos) - Primera carga
  Future<void> fetchUsers({int? roleId, int? specialtyId}) async {
    try {
      emit(state.copyWith(
        fetchUsersStatus: Status.loading(),
        currentPage: 0,
        hasMorePages: true,
      ));

      final academyFilter = _isAdmin ? null : _currentAcademyId;

      final users = await _userRepository.fetchUsers(
        academyId: academyFilter,
        roleId: roleId,
        specialtyId: specialtyId,
        page: 0,
        pageSize: state.pageSize,
      );

      logger.debug(
          'Fetched ${users.length} users (academyFilter: $academyFilter, isAdmin: $_isAdmin)');

      emit(state.copyWith(
        users: users,
        fetchUsersStatus: Status.done(),
        error: null,
        currentPage: 0,
        hasMorePages: users.length >= state.pageSize,
      ));
    } catch (e) {
      emit(state.copyWith(
        fetchUsersStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error fetching users: $e');
    }
  }

  /// Carga más usuarios (scroll infinito)
  Future<void> loadMoreUsers({int? roleId, int? specialtyId}) async {
    // Si ya estamos cargando o no hay más páginas, no hacer nada
    if (state.isLoadingMore || !state.hasMorePages) return;

    try {
      emit(state.copyWith(isLoadingMore: true));

      final academyFilter = _isAdmin ? null : _currentAcademyId;
      final nextPage = state.currentPage + 1;

      final newUsers = await _userRepository.fetchUsers(
        academyId: academyFilter,
        roleId: roleId,
        specialtyId: specialtyId,
        page: nextPage,
        pageSize: state.pageSize,
      );

      logger.debug('Loaded ${newUsers.length} more users (page: $nextPage)');

      // Combinar usuarios existentes con los nuevos
      final allUsers = [...state.users, ...newUsers];

      emit(state.copyWith(
        users: allUsers,
        isLoadingMore: false,
        currentPage: nextPage,
        hasMorePages: newUsers.length >= state.pageSize,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      ));
      logger.error('Error loading more users: $e');
    }
  }

  /// Busca usuarios por texto
  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      await fetchUsers();
      return;
    }

    try {
      emit(state.copyWith(
        searchUsersStatus: Status.loading(),
        searchQuery: query,
        currentPage: 0,
        hasMorePages: true,
      ));

      final academyFilter = _isAdmin ? null : _currentAcademyId;

      final users = await _userRepository.searchUsers(
        query: query,
        academyId: academyFilter,
        page: 0,
        pageSize: state.pageSize,
      );

      logger.debug(
          'Found ${users.length} users matching "$query" (academyFilter: $academyFilter)');

      emit(state.copyWith(
        users: users,
        searchUsersStatus: Status.done(),
        error: null,
        currentPage: 0,
        hasMorePages: users.length >= state.pageSize,
      ));
    } catch (e) {
      emit(state.copyWith(
        searchUsersStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error searching users: $e');
    }
  }

  /// Carga más resultados de búsqueda
  Future<void> loadMoreSearchResults() async {
    if (state.isLoadingMore ||
        !state.hasMorePages ||
        state.searchQuery == null) {
      return;
    }

    try {
      emit(state.copyWith(isLoadingMore: true));

      final academyFilter = _isAdmin ? null : _currentAcademyId;
      final nextPage = state.currentPage + 1;

      final newUsers = await _userRepository.searchUsers(
        query: state.searchQuery!,
        academyId: academyFilter,
        page: nextPage,
        pageSize: state.pageSize,
      );

      logger.debug(
          'Loaded ${newUsers.length} more search results (page: $nextPage)');

      final allUsers = [...state.users, ...newUsers];

      emit(state.copyWith(
        users: allUsers,
        isLoadingMore: false,
        currentPage: nextPage,
        hasMorePages: newUsers.length >= state.pageSize,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      ));
      logger.error('Error loading more search results: $e');
    }
  }

  /// Crea un nuevo usuario (alumno)
  Future<void> createUser(User user) async {
    try {
      emit(state.copyWith(createUserStatus: Status.loading()));

      final User userToCreate;
      if (!_isAdmin) {
        userToCreate = user.copyWith(academyId: _currentAcademyId);
      } else {
        userToCreate = user;
      }

      final newUser = await _userRepository.createUser(userToCreate);

      // Agregar al inicio de la lista
      final updatedUsers = [newUser, ...state.users];
      emit(state.copyWith(
        users: updatedUsers,
        createUserStatus: Status.done(),
        error: null,
      ));

      logger.debug(
          'User created successfully: ${newUser.username} (academy: ${newUser.academyId})');
    } catch (e) {
      emit(state.copyWith(
        createUserStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error creating user: $e');
    }
  }

  /// Actualiza un usuario existente
  Future<void> updateUser(int id, User user) async {
    try {
      emit(state.copyWith(updateUserStatus: Status.loading()));

      final updatedUser = await _userRepository.updateUser(id, user);
      final updatedUsers =
          state.users.map((u) => u.id == id ? updatedUser : u).toList();

      emit(state.copyWith(
        users: updatedUsers,
        selectedUser:
            state.selectedUser?.id == id ? updatedUser : state.selectedUser,
        updateUserStatus: Status.done(),
        error: null,
      ));

      logger.debug('User updated successfully: ${updatedUser.username}');
    } catch (e) {
      emit(state.copyWith(
        updateUserStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error updating user: $e');
    }
  }

  /// Elimina un usuario
  Future<void> deleteUser(int id) async {
    try {
      emit(state.copyWith(deleteUserStatus: Status.loading()));

      await _userRepository.deleteUser(id);
      final updatedUsers = state.users.where((u) => u.id != id).toList();

      emit(state.copyWith(
        users: updatedUsers,
        selectedUser: state.selectedUser?.id == id ? null : state.selectedUser,
        deleteUserStatus: Status.done(),
        error: null,
      ));

      logger.debug('User deleted successfully: ID $id');
    } catch (e) {
      emit(state.copyWith(
        deleteUserStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error deleting user: $e');
    }
  }

  /// Selecciona un usuario
  void selectUser(User? user) {
    emit(state.copyWith(selectedUser: user));
  }

  /// Limpia los errores
  void clearError() {
    emit(state.copyWith(error: null));
  }

  /// Limpia la búsqueda y recarga todos los usuarios
  Future<void> clearSearch() async {
    emit(state.copyWith(searchQuery: null));
    await fetchUsers();
  }
}
