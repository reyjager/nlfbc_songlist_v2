import 'package:flutter/material.dart';
import 'bible_viewmodel.dart';

class BibleView extends StatelessWidget {
  BibleView({super.key});

  final _viewModel = BibleViewModel()..loadBooks();
  final _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        if (_viewModel.currentBook.isEmpty) {
          return _buildBookList(context);
        }
        return _buildChapterView(context);
      },
    );
  }

  Widget _buildBookList(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KJV Bible'),
        backgroundColor: Colors.purpleAccent,
      ),
      body: _viewModel.books.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _viewModel.books.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_viewModel.books[index]),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _viewModel.selectBook(_viewModel.books[index]),
                );
              },
            ),
    );
  }

  void _showBookPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => ListView.builder(
        itemCount: _viewModel.books.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_viewModel.books[index]),
            selected: _viewModel.books[index] == _viewModel.currentBook,
            onTap: () {
              Navigator.pop(context);
              _viewModel.selectBook(_viewModel.books[index]);
            },
          );
        },
      ),
    );
  }

  void _showChapterGrid(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_viewModel.currentBook),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: _viewModel.chapterCount,
            itemBuilder: (context, index) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: index + 1 == _viewModel.currentChapter
                      ? Colors.purpleAccent
                      : null,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _pageController.jumpToPage(index);
                },
                child: Text('${index + 1}'),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildChapterView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => _showBookPicker(context),
          child: Text('${_viewModel.currentBook} ${_viewModel.currentChapter}'),
        ),
        backgroundColor: Colors.purpleAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _viewModel.selectBook(''),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
          ),
          Center(
            child: GestureDetector(
              onTap: () => _showChapterGrid(context),
              child: Text(
                '${_viewModel.currentChapter}/${_viewModel.chapterCount}',
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
          ),
        ],
      ),
      body: _viewModel.verses.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : PageView.builder(
              controller: _pageController,
              itemCount: _viewModel.chapterCount,
              onPageChanged: (index) {
                _viewModel.goToChapter(index + 1);
              },
              itemBuilder: (context, index) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _viewModel.verses.map((v) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                            children: [
                              TextSpan(
                                text: '${v['verse']} ',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purpleAccent,
                                ),
                              ),
                              TextSpan(text: '${v['text']}'),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
    );
  }
}
