import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
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
  List<SongModel> _filteredSongs = [];
  bool _isLoading = true;
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _playlistNameController = TextEditingController();

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
          artist: 'Bensound',
          album: 'Bensound Music',
          filePath: 'assets/audio/sample_songs/bensound-hearty.mp3',
          duration: const Duration(minutes: 3, seconds: 45),
        ),
        SongModel(
          id: 'asset_2',
          title: 'Dawn of Change',
          artist: 'Bensound',
          album: 'Bensound Music',
          filePath: 'assets/audio/sample_songs/bensound-dawnofchange.mp3',
          duration: const Duration(minutes: 4, seconds: 12),
        ),
        SongModel(
          id: 'asset_3',
          title: 'Slow Life',
          artist: 'Bensound',
          album: 'Bensound Music',
          filePath: 'assets/audio/sample_songs/bensound-slowlife.mp3',
          duration: const Duration(minutes: 2, seconds: 58),
        ),
      ];

      if (mounted) {
        setState(() {
          _songs = assetSongs;
          _filteredSongs = assetSongs;
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _filterSongs(String query) {
    setState(() {
      _filteredSongs = _songs
          .where((song) =>
              song.title.toLowerCase().contains(query.toLowerCase()) ||
              song.artist.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _showFeatureComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        backgroundColor: const Color(0xFF282828),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showCreatePlaylistDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF282828),
        title: const Text('New Playlist', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _playlistNameController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Playlist name',
            hintStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF1DB954))),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _playlistNameController.clear();
              Navigator.pop(context);
            },
            child: const Text('CANCEL', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              if (_playlistNameController.text.isNotEmpty) {
                context.read<AudioProvider>().createPlaylist(_playlistNameController.text);
                String name = _playlistNameController.text;
                _playlistNameController.clear();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Playlist "$name" created!')),
                );
              }
            },
            child: const Text('CREATE', style: TextStyle(color: Color(0xFF1DB954), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191414),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF2E2E2E), Color(0xFF191414)],
                stops: [0.0, 0.3],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                if (_selectedIndex == 0) _buildAppBar(),
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: [
                      _buildMainContent(),
                      _buildSearchPage(),
                      _buildLibraryPage(),
                    ],
                  ),
                ),
                _buildBottomPlayer(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      backgroundColor: Colors.black,
      selectedItemColor: const Color(0xFF1DB954),
      unselectedItemColor: Colors.white54,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(icon: Icon(Icons.library_music), label: 'Library'),
      ],
    );
  }

  Widget _buildMainContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF1DB954)));
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Text(
              'Recommended for today',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          _buildSongList(_songs),
        ],
      ),
    );
  }

  Widget _buildSearchPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Search', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            onChanged: _filterSongs,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: "Artists, songs, or podcasts",
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Colors.black),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
            ),
          ),
        ),
        Expanded(
          child: _filteredSongs.isEmpty
              ? const Center(child: Text('No results found', style: TextStyle(color: Colors.white54)))
              : _buildSongList(_filteredSongs),
        ),
      ],
    );
  }

  Widget _buildLibraryPage() {
    return Consumer<AudioProvider>(
      builder: (context, provider, child) {
        // Lấy danh sách bài hát yêu thích thực tế
        final likedSongs = _songs.where((s) => provider.isFavorite(s.id)).toList();
        final customPlaylists = provider.customPlaylists;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Your Library', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            // Mục Liked Songs
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Colors.deepPurple, Colors.blueAccent]),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.favorite, color: Colors.white),
              ),
              title: const Text('Liked Songs', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text('Playlist • ${likedSongs.length} songs', style: const TextStyle(color: Colors.white54)),
              onTap: () {
                if (likedSongs.isNotEmpty) {
                  _showSongsSheet('Liked Songs', likedSongs, provider);
                } else {
                  _showFeatureComingSoon('Add some songs to favorites first!');
                }
              },
            ),
            
            // Danh sách Playlist tự tạo
            ...customPlaylists.map((playlist) {
              // Lọc ra các bài hát thuộc về playlist này
              final playlistSongs = _songs.where((s) => playlist.songIds.contains(s.id)).toList();
              
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.music_note, color: Colors.white54),
                ),
                title: Text(playlist.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text('Playlist • ${playlistSongs.length} songs', style: const TextStyle(color: Colors.white54)),
                onTap: () {
                  if (playlistSongs.isNotEmpty) {
                    _showSongsSheet(playlist.name, playlistSongs, provider);
                  } else {
                    _showFeatureComingSoon('This playlist is empty. Add some songs!');
                  }
                },
              );
            }),
            
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 56, height: 56,
                color: Colors.grey[900],
                child: const Icon(Icons.add, color: Colors.white54, size: 32),
              ),
              title: const Text('Add New Playlist', style: TextStyle(color: Colors.white)),
              onTap: _showCreatePlaylistDialog,
            ),
          ],
        );
      },
    );
  }

  void _showSongsSheet(String title, List<SongModel> songs, AudioProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF191414),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: songs.length,
                itemBuilder: (context, index) => SongTile(
                  song: songs[index],
                  onTap: () {
                    provider.setPlaylist(songs, index);
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Text('Good afternoon', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () => _showFeatureComingSoon('History'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () => _showFeatureComingSoon('Settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildSongList(List<SongModel> list) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final song = list[index];
        return SongTile(
          song: song,
          onTap: () => context.read<AudioProvider>().setPlaylist(list, index),
        );
      },
    );
  }

  Widget _buildBottomPlayer() {
    return Consumer<AudioProvider>(
      builder: (context, provider, child) {
        return provider.currentSong == null ? const SizedBox.shrink() : const MiniPlayer();
      },
    );
  }

  Widget _buildNoSongs() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.music_note, size: 80, color: Colors.grey),
          SizedBox(height: 20),
          Text('No Music Found', style: TextStyle(color: Colors.white, fontSize: 20)),
        ],
      ),
    );
  }
}