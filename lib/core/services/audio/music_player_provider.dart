import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:musicapp/features/dashboard/domain/entities/music_entity.dart';
import 'music_player_service.dart';

// Audio player provider
final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  return AudioPlayer();
});

// Current song provider
final currentSongProvider = StateProvider<MusicEntity?>((ref) => null);

// Playing state provider
final isPlayingProvider = StateProvider<bool>((ref) => false);

// Song list provider
final songListProvider = StateProvider<List<MusicEntity>>((ref) => []);

// Music player service provider
final musicPlayerServiceProvider = Provider<MusicPlayerService>((ref) {
  final audioPlayer = ref.read(audioPlayerProvider);
  final currentSongController = ref.read(currentSongProvider.notifier);
  final isPlayingController = ref.read(isPlayingProvider.notifier);
  final songList = ref.watch(songListProvider);
  
  return MusicPlayerService(
    audioPlayer: audioPlayer,
    currentSongController: currentSongController,
    isPlayingController: isPlayingController,
    songList: songList,
  );
});