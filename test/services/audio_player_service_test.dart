import 'package:flutter_test/flutter_test.dart';
import 'package:simple_music_player/services/audio_player_service.dart';

void main() {
  group('AudioPlayerService Tests', () {
    late AudioPlayerService service;

    setUp(() {
      service = AudioPlayerService();
    });

    test('Initial state is not playing', () {
      expect(service.isPlaying, false);
    });

    test('Initial position is zero', () {
      expect(service.currentPosition, Duration.zero);
    });

    test('Initial duration is null', () {
      expect(service.currentDuration, isNull);
    });

    tearDown(() {
      service.dispose();
    });
  });
}