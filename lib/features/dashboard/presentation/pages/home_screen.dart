import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:musicapp/features/dashboard/presentation/widgets/section_header.dart';
import 'package:musicapp/features/dashboard/presentation/widgets/horizontal_music_list.dart';
import 'package:musicapp/features/dashboard/presentation/widgets/top_artists_list.dart';
import 'package:musicapp/features/dashboard/presentation/view_model/top_picks_viewmodel.dart';
import 'package:musicapp/features/dashboard/presentation/view_model/new_releases_viewmodel.dart';
import 'package:musicapp/core/providers/offline_mode_provider.dart';
import 'package:musicapp/features/dashboard/domain/entities/music_entity.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  // Mock top artists data - replace with real API call later
  final List<Artist> topArtists = const [
    Artist(
      id: '1',
      name: 'Jax Bloom',
      sub: 'Artist',
      imageUrl: 'http://192.168.1.67:5000/upload/images/singer%201.webp',
    ),
    Artist(
      id: '2',
      name: 'Sonu Nigam',
      sub: 'Artist',
      imageUrl: 'http://192.168.1.67:5000/upload/images/singer2.webp',
    ),
    Artist(
      id: '3',
      name: 'The Weeknd',
      sub: 'Artist',
      imageUrl: 'http://192.168.1.67:5000/upload/images/singer%201.webp',
    ),
    Artist(
      id: '4',
      name: 'Lofi Girl',
      sub: 'Artist',
      imageUrl: 'http://192.168.1.67:5000/upload/images/singer2.webp',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topPicksAsync = ref.watch(topPicksProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          "Home",
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        leading: Icon(Icons.music_note, color: Theme.of(context).iconTheme.color),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Theme.of(context).iconTheme.color),
            onPressed: () {
              ref.read(topPicksProvider.notifier).loadTopPicks();
              ref.read(newReleasesProvider.notifier).loadNewReleases();
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // Quick Actions Section
            SectionHeader(
              title: "Quick Actions",
              subtitle: "Jump to your favorites",
              onSeeAll: () {
                
              },
            ),
            _buildMusicList(topPicksAsync, ref),

            const SizedBox(height: 32),

            // Top Artists Section
            SectionHeader(
              title: "Top Artists",
              subtitle: "Your favorite creators",
              onSeeAll: () {
                
              },
            ),
            TopArtistsList(artists: topArtists),

            const SizedBox(height: 32),

            // Trending Now Section
            SectionHeader(
              title: "Trending Now",
              subtitle: "Most played this week",
              onSeeAll: () {
                
              },
            ),
            _buildMusicList(topPicksAsync, ref), // Reuse for now, replace with trending data later
          ],
        ),
      ),
    );
  }

  Widget _buildMusicList(AsyncValue<List> musicAsync, WidgetRef ref) {
    final offlineModeState = ref.read(offlineModeProvider);
    
    return musicAsync.when(
      data: (musicList) {
        if (musicList.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'No music available',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }
        return HorizontalMusicList(data: musicList.cast<MusicEntity>());
      },
      loading: () => const SizedBox(
        height: 210,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) {
        // In offline mode, show cached content instead of error
        if (offlineModeState.hasLimitedAccess) {
          // Try to get cached data from Hive
          return const SizedBox(
            height: 210,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.music_note, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'No internet connection',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }
        
        // Show error for online mode
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(Icons.error_outline, color: Colors.red[400], size: 48),
              const SizedBox(height: 8),
              Text(
                'Failed to load music',
                style: TextStyle(color: Colors.red[400]),
              ),
              const SizedBox(height: 4),
              Text(
                error.toString(),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
