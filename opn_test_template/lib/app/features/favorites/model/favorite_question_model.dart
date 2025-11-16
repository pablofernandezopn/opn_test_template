import 'package:json_annotation/json_annotation.dart';

part 'favorite_question_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class FavoriteQuestion {
  final int? id;
  final int userId;
  final int questionId;
  final DateTime? createdAt;

  const FavoriteQuestion({
    this.id,
    required this.userId,
    required this.questionId,
    this.createdAt,
  });

  factory FavoriteQuestion.fromJson(Map<String, dynamic> json) =>
      _$FavoriteQuestionFromJson(json);

  Map<String, dynamic> toJson() {
    final json = _$FavoriteQuestionToJson(this);
    if (id == null) {
      json.remove('id');
      json.remove('created_at');
    }
    return json;
  }

  FavoriteQuestion copyWith({
    int? id,
    int? userId,
    int? questionId,
    DateTime? createdAt,
  }) {
    return FavoriteQuestion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      questionId: questionId ?? this.questionId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}