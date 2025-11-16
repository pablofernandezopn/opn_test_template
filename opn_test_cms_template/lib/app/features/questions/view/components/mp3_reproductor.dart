import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import '../../cubit/cubit.dart';
import '../../cubit/state.dart';
import '../../model/question_model.dart';

enum AudioMode { play, stop, resume }

class Reproductor extends StatefulWidget {
  const Reproductor({
    super.key,
    required this.question,
    this.generateAudio = true,
  });

  final Question question;
  final bool generateAudio;

  @override
  State<Reproductor> createState() => _ReproductorState();
}

class _ReproductorState extends State<Reproductor> {
  late AudioPlayer player;
  late AudioMode mode;
  late bool isRetroAudio;
  late String url;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    isRetroAudio = widget.question.retroAudioUrl.isNotEmpty;
    _updateUrl();
    mode = AudioMode.stop;
    player = AudioPlayer();

    player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        mode = state == PlayerState.playing ? AudioMode.play : AudioMode.stop;
      });
    });
    player.onDurationChanged.listen((newDuration) {
      if (!mounted) return;
      setState(() => duration = newDuration);
    });
    player.onPositionChanged.listen((newPosition) {
      if (!mounted) return;
      setState(() => position = newPosition);
    });
  }

  @override
  void didUpdateWidget(covariant Reproductor oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si cambia la pregunta (id distinto) se actualiza la URL
    if (widget.question.id != oldWidget.question.id ||
        widget.question.retroAudioUrl != oldWidget.question.retroAudioUrl) {
      setState(() {
        isRetroAudio = widget.question.retroAudioUrl.isNotEmpty;
        _updateUrl();
      });
    }
  }

  void _updateUrl() {
    if (widget.question.retroAudioUrl.isEmpty) {
      url = '';
      return;
    }

    // Construir la URL pública desde el storage de Supabase
    url = Supabase.instance.client.storage
        .from('topics')
        .getPublicUrl(widget.question.retroAudioUrl);
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  void _togglePlayPause() async {
    if (url.isEmpty) return;

    setState(() {
      if (mode == AudioMode.stop || mode == AudioMode.resume) {
        player.play(UrlSource(url));
        mode = AudioMode.play;
      } else if (mode == AudioMode.play) {
        player.pause();
        mode = AudioMode.resume;
      }
    });
  }

  void _seekAudio(double value) {
    final newPosition = Duration(seconds: value.toInt());
    player.seek(newPosition);
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 400),
      child: Container(
        alignment: Alignment.centerLeft,
        child: isRetroAudio
            ? Stack(
                children: [
                  Row(
                    children: [
                      IconButton(
                        iconSize: 48,
                        icon: Icon(
                          mode == AudioMode.play
                              ? Icons.pause_circle_filled_outlined
                              : Icons.play_circle_outlined,
                        ),
                        onPressed: _togglePlayPause,
                      ),
                      Expanded(
                        child: Slider(
                          thumbColor: Theme.of(context).colorScheme.primary,
                          activeColor: Theme.of(context).colorScheme.primary,
                          inactiveColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.3),
                          min: 0.0,
                          max: duration.inSeconds.toDouble(),
                          value: position.inSeconds
                              .toDouble()
                              .clamp(0.0, duration.inSeconds.toDouble()),
                          onChanged: _seekAudio,
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    right: 8,
                    top: 4,
                    child: Text(
                      _formatDuration(duration - position),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  if (widget.generateAudio)
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: TextButton(
                        onPressed: () async {
                          await _showGenerateAudioDialog();
                        },
                        child: const Text(
                          'Actualizar retroaudio',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                ],
              )
            : InkWell(
                onTap: () async {
                  await _showGenerateAudioDialog();
                },
                child: const Text(
                  'Haz click para generar un retroaudio.',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _showGenerateAudioDialog() async {
    final questionCubit = context.read<QuestionCubit>();

    await showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: questionCubit,
        child: _GenerateAudioDialog(question: widget.question),
      ),
    );

    // Actualizar después de cerrar el diálogo
    setState(() {
      isRetroAudio = widget.question.retroAudioUrl.isNotEmpty;
      _updateUrl();
    });
  }

  String _formatDuration(Duration duration) {
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$seconds seg';
  }
}

/// Widget para generar el retroaudio; se muestra en el Dialog.
class _GenerateAudioDialog extends StatefulWidget {
  const _GenerateAudioDialog({required this.question});

  final Question question;

  @override
  State<_GenerateAudioDialog> createState() => _GenerateAudioDialogState();
}

class _GenerateAudioDialogState extends State<_GenerateAudioDialog> {
  final TextEditingController _textController = TextEditingController();
  late AudioPlayer audioPlayer;
  bool isPlaying = false;
  bool isGeneratingText = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _textController.text = widget.question.retroAudioText;
    audioPlayer = AudioPlayer();

    // Autoguardado con debounce de 1.5 segundos
    _textController.addListener(() {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 700), () {
        _autoSaveText();
      });
    });

    audioPlayer.onDurationChanged.listen((newDuration) {
      if (!mounted) return;
      setState(() => duration = newDuration);
    });
    audioPlayer.onPositionChanged.listen((newPosition) {
      if (!mounted) return;
      setState(() => position = newPosition);
    });
    audioPlayer.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        isPlaying = false;
        position = Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    audioPlayer.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _autoSaveText() async {
    if (!mounted) return;

    // Solo guardar si el texto cambió
    if (_textController.text != widget.question.retroAudioText) {
      final updated = widget.question.copyWith(
        retroAudioText: _textController.text,
      );
      await context.read<QuestionCubit>().updateQuestion(
            widget.question.id!,
            updated,
          );
    }
  }

  Future<void> _generateTextWithAI() async {
    if (!mounted) return;

    setState(() => isGeneratingText = true);

    try {
      // Llamar al cubit para generar texto usando IA
      final generatedText = await context
          .read<QuestionCubit>()
          .generateRetroAudioText(widget.question);

      // Actualizar el TextField con el texto generado
      if (mounted) {
        setState(() {
          _textController.text = generatedText;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Texto generado con éxito'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar texto: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isGeneratingText = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuestionCubit, QuestionState>(
      builder: (context, state) {
        final isGenerating = state.generateRetroAudioStatus.isLoading;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título y botón de cerrar
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Generación de retroaudio',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  // TextField para editar el texto
                  TextField(
                    controller: _textController,
                    maxLines: null,
                    minLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Escribe aquí el texto para el retroaudio',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Botones para generar texto y audio
                  Row(
                    children: [
                      // Botón para generar texto con IA
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isGeneratingText || isGenerating
                              ? null
                              : _generateTextWithAI,
                          icon: isGeneratingText
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.auto_awesome),
                          label: Text(
                            isGeneratingText
                                ? 'Generando texto...'
                                : 'Generar texto con IA',
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            foregroundColor: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Botón para generar audio
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isGenerating || isGeneratingText
                              ? null
                              : () async {
                                  // Cancelar el timer de autoguardado y guardar inmediatamente
                                  _debounceTimer?.cancel();
                                  await _autoSaveText();

                                  // Generar el audio
                                  await context
                                      .read<QuestionCubit>()
                                      .generateRetroAudio(
                                        widget.question,
                                        customText: _textController.text,
                                      );
                                },
                          icon: isGenerating
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.record_voice_over),
                          label: Text(
                            isGenerating
                                ? 'Generando audio...'
                                : 'Generar audio',
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  // Mostrar reproductor si hay audio
                  if (widget.question.retroAudioUrl.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Reproductor',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                          ),
                          onPressed: () async {
                            if (isPlaying) {
                              await audioPlayer.pause();
                            } else {
                              final url = Supabase.instance.client.storage
                                  .from('topics')
                                  .getPublicUrl(widget.question.retroAudioUrl);
                              await audioPlayer.play(UrlSource(url));
                            }
                            setState(() => isPlaying = !isPlaying);
                          },
                        ),
                        Expanded(
                          child: Slider(
                            thumbColor: Theme.of(context).colorScheme.primary,
                            activeColor: Theme.of(context).colorScheme.primary,
                            inactiveColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.3),
                            min: 0,
                            max: duration.inSeconds.toDouble(),
                            value: position.inSeconds
                                .toDouble()
                                .clamp(0.0, duration.inSeconds.toDouble()),
                            onChanged: (value) async {
                              final newPosition =
                                  Duration(seconds: value.toInt());
                              await audioPlayer.seek(newPosition);
                              setState(() => position = newPosition);
                            },
                          ),
                        ),
                        Text(
                          position.toString().split('.').first,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
