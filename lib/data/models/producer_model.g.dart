// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'producer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProducerModel _$ProducerModelFromJson(Map<String, dynamic> json) =>
    ProducerModel(
      malId: (json['mal_id'] as num).toInt(),
      type: json['type'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
    );

Map<String, dynamic> _$ProducerModelToJson(ProducerModel instance) =>
    <String, dynamic>{
      'mal_id': instance.malId,
      'type': instance.type,
      'name': instance.name,
      'url': instance.url,
    };
