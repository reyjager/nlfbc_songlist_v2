import 'package:flutter/material.dart';
import '../../services/bible_service.dart';

class BibleViewModel extends ChangeNotifier {
  final service = BibleService();

  List<String> books = [];
  List<Map<String, dynamic>> verses = [];
  String currentBook = '';
  int currentChapter = 1;
  int chapterCount = 0;

  Future<void> loadBooks() async {
    await service.loadBooks();
    books = service.books;
    notifyListeners();
  }

  Future<int> getChapterCountForBook(String book) async {
    return await service.getChapterCount(book);
  }

  Future<void> selectBook(String book) async {
    if (book.isEmpty) {
      currentBook = '';
      chapterCount = 0;
      verses = [];
      notifyListeners();
      return;
    }
    currentBook = book;
    try {
      chapterCount = await service.getChapterCount(book);
      currentChapter = 1;
      await loadChapter();
    } catch (e) {
      verses = [];
      chapterCount = 0;
      notifyListeners();
    }
  }

  Future<void> nextChapter() async {
    if (currentChapter < chapterCount) {
      currentChapter++;
      await loadChapter();
    }
  }

  Future<void> prevChapter() async {
    if (currentChapter > 1) {
      currentChapter--;
      await loadChapter();
    }
  }

  Future<void> goToChapter(int chapter) async {
    currentChapter = chapter;
    await loadChapter();
  }

  Future<void> loadChapter() async {
    verses = await service.getChapter(currentBook, currentChapter);
    notifyListeners();
  }
}
