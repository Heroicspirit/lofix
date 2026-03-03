import 'package:hive/hive.dart';
import 'package:musicapp/core/constants/hive_table_constant.dart';

part 'song_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.songTypeId)
class SongHiveModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String artist;
  
  @HiveField(3)
  final String? imageUrl;
  
  @HiveField(4)
  final String? audioUrl;
  
  @HiveField(5)
  final int? durationInSeconds;

  SongHiveModel({
    required this.id,
    required this.title,
    required this.artist,
    this.imageUrl,
    this.audioUrl,
    this.durationInSeconds,
  });

  factory SongHiveModel.fromJson(Map<String, dynamic> json) {
    return SongHiveModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      artist: json['artist'] ?? '',
      imageUrl: json['imageUrl']?.toString() ?? json['coverImage']?.toString(),
      audioUrl: json['audioUrl']?.toString(),
      durationInSeconds: int.tryParse(json['duration']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'duration': durationInSeconds,
    };
  }

  // Note: No audio playback when offline - this is for display only
  bool get canPlay => false; // Always false for offline mode
}
