// lib/models/bootprint_models.dart
import 'package:json_annotation/json_annotation.dart';

part 'bootprint_models.g.dart';

// Base class for all Bootprint API responses
abstract class BootprintResponse {
  final String object;

  BootprintResponse({required this.object});
}

// Model for the combined image and fact response
@JsonSerializable()
class SpaceImageFact extends BootprintResponse {
  final String image;
  final String imageId;
  final String fact;
  final String factId;

  SpaceImageFact({
    required String object,
    required this.image,
    @JsonKey(name: 'image_id') required this.imageId,
    required this.fact,
    @JsonKey(name: 'fact_id') required this.factId,
  }) : super(object: object);

  factory SpaceImageFact.fromJson(Map<String, dynamic> json) => _$SpaceImageFactFromJson(json);
  Map<String, dynamic> toJson() => _$SpaceImageFactToJson(this);
}

// Model for just the image response
@JsonSerializable()
class SpaceImage extends BootprintResponse {
  final String image;
  final String imageId;

  SpaceImage({
    required String object,
    required this.image,
    @JsonKey(name: 'image_id') required this.imageId,
  }) : super(object: object);

  factory SpaceImage.fromJson(Map<String, dynamic> json) => _$SpaceImageFromJson(json);
  Map<String, dynamic> toJson() => _$SpaceImageToJson(this);
}

// Model for just the fact response
@JsonSerializable()
class SpaceFact extends BootprintResponse {
  final String fact;
  final String factId;

  SpaceFact({
    required String object,
    required this.fact,
    @JsonKey(name: 'fact_id') required this.factId,
  }) : super(object: object);

  factory SpaceFact.fromJson(Map<String, dynamic> json) => _$SpaceFactFromJson(json);
  Map<String, dynamic> toJson() => _$SpaceFactToJson(this);
}

// Error response model
@JsonSerializable()
class BootprintError {
  final String error;

  BootprintError({required this.error});

  factory BootprintError.fromJson(Map<String, dynamic> json) => _$BootprintErrorFromJson(json);
  Map<String, dynamic> toJson() => _$BootprintErrorToJson(this);
}

// Enum for celestial objects supported by the API
enum CelestialObject {
  mars,
  jupiter,
  moon,
  // Add other supported objects as you discover them
  earth,
  venus,
  saturn,
  neptune,
  uranus,
  mercury,
  pluto;

  @override
  String toString() => name;
}