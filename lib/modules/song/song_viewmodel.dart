import 'package:flutter/material.dart';
import '../../models/chord_lyric_pair.dart';
import '../../services/song_storage_service.dart';

class SongViewModel extends ChangeNotifier {
  static const notes = [
    'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B',
  ];
  static const flats = [
    'C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B',
  ];

  final storage = SongStorageService();

  String chordProText = '';
  String fileName = '';
  int transpose = 0;
  double fontSize = 18.0;

  double get chordFontSize => fontSize - 2;
  List<String> get lines => chordProText.split('\n');

  Future<void> loadSong(String file) async {
    fileName = file;
    chordProText = await storage.readSong(file);
    notifyListeners();
  }

  Future<void> saveSong(String content) async {
    chordProText = content;
    await storage.saveSong(fileName, content);
    notifyListeners();
  }

  void transposeUp() {
    transpose = (transpose + 1) % 12;
    notifyListeners();
  }

  void transposeDown() {
    transpose = (transpose - 1) % 12;
    notifyListeners();
  }

  void increaseFontSize() {
    fontSize += 2;
    notifyListeners();
  }

  void decreaseFontSize() {
    if (fontSize > 10) {
      fontSize -= 2;
      notifyListeners();
    }
  }

  String transposeChord(String chord) {
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

    int index = notes.indexOf(root);
    if (index == -1) index = flats.indexOf(root);
    if (index == -1) return chord;

    int newIndex = (index + transpose) % 12;
    if (newIndex < 0) newIndex += 12;
    return notes[newIndex] + suffix;
  }

  List<ChordLyricPair> parseLine(String line) {
    List<ChordLyricPair> pairs = [];
    var parts = line.split('[');

    for (var part in parts) {
      if (part.contains(']')) {
        var splitPart = part.split(']');
        String chord = transposeChord(splitPart[0]);
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
