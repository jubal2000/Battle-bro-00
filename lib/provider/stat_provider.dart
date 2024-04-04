import 'package:battle_bro_00/common/enums.dart';
import 'package:battle_bro_00/model/stat_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const levelMin = 1;
const levelMax = 11;

final statProvider = ChangeNotifierProvider<StatProvider>((ref) {
  return StatProvider();
});

class StatProvider extends ChangeNotifier {
  List<StatModel> statInfo =  List.generate(StatType.values.length,
          (index) => StatModel(type: StatType.values[index], value: 0));

  int currentLevel = levelMax;
  int resultType = 1;

  initStat(int value) {
    for (var i=0; i<statInfo.length; i++) {
      statInfo[i].value = value;
    }
    notifyListeners();
  }

  get incLevel {
    if (++currentLevel > levelMax) currentLevel = levelMax;
    notifyListeners();
    return currentLevel;
  }

  get decLevel {
    if (--currentLevel < levelMin) currentLevel = levelMin;
    notifyListeners();
    return currentLevel;
  }

  get maxLevel {
    currentLevel = levelMax;
    notifyListeners();
    return currentLevel;
  }

  get clear {
    resultType = 1;
    currentLevel = levelMax;
    initStat(0);
  }

  get isMaxLevel {
    return currentLevel >= levelMax;
  }

  setResultType(int value) {
    resultType = value;
    notifyListeners();
    return resultType;
  }

  setStarValue(StatType type, [int? value]) {
    statInfo[type.index].star = value ?? 0;
    notifyListeners();
    return statInfo[type.index].star;
  }

  setStatValue(StatType type, [int? value]) {
    statInfo[type.index].value = value ?? 1;
    notifyListeners();
    return statInfo[type.index].value;
  }

  getStatValue(StatType type, [int? level]) {
    return statInfo[type.index].getValueFromLevel(level ?? currentLevel, resultType);
  }

}
