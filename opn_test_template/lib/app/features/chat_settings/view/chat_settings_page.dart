import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../authentification/auth/cubit/auth_state.dart';
import '../../../authentification/auth/model/user.dart';
import '../../../config/service_locator.dart';
import '../../../authentification/auth/cubit/auth_cubit.dart';
import '../../../shared/widgets/opn_app_bar.dart';
import '../../../config/widgets/premium/premium_content.dart';
import '../cubit/chat_preferences_cubit.dart';
import '../cubit/chat_preferences_state.dart';
import '../model/ai_model.dart';
import '../model/chat_user_preferences.dart';
import '../repository/chat_preferences_repository.dart';

class ChatSettingsPage extends StatelessWidget {
  const ChatSettingsPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (_) => const ChatSettingsPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthCubit>().state.user?.id;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
            title:  Text('Configuración del Chat', style:TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.primary,
            ),),
        ),
        body: const Center(child: Text('Usuario no autenticado')),
      );
    }

    return BlocProvider(
      create: (context) => ChatPreferencesCubit(
        repository: getIt<ChatPreferencesRepository>(),
        userId: userId,
      )..initialize(),
      child: const _ChatSettingsView(),
    );
  }
}

class _ChatSettingsView extends StatelessWidget {
  const _ChatSettingsView();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: OpnPrimaryAppBar(
        title:  Text('Inteligencia OPN',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Theme.of(context).colorScheme.surface,
        )),
      ),
      body: BlocConsumer<ChatPreferencesCubit, ChatPreferencesState>(
        listener: (context, state) {
          if (state.hasError && state.errorMessage != null) {
            ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: colors.error,
                ),
              );
            context.read<ChatPreferencesCubit>().clearError();
          }
        },
        builder: (context, state) {
          if (state.isLoadingModels || state.isLoadingPreferences) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.preferences == null) {
            return const Center(
              child: Text('No se pudieron cargar las preferencias'),
            );
          }

          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _ModelSelector(
                    availableModels: state.availableModels,
                    selectedModel: state.selectedModel,
                    onModelSelected: (model) {
                      context
                          .read<ChatPreferencesCubit>()
                          .updateSelectedModel(model);
                    },
                  ),
                  const SizedBox(height: 24),
                  _ResponseLengthSelector(
                    currentLength: state.preferences!.responseLength,
                    onLengthChanged: (length) {
                      context
                          .read<ChatPreferencesCubit>()
                          .updateResponseLength(length);
                    },
                  ),
                  const SizedBox(height: 24),
                  _ToneSelector(
                    currentTone: state.preferences!.tone,
                    onToneChanged: (tone) {
                      context.read<ChatPreferencesCubit>().updateTone(tone);
                    },
                  ),
                  const SizedBox(height: 24),
                  _EmojiSwitch(
                    enableEmojis: state.preferences!.enableEmojis,
                    onChanged: (value) {
                      context
                          .read<ChatPreferencesCubit>()
                          .updateEnableEmojis(value);
                    },
                  ),
                  const SizedBox(height: 24),


                  BlocSelector<AuthCubit, AuthState, User>(
                    selector: (state) => state.user,
                    builder: (context, user) => user.isBetaTester?_MaxTokensSlider(
                      maxTokens: state.preferences!.maxTokens,
                      selectedModel: state.selectedModel,
                      onChanged: (value) {
                        context
                            .read<ChatPreferencesCubit>()
                            .updateMaxTokens(value);
                      },
                    ): SizedBox(),
                  ),
                  const SizedBox(height: 24),
                  _CustomSystemPrompt(
                    customPrompt: state.preferences!.customSystemPrompt,
                    onChanged: (value) {
                      context
                          .read<ChatPreferencesCubit>()
                          .updateCustomSystemPrompt(value);
                    },
                  ),
                  const SizedBox(height: 100),
                ],
              ),
              if (state.hasUnsavedChanges) _BottomActionBar(),
            ],
          );
        },
      ),
    );
  }
}

// Widget para seleccionar el modelo de IA
class _ModelSelector extends StatelessWidget {
  const _ModelSelector({
    required this.availableModels,
    required this.selectedModel,
    required this.onModelSelected,
  });

  final List<AiModel> availableModels;
  final AiModel? selectedModel;
  final ValueChanged<AiModel?> onModelSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Modelo de IA',
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Selecciona el modelo que mejor se adapte a tus necesidades',
          style: textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 16),
        ...availableModels.map(
          (model) => ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: PremiumContent(
              requiresPremium: true,
              child: _ModelCard(
                model: model,
                isSelected: selectedModel?.id == model.id,
                onTap: () => onModelSelected(model),
              ),
            ),
          ),
        ),
        _ModelCard(
          model: null,
          isSelected: selectedModel == null,
          onTap: () => onModelSelected(null),
        ),
      ],
    );
  }
}

// Card individual para cada modelo
class _ModelCard extends StatelessWidget {
  const _ModelCard({
    required this.model,
    required this.isSelected,
    required this.onTap,
  });

  final AiModel? model;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final displayName = model?.displayName ?? 'Predeterminado del Sistema';
    final description =
        model?.description ?? 'Usa el modelo configurado por defecto';
    final speedRating = model?.speedRating;
    final thinkingCapability = model?.thinkingCapability;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: isSelected
            ? colors.primaryContainer.withOpacity(0.3)
            : colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? colors.primary : colors.outlineVariant,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayName,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: colors.primary,
                        size: 20,
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (model != null) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (speedRating != null)
                        _RatingChip(
                          icon: Icons.flash_on,
                          label: 'Velocidad',
                          rating: speedRating,
                          colors: colors,
                        ),
                      if (thinkingCapability != null)
                        _RatingChip(
                          icon: Icons.psychology,
                          label: 'Razonamiento',
                          rating: thinkingCapability,
                          colors: colors,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Chip para mostrar ratings
class _RatingChip extends StatelessWidget {
  const _RatingChip({
    required this.icon,
    required this.label,
    required this.rating,
    required this.colors,
  });

  final IconData icon;
  final String label;
  final int rating;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.secondaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colors.secondary),
          const SizedBox(width: 4),
          ...List.generate(
            5,
            (index) => Icon(
              index < rating ? Icons.star : Icons.star_border,
              size: 12,
              color: colors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

// Selector de longitud de respuesta
class _ResponseLengthSelector extends StatelessWidget {
  const _ResponseLengthSelector({
    required this.currentLength,
    required this.onLengthChanged,
  });

  final ResponseLength currentLength;
  final ValueChanged<ResponseLength> onLengthChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Longitud de Respuestas',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        SegmentedButton<ResponseLength>(
          segments: ResponseLength.values
              .map(
                (length) => ButtonSegment(
                  value: length,
                  label: Text(
                      length.displayName,
                      style: TextStyle(
                        fontSize: 12
                      ),
                  ),
                ),
              )
              .toList(),
          selected: {currentLength},
          onSelectionChanged: (Set<ResponseLength> newSelection) {
            onLengthChanged(newSelection.first);
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return colors.primaryContainer;
              }
              return colors.surfaceContainerLowest;
            }),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          currentLength.description,
          style: textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// Selector de tono
class _ToneSelector extends StatelessWidget {
  const _ToneSelector({
    required this.currentTone,
    required this.onToneChanged,
  });

  final ConversationTone currentTone;
  final ValueChanged<ConversationTone> onToneChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tono de Conversación',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        SegmentedButton<ConversationTone>(
          segments: ConversationTone.values
              .map(
                (tone) => ButtonSegment(
                  value: tone,
                  label: Text(tone.displayName,
                  style: TextStyle(
                    fontSize: 12
                  ),
                  ),
                ),
              )
              .toList(),
          selected: {currentTone},
          onSelectionChanged: (Set<ConversationTone> newSelection) {
            onToneChanged(newSelection.first);
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return colors.primaryContainer;
              }
              return colors.surfaceContainerLowest;
            }),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          currentTone.description,
          style: textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// Switch para emojis
class _EmojiSwitch extends StatelessWidget {
  const _EmojiSwitch({
    required this.enableEmojis,
    required this.onChanged,
  });

  final bool enableEmojis;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(
            enableEmojis ? Icons.emoji_emotions : Icons.emoji_emotions_outlined,
            color: colors.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Usar Emojis',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'La IA usará emojis en sus respuestas',
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: enableEmojis,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// Slider para tokens máximos
class _MaxTokensSlider extends StatelessWidget {
  const _MaxTokensSlider({
    required this.maxTokens,
    required this.selectedModel,
    required this.onChanged,
  });

  final int? maxTokens;
  final AiModel? selectedModel;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final modelMaxTokens = selectedModel?.maxTokens ?? 8192;
    final currentValue = (maxTokens ?? modelMaxTokens).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Límite de Tokens',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            Text(
              maxTokens == null
                  ? 'Por defecto ($modelMaxTokens)'
                  : '$maxTokens tokens',
              style: textTheme.bodySmall?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: currentValue,
          min: 100,
          max: modelMaxTokens.toDouble(),
          divisions: (modelMaxTokens - 100) ~/ 100,
          label: currentValue.round().toString(),
          onChanged: (value) => onChanged(value.round()),
        ),
        if (maxTokens != null)
          Center(
            child: TextButton(
              onPressed: () => onChanged(null),
              child: const Text(
                  'Restaurar por defecto',
              style: TextStyle(
                fontSize: 12,
              ),
              ),
            ),
          ),
      ],
    );
  }
}

// Campo para system prompt personalizado
class _CustomSystemPrompt extends StatefulWidget {
  const _CustomSystemPrompt({
    required this.customPrompt,
    required this.onChanged,
  });

  final String? customPrompt;
  final ValueChanged<String> onChanged;

  @override
  State<_CustomSystemPrompt> createState() => _CustomSystemPromptState();
}

class _CustomSystemPromptState extends State<_CustomSystemPrompt> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.customPrompt);
  }

  @override
  void didUpdateWidget(_CustomSystemPrompt oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.customPrompt != oldWidget.customPrompt &&
        widget.customPrompt != _controller.text) {
      _controller.text = widget.customPrompt ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Instrucciones Personalizadas',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Añade instrucciones adicionales para personalizar el comportamiento de la IA',
          style: textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _controller,
          maxLines: 5,
          decoration: InputDecoration(
            hintText:
                'Ejemplo: "Siempre responde citando el artículo de ley correspondiente"',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: colors.surfaceContainerLowest,
          ),
          onChanged: widget.onChanged,
        ),
      ],
    );
  }
}

// Barra de acciones inferior
class _BottomActionBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BlocBuilder<ChatPreferencesCubit, ChatPreferencesState>(
          builder: (context, state) {
            return Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: state.isSaving
                        ? null
                        : () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Restaurar por defecto'),
                                content: const Text(
                                  '¿Estás seguro? Se perderán todas tus configuraciones personalizadas.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text('Cancelar'),
                                  ),
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text('Restaurar'),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed == true && context.mounted) {
                              await context
                                  .read<ChatPreferencesCubit>()
                                  .resetToDefaults();
                            }
                          },
                    icon: const Icon(Icons.restart_alt, size: 18),
                    label: const Text(
                      'Restaurar',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: state.isSaving
                        ? null
                        : () async {
                            await context
                                .read<ChatPreferencesCubit>()
                                .savePreferences();

                            if (context.mounted) {
                              ScaffoldMessenger.of(context)
                                ..clearSnackBars()
                                ..showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Configuración guardada correctamente',
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: colors.primary,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                );
                            }
                          },
                    icon: state.isSaving
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.onPrimary,
                            ),
                          )
                        : const Icon(Icons.save, size: 18),
                    label: Text(
                      state.isSaving ? 'Guardando...' : 'Guardar',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
