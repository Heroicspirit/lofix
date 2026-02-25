import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:musicapp/app/theme/theme_provider.dart';
import 'package:musicapp/features/playlist/domain/entities/playlist_entity.dart';
import 'package:musicapp/features/dashboard/domain/entities/music_entity.dart';
import 'package:musicapp/features/dashboard/presentation/pages/now_playing_screen.dart';
import 'package:musicapp/core/services/audio/music_player_provider.dart';
import 'package:musicapp/features/playlist/presentation/providers/playlist_provider.dart';

class PlaylistDetailScreen extends ConsumerStatefulWidget {
  final PlaylistEntity playlist;

  const PlaylistDetailScreen({
    super.key,
    required this.playlist,
  });

  @override
  ConsumerState<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends ConsumerState<PlaylistDetailScreen> {
  late bool isDarkMode;
  late PlaylistEntity _currentPlaylist;

  @override
  void initState() {
    super.initState();
    _currentPlaylist = widget.playlist;
  }

  Future<void> _refreshPlaylist() async {
    try {
      print('DEBUG: Refreshing playlist...');
      
      // Force refresh the playlists
      await ref.read(playlistNotifierProvider.notifier).loadPlaylists();
      
      // Get the updated playlists from the notifier state
      final playlists = ref.read(playlistNotifierProvider);
      print('DEBUG: Found ${playlists.length} playlists');
      
      final updatedPlaylist = playlists.firstWhere(
        (p) => p.id == _currentPlaylist.id,
        orElse: () => _currentPlaylist,
      );
      
      print('DEBUG: Updated playlist has ${updatedPlaylist.songs.length} songs');
      print('DEBUG: Current playlist has ${_currentPlaylist.songs.length} songs');
      
      if (mounted) {
        setState(() {
          _currentPlaylist = updatedPlaylist;
        });
        print('DEBUG: State updated with new playlist data');
      }
    } catch (e) {
      print('Error refreshing playlist: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeData = ref.watch(themeProvider);
    isDarkMode = themeData.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: CustomScrollView(
        slivers: [
          // Header with _currentPlaylist info
          SliverAppBar(
            backgroundColor: isDarkMode ? Colors.black : Colors.white,
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background image or gradient
                  if (_currentPlaylist.coverImage != null)
                    Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(_currentPlaylist.coverImage!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDarkMode
                              ? [Colors.purple, Colors.blue]
                              : [Colors.blue.shade300, Colors.purple.shade300],
                        ),
                      ),
                    ),
                  
                  // Dark overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  
                  // Playlist info
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentPlaylist.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_currentPlaylist.songs.length} songs',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                offset: const Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        if (_currentPlaylist.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _currentPlaylist.description!,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  offset: const Offset(0, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                onSelected: (value) {
                  _handlePlaylistAction(value);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'play_all',
                    child: Row(
                      children: [
                        Icon(Icons.play_arrow, size: 16),
                        SizedBox(width: 8),
                        Text('Play All'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'shuffle',
                    child: Row(
                      children: [
                        Icon(Icons.shuffle, size: 16),
                        SizedBox(width: 8),
                        Text('Shuffle'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 16),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Songs list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final song = _currentPlaylist.songs[index];
                return _buildSongItem(song, isDarkMode, index);
              },
              childCount: _currentPlaylist.songs.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongItem(MusicEntity song, bool isDarkMode, int index) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          song.imageUrl,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 56,
              height: 56,
              color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
              child: Icon(
                Icons.music_note,
                color: isDarkMode ? Colors.white54 : Colors.black54,
                size: 28,
              ),
            );
          },
        ),
      ),
      title: Text(
        song.title,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        song.artist,
        style: TextStyle(
          color: isDarkMode ? Colors.white70 : Colors.black54,
          fontSize: 14,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Remove from _currentPlaylist button
          IconButton(
            icon: Icon(
              Icons.remove_circle_outline,
              color: isDarkMode ? Colors.white54 : Colors.black54,
            ),
            onPressed: () => _removeSongFromPlaylist(song),
          ),
          // Play button
          IconButton(
            icon: Icon(
              Icons.play_circle_filled,
              color: isDarkMode ? Colors.white70 : Colors.black54,
              size: 32,
            ),
            onPressed: () => _playSong(song),
          ),
        ],
      ),
      onTap: () => _playSong(song),
    );
  }

  void _playSong(MusicEntity song) {
    // Update the song list in provider for next/previous functionality
    ref.read(songListProvider.notifier).state = _currentPlaylist.songs;
    
    // Play the song
    final musicPlayerService = ref.read(musicPlayerServiceProvider);
    musicPlayerService.playSong(song);
    
    // Navigate to now playing screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NowPlayingScreen(
          song: song,
          songList: _currentPlaylist.songs,
        ),
      ),
    );
  }

  void _removeSongFromPlaylist(MusicEntity song) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        title: Text(
          'Remove Song',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        content: Text(
          'Are you sure you want to remove "${song.title}" from "${_currentPlaylist.name}"?',
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(playlistNotifierProvider.notifier)
                    .removeSongFromPlaylist(_currentPlaylist.id, song.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('"${song.title}" removed from playlist'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Wait a moment for backend to update, then refresh
                  await Future.delayed(const Duration(milliseconds: 500));
                  await _refreshPlaylist();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to remove song: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _handlePlaylistAction(String action) {
    switch (action) {
      case 'play_all':
        if (_currentPlaylist.songs.isNotEmpty) {
          _playSong(_currentPlaylist.songs.first);
        }
        break;
      case 'shuffle':
        if (_currentPlaylist.songs.isNotEmpty) {
          final shuffledSongs = List<MusicEntity>.from(_currentPlaylist.songs);
          shuffledSongs.shuffle();
          _playSong(shuffledSongs.first);
        }
        break;
      case 'edit':
        // TODO: Navigate to edit _currentPlaylist
        break;
      case 'delete':
        _showDeletePlaylistDialog();
        break;
    }
  }

  void _showDeletePlaylistDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        title: Text(
          'Delete Playlist',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${_currentPlaylist.name}"? This action cannot be undone.',
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(playlistNotifierProvider.notifier).deletePlaylist(_currentPlaylist.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Playlist "${_currentPlaylist.name}" deleted'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context); // Go back to library
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete playlist: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
