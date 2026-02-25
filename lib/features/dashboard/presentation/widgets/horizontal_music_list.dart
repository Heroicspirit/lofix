import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/music_entity.dart';
import 'package:musicapp/core/services/audio/music_player_provider.dart';
import '../pages/now_playing_screen.dart';

class HorizontalMusicList extends ConsumerWidget {
  final List<MusicEntity> data;

  const HorizontalMusicList({super.key, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSong = ref.watch(currentSongProvider);
    final isPlaying = ref.watch(isPlayingProvider);

    return SizedBox(
      height: 210,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        itemCount: data.length,
        itemBuilder: (context, index) {
          final song = data[index];
          final isCurrentSong = currentSong?.id == song.id;
          
          return GestureDetector(
            onTap: () {
              // Update the song list in provider for next/previous functionality
              ref.read(songListProvider.notifier).state = data;
              
              // Navigate to now playing screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NowPlayingScreen(
                    song: song,
                    songList: data, // Pass the song list
                  ),
                ),
              );
              
              // Play the song
              final musicPlayerService = ref.read(musicPlayerServiceProvider);
              musicPlayerService.playSong(song);
            },
            child: Container(
              width: 150,
              margin: const EdgeInsets.only(right: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: song.imageUrl,
                          height: 130,
                          width: 150,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 130,
                            width: 150,
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 130,
                            width: 150,
                            color: Colors.grey[300],
                            child: const Icon(Icons.music_note, size: 40),
                          ),
                        ),
                      ),
                      // Play/Pause overlay
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 0,
                          child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.black.withOpacity(0.3),
                          ),
                          child: Center(
                            child: Icon(
                              isCurrentSong && isPlaying 
                                ? Icons.pause_circle_filled 
                                : Icons.play_circle_filled,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    song.artist,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
