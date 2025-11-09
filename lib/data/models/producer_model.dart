import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/producer.dart';

part 'producer_model.g.dart';

@JsonSerializable()
class ProducerModel {
  @JsonKey(name: 'mal_id')
  final int malId;
  final String type;
  final String name;
  final String url;

  ProducerModel({
    required this.malId,
    required this.type,
    required this.name,
    required this.url,
  });

  factory ProducerModel.fromJson(Map<String, dynamic> json) =>
      _$ProducerModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProducerModelToJson(this);

  // Convert to domain entity
  Producer toDomain() {
    return Producer(
      malId: malId,
      type: type,
      name: name,
      url: url,
    );
  }
}