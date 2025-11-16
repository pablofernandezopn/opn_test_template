import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class RetroAudioPlayer extends StatefulWidget {
  const RetroAudioPlayer({
    super.key,
    required this.text,
  });

  final String text;

  @override
  State<RetroAudioPlayer> createState() => _RetroAudioPlayerState();
}

class _RetroAudioPlayerState extends State<RetroAudioPlayer> {
  late final FlutterTts _flutterTts;
  bool _isPlaying = false;
  bool _isLoading = false;
  double _speechRate = 0.5;

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage('es-ES');
      await _flutterTts.setSpeechRate(_speechRate);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setStartHandler(() {
        if (mounted) {
          setState(() {
            _isPlaying = true;
            _isLoading = false;
          });
        }
      });

      _flutterTts.setCompletionHandler(() {
        if (mounted) {
          setState(() {
            _isPlaying = false;
          });
        }
      });

      _flutterTts.setErrorHandler((msg) {
        if (mounted) {
          setState(() {
            _isPlaying = false;
            _isLoading = false;
          });
        }
      });

      _flutterTts.setCancelHandler(() {
        if (mounted) {
          setState(() {
            _isPlaying = false;
          });
        }
      });
    } catch (e) {
      debugPrint('Error initializing TTS: $e');
    }
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _flutterTts.stop();
      setState(() {
        _isPlaying = false;
      });
    } else {
      setState(() {
        _isLoading = true;
      });
      await _flutterTts.speak(widget.text);
    }
  }

  Future<void> _stop() async {
    await _flutterTts.stop();
    setState(() {
      _isPlaying = false;
    });
  }

  Future<void> _changeSpeechRate(double rate) async {
    setState(() {
      _speechRate = rate;
    });
    await _flutterTts.setSpeechRate(rate);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.volume_up,
                color: colors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Audio de retroalimentación',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
              ),
              if (_isPlaying)
                IconButton(
                  onPressed: _stop,
                  icon: Icon(
                    Icons.stop,
                    color: colors.error,
                  ),
                  tooltip: 'Detener',
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              FilledButton.icon(
                onPressed: _isLoading ? null : _togglePlayPause,
                icon: _isLoading
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.onPrimary,
                        ),
                      )
                    : Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 20,
                      ),
                label: Text(_isPlaying ? 'Pausar' : 'Reproducir'),
                style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Velocidad:',
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_speechRate.toStringAsFixed(1)}x',
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _speechRate,
                      min: 0.3,
                      max: 1.0,
                      divisions: 7,
                      onChanged: (value) => _changeSpeechRate(value),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.text,
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