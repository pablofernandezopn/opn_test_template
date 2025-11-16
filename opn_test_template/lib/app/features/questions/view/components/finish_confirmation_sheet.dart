import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../topics/model/topic_type_model.dart';

enum FinishConfirmationAction {
  continueTest,
  finalize,
  continueLater,
}

Future<FinishConfirmationAction?> showFinishConfirmationSheet({
  required BuildContext context,
  TopicType? topicType,
  bool isTestGroup = false,
  bool isLastPart = true,
  bool isGeneratedTest = false, // 🆕 Flag para tests generados
}) {
  return showModalBottomSheet<FinishConfirmationAction>(
    context: context,
    builder: (sheetContext) {
      final colors = Theme.of(sheetContext).colorScheme;
      final textTheme = Theme.of(sheetContext).textTheme;

      // Determinar textos según el contexto
      final String title;
      final String description;
      final String finalizeButtonText;
      final bool showContinueLaterButton;

      if (isTestGroup && !isLastPart) {
        // Test agrupado, no es la última parte
        title = '¿Pasar a la siguiente parte?';
        description = 'Se guardará tu progreso y continuarás con el siguiente tema del examen.';
        finalizeButtonText = 'Pasar a siguiente parte';
        showContinueLaterButton = false;
      } else if (isTestGroup && isLastPart) {
        // Test agrupado, última parte
        title = '¿Finalizar el examen?';
        description = 'Se guardará tu progreso y podrás ver el resumen completo del examen.';
        finalizeButtonText = 'Finalizar examen';
        showContinueLaterButton = false;
      } else {
        // Test simple
        title = '¿Finalizar el test?';

        // Descripción específica según tipo de test
        if (topicType?.isFlashcards ?? false) {
          description = 'Al finalizar, se guardarán tus progresos y podrás revisar las tarjetas más tarde.';
          showContinueLaterButton = false;
        } else if (topicType?.isStudy ?? false || isGeneratedTest) {
          // Study test o test generado: mostrar opción de continuar más tarde
          description = 'Puedes continuar más tarde y retomar desde donde lo dejaste, seguir revisando tus respuestas, o finalizar para ver el resumen.';
          showContinueLaterButton = true;
        } else {
          description = 'Puedes revisar tus respuestas antes de finalizar. Al concluir, se guardarán tus resultados y podrás ver el resumen.';
          showContinueLaterButton = false;
        }

        finalizeButtonText = 'Finalizar';
      }

      return ColoredBox(
        color: colors.surface,
        child: SafeArea(
          top: false,
          bottom: true,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(sheetContext).pop(FinishConfirmationAction.continueTest);
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Continuar revisando'),
                ),
                if (showContinueLaterButton) ...[
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(sheetContext).pop(FinishConfirmationAction.continueLater);
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      side: BorderSide(
                        color: colors.tertiary,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      'Continuar más tarde',
                      style: TextStyle(color: colors.tertiary),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () {
                    Navigator.of(sheetContext).pop(FinishConfirmationAction.finalize);
                  },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text(finalizeButtonText),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
