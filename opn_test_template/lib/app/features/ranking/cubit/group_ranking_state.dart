import 'package:freezed_annotation/freezed_annotation.dart';
import '../model/group_ranking_entry_model.dart';

part 'group_ranking_state.freezed.dart';

enum GroupRankingStatus {
  initial,
  loading,
  success,
  loadingMore,
  error,
}

@freezed
class GroupRankingState with _$GroupRankingState {
  const GroupRankingState._();

  const factory GroupRankingState({
    @Default(GroupRankingStatus.initial) GroupRankingStatus status,
    @Default([]) List<GroupRankingEntry> allEntries,
    @Default([]) List<GroupRankingEntry> displayedEntries,
    GroupRankingEntry? userEntry,
    @Default(0) int currentDisplayIndex,
    @Default(20) int pageSize,
    @Default(0) int totalParticipants,
    int? topicGroupId,
    String? errorMessage,
  }) = _GroupRankingState;

  factory GroupRankingState.initial() => const GroupRankingState();

  bool get isLoading => status == GroupRankingStatus.loading;
  bool get isLoadingMore => status == GroupRankingStatus.loadingMore;
  bool get hasError => status == GroupRankingStatus.error;
  bool get hasData => displayedEntries.isNotEmpty;
  bool get hasMore => currentDisplayIndex < allEntries.length;
  bool get canLoadMore => hasMore && !isLoading && !isLoadingMore;
}