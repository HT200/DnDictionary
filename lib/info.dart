class Spell {
  String name = "default";
  String school = "default";
  String level = "default";
  String cast = "default";
  String range = "default";
  String comp = "default";
  String dur = "default";
  String ritual = "default";
  String con = "default";
  String dClass = "default";
  String desc = "default";
  String hdesc = "default";

  Spell([var spell]){
    if (spell == null) return;
    name = spell["name"];
    school = spell["school"];
    level = spell["level"];
    cast = spell["casting_time"];
    range = spell["range"];
    comp = spell["components"];
    dur = spell["duration"];
    ritual = spell["ritual"];
    con = spell["concentration"];
    dClass = spell["dnd_class"];
    desc = spell["desc"].replaceAll('**', '*');
    hdesc = spell["higher_level"].replaceAll('**', '*');
  }
}