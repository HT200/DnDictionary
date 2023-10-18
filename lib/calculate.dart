import 'dart:math';

// Convert spell level to API's level term
String getSpellLevel(String sLevel){
  switch (sLevel) {
    case "0": {return "Cantrip";}
    case "1": {return "1st-level";}    
    case "2": {return "2nd-level";}
    case "3": {return "3rd-level";}
    case "4": case "5": case "6": case "7": case "8": case "9": {return "${sLevel}th-level";}
  }
  return "error";
}

// Calculate spell level range based on player filter
String calculateLevel(String pClass, String pLevel){
  int iLevel = int.parse(pLevel);
  switch (pClass) {
    case "Wizard": case "Sorcerer": case "Cleric": case "Bard": case "Druid":
      { return (min(((iLevel / 2 + iLevel) % 2).floor(), 9)).toString(); }
    
    case "Warlock":
      { return (min((iLevel / 2 + iLevel % 2).floor(), 5)).toString(); }

    case "Ranger": case "Paladin":
      { return (iLevel == 1) ? "-1" : ((iLevel - 1) / 4 + 1).floor().toString(); }
  }
  return "error";
}