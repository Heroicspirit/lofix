import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:musicapp/app/theme/theme_provider.dart';
import 'package:musicapp/core/services/audio/music_player_provider.dart';
import 'package:musicapp/core/providers/offline_mode_provider.dart';
import 'package:musicapp/features/dashboard/domain/entities/music_entity.dart';
import 'package:musicapp/features/dashboard/presentation/pages/now_playing_screen.dart';
import 'package:musicapp/features/playlist/domain/entities/playlist_entity.dart';
import 'package:musicapp/features/playlist/presentation/view_model/playlist_viewmodel.dart';
import 'package:musicapp/features/dashboard/data/repositories/music_repository_impl.dart';
import 'package:musicapp/features/dashboard/data/datasources/remote/music_remote_datasource.dart';
import 'package:musicapp/core/api/api_client.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<MusicEntity> _searchResults = [];
  bool _isLoading = false;
  String _lastQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchSongs(String query) async {
    if (query.isEmpty || query == _lastQuery) return;
    
    // Check if offline mode restricts search
    final offlineModeState = ref.read(offlineModeProvider);
    if (!offlineModeState.canSearch) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot search in offline mode'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
      _lastQuery = query;
    });

    try {
      // Use existing songs endpoint and filter locally
      final apiClient = ref.read(apiClientProvider);
      final remoteDataSource = MusicRemoteDataSourceImpl(apiClient);
      final repository = MusicRepositoryImpl(remoteDataSource);
      
      // Get all songs first
      final allSongs = await repository.getTopPicks(); // Using getTopPicks which calls /songs
      
      // Filter songs locally based on search query
      final searchQuery = query.toLowerCase();
      final filteredResults = allSongs.where((song) {
        final titleMatch = song.title.toLowerCase().contains(searchQuery);
        final artistMatch = song.artist.toLowerCase().contains(searchQuery);
        final albumMatch = song.album?.toLowerCase().contains(searchQuery) ?? false;
        return titleMatch || artistMatch || albumMatch;
      }).toList();
      
      setState(() {
        _searchResults = filteredResults;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeData = ref.watch(themeProvider);
    final isDarkMode = themeData.brightness == Brightness.dark;
    final musicPlayerService = ref.read(musicPlayerServiceProvider);

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            decoration: InputDecoration(
              hintText: 'Search songs, artists, albums...',
              hintStyle: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
            onChanged: (value) {
              if (value.length >= 2) {
                _searchSongs(value);
              }
            },
            onSubmitted: (value) {
              _searchSongs(value);
            },
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            )
          : _searchResults.isEmpty && _lastQuery.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: isDarkMode ? Colors.white54 : Colors.black54,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No results found',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try different keywords',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white54 : Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : _searchResults.isNotEmpty
                  ? Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            '${_searchResults.length} results found',
                            style: TextStyle(
                              color: isDarkMode ? Colors.white70 : Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _searchResults.length,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemBuilder: (context, index) {
                              final song = _searchResults[index];
                              return _buildSearchResultItem(song, isDarkMode);
                            },
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.music_note,
                            size: 64,
                            color: isDarkMode ? Colors.white54 : Colors.black54,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Search for your favorite music',
                            style: TextStyle(
                              color: isDarkMode ? Colors.white70 : Colors.black54,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start typing to discover songs',
                            style: TextStyle(
                              color: isDarkMode ? Colors.white54 : Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildSearchResultItem(MusicEntity song, bool isDarkMode) {
    final offlineModeState = ref.read(offlineModeProvider);
    
    return GestureDetector(
      onTap: () {
        // Check if offline mode restricts playback
        if (!offlineModeState.canPlayMusic) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cannot play music in offline mode'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        // Update the song list in provider for next/previous functionality
        ref.read(songListProvider.notifier).state = _searchResults;
        
        // Navigate to now playing screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NowPlayingScreen(
              song: song,
              songList: _searchResults,
            ),
          ),
        );
        
        // Play the song
        final musicPlayerService = ref.read(musicPlayerServiceProvider);
        musicPlayerService.playSong(song);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            // Album cover
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: offlineModeState.canLoadImages
                  ? Image.network(
                      song.imageUrl,
                      height: 60,
                      width: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 60,
                          width: 60,
                          color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                          child: Icon(
                            Icons.music_note,
                            color: isDarkMode ? Colors.white54 : Colors.black54,
                            size: 30,
                          ),
                        );
                      },
                    )
                  : Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                      ),
                      child: Icon(
                        Icons.music_note,
                        color: isDarkMode ? Colors.white54 : Colors.black54,
                        size: 30,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            
            // Song info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song.artist ?? 'Unknown Artist',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (song.album != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      song.album!,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white54 : Colors.black87,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            
            // Play button
            IconButton(
              onPressed: () {
                // Update the song list in provider for next/previous functionality
                ref.read(songListProvider.notifier).state = _searchResults;
                
                // Play the song
                final musicPlayerService = ref.read(musicPlayerServiceProvider);
                musicPlayerService.playSong(song);
              },
              icon: Icon(
                Icons.play_circle_filled,
                color: isDarkMode ? Colors.white70 : Colors.black54,
                size: 32,
              ),
            ),
            
            // Add to playlist button
            IconButton(
              onPressed: () => _showAddToPlaylistDialog(song),
              icon: Icon(
                Icons.playlist_add,
                color: isDarkMode ? Colors.white70 : Colors.black54,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddToPlaylistDialog(MusicEntity song) {
    final themeData = ref.read(themeProvider);
    final isDarkMode = themeData.brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        title: Text(
          'Add to Playlist',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: FutureBuilder<List<PlaylistEntity>>(
            future: ref.read(userPlaylistsProvider.future),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading playlists',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                );
              }
              
              final playlists = snapshot.data ?? [];
              if (playlists.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.playlist_add,
                        size: 48,
                        color: isDarkMode ? Colors.white54 : Colors.black54,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No playlists yet',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create a playlist first',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white54 : Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                shrinkWrap: true,
                itemCount: playlists.length,
                itemBuilder: (context, index) {
                  final playlist = playlists[index];
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: playlist.coverImage != null
                          ? Image.network(
                              playlist.coverImage!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 40,
                                  height: 40,
                                  color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                                  child: Icon(
                                    Icons.playlist_play,
                                    color: isDarkMode ? Colors.white54 : Colors.black54,
                                    size: 20,
                                  ),
                                );
                              },
                            )
                          : Container(
                              width: 40,
                              height: 40,
                              color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                              child: Icon(
                                Icons.playlist_play,
                                color: isDarkMode ? Colors.white54 : Colors.black54,
                                size: 20,
                              ),
                            ),
                    ),
                    title: Text(
                      playlist.name,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      '${playlist.songs.length} songs',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(dialogContext);
                      try {
                        await ref.read(playlistViewModelProvider.notifier)
                            .addSongToPlaylist(playlist.id, song.id);
                        if (mounted) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(
                              content: Text('"${song.title}" added to "${playlist.name}"'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          // Refresh the playlist data to show updated songs list
                          ref.read(playlistViewModelProvider.notifier).loadPlaylists();
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(
                              content: Text('Failed to add song to playlist: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}