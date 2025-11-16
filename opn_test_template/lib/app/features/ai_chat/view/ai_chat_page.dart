import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../authentification/auth/cubit/auth_cubit.dart';
import '../cubit/ai_chat_cubit.dart';
import '../cubit/ai_chat_state.dart';
import '../model/chat_message_model.dart';
import '../../questions/model/question_model.dart';
import '../../questions/model/question_option_model.dart';
import '../../questions/repository/repository.dart';
import '../../../config/service_locator.dart';
import 'expandable_question_panel.dart';
import 'custom_app_bar.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({
    super.key,
    this.questionText,
    this.questionId,
    this.question,
    this.options,
    this.selectedOptionId,
  });

  final String? questionText;
  final int? questionId;
  final Question? question;
  final List<QuestionOption>? options;
  final int? selectedOptionId;

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  late TextEditingController _messageController;
  late final ScrollController _scrollController;
  late final FocusNode _textFieldFocusNode;
  late final DraggableScrollableController _draggableController;

  Question? _question;
  List<QuestionOption> _options = [];

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    _textFieldFocusNode = FocusNode();
    _draggableController = DraggableScrollableController();

    // Si ya tenemos la pregunta, usarla directamente
    if (widget.question != null) {
      _question = widget.question;
      _options = widget.options ?? [];
      _options.sort((a, b) => a.optionOrder.compareTo(b.optionOrder));
    }
    // Si no, cargar la pregunta si tenemos el ID
    else if (widget.questionId != null) {
      _loadQuestion();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _textFieldFocusNode.dispose();
    _draggableController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestion() async {
    if (widget.questionId == null) return;

    try {
      final repository = getIt<QuestionRepository>();
      final questions = await repository.fetchQuestionsByIds([widget.questionId!]);
      if (questions.isNotEmpty) {
        final question = questions.first;
        final options = await repository.fetchQuestionOptions(widget.questionId!);
        options.sort((a, b) => a.optionOrder.compareTo(b.optionOrder));

        if (mounted) {
          setState(() {
            _question = question;
            _options = options;
          });
        }
      }
    } catch (e) {
      // Silently fail - the chat can still work without the question panel
    }
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    // Limpiar el campo INMEDIATAMENTE antes de enviar
    _messageController.clear();
    _messageController.selection = const TextSelection.collapsed(offset: 0);

    // Enviar el mensaje
    context.read<AiChatCubit>().sendMessage(message);

    // Forzar un rebuild del TextField
    setState(() {});

    // Mantener el foco en el TextField
    _textFieldFocusNode.requestFocus();

    // Scroll al final después de enviar
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: colors.primary,
        body: SafeArea(

          child: Stack(
            children: [
              // Contenido principal del chat
              ColoredBox(
                color: colors.surface,
                child: Column(
                  children: [
                    // Espacio para el AppBar custom
                    const SizedBox(height: 64),

                    // Lista de mensajes con padding top para la pregunta expandible
                    Expanded(
                      child: BlocBuilder<AiChatCubit, AiChatState>(
                        builder: (context, state) {
                          if (state.messages.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      Theme.of(context).brightness == Brightness.dark
                                          ? 'assets/images/opn_logos/opn_intelligence_dark.svg'
                                          : 'assets/images/opn_logos/opn_intelligence.svg',
                                      height: 80,
                                      colorFilter: ColorFilter.mode(
                                        colors.primary.withValues(alpha: 0.5),
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Escribe un mensaje para empezar',
                                      style: textTheme.titleMedium?.copyWith(
                                        color: colors.onSurfaceVariant,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Puedo ayudarte a entender mejor esta pregunta',
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              top: 100, // Espacio para el panel de pregunta
                              bottom: 16,
                            ),
                            itemCount: state.messages.length + (state.isLoading ? 1 : 0),
                            itemBuilder: (context, index) {
                              // Mostrar indicador de carga al final
                              if (state.isLoading && index == state.messages.length) {
                                return _LoadingMessageBubble(
                                  colors: colors,
                                  isRagMode: state.ragModeEnabled,
                                );
                              }

                              final message = state.messages[index];
                              // Obtener el usuario del AuthCubit
                              final authState = context.read<AuthCubit>().state;
                              final user = authState.user;

                              return _MessageBubble(
                                message: message,
                                colors: colors,
                                textTheme: textTheme,
                                userProfileImage: user.profileImage,
                              );
                            },
                          );
                        },
                      ),
                    ),

                    // Error banner
                    BlocBuilder<AiChatCubit, AiChatState>(
                      builder: (context, state) {
                        if (!state.hasError) return const SizedBox.shrink();

                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          color: colors.errorContainer,
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: colors.onErrorContainer),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  state.errorMessage ?? 'Ha ocurrido un error',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colors.onErrorContainer,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: colors.onErrorContainer),
                                onPressed: () {
                                  context.read<AiChatCubit>().clearError();
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // Campo de texto para escribir mensajes
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        border: Border(
                          top: BorderSide(color: colors.outlineVariant),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Botón de eliminar conversación
                          BlocBuilder<AiChatCubit, AiChatState>(
                            builder: (context, state) {
                              // Solo mostrar el botón si hay una conversación activa
                              if (state.conversationId == null) {
                                return const SizedBox.shrink();
                              }

                              return InkWell(
                                onTap: () async {
                                  // Mostrar diálogo de confirmación
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('¿Borrar conversación?'),
                                      content: const Text(
                                        'Se eliminará todo el historial de esta conversación. Esta acción no se puede deshacer.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: const Text('Cancelar'),
                                        ),
                                        FilledButton(
                                          onPressed: () => Navigator.of(context).pop(true),
                                          child: const Text('Borrar'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirmed == true && context.mounted) {
                                    context.read<AiChatCubit>().deleteAndRestart();
                                  }
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Icon(Icons.delete_outline),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 4),
                          // Botón de modo RAG
                          BlocBuilder<AiChatCubit, AiChatState>(
                            builder: (context, state) {
                              return Tooltip(
                                message: state.ragModeEnabled
                                    ? 'Modo búsqueda legal activado'
                                    : 'Activar modo búsqueda legal',
                                child: InkWell(
                                  onTap: () async {
                                    // Si se está activando, mostrar explicación
                                    if (!state.ragModeEnabled) {
                                      final activate = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Modo Búsqueda Legal'),
                                          content: const Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '¿Qué es el Modo Búsqueda Legal?',
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                'Este modo busca información específica en la base de datos legal (leyes, artículos, códigos, normativas) para responder tus preguntas.',
                                              ),
                                              SizedBox(height: 12),
                                              Text(
                                                'Úsalo cuando:',
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              SizedBox(height: 4),
                                              Text('• Necesites fundamento legal específico'),
                                              Text('• Quieras conocer artículos o leyes'),
                                              Text('• Busques información jurídica detallada'),
                                              SizedBox(height: 12),
                                              Text(
                                                'Modo normal:',
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              SizedBox(height: 4),
                                              Text('• Explicaciones de la pregunta'),
                                              Text('• Ayuda con las opciones'),
                                              Text('• Consejos de estudio'),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(false),
                                              child: const Text('Cancelar'),
                                            ),
                                            FilledButton(
                                              onPressed: () => Navigator.of(context).pop(true),
                                              child: const Text('Activar'),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (activate == true && context.mounted) {
                                        context.read<AiChatCubit>().toggleRagMode();
                                      }
                                    } else {
                                      // Si se está desactivando, hacerlo directamente
                                      context.read<AiChatCubit>().toggleRagMode();
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Icon(
                                      state.ragModeEnabled
                                          ? Icons.search
                                          : Icons.search_off,
                                      color: state.ragModeEnabled
                                          ? colors.primary
                                          : null,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Container(
                              alignment: Alignment.center,
                              constraints: const BoxConstraints(
                                minHeight: 42,
                              ),
                              decoration: BoxDecoration(
                                color: colors.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: StatefulBuilder(
                                builder: (context, setState) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: KeyboardListener(
                                      focusNode: FocusNode(),
                                      onKeyEvent: (e) {
                                        if (e is KeyDownEvent && e.logicalKey == LogicalKeyboardKey.enter) {
                                          if (HardwareKeyboard.instance.isShiftPressed) {
                                            // Shift + Enter → salto de línea (prevenir el envío)
                                            // Dejamos que el TextField maneje el salto de línea naturalmente
                                          }
                                          // Si es Enter solo, el TextField lo maneja con onSubmitted
                                        }
                                      },
                                      child: TextField(
                                        controller: _messageController,
                                        focusNode: _textFieldFocusNode,
                                        keyboardType: TextInputType.multiline,
                                        textInputAction: TextInputAction.send,
                                        minLines: 1,
                                        maxLines: 5,
                                        decoration: InputDecoration(
                                          hoverColor: Colors.transparent,
                                          fillColor: colors.surfaceContainerLowest,
                                          hintText: 'Enviar un mensaje...',
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          isDense: true,
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                        ),
                                        textCapitalization: TextCapitalization.sentences,
                                        onSubmitted: (_) {
                                          // Solo enviar si NO se está presionando Shift
                                          if (!HardwareKeyboard.instance.isShiftPressed) {
                                            _sendMessage();
                                          }
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          BlocBuilder<AiChatCubit, AiChatState>(
                            builder: (context, state) {
                              return FilledButton(
                                onPressed: state.isLoading ? null : _sendMessage,
                                style: FilledButton.styleFrom(
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(4),
                                ),
                                child: state.isLoading
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: colors.onPrimary,
                                        ),
                                      )
                                    : const Icon(Icons.send),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              ),

              // Panel expandible con la pregunta (desde arriba)
              if (_question != null)
                ExpandableQuestionPanel(
                  question: _question!,
                  options: _options,
                  selectedOptionId: widget.selectedOptionId,
                ),

              // AppBar custom en la parte superior
              CustomAiChatAppBar(
                onBack: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.colors,
    required this.textTheme,
    this.userProfileImage,
  });

  final ChatMessage message;
  final ColorScheme colors;
  final TextTheme textTheme;
  final String? userProfileImage;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: SvgPicture.asset(
                  Theme.of(context).brightness == Brightness.dark
                      ? 'assets/images/opn_logos/opn_intelligence_dark.svg'
                      : 'assets/images/opn_logos/opn_intelligence.svg',
                  colorFilter: ColorFilter.mode(
                    colors.onPrimaryContainer,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? colors.primary : colors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(20).copyWith(
                  topLeft: isUser ? const Radius.circular(20) : const Radius.circular(4),
                  topRight: isUser ? const Radius.circular(4) : const Radius.circular(20),
                ),
              ),
              child: isUser
                  ? Text(
                      message.content,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onPrimary,
                      ),
                    )
                  : MarkdownBody(
                      data: message.content,
                      styleSheet: MarkdownStyleSheet(
                        p: textTheme.bodyMedium?.copyWith(
                          color: colors.onSurface,
                        ),
                        h1: textTheme.headlineLarge?.copyWith(
                          color: colors.onSurface,
                        ),
                        h2: textTheme.headlineMedium?.copyWith(
                          color: colors.onSurface,
                        ),
                        h3: textTheme.headlineSmall?.copyWith(
                          color: colors.onSurface,
                        ),
                        code: textTheme.bodyMedium?.copyWith(
                          fontFamily: 'monospace',
                          backgroundColor: colors.surfaceContainerHighest,
                          color: colors.onSurface,
                        ),
                        codeblockDecoration: BoxDecoration(
                          color: colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        blockquote: textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                        blockquoteDecoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: colors.primary,
                              width: 4,
                            ),
                          ),
                        ),
                        listBullet: textTheme.bodyMedium?.copyWith(
                          color: colors.onSurface,
                        ),
                        a: textTheme.bodyMedium?.copyWith(
                          color: colors.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      selectable: true,
                    ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colors.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: userProfileImage != null && userProfileImage!.isNotEmpty
                    ? Image.network(
                        userProfileImage!,
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.person,
                          size: 20,
                          color: colors.onSecondaryContainer,
                        ),
                      )
                    : Icon(
                        Icons.person,
                        size: 20,
                        color: colors.onSecondaryContainer,
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LoadingMessageBubble extends StatelessWidget {
  const _LoadingMessageBubble({
    required this.colors,
    required this.isRagMode,
  });

  final ColorScheme colors;
  final bool isRagMode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: isRagMode
                ? Icon(
                    Icons.search,
                    size: 20,
                    color: colors.onPrimaryContainer,
                  )
                : Padding(
                    padding: const EdgeInsets.all(6),
                    child: SvgPicture.asset(
                      Theme.of(context).brightness == Brightness.dark
                          ? 'assets/images/opn_logos/opn_intelligence_dark.svg'
                          : 'assets/images/opn_logos/opn_intelligence.svg',
                      colorFilter: ColorFilter.mode(
                        colors.onPrimaryContainer,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(20).copyWith(
                topLeft: const Radius.circular(4),
              ),
            ),
            child: isRagMode
                ? _ShimmerTextLoading(colors: colors)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _LoadingDot(colors: colors, delay: 0),
                      const SizedBox(width: 4),
                      _LoadingDot(colors: colors, delay: 200),
                      const SizedBox(width: 4),
                      _LoadingDot(colors: colors, delay: 400),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _LoadingDot extends StatefulWidget {
  const _LoadingDot({
    required this.colors,
    required this.delay,
  });

  final ColorScheme colors;
  final int delay;

  @override
  State<_LoadingDot> createState() => _LoadingDotState();
}

class _LoadingDotState extends State<_LoadingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: widget.colors.onSurfaceVariant,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

// Widget de texto animado con efecto de brillo para el modo RAG
class _ShimmerTextLoading extends StatefulWidget {
  const _ShimmerTextLoading({
    required this.colors,
  });

  final ColorScheme colors;

  @override
  State<_ShimmerTextLoading> createState() => _ShimmerTextLoadingState();
}

class _ShimmerTextLoadingState extends State<_ShimmerTextLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;
  String _displayText = 'Accediendo al BOE';
  bool _hasChangedText = false;

  @override
  void initState() {
    super.initState();

    // Controlador para el efecto de brillo
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _shimmerAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _shimmerController.repeat();

    // Cambiar el texto después de 10 segundos
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && !_hasChangedText) {
        setState(() {
          _displayText = 'Buscando en el BOE';
          _hasChangedText = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.colors.onSurface.withValues(alpha: 0.5),
                widget.colors.primary,
                widget.colors.onSurface.withValues(alpha: 0.5),
              ],
              stops: const [0.0, 0.5, 1.0],
              transform: GradientRotation(_shimmerAnimation.value),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Text(
              _displayText,
              key: ValueKey(_displayText),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: widget.colors.onSurface,
              ),
            ),
          ),
        );
      },
    );
  }
}