import 'user_test_model.dart';
import 'grouped_user_test_model.dart';

/// Clase base abstracta que representa un item del historial
///
/// Puede ser un UserTest individual o un GroupedUserTest
abstract class HistoryItemModel {
  /// Fecha de creación del item (para ordenamiento)
  DateTime? get createdAt;

  /// Retorna si el item fue realizado hoy
  bool get isToday {
    final now = DateTime.now();
    final date = createdAt;
    if (date == null) return false;
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

/// Item del historial que representa un test individual
class SingleHistoryItem extends HistoryItemModel {
  final UserTest test;

  SingleHistoryItem(this.test);

  @override
  DateTime? get createdAt => test.createdAt;

  @override
  String toString() => 'SingleHistoryItem(test: $test)';
}

/// Item del historial que representa un grupo de tests
class GroupedHistoryItemModel extends HistoryItemModel {
  final GroupedUserTest groupedTest;

  GroupedHistoryItemModel(this.groupedTest);

  @override
  DateTime? get createdAt => groupedTest.createdAt;

  @override
  String toString() => 'GroupedHistoryItemModel(groupedTest: $groupedTest)';
}

/// Helper para transformar una lista de UserTest en una lista de HistoryItemModel
///
/// Agrupa los tests que tienen topicGroupId y los combina con los individuales
class HistoryItemTransformer {
  /// Transforma la lista de tests en items del historial
  ///
  /// - Tests con topicGroupId → GroupedHistoryItem (un item por grupo)
  /// - Tests sin topicGroupId → SingleHistoryItem (un item por test)
  static List<HistoryItemModel> transform(
    List<UserTest> tests, {
    Map<int, String>? topicGroupNames,
  }) {
    final items = <HistoryItemModel>[];
    final groupedTestsMap = <int, List<UserTest>>{};
    final individualTests = <UserTest>[];

    // Separar tests agrupados de individuales
    for (final test in tests) {
      if (test.topicGroupId != null) {
        groupedTestsMap.putIfAbsent(test.topicGroupId!, () => []).add(test);
      } else {
        individualTests.add(test);
      }
    }

    // Crear GroupedHistoryItemModel para cada grupo
    for (final entry in groupedTestsMap.entries) {
      final topicGroupId = entry.key;
      final groupTests = entry.value;

      final groupedTest = GroupedUserTest(
        topicGroupId: topicGroupId,
        topicGroupName: topicGroupNames?[topicGroupId],
        tests: groupTests,
      );

      items.add(GroupedHistoryItemModel(groupedTest));
    }

    // Crear SingleHistoryItem para cada test individual
    for (final test in individualTests) {
      items.add(SingleHistoryItem(test));
    }

    // Ordenar por fecha (más recientes primero)
    items.sort((a, b) {
      final dateA = a.createdAt;
      final dateB = b.createdAt;
      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;
      return dateB.compareTo(dateA); // Descendente
    });

    return items;
  }
}