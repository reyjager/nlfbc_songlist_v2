import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/worship_service_model.dart';
import '../../services/song_storage_service.dart';
import '../song/song_view.dart';

class WorshipServiceViewModel extends ChangeNotifier {
  final _storage = SongStorageService();

  List<WorshipServiceModel> _services = [];
  List<String> _allSongFiles = [];
  WorshipServiceModel? _current;

  List<WorshipServiceModel> get services => _services;
  List<String> get allSongFiles => _allSongFiles;
  WorshipServiceModel? get current => _current;

  List<String> get selectedSongs => _current?.songs ?? [];
  List<String> get selectedTitles => selectedSongs.map(_fileToTitle).toList();

  String _fileToTitle(String f) {
    var name = f.replaceAll('.txt', '');
    var spaceIndex = name.indexOf(' ');
    if (spaceIndex > 0) name = name.substring(spaceIndex + 1);
    return name;
  }

  Future<void> loadSongs() async {
    await _storage.initializeIfNeeded();
    _allSongFiles = await _storage.getSongFiles();
    _services = WorshipServiceStorage.getAll();
    notifyListeners();
  }

  void openService(WorshipServiceModel service) {
    _current = service;
    notifyListeners();
  }

  void goBack() {
    _current = null;
    _services = WorshipServiceStorage.getAll();
    notifyListeners();
  }

  Future<void> createService(String name) async {
    final service = WorshipServiceModel(
      name: name,
      songs: [],
      date: DateTime.now(),
    );
    await WorshipServiceStorage.save(service);
    _services = WorshipServiceStorage.getAll();
    _current = service;
    notifyListeners();
  }

  Future<void> deleteService(String name) async {
    await WorshipServiceStorage.delete(name);
    _services = WorshipServiceStorage.getAll();
    notifyListeners();
  }

  Future<void> addSong(String file) async {
    if (_current == null) return;
    final updated = WorshipServiceModel(
      name: _current!.name,
      songs: [..._current!.songs, file],
      date: _current!.date,
    );
    await WorshipServiceStorage.save(updated);
    _current = updated;
    notifyListeners();
  }

  Future<void> removeSong(int index) async {
    if (_current == null) return;
    final songs = List<String>.from(_current!.songs)..removeAt(index);
    final updated = WorshipServiceModel(
      name: _current!.name,
      songs: songs,
      date: _current!.date,
    );
    await WorshipServiceStorage.save(updated);
    _current = updated;
    notifyListeners();
  }

  void goToSong(int index) {
    Get.to(() => SongView(
      title: selectedTitles[index],
      fileName: selectedSongs[index],
    ));
  }
}
