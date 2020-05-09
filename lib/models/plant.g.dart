// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Plant _$PlantFromJson(Map<String, dynamic> json) {
  return Plant(
    id: json['id'] as int,
    name: json['name'] as String,
    imageUrl: json['image_url'] as String,
    createdAt: json['created_at'] == null
        ? null
        : DateTime.parse(json['created_at'] as String),
  );
}

Map<String, dynamic> _$PlantToJson(Plant instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'image_url': instance.imageUrl,
      'created_at': instance.createdAt?.toIso8601String(),
    };
