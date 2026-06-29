import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/worship_service_model.dart';
import '../../services/song_storage_service.dart';
import '../song/song_view.dart';

class WorshipServiceViewModel extends ChangeNotifier {
  final storage = SongStorageService();

  List<WorshipServiceModel> services = [];
  List<String> allSongFiles = [];
  WorshipServiceModel? current;

  List<String> get selectedSongs => current?.songs ?? [];
  List<String> get selectedTitles => selectedSongs.map(fileToTitle).toList();

  String fileToTitle(String f) {
    var name = f.replaceAll('.txt', '');
    var spaceIndex = name.indexOf(' ');
    if (spaceIndex > 0) name = name.substring(spaceIndex + 1);
    return name;
  }

  Future<void> loadSongs() async {
    await storage.initializeIfNeeded();
    allSongFiles = await storage.getSongFiles();
    services = WorshipServiceStorage.getAll();
    notifyListeners();
  }

  void openService(WorshipServiceModel service) {
    current = service;
    notifyListeners();
  }

  void goBack() {
    current = null;
    services = WorshipServiceStorage.getAll();
    notifyListeners();
  }

  Future<void> createService(String name) async {
    final service = WorshipServiceModel(
      name: name,
      songs: [],
      date: DateTime.now(),
    );
    await WorshipServiceStorage.save(service);
    services = WorshipServiceStorage.getAll();
    current = service;
    notifyListeners();
  }

  Future<void> deleteService(String name) async {
    await WorshipServiceStorage.delete(name);
    services = WorshipServiceStorage.getAll();
    notifyListeners();
  }

  Future<void> addSong(String file) async {
    if (current == null) return;
    final updated = WorshipServiceModel(
      name: current!.name,
      songs: [...current!.songs, file],
      date: current!.date,
    );
    await WorshipServiceStorage.save(updated);
    current = updated;
    notifyListeners();
  }

  Future<void> removeSong(int index) async {
    if (current == null) return;
    final songs = List<String>.from(current!.songs)..removeAt(index);
    final updated = WorshipServiceModel(
      name: current!.name,
      songs: songs,
      date: current!.date,
    );
    await WorshipServiceStorage.save(updated);
    current = updated;
    notifyListeners();
  }

  void goToSong(int index) {
    Get.to(() => SongView(
      title: selectedTitles[index],
      fileName: selectedSongs[index],
    ));
  }
}
