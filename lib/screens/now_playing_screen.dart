import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../providers/audio_provider.dart';
import '../services/audio_player_service.dart';
import '../widgets/player_controls.dart';
import '../widgets/progress_bar.dart';
import 'package:just_audio/just_audio.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191414),
      body: Consumer<AudioProvider>(
        builder: (context, provider, child) {
          final song = provider.currentSong;

          if (song == null) {
            return const Center(
              child: Text(
                'No song playing',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF2E2E2E),
                  Color(0xFF191414),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(context, provider),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // TRUYỀN CONTEXT VÀO ĐÂY
                          _buildAlbumArt(context, song, provider),
                          _buildSongInfo(song),
                          Column(
                            children: [
                              _buildProgressBar(provider),
                              const SizedBox(height: 16),
                              _buildAudioModeControls(provider),
                              const SizedBox(height: 16),
                              PlayerControls(provider: provider),
                            ],
                          ),
                          _buildExtraControls(context, provider),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AudioProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 32),
            onPressed: () => Navigator.pop(context),
          ),
          Column(
            children: [
              const Text(
                'PLAYING FROM PLAYLIST',
                style: TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold),
              ),
              Text(
                provider.currentSong?.album ?? 'Asset Album',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              Icons.timer_outlined, 
              color: provider.remainingSleepTime != null ? const Color(0xFF1DB954) : Colors.white
            ),
            onPressed: () => _showSleepTimerDialog(context, provider),
          ),
        ],
      ),
    );
  }

  // ĐÃ THÊM THAM SỐ BuildContext context VÀO ĐÂY
  Widget _buildAlbumArt(BuildContext context, SongModel song, AudioProvider provider) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! < 0) {
          provider.next();
        } else if (details.primaryVelocity! > 0) {
          provider.previous();
        }
      },
      child: Hero(
        tag: 'album_art_${song.id}',
        child: Container(
          // BÂY GIỜ LỆNH context.size SẼ HOẠT ĐỘNG
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.width * 0.8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: song.albumArt != null && File(song.albumArt!).existsSync()
                ? Image.file(File(song.albumArt!), fit: BoxFit.cover)
                : Container(
                    color: const Color(0xFF282828),
                    child: const Icon(Icons.music_note, size: 100, color: Color(0xFF1DB954)),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSongInfo(SongModel song) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                song.title,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                song.artist,
                style: const TextStyle(color: Color(0xFFB3B3B3), fontSize: 18),
              ),
            ],
          ),
        ),
        const Icon(Icons.favorite_border, color: Color(0xFF1DB954), size: 28),
      ],
    );
  }

  Widget _buildProgressBar(AudioProvider provider) {
    return StreamBuilder<PlaybackState>(
      stream: provider.playbackStateStream,
      builder: (context, snapshot) {
        final state = snapshot.data;
        return ProgressBarCustom(
          position: state?.position ?? Duration.zero,
          duration: state?.duration ?? Duration.zero,
          onSeek: (position) => provider.seek(position),
        );
      },
    );
  }

  Widget _buildAudioModeControls(AudioProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(
            Icons.shuffle,
            color: provider.isShuffleEnabled ? const Color(0xFF1DB954) : Colors.white54,
          ),
          onPressed: () => provider.toggleShuffle(),
        ),
        IconButton(
          icon: Icon(
            provider.loopMode == LoopMode.one ? Icons.repeat_one : Icons.repeat,
            color: provider.loopMode != LoopMode.off ? const Color(0xFF1DB954) : Colors.white54,
          ),
          onPressed: () => provider.toggleRepeat(),
        ),
      ],
    );
  }

  Widget _buildExtraControls(BuildContext context, AudioProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () => _showSpeedDialog(context, provider),
          child: Text(
            '${provider.playbackSpeed}x Speed',
            style: const TextStyle(color: Color(0xFF1DB954), fontWeight: FontWeight.bold),
          ),
        ),
        if (provider.remainingSleepTime != null)
          Text(
            _formatDuration(provider.remainingSleepTime!),
            style: const TextStyle(color: Color(0xFF1DB954), fontSize: 12),
          ),
        IconButton(
          icon: const Icon(Icons.playlist_play, color: Colors.white, size: 28),
          onPressed: () {},
        ),
      ],
    );
  }

  void _showSleepTimerDialog(BuildContext context, AudioProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF282828),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Stop audio in', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            _timerOption(context, provider, 'Off', null),
            _timerOption(context, provider, '15 minutes', const Duration(minutes: 15)),
            _timerOption(context, provider, '30 minutes', const Duration(minutes: 30)),
            _timerOption(context, provider, '1 hour', const Duration(minutes: 60)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _timerOption(BuildContext context, AudioProvider provider, String title, Duration? duration) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: provider.remainingSleepTime?.inMinutes == duration?.inMinutes ? const Icon(Icons.check, color: Color(0xFF1DB954)) : null,
      onTap: () {
        duration == null ? provider.cancelSleepTimer() : provider.setSleepTimer(duration);
        Navigator.pop(context);
      },
    );
  }

  void _showSpeedDialog(BuildContext context, AudioProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF282828),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Playback Speed', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [0.5, 1.0, 1.5, 2.0].map((speed) {
                return GestureDetector(
                  onTap: () {
                    provider.setPlaybackSpeed(speed);
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: provider.playbackSpeed == speed ? const Color(0xFF1DB954) : Colors.grey[800],
                      child: Text('${speed}x', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}";
  }
}