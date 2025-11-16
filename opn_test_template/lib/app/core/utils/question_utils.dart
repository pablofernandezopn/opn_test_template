import 'dart:math';
import '../../features/questions/model/question_option_model.dart';
import '../../features/questions/model/question_model.dart';

/// Utilidades para manejo de preguntas y opciones

/// Ordena o mezcla opciones según la configuración de la pregunta
///
/// Esta función implementa las siguientes reglas:
/// 1. FLASHCARDS: Nunca se mezclan (siempre orden original por optionOrder)
/// 2. HISTORIAL: Si hay un orden preservado, usarlo
/// 3. SHUFFLE: Si shouldShuffle = true, mezclar aleatoriamente
/// 4. DEFAULT: Ordenar por optionOrder
///
/// Parámetros:
/// - [options]: Lista de opciones a ordenar/mezclar
/// - [shouldShuffle]: Si la pregunta tiene shuffle activado
/// - [preservedOrder]: Orden guardado desde historial (IDs de opciones)
/// - [isFlashcardMode]: Si es modo flashcard (NUNCA mezcla)
///
/// Retorna:
/// Lista de opciones en el orden apropiado
List<QuestionOption> sortOrShuffleOptions(
  List<QuestionOption> options, {
  required bool? shouldShuffle,
  List<int>? preservedOrder,
  bool isFlashcardMode = false,
}) {
  // REGLA 1: Flashcards NUNCA se mezclan
  if (isFlashcardMode) {
    final sorted = List<QuestionOption>.from(options);
    sorted.sort((a, b) => a.optionOrder.compareTo(b.optionOrder));
    return sorted;
  }

  // REGLA 2: Si hay orden preservado (historial), usarlo
  if (preservedOrder != null && preservedOrder.isNotEmpty) {
    final orderMap = <int, QuestionOption>{
      for (var opt in options)
        if (opt.id != null) opt.id!: opt
    };

    return preservedOrder
        .where((id) => orderMap.containsKey(id))
        .map((id) => orderMap[id]!)
        .toList();
  }

  // REGLA 3: Si debe mezclarse, shuffle aleatorio
  if (shouldShuffle == true) {
    final shuffled = List<QuestionOption>.from(options);
    shuffled.shuffle(Random());
    return shuffled;
  }

  // REGLA 4: Por defecto, ordenar por optionOrder
  final sorted = List<QuestionOption>.from(options);
  sorted.sort((a, b) => a.optionOrder.compareTo(b.optionOrder));
  return sorted;
}

/// Extrae los IDs de opciones en el orden actual
///
/// Útil para guardar el orden en que se presentaron las opciones al usuario
///
/// Parámetros:
/// - [options]: Lista de opciones en el orden a guardar
///
/// Retorna:
/// Lista de IDs de opciones (filtrando nulls)
List<int> extractOptionIds(List<QuestionOption> options) {
  return options
      .where((opt) => opt.id != null)
      .map((opt) => opt.id!)
      .toList();
}

/// Crea un mapa de opciones agrupadas por question_id para acceso rápido
///
/// Parámetros:
/// - [allOptions]: Lista completa de opciones
///
/// Retorna:
/// Mapa de question_id -> lista de opciones
Map<int, List<QuestionOption>> groupOptionsByQuestion(
  List<QuestionOption> allOptions,
) {
  final grouped = <int, List<QuestionOption>>{};
  for (final option in allOptions) {
    grouped.putIfAbsent(option.questionId, () => []).add(option);
  }
  return grouped;
}