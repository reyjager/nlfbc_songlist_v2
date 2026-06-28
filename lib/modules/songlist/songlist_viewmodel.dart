import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/song_storage_service.dart';
import '../song/song_view.dart';

class SonglistViewModel extends ChangeNotifier {
  final _storage = SongStorageService();

  List<String> _songFiles = [];
  List<String> _filteredFiles = [];
  String _query = '';

  List<String> get songFiles => _filteredFiles;

  List<String> get songTitles => _filteredFiles.map((f) {
    var name = f.replaceAll('.txt', '');
    var spaceIndex = name.indexOf(' ');
    if (spaceIndex > 0) {
      name = name.substring(spaceIndex + 1);
    }
    return name;
  }).toList();

  void search(String query) {
    _query = query.toLowerCase();
    _filteredFiles = _songFiles
        .where((f) => f.toLowerCase().contains(_query))
        .toList();
    notifyListeners();
  }

  Future<void> loadSongs() async {
    await _storage.initializeIfNeeded();
    _songFiles = await _storage.getSongFiles();
    _filteredFiles = _songFiles;
    notifyListeners();
  }

  String getFileName(int index) => _filteredFiles[index];

  void goToSong(int index) {
    Get.to(() => SongView(
      title: songTitles[index],
      fileName: getFileName(index),
    ));
  }
}
