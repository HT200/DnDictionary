import 'package:flutter/material.dart';
import 'package:simple_rich_text/simple_rich_text.dart';
import 'info.dart' show Spell;
// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

class SpellDetail extends StatefulWidget {
  final Spell spell;
  const SpellDetail({ super.key, required this.spell });

  @override
  State<SpellDetail> createState() => _SpellDetailState();
}

class _SpellDetailState extends State<SpellDetail> {
  @override
  Widget build(BuildContext context) {
    Spell spell = widget.spell;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spell D&Dictionary'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Text(spell.name, style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Text("${spell.school} - ${spell.level}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Text("Casting time: ${spell.cast}"),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Text("Range: ${spell.range}"),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Text("Components: ${spell.comp}"),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Text("Duration: ${spell.dur}"),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Text("Ritual: ${spell.ritual}"),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Text("Concentration: ${spell.con}"),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Text("Class: ${spell.dClass}"),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: SimpleRichText("Description: ${spell.desc}", style: TextStyle(color: Colors.black))
              ),
            ),
            (spell.hdesc.isNotEmpty) ? Padding(
              padding: const EdgeInsets.all(15),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: SimpleRichText("At higher level: ${spell.hdesc}", style: TextStyle(color: Colors.black))
              ),
            ) : Text(""),
          ],
        ),
      ),
    );
  }
}