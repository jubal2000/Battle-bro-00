import 'package:battle_bro_00/model/stat_model.dart';
import 'package:json_annotation/json_annotation.dart';

import '../common/enums.dart';
import '../common/utils.dart';

part 'char_model.g.dart';

typedef CHAR_MAP  = Map<String, CharModel>;
typedef CHAR_LIST = List<CharModel>;

@JsonSerializable(
  explicitToJson: true,
  includeIfNull: false,
)
class CharModel {
  CharType  type;
  STAT_MAP? minStat;
  STAT_MAP? maxStat;

  CharModel({
    required this.type,
    this.minStat,
    this.maxStat,
  });

  static const modelName = 'CharModel';

  factory CharModel.fromJson(Map<String, dynamic> json) => _$CharModelFromJson(json);
  Map<String, dynamic> toJson() => _$CharModelToJson(this);
}

