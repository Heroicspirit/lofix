import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:musicapp/features/dashboard/domain/entities/music_entity.dart';

// Music player service
class MusicPlayerService {
  final AudioPlayer _audioPlayer;
  final StateController<MusicEntity?> _currentSongController;
  final StateController<bool> _isPlayingController;
  final List<MusicEntity> _songList;
  bool _isInitialized = false;

  MusicPlayerService({
    required AudioPlayer audioPlayer,
    required StateController<MusicEntity?> currentSongController,
    required StateController<bool> isPlayingController,
    required List<MusicEntity> songList,
  })  : _audioPlayer = audioPlayer,
        _currentSongController = currentSongController,
        _isPlayingController = isPlayingController,
        _songList = songList;

  Future<void> _initializeAudio() async {
    if (_isInitialized) return;
    
    try {
      // Use simple audio context without custom settings
      await _audioPlayer.setAudioContext(
        const AudioContext(
          android: AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: true,
          ),
        ),
      );
      _isInitialized = true;
      print('Audio context initialized successfully');
    } catch (e) {
      print('Error initializing audio context: $e');
    }
  }

  Future<void> playSong(MusicEntity song) async {
    // Validate audio URL
    final url = song.audioUrl ?? '';
    if (url.isEmpty) {
      print('No audio URL for song: ${song.title}');
      _isPlayingController.state = false;
      return;
    }

    // Debug URL construction
    print('DEBUG: Audio URL from song entity: "$url"');
    print('DEBUG: URL starts with http: ${url.startsWith('http')}');
    print('DEBUG: URL length: ${url.length}');

    try {
      // Check if it's the same song
      final currentSong = _currentSongController.state;
      final isSameSong = currentSong?.id == song.id;
      
      // Set current song
      _currentSongController.state = song;

      if (isSameSong && _isPlayingController.state) {
        // Same song is already playing, do nothing
        print('Song already playing: ${song.title}');
        return;
      } else if (isSameSong && !_isPlayingController.state) {
        // Same song but paused, resume playback
        print('Resuming playback: ${song.title}');
        await _audioPlayer.resume();
        _isPlayingController.state = true;
        return;
      } else {
        // Different song, stop current and start new
        print('Switching to new song: ${song.title}');
        await _audioPlayer.stop();
        
        // Configure player for streaming
        await _audioPlayer.setVolume(1.0);
        await _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);
        
        print('Attempting to play: ${song.title} - $url');
        
        // Play the audio
        await _audioPlayer.play(UrlSource(url));

        // Update playing state
        _isPlayingController.state = true;
        
        print('Successfully started playing: ${song.title}');
      }
    } catch (e) {
      print('Error playing song: $e');
      print('URL: $url');
      print('This might be a format, network, or timeout issue');
      
      // Try fallback with different player mode if format error
      if (e.toString().contains('MEDIA_ERROR_SYSTEM') || e.toString().contains('format')) {
        print('Trying fallback player mode...');
        try {
          await _audioPlayer.setPlayerMode(PlayerMode.lowLatency);
          await _audioPlayer.play(UrlSource(url));
          print('Fallback playback started');
        } catch (fallbackError) {
          print('Fallback also failed: $fallbackError');
        }
      }
      
      _isPlayingController.state = false;
    }
  }

  // Test method with known working URL
  Future<void> testAudio() async {
    try {
      await _initializeAudio();
      await _audioPlayer.stop();
      await _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      
      // Test with known working MP3
      await _audioPlayer.play(UrlSource('https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'));
      print('Test audio playing - should hear sound');
    } catch (e) {
      print('Test audio error: $e');
    }
  }

  // Test with your backend URL
  Future<void> testBackendAudio() async {
    try {
      await _initializeAudio();
      await _audioPlayer.stop();
      await _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      
      // Test with your exact backend URL
      await _audioPlayer.play(UrlSource('http://192.168.1.67:5000/upload/songs/Dhun_Song___Arijit_Singh-90cf6818-4d1f-4713-a942-e16715c7419e-1771688206312.mp3'));
      print('Backend test audio playing');
    } catch (e) {
      print('Backend test audio error: $e');
    }
  }

  Future<void> pauseSong() async {
    try {
      await _audioPlayer.pause();
      _isPlayingController.state = false;
      print('Song paused');
    } catch (e) {
      print('Error pausing song: $e');
    }
  }

  Future<void> resumeSong() async {
    try {
      await _audioPlayer.resume();
      _isPlayingController.state = true;
      print('Song resumed');
    } catch (e) {
      print('Error resuming song: $e');
    }
  }

  Future<void> stopSong() async {
    try {
      await _audioPlayer.stop();
      _isPlayingController.state = false;
      _currentSongController.state = null;
      print('Song stopped');
    } catch (e) {
      print('Error stopping song: $e');
    }
  }

  Future<void> nextSong() async {
    if (_songList.isEmpty) return;
    
    // Find current song index in the playlist
    final currentSongIndex = _songList.indexWhere((song) => song.id == _currentSongController.state?.id);
    if (currentSongIndex == -1) return; // Current song not found in playlist
    
    final nextIndex = (currentSongIndex + 1) % _songList.length;
    final nextSong = _songList[nextIndex];
    
    await playSong(nextSong);
    print('Playing next song: ${nextSong.title} (index: $nextIndex)');
  }

  Future<void> previousSong() async {
    if (_songList.isEmpty) return;
    
    // Find current song index in the playlist
    final currentSongIndex = _songList.indexWhere((song) => song.id == _currentSongController.state?.id);
    if (currentSongIndex == -1) return; // Current song not found in playlist
    
    final previousIndex = (currentSongIndex - 1 + _songList.length) % _songList.length;
    final previousSong = _songList[previousIndex];
    
    await playSong(previousSong);
    print('Playing previous song: ${previousSong.title} (index: $previousIndex)');
  }

  Future<void> togglePlayPause() async {
    final isPlaying = _isPlayingController.state;
    if (isPlaying) {
      await pauseSong();
    } else {
      await resumeSong();
    }
  }

  // Listen to player state changes
  void initializePlayerListeners() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.playing) {
        _isPlayingController.state = true;
      } else if (state == PlayerState.paused || state == PlayerState.completed) {
        _isPlayingController.state = false;
      }
    });
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
