import 'dart:math';
import 'package:flutter/foundation.dart';
import '../services/audio_player_service.dart';
import '../services/audio_api_service.dart';
import '../models/track_model.dart';
import '../models/playlist_category.dart';

class AudioProvider extends ChangeNotifier {
  final AudioPlayerService _playerService = AudioPlayerService();
  final AudioApiService _apiService = AudioApiService();

  List<PlaylistCategory> _categories = [];
  List<TrackModel> _currentPlaylist = [];
  bool _isLoading = false;
  String? _errorMessage;

  Duration _position = Duration.zero;
  Duration? _duration;
  bool _isPlaying = false;
  bool _isRepeat = false;
  bool _isShuffled = false;
  int? _currentIndex;

  TrackModel? _lastTrack;
  DateTime? _lastPlayStart;

  AudioPlayerService get playerService => _playerService;
  List<PlaylistCategory> get categories => _categories;
  List<TrackModel> get currentPlaylist => _currentPlaylist;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Duration get position => _position;
  Duration? get duration => _duration;
  bool get isPlaying => _isPlaying;
  bool get isRepeat => _isRepeat;
  bool get isShuffled => _isShuffled;
  int? get currentIndex => _currentIndex;

  TrackModel? get currentTrack {
    if (_currentIndex != null &&
        _currentIndex! >= 0 &&
        _currentIndex! < _currentPlaylist.length) {
      return _currentPlaylist[_currentIndex!];
    }
    return null;
  }

  AudioProvider() {
    _initListeners();
  }

  void _initListeners() {
    _playerService.positionStream.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    _playerService.durationStream.listen((dur) {
      _duration = dur;
      notifyListeners();
    });

    _playerService.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      _handlePlayingStateChange(state.playing);
      notifyListeners();
    });

    _playerService.player.currentIndexStream.listen((index) {
      _currentIndex = index;
      _updateCurrentTrack();
      notifyListeners();
    });

    _playerService.loopModeStream.listen((mode) {
      _isRepeat = mode.name != 'off';
      notifyListeners();
    });
  }

  void _handlePlayingStateChange(bool isPlaying) {
    if (isPlaying && _lastTrack != null) {
      _lastPlayStart = DateTime.now();
    } else {
      _recordCurrentSession();
    }
  }

  void _updateCurrentTrack() {
    if (_currentIndex != null &&
        _currentIndex! >= 0 &&
        _currentIndex! < _currentPlaylist.length) {
      // Record previous track session before switching
      _recordCurrentSession();
      _lastTrack = _currentPlaylist[_currentIndex!];
      _lastPlayStart = DateTime.now();
    }
  }

  void _recordCurrentSession() {
    if (_lastTrack != null && _lastPlayStart != null && _isPlaying) {
      final duration = DateTime.now().difference(_lastPlayStart!);
      if (duration.inSeconds > 0) {
        _onTrackListened?.call(_lastTrack!, duration);
      }
    }
    // Don't reset here - let the update method handle it
  }

  Function(TrackModel, Duration)? _onTrackListened;

  void setOnTrackListened(Function(TrackModel, Duration) callback) {
    _onTrackListened = callback;
  }

  Future<void> init() async {
    await _playerService.init();
    await loadCategories();
  }

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      _categories = await _apiService.fetchPlaylists();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> selectCategory(int index) async {
    if (index < 0 || index >= _categories.length) return;

    _currentPlaylist = _categories[index].tracks;
    notifyListeners();
  }

  Future<void> playTrack(int trackIndex) async {
    if (_currentPlaylist.isEmpty) return;

    try {
      await _playerService.loadTracks(
        _currentPlaylist,
        initialIndex: trackIndex,
      );
      await _playerService.play();
    } catch (e) {
      _errorMessage = 'Failed to play track: $e';
      notifyListeners();
    }
  }

  Future<void> togglePlayPause() async {
    await _playerService.togglePlayPause();
  }

  Future<void> seekToNext() async {
    await _playerService.seekToNext();
  }

  Future<void> seekToPrevious() async {
    await _playerService.seekToPrevious();
  }

  Future<void> seekTo(Duration position) async {
    await _playerService.seekTo(position);
  }

  Future<void> toggleRepeat() async {
    await _playerService.toggleRepeat();
  }

  Future<void> toggleShuffle() async {
    _isShuffled = !_isShuffled;
    if (_isShuffled) {
      _currentPlaylist.shuffle(Random());
    } else {
      await loadCategories();
    }
    notifyListeners();
  }

  double get playbackProgress {
    if (_duration == null || _duration!.inMilliseconds == 0) return 0.0;
    final progress = _position.inMilliseconds / _duration!.inMilliseconds;
    if (progress.isNaN || progress.isInfinite) return 0.0;
    return progress.clamp(0.0, 1.0);
  }

  Future<void> playFavorites(List<TrackModel> favorites, int startIndex) async {
    if (favorites.isEmpty) return;
    _currentPlaylist = List.from(favorites);
    notifyListeners();
    try {
      await _playerService.loadTracks(
        _currentPlaylist,
        initialIndex: startIndex,
      );
      await _playerService.play();
    } catch (e) {
      _errorMessage = 'Failed to play favorite: $e';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _playerService.dispose();
    super.dispose();
  }
}
