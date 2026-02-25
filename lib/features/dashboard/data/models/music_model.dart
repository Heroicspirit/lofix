import 'package:musicapp/features/dashboard/domain/entities/music_entity.dart';
import 'package:musicapp/core/api/api_endpoints.dart';

class MusicModel extends MusicEntity {
  const MusicModel({
    required super.id,
    required super.title,
    required super.artist,
    required super.imageUrl,
    super.audioUrl,
    super.duration,
    super.album,
    super.releaseDate,
  });

  factory MusicModel.fromJson(Map<String, dynamic> json) {
    // Handle artist as either ObjectId string or populated object
    String artistName = 'Unknown Artist';
    
    // Try different ways to get the artist name
    if (json['artist'] is Map) {
      // If artist is populated object
      artistName = json['artist']['name'] ?? json['artist']['_id'] ?? 'Unknown Artist';
    } else if (json['artist'] is String) {
      final artistStr = json['artist'].toString();
      // If it looks like an ObjectId (24 hex characters), treat as unknown
      if (artistStr.length == 24 && RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(artistStr)) {
        artistName = 'Unknown Artist';
      } else {
        artistName = artistStr;
      }
    }
    
    // Also try to get artist from other possible fields
    if (artistName == 'Unknown Artist') {
      // Try artistName field (some backends use this)
      artistName = json['artistName'] ?? json['artist_name'] ?? 'Unknown Artist';
    }

    // Normalize image URL: handle absolute URLs and several relative forms the
    // backend may return. Backend stores covers under `upload/images` and
    // songs under `upload/songs`. Profile images live under `upload/` and are
    // handled separately in the profile screen, so we don't modify that logic.
    final rawImage = (json['coverImage'] ?? json['imageUrl'] ?? json['image'] ?? '').toString();
    String normalizedImage = '';
    if (rawImage.isNotEmpty) {
      final lower = rawImage.toLowerCase();
      if (lower.startsWith('http')) {
        normalizedImage = rawImage;
      } else {
        // Make path start with '/'
        String path = rawImage.startsWith('/') ? rawImage : '/$rawImage';

        // If backend returned a path like '/images/...' or 'images/...',
        // ensure it becomes '/upload/images/...'
        if (path.startsWith('/images/')) {
          path = '/upload$path';
        } else if (path.startsWith('/songs/')) {
          path = '/upload$path';
        } else if (!path.startsWith('/upload/')) {
          // If it's some other relative path, assume it's under /upload/
          path = '/upload$path';
        }

        // Remove '/api' suffix from baseUrl so we reach server root
        var base = ApiEndpoints.baseUrl;
        if (base.endsWith('/api/')) {
          base = base.replaceFirst('/api/', '');
        } else if (base.endsWith('/api')) {
          base = base.replaceFirst('/api', '');
        }

        normalizedImage = '$base$path';
      }
    }

    // Normalize audio URL: similar to image URL normalization
    final rawAudio = (json['audioUrl'] ?? '').toString();
    String normalizedAudio = '';
    if (rawAudio.isNotEmpty) {
      final lower = rawAudio.toLowerCase();
      if (lower.startsWith('http')) {
        normalizedAudio = rawAudio;
      } else {
        // Make path start with '/'
        String path = rawAudio.startsWith('/') ? rawAudio : '/$rawAudio';

        // If backend returned a path like '/songs/...', ensure it becomes '/upload/songs/...'
        if (path.startsWith('/songs/')) {
          path = '/upload$path';
        } else if (!path.startsWith('/upload/')) {
          // If it's some other relative path, assume it's under /upload/
          path = '/upload$path';
        }

        // Remove '/api' suffix from baseUrl so we reach server root
        var base = ApiEndpoints.baseUrl;
        if (base.endsWith('/api/')) {
          base = base.replaceFirst('/api/', '');
        } else if (base.endsWith('/api')) {
          base = base.replaceFirst('/api', '');
        }

        normalizedAudio = '$base$path';
      }
    }

    return MusicModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      artist: artistName,
      imageUrl: normalizedImage,
      audioUrl: normalizedAudio,
      duration: json['duration'] != null ? int.tryParse(json['duration'].toString()) : null,
      album: json['album'],
      releaseDate: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'artist': artist,
      'coverImage': imageUrl,
      'audioUrl': audioUrl,
      'duration': duration,
      'album': album,
    };
  }

  // Convert Entity to Model
  factory MusicModel.fromEntity(MusicEntity entity) {
    return MusicModel(
      id: entity.id,
      title: entity.title,
      artist: entity.artist,
      imageUrl: entity.imageUrl,
      audioUrl: entity.audioUrl,
      duration: entity.duration,
      album: entity.album,
      releaseDate: entity.releaseDate,
    );
  }
}
