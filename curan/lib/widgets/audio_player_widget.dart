import 'package:flutter/material.dart';
import '../../models/track_model.dart';

class AudioPlayerWidget extends StatelessWidget {
  final TrackModel track;
  final Duration position;
  final Duration? duration;
  final bool isPlaying;
  final bool isRepeat;
  final bool isShuffled;
  final VoidCallback onPlayPause;
  final Function(Duration) onSeek;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onToggleRepeat;
  final VoidCallback onToggleShuffle;
  final double progress;

  const AudioPlayerWidget({
    super.key,
    required this.track,
    required this.position,
    this.duration,
    required this.isPlaying,
    required this.isRepeat,
    required this.isShuffled,
    required this.onPlayPause,
    required this.onSeek,
    required this.onNext,
    required this.onPrevious,
    required this.onToggleRepeat,
    required this.onToggleShuffle,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.music_note,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          track.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          track.category ?? '',
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape:
                      const RoundSliderOverlayShape(overlayRadius: 12),
                  activeTrackColor: Theme.of(context).colorScheme.primary,
                  inactiveTrackColor:
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  thumbColor: Theme.of(context).colorScheme.primary,
                ),
                child: Slider(
                  value: progress.clamp(0.0, 1.0),
                  onChanged: (value) {
                    if (duration != null) {
                      onSeek(Duration(
                        milliseconds: (value * duration!.inMilliseconds).round(),
                      ));
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(position),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      duration != null ? _formatDuration(duration!) : '--:--',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(
                      isRepeat ? Icons.repeat_on : Icons.repeat,
                      color: isRepeat ? Theme.of(context).colorScheme.primary : Colors.grey,
                    ),
                    onPressed: onToggleRepeat,
                    tooltip: 'Repeat',
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_previous),
                    iconSize: 36,
                    color: Colors.white,
                    onPressed: onPrevious,
                    tooltip: 'Previous',
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      iconSize: 40,
                      onPressed: onPlayPause,
                      tooltip: isPlaying ? 'Pause' : 'Play',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next),
                    iconSize: 36,
                    color: Colors.white,
                    onPressed: onNext,
                    tooltip: 'Next',
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.shuffle,
                      color: isShuffled ? Theme.of(context).colorScheme.primary : Colors.grey,
                    ),
                    onPressed: onToggleShuffle,
                    tooltip: 'Shuffle',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
