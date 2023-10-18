import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'calculate.dart' as calc;
import 'info.dart' show Spell;
import 'spell.dart' show SpellDetail;
import 'rangeformat.dart' show NumericalRangeFormatter;
// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spell D&Dictionary',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
List<String> pClassList = ["", "Bard", "Cleric", "Druid", "Paladin", "Ranger", "Sorcerer", "Warlock", "Wizard"];
List<String> schoolList = ["", "Abjuration", "Conjuration", "Divination", "Enchantment", "Evocation", "Illusion", "Necromancy", "Transmutation"];
List<String> timeList = ["", "1 Action", "1 Bonus Action", "1 Minute", "10 Minutes", "1 Hour", "8 Hours", "12 Hours", "24 Hours", "1 Reaction"];
List<String> conList = ["", "Yes", "No"];

bool classEmpty = false;
bool isLoading = false;

late final TabController _tab = TabController(length: 3, vsync: this);

late SharedPreferences prefs;

String pLevel = '';
String sLevel = '';
String key = '';
String pClass = '';
String school = '';
String time = '';
String con = '';

Spell def = Spell();

final _pLevel = TextEditingController();
final _sLevel = TextEditingController();
final _key = TextEditingController();
final GlobalKey<FormFieldState> _pClass = GlobalKey<FormFieldState>();
final GlobalKey<FormFieldState> _school = GlobalKey<FormFieldState>();
final GlobalKey<FormFieldState> _time = GlobalKey<FormFieldState>();
final GlobalKey<FormFieldState> _con = GlobalKey<FormFieldState>();

Map spellList = {};

@override
void initState(){
  // Initialize controller
  _key.addListener(() async => { key = _key.text});
  _sLevel.addListener(() => {sLevel = _sLevel.text});
  _pLevel.addListener(() => {pLevel = _pLevel.text});

  // Set default tab
  _tab.index = 2;

  // Grab saved states
  futureInit();

  // Grab all spells
  search();

  super.initState();
}

// Grab saved states and paste them into text fields
Future futureInit() async{
  prefs = await SharedPreferences.getInstance();

  var temp2;
  var temp3;

  temp2 = prefs.getString("sLevel");
  if (temp2 != null) { sLevel = temp2; _sLevel.text = sLevel; }
  temp3 = prefs.getString("key");
  if (temp3 != null) { key = temp3; _key.text = key; }
}

// Reset all filters
void resetForm(){
  pLevel = '';
  sLevel = '';
  key = '';
  pClass = '';
  time = '';
  con = '';
  _pLevel.text = '';
  _sLevel.text = '';
  _key.text = '';
  _pClass.currentState?.reset();
  _school.currentState?.reset();
  _time.currentState?.reset();
  _con.currentState?.reset();
}

// Grab data from API
Future<void> search([int rec = 0, String url = ""]) async{
  // Disable button
  setState(() { isLoading = true; });

  // If not recursing, get default url
  if (rec == 0) url = getUrl();
  
  // Grab data from API
  var response = await http.get(Uri.parse(url));
  var jData = jsonDecode(response.body);

  // Add spell detail to spell list
  for (int i = 0; i < jData["results"].length; i++) { 
    setState(() {spellList[i + rec * 50] = Spell(jData["results"][i]);});
  }

  // Recursion if result has more than 50 spells
  if(jData["next"] != null) {search(rec + 1, jData["next"]);}

  // Enable button
  isLoading = false;
}

// Grab url based on filters
String getUrl(){
  String min, max, sLevelTemp;

  // If nothing was put inside either the player's class or player's level box, automatically assign the spell level's range
  if (pClass == "" || pLevel == "") { min = "0"; max = "9"; }

  // Else calculate the spell level range
  else {
    max = calc.calculateLevel(pClass, pLevel);
    min = ((max == "-1") ? -1 : 0).toString();
  }

  // Get API's term for levels
  sLevelTemp = (sLevel == "") ? "" : calc.getSpellLevel(sLevel);

  String url = "https://api.open5e.com/spells/?search=$key&ordering=level_int&level__in=$sLevelTemp&level_int__range=$min%2C$max&school__in=$school&concentration__in=$con&casting_time__in=$time&dnd_class__icontains=$pClass";
  //print(url);
  return url;
}

@override
Widget build(BuildContext context) {
  return MaterialApp(
    home: DefaultTabController(
      length: 3,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          bottom: TabBar(
            controller: _tab,
            labelStyle: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: "Spell"),
              Tab(text: "Filter"),
              Tab(icon: Icon(Icons.paste))
            ],
          ),
          title: const Text('Spell D&Dictionary'),
        ),
        body: TabBarView(
          controller: _tab,
          children: [
            spellPage(),
            filter(),
            documentation()
          ],
        ),
      ),
    ),
  );}

  Widget documentation() => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      Padding(
        padding: const EdgeInsets.only(top: 15, left: 15, bottom: 5),
        child: Text("API:", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 30),
        child: GestureDetector(
          onTap: () async { await launchUrl(Uri.parse("https://open5e.com/")); },
          child: Text("- API home: https://open5e.com/", style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline))
        )
      ),
      Padding(
        padding: const EdgeInsets.only(left: 30),
        child: GestureDetector(
          onTap: () async { await launchUrl(Uri.parse("https://open5e.com/api-docs")); },
          child: Text("- API documentation: https://open5e.com/api-docs", style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline))
        )
      ),
      Padding(
        padding: const EdgeInsets.only(top: 30, left: 15, bottom: 5),
        child: Text("Requirements achieved:", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 30),
        child: Text("- Working API search engine."),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 30),
        child: Text("- Save last term searched."),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 30),
        child: Text("- More than 3 controls with 2 variants (TextField & DropDownButton)."),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 30),
        child: Text("- Pleasing and easy-to-use interface."),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 30),
        child: Text("- Clearly-indicated state."),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 30),
        child: Text("- Code convention is followed."),
      )
    ]),
  );

  Widget spellPage() => Expanded(
    child: ListView.builder(
      itemCount: spellList.length,
      shrinkWrap: true,
      itemBuilder: (context, index){
        if (spellList.isEmpty && index == 0) {
          return Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text("No result found!", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
          );
        }
        return (index < spellList.length) ? Card(
          color: Colors.grey,
          child: ListTile(
            title: Text(spellList[index].name),
            subtitle: Text(spellList[index].school),
            leading: Text((index + 1).toString()),
            trailing: Text(spellList[index].level),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SpellDetail(spell: spellList[index]))
              )
            }
          ),
        ) : SizedBox(height:0);
      }
    ),
  );

  Widget filter() => Column(children:[
    Padding(
      padding: const EdgeInsets.all(30),
      child: Text("Player's Info", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
    ),
    Padding(
      padding: const EdgeInsets.all(15),
      child: SizedBox(
        height: 50,
        child: Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.63,
              child: Expanded(
                child: DropdownButtonFormField(
                  items: pClassList.map((itemone){
                    return DropdownMenuItem(
                      value: itemone,
                      child: Text(itemone, style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.028))
                    );
                  }).toList(),
                  key: _pClass, onChanged: (String? value) { setState((){
                    pClass = value!; 
                    classEmpty = pClass.isNotEmpty;
                    if (!classEmpty){
                      pLevel = "";
                      _pLevel.text = "";
                    }
                  });},
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text("Player's Class"),
                  ),
                )
              ),
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.05 - 15),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.27,
              child: TextField(
                enabled: classEmpty,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, NumericalRangeFormatter(min: 1, max: 20)],
                controller: _pLevel,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text("Player's Level"),
                ),
              ),
            ),
          ]),
      ),
    ),
    Padding(
      padding: const EdgeInsets.all(30),
      child: Text("Spell's Info", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
    ),
    Padding(
      padding: const EdgeInsets.all(15),
      child: SizedBox(
        height: 50,
        child: Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.63,
              child: TextField(
                controller: _key,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text("Keyword"),
                ),
              ),
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.05 - 15),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.27,
              child: TextField(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(1)],
                controller: _sLevel,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text("Spell Level"),
                ),
              ),
            ),
          ]),
      ),
    ),
    Padding(
      padding: const EdgeInsets.all(15),
      child: SizedBox(
        height: 50,
        child: Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.29 - 1.5,
              child: Expanded(
                child: DropdownButtonFormField(
                  items: schoolList.map((itemone){
                    return DropdownMenuItem(
                      value: itemone,
                      child: Text(itemone, style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.025))
                    );
                  }).toList(),
                  isExpanded: true,  
                  key: _school, onChanged: (String? value) { setState((){school = value!;}); },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text("School"),
                  ),
                )
              ),
            ),
            //SizedBox(width: MediaQuery.of(context).size.width * 0.035 - 7.5),
            Padding(
              padding: const EdgeInsets.only(left: 4, right: 4),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.29 - 1.5,
                child: Expanded(
                  child: DropdownButtonFormField(
                    items: timeList.map((itemone){
                      return DropdownMenuItem(
                        value: (itemone.isNotEmpty) ? itemone.toLowerCase().replaceAll(" ", "+") : itemone,
                        child: Text(itemone, style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.028))
                      );
                    }).toList(),
                    isExpanded: true,  
                    key: _time, onChanged: (String? value) { setState((){time = value!;}); },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("Casting Time"),
                    ),
                  )
                ),
              ),
            ),
            //SizedBox(width: MediaQuery.of(context).size.width * 0.035 - 7.5),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.32,
              child: Expanded(
                child: DropdownButtonFormField(
                  items: conList.map((itemone){
                    return DropdownMenuItem(
                      value: (itemone.isNotEmpty) ? itemone.toLowerCase() : itemone,
                      child: Text(itemone, style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.028))
                    );
                  }).toList(),
                  isExpanded: true,  
                  key: _con, onChanged: (String? value) { setState((){con = value!;}); },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text("Concentration"),
                  ),
                )
              ),
            ),
          ]),
      ),
    ),
    Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 30),
      child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 50,
          width: MediaQuery.of(context).size.width * 0.3,
          child: ElevatedButton(
            onPressed: (resetForm), 
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text("Reset", style: TextStyle(color: Colors.white, fontSize: 20)),
          ),
        ),
        SizedBox(width: MediaQuery.of(context).size.width * 0.05),
        SizedBox(
          height: 50,
          width: MediaQuery.of(context).size.width * 0.5,
          child: ElevatedButton.icon(
            icon: isLoading ? Container(
              width: 24,
              height: 24,
              padding: const EdgeInsets.all(2.0),
              child: const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ): const Icon(Icons.filter_alt),
            onPressed: !isLoading ? () async { spellList = {}; search(); await saveData(); } : null, 
            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
            label: Text("Filter", style: TextStyle(color: Colors.white, fontSize: 20)),
          ),
        ),
      ]),
    ),
  ]);

  // Persisting state for search terms
  saveData(){
    //prefs.setString("pLevel", pLevel); This data needs player's class to be useful
    prefs.setString("sLevel", sLevel);
    prefs.setString("key", key);
  }
}
