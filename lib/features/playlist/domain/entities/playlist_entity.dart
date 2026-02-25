import 'package:musicapp/features/dashboard/domain/entities/music_entity.dart';

class PlaylistEntity {
  final String id;
  final String name;
  final String? description;
  final String? coverImage;
  final List<MusicEntity> songs;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PlaylistEntity({
    required this.id,
    required this.name,
    this.description,
    this.coverImage,
    required this.songs,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaylistEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PlaylistEntity{id: $id, name: $name, songs: ${songs.length}}';
  }
}
