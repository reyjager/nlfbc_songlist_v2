import 'dart:convert';
import 'package:flutter/services.dart';

class BibleService {
  List<String> books = [];

  Future<void> loadBooks() async {
    final data = await rootBundle.loadString('assets/bible/books.json');
    books = List<String>.from(json.decode(data));
  }

  Future<Map<String, dynamic>> loadBook(String bookName) async {
    final data = await rootBundle.loadString('assets/bible/$bookName.json');
    return json.decode(data);
  }

  Future<List<Map<String, dynamic>>> getChapter(
    String bookName,
    int chapter,
  ) async {
    final book = await loadBook(bookName);
    final chapters = book['chapters'] as List;
    if (chapter < 1 || chapter > chapters.length) return [];
    final verses = chapters[chapter - 1]['verses'] as List;
    return verses.cast<Map<String, dynamic>>();
  }

  Future<int> getChapterCount(String bookName) async {
    final book = await loadBook(bookName);
    return (book['chapters'] as List).length;
  }
}
