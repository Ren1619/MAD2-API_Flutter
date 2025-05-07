// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bootprint_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpaceImageFact _$SpaceImageFactFromJson(Map<String, dynamic> json) =>
    SpaceImageFact(
      object: json['object'] as String,
      image: json['image'] as String,
      imageId: json['imageId'] as String,
      fact: json['fact'] as String,
      factId: json['factId'] as String,
    );

Map<String, dynamic> _$SpaceImageFactToJson(SpaceImageFact instance) =>
    <String, dynamic>{
      'object': instance.object,
      'image': instance.image,
      'imageId': instance.imageId,
      'fact': instance.fact,
      'factId': instance.factId,
    };

SpaceImage _$SpaceImageFromJson(Map<String, dynamic> json) => SpaceImage(
  object: json['object'] as String,
  image: json['image'] as String,
  imageId: json['imageId'] as String,
);

Map<String, dynamic> _$SpaceImageToJson(SpaceImage instance) =>
    <String, dynamic>{
      'object': instance.object,
      'image': instance.image,
      'imageId': instance.imageId,
    };

SpaceFact _$SpaceFactFromJson(Map<String, dynamic> json) => SpaceFact(
  object: json['object'] as String,
  fact: json['fact'] as String,
  factId: json['factId'] as String,
);

Map<String, dynamic> _$SpaceFactToJson(SpaceFact instance) => <String, dynamic>{
  'object': instance.object,
  'fact': instance.fact,
  'factId': instance.factId,
};

BootprintError _$BootprintErrorFromJson(Map<String, dynamic> json) =>
    BootprintError(error: json['error'] as String);

Map<String, dynamic> _$BootprintErrorToJson(BootprintError instance) =>
    <String, dynamic>{'error': instance.error};
