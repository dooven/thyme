import 'package:boopplant/convert.dart';
import 'package:json_annotation/json_annotation.dart';

part 'plant.g.dart';

@JsonSerializable(includeIfNull: false)
class Plant {
  int id;
  String name;

  @JsonKey(name: "image_url")
  String imageUrl;

  @JsonKey(
    name: "created_at",
    toJson: dateTimeToMilli,
    fromJson: milliToDateTime,
  )
  DateTime createdAt;

  Plant({this.id, this.name, this.imageUrl, this.createdAt});

  factory Plant.fromJson(Map<String, dynamic> json) => _$PlantFromJson(json);

  Map<String, dynamic> toJson() => _$PlantToJson(this);
}
