import 'package:musicapp/features/dashboard/domain/entities/music_entity.dart';
import 'package:musicapp/features/playlist/domain/entities/playlist_entity.dart';
import 'package:musicapp/features/dashboard/data/models/music_model.dart';

class PlaylistModel extends PlaylistEntity {
  const PlaylistModel({
    required super.id,
    required super.name,
    super.description,
    super.coverImage,
    required super.songs,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    // Parse songs array - handle both populated objects and ObjectId strings
    List<MusicEntity> songs = [];
    if (json['songs'] != null) {
      final songsList = json['songs'] as List;
      songs = songsList.map((song) {
        if (song is String) {
          // If it's a string (ObjectId), create a placeholder MusicEntity
          return MusicEntity(
            id: song,
            title: 'Unknown Song',
            artist: 'Unknown Artist',
            imageUrl: '',
          );
        } else if (song is Map<String, dynamic>) {
          // If it's a populated object, parse it normally
          return MusicModel.fromJson(song);
        } else {
          // Fallback for unexpected types
          return MusicEntity(
            id: song.toString(),
            title: 'Unknown Song',
            artist: 'Unknown Artist', 
            imageUrl: '',
          );
        }
      }).toList();
    }

    return PlaylistModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      coverImage: json['coverImage']?.toString().isNotEmpty == true 
          ? json['coverImage'].toString()
          : 'https://via.placeholder.com/300',
      songs: songs,
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'coverImage': coverImage,
      'songs': songs.map((song) => MusicModel.fromEntity(song).toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Convert Entity to Model
  factory PlaylistModel.fromEntity(PlaylistEntity entity) {
    return PlaylistModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      coverImage: entity.coverImage,
      songs: entity.songs,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
