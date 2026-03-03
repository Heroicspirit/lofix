import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:musicapp/core/services/connectivity/network_info.dart';
import 'package:musicapp/core/services/hive/hive_service.dart';
import 'package:musicapp/core/providers/offline_mode_provider.dart';
import 'package:musicapp/features/playlist/data/models/playlist_hive_model.dart';
import 'package:musicapp/features/music/data/models/song_hive_model.dart';
import 'package:musicapp/features/playlist/domain/entities/playlist_entity.dart';
import 'package:musicapp/features/dashboard/domain/entities/music_entity.dart';

// Local Data Source with fallback to Hive when API fails
class PlaylistLocalDataSource {
  final HiveService _hiveService;
  final INetworkInfo _networkInfo;
  final Ref _ref;

  PlaylistLocalDataSource({
    required HiveService hiveService,
    required INetworkInfo networkInfo,
    required Ref ref,
  }) : _hiveService = hiveService,
       _networkInfo = networkInfo,
       _ref = ref;

  /// Get playlists with API fallback to local storage
  Future<Either<String, List<PlaylistEntity>>> getPlaylists({
    Future<Either<String, List<PlaylistEntity>>>? remoteCall,
  }) async {
    // If online and remote call provided, try API first
    final hasNetwork = await _networkInfo.isConnected;
    
    if (hasNetwork && remoteCall != null) {
      try {
        final result = await remoteCall;
        return result.fold(
          (failure) {
            print('API failed: $failure, falling back to local storage');
            return _getLocalPlaylists();
          },
          (playlists) async {
            // Save to local storage for offline use
            await _savePlaylistsToLocal(playlists);
            return Right(playlists);
          },
        );
      } catch (e) {
        print('API error: $e, falling back to local storage');
        return _getLocalPlaylists();
      }
    } else {
      // Offline or no remote call - use local storage
      print('Using local storage for playlists');
      return _getLocalPlaylists();
    }
  }

  /// Get playlists from local Hive storage
  Future<Either<String, List<PlaylistEntity>>> _getLocalPlaylists() async {
    try {
      final hivePlaylists = await _hiveService.getPlaylists();
      final playlists = hivePlaylists.map(_hiveToEntity).toList();
      return Right(playlists);
    } catch (e) {
      print('Error getting local playlists: $e');
      return Left('Failed to load local playlists: $e');
    }
  }

  /// Save playlists to local Hive storage
  Future<void> _savePlaylistsToLocal(List<PlaylistEntity> playlists) async {
    try {
      final hivePlaylists = playlists.map(_entityToHive).toList();
      await _hiveService.savePlaylists(hivePlaylists);
    } catch (e) {
      print('Error saving playlists to local: $e');
    }
  }

  /// Create playlist (only works online)
  Future<Either<String, PlaylistEntity>> createPlaylist({
    required String name,
    String? coverImage,
    Future<Either<String, PlaylistEntity>>? remoteCall,
  }) async {
    final offlineModeState = _ref.read(offlineModeProvider);
    final hasNetwork = await _networkInfo.isConnected;
    
    if (!hasNetwork || !offlineModeState.canCreatePlaylists) {
      return Left('Cannot create playlists in offline mode');
    }

    if (remoteCall != null) {
      try {
        final result = await remoteCall;
        return result.fold(
          (failure) => Left(failure),
          (playlist) async {
            // Save to local storage
            await _savePlaylistToLocal(playlist);
            return Right(playlist);
          },
        );
      } catch (e) {
        return Left('Failed to create playlist: $e');
      }
    }
    
    return Left('No remote call provided for creating playlist');
  }

  /// Delete playlist (only works online)
  Future<Either<String, void>> deletePlaylist({
    required String playlistId,
    Future<Either<String, void>>? remoteCall,
  }) async {
    final hasNetwork = await _networkInfo.isConnected;
    final offlineModeState = _ref.read(offlineModeProvider);
    
    if (!hasNetwork || !offlineModeState.canDeletePlaylists) {
      return Left('Cannot delete playlists in offline mode');
    }

    if (remoteCall != null) {
      try {
        final result = await remoteCall;
        return result.fold(
          (failure) => Left(failure),
          (_) async {
            // Remove from local storage
            await _hiveService.deletePlaylist(playlistId);
            return Right(null);
          },
        );
      } catch (e) {
        return Left('Failed to delete playlist: $e');
      }
    }
    
    return Left('No remote call provided for deleting playlist');
  }

  /// Add song to playlist (only works online)
  Future<Either<String, void>> addSongToPlaylist({
    required String playlistId,
    required String songId,
    Future<Either<String, void>>? remoteCall,
  }) async {
    final hasNetwork = await _networkInfo.isConnected;
    final offlineModeState = _ref.read(offlineModeProvider);
    
    if (!hasNetwork || !offlineModeState.canAddRemoveSongs) {
      return Left('Cannot add songs to playlists in offline mode');
    }

    if (remoteCall != null) {
      try {
        final result = await remoteCall;
        return result.fold(
          (failure) => Left(failure),
          (_) async {
            // Add to local storage
            await _hiveService.addSongToPlaylist(playlistId, songId);
            return Right(null);
          },
        );
      } catch (e) {
        return Left('Failed to add song to playlist: $e');
      }
    }
    
    return Left('No remote call provided for adding song to playlist');
  }

  /// Remove song from playlist (only works online)
  Future<Either<String, void>> removeSongFromPlaylist({
    required String playlistId,
    required String songId,
    Future<Either<String, void>>? remoteCall,
  }) async {
    final hasNetwork = await _networkInfo.isConnected;
    final offlineModeState = _ref.read(offlineModeProvider);
    
    if (!hasNetwork || !offlineModeState.canAddRemoveSongs) {
      return Left('Cannot remove songs from playlists in offline mode');
    }

    if (remoteCall != null) {
      try {
        final result = await remoteCall;
        return result.fold(
          (failure) => Left(failure),
          (_) async {
            // Remove from local storage
            await _hiveService.removeSongFromPlaylist(playlistId, songId);
            return Right(null);
          },
        );
      } catch (e) {
        return Left('Failed to remove song from playlist: $e');
      }
    }
    
    return Left('No remote call provided for removing song from playlist');
  }

  /// Convert Hive model to Entity
  PlaylistEntity _hiveToEntity(PlaylistHiveModel hiveModel) {
    return PlaylistEntity(
      id: hiveModel.id,
      name: hiveModel.name,
      coverImage: hiveModel.coverImage,
      songs: [], // Songs loaded separately
      createdAt: hiveModel.createdAt,
      updatedAt: hiveModel.updatedAt,
    );
  }

  /// Convert Entity to Hive model
  PlaylistHiveModel _entityToHive(PlaylistEntity entity) {
    return PlaylistHiveModel(
      id: entity.id,
      name: entity.name,
      coverImage: entity.coverImage,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      songIds: entity.songs.map((song) => song.id).toList(),
    );
  }

  /// Save single playlist to local storage
  Future<void> _savePlaylistToLocal(PlaylistEntity playlist) async {
    try {
      final hivePlaylist = _entityToHive(playlist);
      await _hiveService.savePlaylist(hivePlaylist);
    } catch (e) {
      print('Error saving playlist to local: $e');
    }
  }
}
