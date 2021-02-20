import 'dart:async';

import 'package:xml/xml.dart';

class HangmanGame {
  static const int hanged = 7; // ölümden önceki yanlış tahmin sayısı

  List<String> wordList; // tahmin edilebilecek kelimelerin listesi
  final Set<String> lettersGuessed = new Set<String>();

  XmlDocument xmlfile;
  String lang = "tr";

  List<String> _wordToGuess;
  int _wrongGuesses;

  StreamController<Null> _onWin = new StreamController<Null>.broadcast();
  Stream<Null> get onWin => _onWin.stream;

  StreamController<Null> _onLose = new StreamController<Null>.broadcast();
  Stream<Null> get onLose => _onLose.stream;

  StreamController<int> _onWrong = new StreamController<int>.broadcast();
  Stream<int> get onWrong => _onWrong.stream;

  StreamController<String> _onRight = new StreamController<String>.broadcast();
  Stream<String> get onRight => _onRight.stream;

  StreamController<String> _onChange = new StreamController<String>.broadcast();
  Stream<String> get onChange => _onChange.stream;

  HangmanGame(this.xmlfile, this.lang);

  void langProccess() {
    var langEl = xmlfile.findAllElements(this.lang);
    Iterable<XmlElement> wordOfLang;

    if (langEl.length > 0) {
      wordOfLang = langEl.first.findAllElements('kelime');
    }

    this.wordList =
        wordOfLang.map((k) => k.getElement('ad').text.toUpperCase()).toList();
  }

  void changeLang(String lang) {
    this.lang = lang;
    this.langProccess();
  }

  void newGame() {
    // kelime listesi random
    wordList.shuffle();

    // gelen kelimeyi harf listesine bölme
    _wordToGuess = wordList.first.split('');

    // YANLIŞ TAHMİN SAYISINI SIFIRLAMA
    _wrongGuesses = 0;

    // TAHMİN EDİLEN HARF KÜMESİNİ TEMİZLEME
    lettersGuessed.clear();

    // YENİ KELİME
    _onChange.add(wordForDisplay);
  }

  void guessLetter(String letter) {
    lettersGuessed.add(letter);

    // KELİME DE TAHMİN EDİLEN HARF VARSA, KAZANCI KONTROL ETME
    // YOKSA ÖLÜMÜ KONTROL ETME
    if (_wordToGuess.contains(letter)) {
      _onRight.add(letter);

      if (isWordComplete) {
        _onChange.add(fullWord);
        _onWin.add(null);
      } else {
        _onChange.add(wordForDisplay);
      }
    } else {
      _wrongGuesses++;

      _onWrong.add(_wrongGuesses);

      if (_wrongGuesses == hanged) {
        _onChange.add(fullWord);
        _onLose.add(null);
      }
    }
  }

  int get wrongGuesses => _wrongGuesses;
  List<String> get wordToGuess => _wordToGuess;
  String get fullWord => wordToGuess.join();

  String get wordForDisplay => wordToGuess
      .map((String letter) => lettersGuessed.contains(letter) ? letter : "_")
      .join();

  // KELİMEDE Kİ HER HARFİN KONTROL EDİLİP EDİLMEDİĞİNİ KONTROL ETME
  bool get isWordComplete {
    for (String letter in _wordToGuess) {
      if (!lettersGuessed.contains(letter)) {
        return false;
      }
    }

    return true;
  }
}
