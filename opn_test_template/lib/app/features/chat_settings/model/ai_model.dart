import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_model.freezed.dart';
part 'ai_model.g.dart';

/// Modelo que representa un modelo de IA disponible
@freezed
class AiModel with _$AiModel {
  const factory AiModel({
    required int id,
    @JsonKey(name: 'model_key') required String modelKey,
    @JsonKey(name: 'display_name') required String displayName,
    String? description,
    required String provider,
    @JsonKey(name: 'speed_rating') int? speedRating,
    @JsonKey(name: 'thinking_capability') int? thinkingCapability,
    @JsonKey(name: 'max_tokens') int? maxTokens,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _AiModel;

  factory AiModel.fromJson(Map<String, dynamic> json) =>
      _$AiModelFromJson(json);
}
