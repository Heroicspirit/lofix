import 'package:hive/hive.dart';
import 'package:musicapp/core/constants/hive_table_constant.dart';

part 'playlist_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.playlistTypeId)
class PlaylistHiveModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String? coverImage;
  
  @HiveField(3)
  final DateTime createdAt;
  
  @HiveField(4)
  final DateTime updatedAt;
  
  @HiveField(5)
  final List<String> songIds; // Store only song IDs for offline

  PlaylistHiveModel({
    required this.id,
    required this.name,
    this.coverImage,
    required this.createdAt,
    required this.updatedAt,
    required this.songIds,
  });

  factory PlaylistHiveModel.fromJson(Map<String, dynamic> json) {
    return PlaylistHiveModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      coverImage: json['coverImage']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
      songIds: (json['songs'] as List<dynamic>?)
          ?.map((song) => song is String ? song : song['id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'coverImage': coverImage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'songs': songIds,
    };
  }
}
