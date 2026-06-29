import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/song_storage_service.dart';
import '../song/song_view.dart';

class SonglistViewModel extends ChangeNotifier {
  final storage = SongStorageService();

  List<String> allSongFiles = [];
  List<String> filteredFiles = [];
  String query = '';

  List<String> get songFiles => filteredFiles;

  List<String> get songTitles => filteredFiles.map((f) {
    var name = f.replaceAll('.txt', '');
    var spaceIndex = name.indexOf(' ');
    if (spaceIndex > 0) {
      name = name.substring(spaceIndex + 1);
    }
    return name;
  }).toList();

  void search(String searchQuery) {
    query = searchQuery.toLowerCase();
    filteredFiles = allSongFiles
        .where((f) => f.toLowerCase().contains(query))
        .toList();
    notifyListeners();
  }

  Future<void> loadSongs() async {
    await storage.initializeIfNeeded();
    allSongFiles = await storage.getSongFiles();
    filteredFiles = allSongFiles;
    notifyListeners();
  }

  String getFileName(int index) => filteredFiles[index];

  void goToSong(int index) {
    Get.to(() => SongView(
      title: songTitles[index],
      fileName: getFileName(index),
    ));
  }
}
