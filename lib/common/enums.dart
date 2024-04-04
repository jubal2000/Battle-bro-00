enum StatType {
  hp,
  meleeAtk,
  fatigue,
  rangeAtk,
  resolve,
  meleeDef,
  initiative,
  rangeDef;

  get min {
    if (this == meleeAtk || this == meleeDef) {
      return 1.0;
    }
    if (this == initiative) {
      return 3.0;
    }
    return 2.0;
  }

  get max {
    return min + 2.0;
  }

  get title {
    switch(this) {
      case hp:          return 'HP';
      case fatigue:     return 'Max.Fatigue';
      case resolve:     return 'Resolve';
      case initiative:  return 'Initiative';
      case meleeAtk:    return 'Melee Skill';
      case rangeAtk:    return 'Ranged Skill';
      case meleeDef:    return 'Melee Defense';
      case rangeDef:    return 'Ranged Defense';
    }
  }
}

enum CharType {
  battleForge,
  nimble,
  banner,
  frontDual,
  frontDef,
  none;

  get title {
    switch(this) {
      case battleForge: return 'BattleForge';
      case nimble:      return 'Nimble';
      case banner:      return 'Banner';
      case frontDual:   return 'FrontDual';
      case frontDef:    return 'FrontDefence';
      case none:        return '';
    }
  }
}