import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  AudioPlayerService() {
    _initAudioSession();
  }

  Future<void> _initAudioSession() async {
    await _audioPlayer.setAudioSource(
      ConcatenatingAudioSource(children: []),
      preload: true,
    );
  }

  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Stream<bool> get playingStream => _audioPlayer.playingStream;

  Duration get currentPosition => _audioPlayer.position;
  Duration? get currentDuration => _audioPlayer.duration;
  bool get isPlaying => _audioPlayer.playing;

  Stream<PlaybackState> get playbackStateStream {
    return Rx.combineLatest3<Duration, Duration?, bool, PlaybackState>(
      positionStream,
      durationStream,
      playingStream,
      (position, duration, isPlaying) => PlaybackState(
        position: position,
        duration: duration ?? Duration.zero,
        isPlaying: isPlaying,
      ),
    );
  }

  Future<void> loadAudio(String filePath) async {
    try {
      if (filePath.startsWith('assets/')) {
        await _audioPlayer.setAudioSource(
          AudioSource.uri(Uri.parse('asset:///$filePath')),
          preload: true,
        );
      } else {
        await _audioPlayer.setAudioSource(
          AudioSource.file(filePath),
          preload: true,
        );
      }
    } catch (e) {
      throw Exception('Error loading audio: $e');
    }
  }

  Future<void> play() async {
    await _audioPlayer.play();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
  }

  Future<void> setSpeed(double speed) async {
    await _audioPlayer.setSpeed(speed);
  }

  Future<void> setLoopMode(LoopMode loopMode) async {
    await _audioPlayer.setLoopMode(loopMode);
  }

  Future<void> setPitch(double pitch) async {
    await _audioPlayer.setPitch(pitch);
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}

class PlaybackState {
  final Duration position;
  final Duration duration;
  final bool isPlaying;

  PlaybackState({
    required this.position,
    required this.duration,
    required this.isPlaying,
  });

  double get progress {
    if (duration.inMilliseconds > 0) {
      return (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
    }
    return 0.0;
  }
}