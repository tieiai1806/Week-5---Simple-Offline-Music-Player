import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../services/playlist_service.dart';
import '../services/permission_service.dart';
import '../providers/audio_provider.dart';
import '../widgets/song_tile.dart';
import '../widgets/mini_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<SongModel> _songs = [];
  bool _isLoading = true;
  bool _hasPermission = true; 

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _loadSongs();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSongs() async {
    try {
      final List<SongModel> assetSongs = [
        SongModel(
          id: 'asset_1',
          title: 'Hearty',
          artist: 'Sample Artist',
          album: 'Asset Album',
          filePath: 'assets/audio/sample_songs/hearty.mp3',
          duration: const Duration(minutes: 3, seconds: 45),
        ),
        SongModel(
          id: 'asset_2',
          title: 'Dawn of Change',
          artist: 'Sample Artist',
          album: 'Asset Album',
          filePath: 'assets/audio/sample_songs/dawn_of_change.mp3',
          duration: const Duration(minutes: 4, seconds: 12),
        ),
        SongModel(
          id: 'asset_3',
          title: 'Slow Life',
          artist: 'Sample Artist',
          album: 'Asset Album',
          filePath: 'assets/audio/sample_songs/slow_life.mp3',
          duration: const Duration(minutes: 2, seconds: 58),
        ),
      ];

      setState(() {
        _songs = assetSongs;
      });
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191414),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: _buildMainContent(),
            ),
            _buildBottomPlayer(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1DB954)),
      );
    }
    
    if (_songs.isEmpty) {
      return _buildNoSongs();
    }
    
    return _buildSongList();
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'My Music',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSongList() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: _songs.length,
      itemBuilder: (context, index) {
        final song = _songs[index];
        return SongTile(
          song: song,
          onTap: () {
            context.read<AudioProvider>().setPlaylist(_songs, index);
          },
        );
      },
    );
  }

  Widget _buildBottomPlayer() {
    return Consumer<AudioProvider>(
      builder: (context, provider, child) {
        if (provider.currentSong == null) {
          return const SizedBox.shrink();
        }
        return const MiniPlayer();
      },
    );
  }

  Widget _buildNoSongs() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.music_note, size: 80, color: Colors.grey),
          SizedBox(height: 20),
          Text(
            'No Music Found',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ],
      ),
    );
  }
}