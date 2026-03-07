import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:musicapp/app/theme/theme_provider.dart';
import 'package:musicapp/core/services/audio/music_player_provider.dart';
import 'package:musicapp/core/services/audio/music_player_service.dart';
import 'package:musicapp/core/providers/offline_mode_provider.dart';
import 'package:musicapp/features/dashboard/domain/entities/music_entity.dart';
import 'package:musicapp/features/dashboard/presentation/view_model/favorites_viewmodel.dart';

class NowPlayingScreen extends ConsumerWidget {
  final MusicEntity song;
  final List<MusicEntity> songList;

  const NowPlayingScreen({
    super.key,
    required this.song,
    required this.songList,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSong = ref.watch(currentSongProvider);
    final isPlaying = ref.watch(isPlayingProvider);
    final musicPlayerService = ref.watch(musicPlayerServiceProvider);
    final themeData = ref.watch(themeProvider);
    final isDarkMode = themeData.brightness == Brightness.dark;
    final offlineModeState = ref.watch(offlineModeProvider);

    // Use a primary color for the glow effect (ideally extracted from the image)
    const accentColor = Colors.blueAccent; 

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, size: 30), // Down arrow feels more "Music App"
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {},
          )
        ],
      ),
      body: Stack(
        children: [
          // 1. Background Blur/Gradient
          _buildBackground(currentSong?.imageUrl ?? song.imageUrl, isDarkMode),

          // 2. Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const Spacer(),
                  
                  // 3. Immersive Album Art
                  _buildAlbumArt(currentSong?.imageUrl ?? song.imageUrl, isPlaying, offlineModeState),
                  
                  const Spacer(),

                  // 4. Song Info
                  _buildSongInfo(currentSong ?? song, isDarkMode, ref),

                  const SizedBox(height: 30),

                  // 5. Interactive Progress Bar
                  _buildProgressBar(currentSong ?? song, isDarkMode, accentColor),

                  const SizedBox(height: 40),

                  // 6. Refined Controls
                  _buildControls(context, musicPlayerService, isPlaying, isDarkMode, accentColor, offlineModeState),
                  
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(String imageUrl, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.black.withOpacity(0.6) : Colors.white.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildAlbumArt(String imageUrl, bool isPlaying, dynamic offlineModeState) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      padding: EdgeInsets.all(isPlaying ? 0 : 20), // Art shrinks slightly when paused
      child: Container(
        height: 320,
        width: 320,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: offlineModeState.canLoadImages
              ? Image.network(imageUrl, fit: BoxFit.cover)
              : Container(
                  height: 320,
                  width: 320,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: Colors.grey[300],
                  ),
                  child: const Icon(Icons.music_note, size: 80, color: Colors.white),
                ),
        ),
      ),
    );
  }

  Widget _buildSongInfo(MusicEntity song, bool isDarkMode, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                song.title,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                  letterSpacing: -0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                song.artist ?? 'Unknown Artist',
                style: TextStyle(
                  fontSize: 18,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            final isFavorite = ref.read(favoritesProvider.notifier).isFavorite(song.id);
            if (isFavorite) {
              ref.read(favoritesProvider.notifier).removeFromFavorites(song.id);
            } else {
              ref.read(favoritesProvider.notifier).addToFavorites(song.id!);
            }
          },
          icon: Consumer(
            builder: (context, ref, child) {
              final isFavorite = ref.watch(favoritesProvider).maybeWhen(
                data: (favorites) => favorites.any((s) => s.id == song.id!),
                orElse: () => false,
              );
              return Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : (isDarkMode ? Colors.white70 : Colors.black54),
              );
            },
          ),
        )
      ],
    );
  }

  Widget _buildProgressBar(MusicEntity song, bool isDarkMode, Color accent) {
    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            activeTrackColor: accent,
            inactiveTrackColor: isDarkMode ? Colors.white24 : Colors.black12,
            overlayColor: accent.withOpacity(0.2),
          ),
          child: Slider(
            value: 0.3, 
            onChanged: (value) {},
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("1:20", style: TextStyle(color: isDarkMode ? Colors.white60 : Colors.black45, fontSize: 12)),
              Text(
                song.duration != null ? '${song.duration! ~/ 60}:${(song.duration! % 60).toString().padLeft(2, '0')}' : '0:00',
                style: TextStyle(color: isDarkMode ? Colors.white60 : Colors.black45, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControls(BuildContext context, MusicPlayerService service, bool isPlaying, bool isDarkMode, Color accent, dynamic offlineModeState) {
    final btnColor = isDarkMode ? Colors.white : Colors.black;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: const Icon(Icons.shuffle),
          onPressed: () {},
          color: btnColor.withOpacity(0.5),
        ),
        IconButton(
          iconSize: 48,
          icon: const Icon(Icons.skip_previous_rounded),
          onPressed: offlineModeState.canPlayMusic ? () => service.previousSong() : null,
          color: offlineModeState.canPlayMusic ? btnColor : btnColor.withOpacity(0.3),
        ),
        GestureDetector(
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
            
            isPlaying ? service.pauseSong() : service.resumeSong();
          },
          child: Container(
            height: 75,
            width: 75,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: btnColor,
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ]
            ),
            child: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: isDarkMode ? Colors.black : Colors.white,
              size: 45,
            ),
          ),
        ),
        IconButton(
          iconSize: 48,
          icon: const Icon(Icons.skip_next_rounded),
          onPressed: offlineModeState.canPlayMusic ? () => service.nextSong() : null,
          color: offlineModeState.canPlayMusic ? btnColor : btnColor.withOpacity(0.3),
        ),
        IconButton(
          icon: const Icon(Icons.repeat),
          onPressed: () {},
          color: btnColor.withOpacity(0.5),
        ),
      ],
    );
  }
}