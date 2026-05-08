import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/playlist_model.dart';
import '../services/storage_service.dart';

class PlaylistProvider extends ChangeNotifier {
  final StorageService _storageService;
  List<PlaylistModel> _playlists = [];

  PlaylistProvider(this._storageService) {
    _loadPlaylists();
  }

  List<PlaylistModel> get playlists => _playlists;

  Future<void> _loadPlaylists() async {
    _playlists = await _storageService.getPlaylists();
    notifyListeners();
  }

  Future<void> createPlaylist(String name) async {
    final newPlaylist = PlaylistModel(
      id: const Uuid().v4(),
      name: name,
      songIds: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _playlists.add(newPlaylist);
    await _storageService.savePlaylists(_playlists);
    notifyListeners();
  }

  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      if (!_playlists[index].songIds.contains(songId)) {
        final updatedSongIds = List<String>.from(_playlists[index].songIds)..add(songId);
        _playlists[index] = _playlists[index].copyWith(songIds: updatedSongIds);
        await _storageService.savePlaylists(_playlists);
        notifyListeners();
      }
    }
  }

  Future<void> deletePlaylist(String id) async {
    _playlists.removeWhere((p) => p.id == id);
    await _storageService.savePlaylists(_playlists);
    notifyListeners();
  }
}