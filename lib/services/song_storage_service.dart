import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SongStorageService {
  static const initKey = 'songs_initialized';

  Future<Directory> get songsDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/songs');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<void> initializeIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(initKey) == true) return;

    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final assets = manifest
        .listAssets()
        .where((p) => p.startsWith('assets/song_list/') && p.endsWith('.txt'))
        .toList();

    final dir = await songsDir;
    for (final asset in assets) {
      final content = await rootBundle.loadString(asset);
      final fileName = asset.split('/').last;
      await File('${dir.path}/$fileName').writeAsString(content);
    }

    await prefs.setBool(initKey, true);
  }

  Future<List<String>> getSongFiles() async {
    final dir = await songsDir;
    final files = dir.listSync().whereType<File>().toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    return files.map((f) => f.path.split('/').last).toList();
  }

  Future<String> readSong(String fileName) async {
    final dir = await songsDir;
    return File('${dir.path}/$fileName').readAsString();
  }

  Future<void> saveSong(String fileName, String content) async {
    final dir = await songsDir;
    await File('${dir.path}/$fileName').writeAsString(content);
  }

  Future<void> deleteSong(String fileName) async {
    final dir = await songsDir;
    final file = File('${dir.path}/$fileName');
    if (await file.exists()) await file.delete();
  }
}
