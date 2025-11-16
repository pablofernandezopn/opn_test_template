import 'package:flutter/material.dart';

/// Resultado del diálogo de crear impugnación
class CreateChallengeResult {
  final String reason;

  CreateChallengeResult({required this.reason});
}

/// Muestra un bottom sheet para crear una nueva impugnación
/// Retorna [CreateChallengeResult] si el usuario confirma, null si cancela
Future<CreateChallengeResult?> showCreateChallengeDialog({
  required BuildContext context,
  required int questionNumber,
}) async {
  return showModalBottomSheet<CreateChallengeResult>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _CreateChallengeDialog(questionNumber: questionNumber),
  );
}

class _CreateChallengeDialog extends StatefulWidget {
  const _CreateChallengeDialog({
    required this.questionNumber,
  });

  final int questionNumber;

  @override
  State<_CreateChallengeDialog> createState() => _CreateChallengeDialogState();
}

class _CreateChallengeDialogState extends State<_CreateChallengeDialog> {
  late final TextEditingController _reasonController;
  late final FocusNode _reasonFocusNode;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController();
    _reasonFocusNode = FocusNode();
    _reasonController.addListener(_validateInput);
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _reasonFocusNode.dispose();
    super.dispose();
  }

  void _validateInput() {
    final text = _reasonController.text.trim();
    final isValid = text.isNotEmpty && text.length >= 10;
    if (_isValid != isValid) {
      setState(() {
        _isValid = isValid;
      });
    }
  }

  void _submit() {
    if (!_isValid) return;

    final reason = _reasonController.text.trim();
    Navigator.of(context).pop(CreateChallengeResult(reason: reason));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle visual
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Icono y título
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.gavel_rounded,
                        size: 28,
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Impugnar pregunta',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colors.onSurface,
                            ),
                          ),
                          Text(
                            'Pregunta #${widget.questionNumber}',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Explicación de qué es una impugnación
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colors.outlineVariant,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '¿Qué es una impugnación?',
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colors.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Una impugnación te permite reportar errores en las preguntas, como:',
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _BulletPoint(
                        text: 'Respuesta correcta marcada incorrectamente',
                        colors: colors,
                        textTheme: textTheme,
                      ),
                      _BulletPoint(
                        text: 'Enunciado confuso o con errores',
                        colors: colors,
                        textTheme: textTheme,
                      ),
                      _BulletPoint(
                        text: 'Retroalimentación incorrecta o incompleta',
                        colors: colors,
                        textTheme: textTheme,
                      ),
                      _BulletPoint(
                        text: 'Contenido desactualizado o erróneo',
                        colors: colors,
                        textTheme: textTheme,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Un tutor revisará tu impugnación y te responderá lo antes posible.',
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Campo de texto para el motivo
                Text(
                  'Describe el problema encontrado',
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _reasonController,
                  focusNode: _reasonFocusNode,
                  maxLines: 5,
                  maxLength: 500,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Ejemplo: La respuesta marcada como correcta es la B, pero según el BOE actualizado debería ser la A...',
                    hintStyle: textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colors.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colors.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colors.primary, width: 2),
                    ),
                    filled: true,
                    fillColor: colors.surface,
                    counterStyle: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface,
                  ),
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mínimo 10 caracteres. Sé lo más específico posible.',
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),

                // Botones de acción
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancelar',
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _isValid ? _submit : null,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Enviar',
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  const _BulletPoint({
    required this.text,
    required this.colors,
    required this.textTheme,
  });

  final String text;
  final ColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•',
            style: textTheme.bodySmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}