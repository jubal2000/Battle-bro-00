// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'char_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CharModel _$CharModelFromJson(Map<String, dynamic> json) => CharModel(
      type: $enumDecode(_$CharTypeEnumMap, json['type']),
      minStat: (json['minStat'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, StatModel.fromJson(e as Map<String, dynamic>)),
      ),
      maxStat: (json['maxStat'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, StatModel.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$CharModelToJson(CharModel instance) {
  final val = <String, dynamic>{
    'type': _$CharTypeEnumMap[instance.type]!,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull(
      'minStat', instance.minStat?.map((k, e) => MapEntry(k, e.toJson())));
  writeNotNull(
      'maxStat', instance.maxStat?.map((k, e) => MapEntry(k, e.toJson())));
  return val;
}

const _$CharTypeEnumMap = {
  CharType.battleForge: 'battleForge',
  CharType.nimble: 'nimble',
  CharType.banner: 'banner',
  CharType.none: 'none',
};
