class MusicEntity {
  final String id;
  final String title;
  final String artist;
  final String imageUrl;
  final String? audioUrl;
  final int? duration;
  final String? album;
  final DateTime? releaseDate;

  const MusicEntity({
    required this.id,
    required this.title,
    required this.artist,
    required this.imageUrl,
    this.audioUrl,
    this.duration,
    this.album,
    this.releaseDate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MusicEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MusicEntity{id: $id, title: $title, artist: $artist, imageUrl: $imageUrl}';
  }
}
