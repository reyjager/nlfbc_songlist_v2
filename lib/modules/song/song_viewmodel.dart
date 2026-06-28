import 'package:flutter/material.dart';
import '../../models/chord_lyric_pair.dart';
import '../../services/song_storage_service.dart';

class SongViewModel extends ChangeNotifier {
  static const _notes = [
    'C',
    'C#',
    'D',
    'D#',
    'E',
    'F',
    'F#',
    'G',
    'G#',
    'A',
    'A#',
    'B',
  ];
  static const _flats = [
    'C',
    'Db',
    'D',
    'Eb',
    'E',
    'F',
    'Gb',
    'G',
    'Ab',
    'A',
    'Bb',
    'B',
  ];

  final _storage = SongStorageService();

  String _chordProText = '';
  String _fileName = '';
  int _transpose = 0;
  double _fontSize = 18.0;

  String get chordProText => _chordProText;
  String get fileName => _fileName;
  int get transpose => _transpose;
  double get fontSize => _fontSize;
  double get chordFontSize => _fontSize - 2;
  List<String> get lines => _chordProText.split('\n');

  Future<void> loadSong(String fileName) async {
    _fileName = fileName;
    _chordProText = await _storage.readSong(fileName);
    notifyListeners();
  }

  Future<void> saveSong(String content) async {
    _chordProText = content;
    await _storage.saveSong(_fileName, content);
    notifyListeners();
  }

  void transposeUp() {
    _transpose = (_transpose + 1) % 12;
    notifyListeners();
  }

  void transposeDown() {
    _transpose = (_transpose - 1) % 12;
    notifyListeners();
  }

  void increaseFontSize() {
    _fontSize += 2;
    notifyListeners();
  }

  void decreaseFontSize() {
    if (_fontSize > 10) {
      _fontSize -= 2;
      notifyListeners();
    }
  }

  String _transposeChord(String chord) {
    if (chord.isEmpty) return chord;

    String root;
    String suffix;

    if (chord.length > 1 && (chord[1] == '#' || chord[1] == 'b')) {
      root = chord.substring(0, 2);
      suffix = chord.substring(2);
    } else {
      root = chord.substring(0, 1);
      suffix = chord.substring(1);
    }

    int index = _notes.indexOf(root);
    if (index == -1) index = _flats.indexOf(root);
    if (index == -1) return chord;

    int newIndex = (index + _transpose) % 12;
    if (newIndex < 0) newIndex += 12;
    return _notes[newIndex] + suffix;
  }

  List<ChordLyricPair> parseLine(String line) {
    List<ChordLyricPair> pairs = [];
    var parts = line.split('[');

    for (var part in parts) {
      if (part.contains(']')) {
        var splitPart = part.split(']');
        String chord = _transposeChord(splitPart[0]);
        pairs.add(
          ChordLyricPair(chord, splitPart.length > 1 ? splitPart[1] : ''),
        );
      } else if (part.isNotEmpty) {
        pairs.add(ChordLyricPair('', part));
      }
    }
    return pairs;
  }
}
