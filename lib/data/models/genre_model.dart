import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/genre.dart';

part 'genre_model.g.dart';

@JsonSerializable()
class GenreModel {
  @JsonKey(name: 'mal_id')
  final int malId;
  final String type;
  final String name;
  final String url;

  GenreModel({
    required this.malId,
    required this.type,
    required this.name,
    required this.url,
  });

  factory GenreModel.fromJson(Map<String, dynamic> json) =>
      _$GenreModelFromJson(json);

  Map<String, dynamic> toJson() => _$GenreModelToJson(this);

  // Convert to domain entity
  Genre toDomain() {
    return Genre(
      malId: malId,
      type: type,
      name: name,
      url: url,
    );
  }
}