import 'package:just_audio/just_audio.dart';
import '../models/track_model.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();
  DateTime? _playStartTime;
  TrackModel? _currentTrack;

  AudioPlayer get player => _player;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<int?> get currentIndexStream => _player.currentIndexStream;
  Stream<SequenceState?> get sequenceStateStream => _player.sequenceStateStream;
  Stream<LoopMode> get loopModeStream => _player.loopModeStream;

  bool get isPlaying => _player.playing;
  Duration get position => _player.position;
  Duration? get duration => _player.duration;
  LoopMode get loopMode => _player.loopMode;

  Future<void> init() async {
    // Listen to player state changes to track listening time
    _player.playerStateStream.listen((state) {
      if (state.playing) {
        _playStartTime = DateTime.now();
      } else {
        _recordListeningSession();
      }
    });
  }

  void _recordListeningSession() {
    if (_playStartTime != null && _currentTrack != null) {
      final duration = DateTime.now().difference(_playStartTime!);
      if (duration.inSeconds > 0) {
        // This will be handled by the provider
        _onListeningRecorded?.call(_currentTrack!, duration);
      }
      _playStartTime = null;
    }
  }

  Function(TrackModel, Duration)? _onListeningRecorded;

  void setOnListeningRecorded(Function(TrackModel, Duration) callback) {
    _onListeningRecorded = callback;
  }

  Future<void> loadTracks(
    List<TrackModel> tracks, {
    int initialIndex = 0,
  }) async {
    if (tracks.isEmpty) return;

    // Record any ongoing listening session before switching
    _recordListeningSession();

    final clampedIndex = initialIndex.clamp(0, tracks.length - 1);
    _currentTrack = tracks[clampedIndex];

    final sources = tracks
        .map((t) => AudioSource.uri(Uri.parse(t.audioUrl)))
        .toList();

    await _player.setAudioSource(
      ConcatenatingAudioSource(children: sources),
      initialIndex: clampedIndex,
      initialPosition: Duration.zero,
      preload: false,
    );
  }

  Future<void> play() async {
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
    _recordListeningSession();
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> seekTo(Duration position) async {
    await _player.seek(position);
  }

  Future<void> seekToNext() async {
    _recordListeningSession();
    await _player.seekToNext();
    if (_player.currentIndex != null) {
      // Update current track reference
    }
  }

  Future<void> seekToPrevious() async {
    _recordListeningSession();
    await _player.seekToPrevious();
  }

  Future<void> toggleRepeat() async {
    if (_player.loopMode == LoopMode.off) {
      await _player.setLoopMode(LoopMode.all);
    } else {
      await _player.setLoopMode(LoopMode.off);
    }
  }

  Future<void> setRepeatAll(bool repeatAll) async {
    await _player.setLoopMode(repeatAll ? LoopMode.all : LoopMode.off);
  }

  int? getCurrentIndex() {
    return _player.currentIndex;
  }

  Future<void> stop() async {
    _recordListeningSession();
    await _player.stop();
  }

  Future<void> dispose() async {
    _recordListeningSession();
    await _player.dispose();
  }

  Duration get currentPosition => _player.position;
}
