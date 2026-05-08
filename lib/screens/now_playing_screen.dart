import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../providers/audio_provider.dart';
import '../services/audio_player_service.dart';
import '../widgets/player_controls.dart';
import '../widgets/progress_bar.dart';

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

          return SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, provider),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildAlbumArt(song, provider),
                        const SizedBox(height: 30),
                        _buildSongInfo(song),
                        const SizedBox(height: 30),
                        _buildProgressBar(provider),
                        const SizedBox(height: 10),
                        _buildExtraControls(context, provider),
                        const SizedBox(height: 10),
                        PlayerControls(provider: provider),
                      ],
                    ),
                  ),
                ),
              ],
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
                'NOW PLAYING',
                style: TextStyle(color: Colors.white, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold),
              ),
              if (provider.remainingSleepTime != null)
                Text(
                  'Timer: ${_formatDuration(provider.remainingSleepTime!)}',
                  style: const TextStyle(color: Color(0xFF1DB954), fontSize: 12, fontWeight: FontWeight.bold),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.timer_outlined, color: Colors.white),
            onPressed: () => _showSleepTimerDialog(context, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt(SongModel song, AudioProvider provider) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! < 0) {
          provider.next();
        } else if (details.primaryVelocity! > 0) {
          provider.previous();
        }
      },
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: song.albumArt != null && File(song.albumArt!).existsSync()
              ? Image.file(File(song.albumArt!), fit: BoxFit.cover)
              : Container(
                  color: const Color(0xFF282828),
                  child: const Icon(Icons.music_note, size: 100, color: Colors.grey),
                ),
        ),
      ),
    );
  }

  Widget _buildSongInfo(SongModel song) {
    return Column(
      children: [
        Text(
          song.title,
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          song.artist,
          style: const TextStyle(color: Color(0xFFB3B3B3), fontSize: 18),
          textAlign: TextAlign.center,
        ),
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

  Widget _buildExtraControls(BuildContext context, AudioProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () => _showSpeedDialog(context, provider),
          child: Text(
            '${provider.playbackSpeed}x',
            style: const TextStyle(color: Color(0xFF1DB954), fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.share_outlined, color: Color(0xFFB3B3B3), size: 20),
          onPressed: () {},
        ),
      ],
    );
  }

  void _showSleepTimerDialog(BuildContext context, AudioProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF282828),
        title: const Text('Sleep Timer', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _timerOption(context, provider, 'Off', null),
            _timerOption(context, provider, '15 minutes', const Duration(minutes: 15)),
            _timerOption(context, provider, '30 minutes', const Duration(minutes: 30)),
            _timerOption(context, provider, '60 minutes', const Duration(minutes: 60)),
          ],
        ),
      ),
    );
  }

  Widget _timerOption(BuildContext context, AudioProvider provider, String title, Duration? duration) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {
        duration == null ? provider.cancelSleepTimer() : provider.setSleepTimer(duration);
        Navigator.pop(context);
      },
    );
  }

  void _showSpeedDialog(BuildContext context, AudioProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF282828),
        title: const Text('Playback Speed', style: TextStyle(color: Colors.white)),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [0.5, 1.0, 1.5, 2.0].map((speed) {
            return GestureDetector(
              onTap: () {
                provider.setPlaybackSpeed(speed);
                Navigator.pop(context);
              },
              child: CircleAvatar(
                backgroundColor: provider.playbackSpeed == speed ? const Color(0xFF1DB954) : Colors.grey[800],
                child: Text(speed.toString(), style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}";
  }
}