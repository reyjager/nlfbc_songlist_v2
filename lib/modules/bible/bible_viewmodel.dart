import 'package:flutter/material.dart';
import '../../services/bible_service.dart';

class BibleViewModel extends ChangeNotifier {
  final _service = BibleService();

  List<String> _books = [];
  List<Map<String, dynamic>> _verses = [];
  String _currentBook = '';
  int _currentChapter = 1;
  int _chapterCount = 0;

  List<String> get books => _books;
  List<Map<String, dynamic>> get verses => _verses;
  String get currentBook => _currentBook;
  int get currentChapter => _currentChapter;
  int get chapterCount => _chapterCount;

  Future<void> loadBooks() async {
    await _service.loadBooks();
    _books = _service.books;
    notifyListeners();
  }

  Future<void> selectBook(String book) async {
    if (book.isEmpty) {
      _currentBook = '';
      _chapterCount = 0;
      _verses = [];
      notifyListeners();
      return;
    }
    _currentBook = book;
    try {
      _chapterCount = await _service.getChapterCount(book);
      _currentChapter = 1;
      await _loadChapter();
    } catch (e) {
      _verses = [];
      _chapterCount = 0;
      notifyListeners();
    }
  }

  Future<void> nextChapter() async {
    if (_currentChapter < _chapterCount) {
      _currentChapter++;
      await _loadChapter();
    }
  }

  Future<void> prevChapter() async {
    if (_currentChapter > 1) {
      _currentChapter--;
      await _loadChapter();
    }
  }

  Future<void> goToChapter(int chapter) async {
    _currentChapter = chapter;
    await _loadChapter();
  }

  Future<void> _loadChapter() async {
    _verses = await _service.getChapter(_currentBook, _currentChapter);
    notifyListeners();
  }
}
