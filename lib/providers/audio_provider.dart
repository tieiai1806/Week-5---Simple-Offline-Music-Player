import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song_model.dart';
import '../models/playlist_model.dart';
import '../services/audio_player_service.dart';
import '../services/storage_service.dart';

class AudioProvider extends ChangeNotifier {
  final AudioPlayerService _audioService;
  final StorageService _storageService;

  List<SongModel> _playlist = [];
  List<String> _favoriteSongIds = [];
  List<PlaylistModel> _customPlaylists = [];
  int _currentIndex = 0;
  bool _isShuffleEnabled = false;
  LoopMode _loopMode = LoopMode.off;
  
  Timer? _sleepTimer;
  Duration? _remainingSleepTime;
  double _playbackSpeed = 1.0;

  AudioProvider(this._audioService, this._storageService) {
    _init();
  }

  List<SongModel> get playlist => _playlist;
  int get currentIndex => _currentIndex;
  SongModel? get currentSong => (_playlist.isNotEmpty && _currentIndex < _playlist.length) 
      ? _playlist[_currentIndex] 
      : null;
  bool get isShuffleEnabled => _isShuffleEnabled;
  LoopMode get loopMode => _loopMode;
  double get playbackSpeed => _playbackSpeed;
  Duration? get remainingSleepTime => _remainingSleepTime;
  List<String> get favoriteSongIds => _favoriteSongIds;
  List<PlaylistModel> get customPlaylists => _customPlaylists;

  Stream<Duration> get positionStream => _audioService.positionStream;
  Stream<Duration?> get durationStream => _audioService.durationStream;
  Stream<bool> get playingStream => _audioService.playingStream;
  Stream<PlaybackState> get playbackStateStream => _audioService.playbackStateStream;

  Future<void> _init() async {
    _isShuffleEnabled = await _storageService.getShuffleState();
    final repeatMode = await _storageService.getRepeatMode();
    _loopMode = LoopMode.values[repeatMode];
    
    await _audioService.setLoopMode(_loopMode);
    final volume = await _storageService.getVolume();
    await _audioService.setVolume(volume);

    _favoriteSongIds = await _storageService.getFavorites();
    _customPlaylists = await _storageService.getPlaylists();
    
    _audioService.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (_playlist.isNotEmpty && _loopMode != LoopMode.one) {
          next();
        }
      }
    });
    notifyListeners();
  }

  Future<void> createPlaylist(String name) async {
    final now = DateTime.now();
    final newPlaylist = PlaylistModel(
      id: now.millisecondsSinceEpoch.toString(),
      name: name,
      songIds: [],
      createdAt: now,
      updatedAt: now,
    );
    _customPlaylists.add(newPlaylist);
    await _storageService.savePlaylists(_customPlaylists);
    notifyListeners();
  }

  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    final index = _customPlaylists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      if (!_customPlaylists[index].songIds.contains(songId)) {
        _customPlaylists[index].songIds.add(songId);
        _customPlaylists[index] = _customPlaylists[index].copyWith(
          updatedAt: DateTime.now(),
        );
        await _storageService.savePlaylists(_customPlaylists);
        notifyListeners();
      }
    }
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    final index = _customPlaylists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      _customPlaylists[index].songIds.remove(songId);
      _customPlaylists[index] = _customPlaylists[index].copyWith(
        updatedAt: DateTime.now(),
      );
      await _storageService.savePlaylists(_customPlaylists);
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(SongModel song) async {
    if (_favoriteSongIds.contains(song.id)) {
      _favoriteSongIds.remove(song.id);
    } else {
      _favoriteSongIds.add(song.id);
    }
    await _storageService.saveFavorites(_favoriteSongIds);
    notifyListeners();
  }

  bool isFavorite(String songId) {
    return _favoriteSongIds.contains(songId);
  }

  Future<void> setPlaylist(List<SongModel> songs, int startIndex) async {
    if (songs.isEmpty) return;
    _playlist = songs;
    _currentIndex = startIndex;
    await _playSongAtIndex(_currentIndex);
    notifyListeners();
  }

  Future<void> _playSongAtIndex(int index) async {
    if (_playlist.isEmpty || index < 0 || index >= _playlist.length) return;
    _currentIndex = index;
    final song = _playlist[index];
    try {
      await _audioService.loadAudio(song.filePath);
      await _audioService.setSpeed(_playbackSpeed);
      await _audioService.play();
      await _storageService.saveLastPlayed(song.id);
    } catch (e) {
      debugPrint('Error playing song: $e');
    }
    notifyListeners();
  }

  Future<void> playPause() async {
    if (_playlist.isEmpty) return;
    if (_audioService.isPlaying) {
      await _audioService.pause();
    } else {
      await _audioService.play();
    }
    notifyListeners();
  }

  Future<void> next() async {
    if (_playlist.isEmpty) return;
    if (_isShuffleEnabled) {
      _currentIndex = _getRandomIndex();
    } else {
      _currentIndex = (_currentIndex + 1) % _playlist.length;
    }
    await _playSongAtIndex(_currentIndex);
  }

  Future<void> previous() async {
    if (_playlist.isEmpty) return;
    if (_audioService.currentPosition.inSeconds > 3) {
      await _audioService.seek(Duration.zero);
    } else {
      if (_isShuffleEnabled) {
        _currentIndex = _getRandomIndex();
      } else {
        _currentIndex = (_currentIndex - 1 + _playlist.length) % _playlist.length;
      }
      await _playSongAtIndex(_currentIndex);
    }
  }

  Future<void> seek(Duration position) async {
    await _audioService.seek(position);
  }

  Future<void> toggleShuffle() async {
    _isShuffleEnabled = !_isShuffleEnabled;
    await _storageService.saveShuffleState(_isShuffleEnabled);
    notifyListeners();
  }

  Future<void> toggleRepeat() async {
    switch (_loopMode) {
      case LoopMode.off:
        _loopMode = LoopMode.all;
        break;
      case LoopMode.all:
        _loopMode = LoopMode.one;
        break;
      case LoopMode.one:
        _loopMode = LoopMode.off;
        break;
    }
    await _audioService.setLoopMode(_loopMode);
    await _storageService.saveRepeatMode(_loopMode.index);
    notifyListeners();
  }

  Future<void> setVolume(double volume) async {
    await _audioService.setVolume(volume);
    await _storageService.saveVolume(volume);
    notifyListeners();
  }

  Future<void> setPlaybackSpeed(double speed) async {
    _playbackSpeed = speed;
    await _audioService.setSpeed(speed);
    notifyListeners();
  }

  void setSleepTimer(Duration duration) {
    _sleepTimer?.cancel();
    _remainingSleepTime = duration;
    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSleepTime != null && _remainingSleepTime!.inSeconds > 0) {
        _remainingSleepTime = Duration(seconds: _remainingSleepTime!.inSeconds - 1);
        notifyListeners();
      } else {
        _audioService.pause();
        cancelSleepTimer();
      }
    });
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _remainingSleepTime = null;
    notifyListeners();
  }

  int _getRandomIndex() {
    if (_playlist.isEmpty) return 0;
    final random = DateTime.now().millisecondsSinceEpoch % _playlist.length;
    return random;
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    _audioService.dispose();
    super.dispose();
  }
}