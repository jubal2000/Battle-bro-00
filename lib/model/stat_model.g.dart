// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StatModel _$StatModelFromJson(Map<String, dynamic> json) => StatModel(
      type: $enumDecode(_$StatTypeEnumMap, json['type']),
      value: json['value'] as int,
      valueNow: json['valueNow'] as int?,
      valueMax: json['valueMax'] as int?,
      star: json['star'] as int?,
    );

Map<String, dynamic> _$StatModelToJson(StatModel instance) {
  final val = <String, dynamic>{
    'type': _$StatTypeEnumMap[instance.type]!,
    'value': instance.value,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('valueNow', instance.valueNow);
  writeNotNull('valueMax', instance.valueMax);
  writeNotNull('star', instance.star);
  return val;
}

const _$StatTypeEnumMap = {
  StatType.hp: 'hp',
  StatType.fatigue: 'fatigue',
  StatType.resolve: 'resolve',
  StatType.initiative: 'initiative',
  StatType.meleeAtk: 'meleeAtk',
  StatType.rangeAtk: 'rangeAtk',
  StatType.meleeDef: 'meleeDef',
  StatType.rangeDef: 'rangeDef',
};
