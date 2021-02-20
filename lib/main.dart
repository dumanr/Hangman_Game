import 'package:xml/xml.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:hangman/engine/hangman.dart';
import 'package:hangman/ui/hangman_page.dart';

List<String> wordList = [];
var yedekList = ["SELAM", "ADANA"];

void main() => runApp(HangmanApp());

class HangmanApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HangmanAppState();
}

class _HangmanAppState extends State<HangmanApp> {
  HangmanGame _engine;
  bool isLoad = false;

  // kelimeler.xml dosyasındaki ad alanlarını döner: liste olarak
  Future<XmlDocument> getLoadXmlFile() async {
    var xmlstr = await rootBundle.loadString('data_repo/kelimeler.xml');
    var xmlfile = XmlDocument.parse(xmlstr);
    return xmlfile;
  }

  @override
  void initState() {
    setState(() {
      this.isLoad = false;
    });
    this.getLoadXmlFile().then((file) {
      _engine = new HangmanGame(file, 'tr');
      setState(() {
        this.isLoad = true;
      });
    }).catchError((_) {
      setState(() {
        this.isLoad = true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hangman',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: isLoad
          ? HangmanPage(_engine)
          : Center(child: CircularProgressIndicator()),
    );
  }
}
