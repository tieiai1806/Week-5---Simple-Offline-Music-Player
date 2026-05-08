import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../screens/now_playing_screen.dart';
import '../services/audio_player_service.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, provider, child) {
        final song = provider.currentSong;
        if (song == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NowPlayingScreen()),
            );
          },
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFF282828),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildProgressBar(provider),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _buildAlbumArt(song.albumArt),
                        const SizedBox(width: 12),
                        _buildSongInfo(song.title, song.artist),
                        _buildControls(provider),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(AudioProvider provider) {
    return StreamBuilder<PlaybackState>(
      stream: provider.playbackStateStream,
      builder: (context, snapshot) {
        final progress = snapshot.data?.progress ?? 0.0;
        return LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.white10,
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1DB954)),
          minHeight: 2,
        );
      },
    );
  }

  Widget _buildAlbumArt(String? albumArt) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.black26,
      ),
      child: albumArt != null && File(albumArt).existsSync()
          ? ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.file(File(albumArt), fit: BoxFit.cover),
            )
          : const Icon(Icons.music_note, color: Colors.white30),
    );
  }

  Widget _buildSongInfo(String title, String artist) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            artist,
            style: const TextStyle(
              color: Color(0xFFB3B3B3),
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildControls(AudioProvider provider) {
    return Row(
      children: [
        StreamBuilder<bool>(
          stream: provider.playingStream,
          builder: (context, snapshot) {
            final isPlaying = snapshot.data ?? false;
            return IconButton(
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () => provider.playPause(),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.skip_next, color: Colors.white),
          onPressed: () => provider.next(),
        ),
      ],
    );
  }
}