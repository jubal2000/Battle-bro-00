import 'package:json_annotation/json_annotation.dart';

import '../common/enums.dart';
import '../common/utils.dart';

part 'stat_model.g.dart';

typedef STAT_MAP  = Map<String, StatModel>;
typedef STAT_LIST = List<StatModel>;

@JsonSerializable(
  explicitToJson: true,
  includeIfNull: false,
)
class StatModel {
  StatType  type;
  int       value;
  int?      valueNow;
  int?      valueMax;
  int?      star;

  StatModel({
    required this.type,
    required this.value,
    this.valueNow,
    this.valueMax,
    this.star,
  });

  static const modelName = 'StatModel';

  getValueFromLevel(int level, [int resultType = 1]) {
    final upValue = resultType == 0 ? type.min : resultType == 1 ? (type.min + type.max) / 2 : type.max;
    final offset = ((level - 1) * (INT(star) + upValue));
    final result = value + offset;
    final resultStr = '$result';
    LOG('--> value [${type.title}] : $level / $resultType => $resultStr ($upValue)');
    if (resultStr.contains('.')) {
      final resultArr = resultStr.split('.');
      if (int.parse(resultArr.last) > 0) return result;
    }
    return result.toInt();
  }

  factory StatModel.fromJson(Map<String, dynamic> json) => _$StatModelFromJson(json);
  Map<String, dynamic> toJson() => _$StatModelToJson(this);
}

