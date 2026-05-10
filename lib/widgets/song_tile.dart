import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../providers/audio_provider.dart';

class SongTile extends StatelessWidget {
  final SongModel song;
  final VoidCallback onTap;

  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF282828),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: _buildAlbumArt(),
        title: Text(
          song.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            "${song.artist} • ${song.album ?? 'Unknown Album'}",
            style: const TextStyle(
              color: Color(0xFFB3B3B3),
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert, color: Color(0xFFB3B3B3)),
          onPressed: () => _showOptionsMenu(context),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildAlbumArt() {
    return Container(
      width: 52, height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFF191414),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _getAlbumArtWidget(),
      ),
    );
  }

  Widget _getAlbumArtWidget() {
    if (song.albumArt != null && File(song.albumArt!).existsSync()) {
      return Image.file(
        File(song.albumArt!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholderIcon(),
      );
    }
    return _buildPlaceholderIcon();
  }

  Widget _buildPlaceholderIcon() {
    return const Center(
      child: Icon(Icons.music_note, color: Color(0xFF1DB954), size: 30),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    final provider = Provider.of<AudioProvider>(context, listen: false);
    final bool isFav = provider.isFavorite(song.id);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF282828),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                height: 4, width: 40,
                decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2)),
              ),
              _buildOptionItem(
                context,
                icon: isFav ? Icons.favorite : Icons.favorite_border,
                label: isFav ? 'Remove from Liked Songs' : 'Add to Liked Songs',
                iconColor: const Color(0xFF1DB954),
                onTap: () {
                  provider.toggleFavorite(song);
                  _showToast(context, isFav ? 'Removed from Liked Songs' : 'Added to Liked Songs');
                },
              ),
              _buildOptionItem(
                context,
                icon: Icons.playlist_add,
                label: 'Add to/Remove from playlist',
                onTap: () => _showSelectPlaylistDialog(context),
              ),
              _buildOptionItem(context, icon: Icons.share_outlined, label: 'Share', onTap: () {}),
              _buildOptionItem(context, icon: Icons.info_outline, label: 'Song info', onTap: () {}),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _showSelectPlaylistDialog(BuildContext context) {
    final provider = context.read<AudioProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF282828),
        title: const Text('Manage Playlists', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  provider.isFavorite(song.id) ? Icons.favorite : Icons.favorite_border,
                  color: const Color(0xFF1DB954),
                ),
                title: const Text('Liked Songs', style: TextStyle(color: Colors.white)),
                onTap: () {
                  provider.toggleFavorite(song);
                  Navigator.pop(context);
                  _showToast(context, provider.isFavorite(song.id) ? 'Removed from Liked Songs' : 'Added to Liked Songs');
                },
              ),
              const Divider(color: Colors.white24),
              if (provider.customPlaylists.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No custom playlists found', style: TextStyle(color: Colors.white54)),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: provider.customPlaylists.length,
                    itemBuilder: (context, index) {
                      final playlist = provider.customPlaylists[index];
                      final bool alreadyIn = playlist.songIds.contains(song.id);
                      return ListTile(
                        leading: Icon(
                          alreadyIn ? Icons.check_circle : Icons.add_circle_outline,
                          color: alreadyIn ? const Color(0xFF1DB954) : Colors.white54,
                        ),
                        title: Text(playlist.name, style: const TextStyle(color: Colors.white)),
                        onTap: () {
                          if (alreadyIn) {
                            provider.removeSongFromPlaylist(playlist.id, song.id);
                            _showToast(context, 'Removed from ${playlist.name}');
                          } else {
                            provider.addSongToPlaylist(playlist.id, song.id);
                            _showToast(context, 'Added to ${playlist.name}');
                          }
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF323232),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildOptionItem(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap, Color iconColor = Colors.white}) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 24),
      title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}