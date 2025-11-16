import 'challenge_model.dart';
import '../../questions/model/question_model.dart';
import '../../questions/model/question_option_model.dart';
import '../../topics/model/topic_model.dart';
import '../../../core/utils/question_utils.dart';

/// Modelo que agrupa toda la información de un challenge con sus relaciones
class ChallengeDetail {
  final Challenge challenge;
  final Question question;
  final List<QuestionOption> options;
  final Topic topic;

  const ChallengeDetail({
    required this.challenge,
    required this.question,
    required this.options,
    required this.topic,
  });

  /// Crea una instancia desde el Map devuelto por el repository
  factory ChallengeDetail.fromMap(Map<String, dynamic> map) {
    final challenge = map['challenge'] as Challenge;
    final questionData = map['question'] as Map<String, dynamic>;
    final topicData = map['topic'] as Map<String, dynamic>;

    // Parsear la pregunta
    final question = Question.fromJson(questionData);

    // Parsear las opciones
    final optionsData = questionData['question_options'] as List<dynamic>?;
    final rawOptions = (optionsData ?? [])
        .map((opt) => QuestionOption.fromJson(opt as Map<String, dynamic>))
        .toList();

    // Aplicar shuffle si la pregunta lo requiere, o mantener orden original
    final options = sortOrShuffleOptions(
      rawOptions,
      shouldShuffle: question.shuffled,
      isFlashcardMode: false,
    );

    // Parsear el topic
    final topic = Topic.fromJson(topicData);

    return ChallengeDetail(
      challenge: challenge,
      question: question,
      options: options,
      topic: topic,
    );
  }

  /// Obtiene la opción correcta
  QuestionOption? get correctOption {
    try {
      return options.firstWhere((opt) => opt.isCorrect);
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() {
    return 'ChallengeDetail(challenge: ${challenge.id}, question: ${question.id}, topic: ${topic.id})';
  }
}