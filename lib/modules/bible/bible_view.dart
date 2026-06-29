import 'package:flutter/material.dart';
import '../../app_theme.dart';
import 'bible_viewmodel.dart';

class BookCategory {
  final String name;
  final List<String> books;
  final Color color;

  BookCategory(this.name, this.books, this.color);
}

final oldTestamentCategories = [
  BookCategory('Law / Pentateuch', [
    'Genesis',
    'Exodus',
    'Leviticus',
    'Numbers',
    'Deuteronomy',
  ], Color.from(alpha: 0.4, red: 0.565, green: 0.843, blue: 0.596)),
  BookCategory('History', [
    'Joshua',
    'Judges',
    'Ruth',
    '1 Samuel',
    '2 Samuel',
    '1 Kings',
    '2 Kings',
    '1 Chronicles',
    '2 Chronicles',
    'Ezra',
    'Nehemiah',
    'Esther',
  ], Color.from(alpha: 0.4, red: 0.565, green: 0.792, blue: 0.976)),
  BookCategory('Poetry / Wisdom', [
    'Job',
    'Psalms',
    'Proverbs',
    'Ecclesiastes',
    'Song of Solomon',
  ], Color.from(alpha: 0.4, red: 0.808, green: 0.576, blue: 0.847)),
  BookCategory('Major Prophets', [
    'Isaiah',
    'Jeremiah',
    'Lamentations',
    'Ezekiel',
    'Daniel',
  ], Color.from(alpha: 0.4, red: 1, green: 0.604, blue: 0.624)),
  BookCategory('Minor Prophets', [
    'Hosea',
    'Joel',
    'Amos',
    'Obadiah',
    'Jonah',
    'Micah',
    'Nahum',
    'Habakkuk',
    'Zephaniah',
    'Haggai',
    'Zechariah',
    'Malachi',
  ], Color.from(alpha: 0.4, red: 1, green: 0.808, blue: 0.533)),
];

final newTestamentCategories = [
  BookCategory('Gospels', [
    'Matthew',
    'Mark',
    'Luke',
    'John',
  ], Color.from(alpha: 0.4, red: 0.533, green: 0.82, blue: 0.792)),
  BookCategory('History', [
    'Acts',
  ], Color.from(alpha: 0.4, red: 0.565, green: 0.792, blue: 0.976)),
  BookCategory('Pauline Epistles', [
    'Romans',
    '1 Corinthians',
    '2 Corinthians',
    'Galatians',
    'Ephesians',
    'Philippians',
    'Colossians',
    '1 Thessalonians',
    '2 Thessalonians',
    '1 Timothy',
    '2 Timothy',
    'Titus',
    'Philemon',
  ], Color.from(alpha: 0.4, red: 0.702, green: 0.616, blue: 0.859)),
  BookCategory('General Epistles', [
    'Hebrews',
    'James',
    '1 Peter',
    '2 Peter',
    '1 John',
    '2 John',
    '3 John',
    'Jude',
  ], Color.from(alpha: 0.4, red: 1, green: 0.604, blue: 0.769)),
  BookCategory('Prophecy', [
    'Revelation',
  ], Color.from(alpha: 0.4, red: 1, green: 0.702, blue: 0.616)),
];

class BibleView extends StatefulWidget {
  const BibleView({super.key});

  @override
  State<BibleView> createState() => BibleViewState();
}

class BibleViewState extends State<BibleView> {
  final viewModel = BibleViewModel()..loadBooks();
  PageController pageController = PageController();

  void initPageController(int page) {
    pageController = PageController(initialPage: page);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        if (viewModel.currentBook.isEmpty) {
          return buildBookList(context);
        }
        return buildChapterView(context);
      },
    );
  }

  Color getBookColor(String book) {
    for (final cat in [...oldTestamentCategories, ...newTestamentCategories]) {
      if (cat.books.contains(book)) {
        return Color.from(
          alpha: 1,
          red: cat.color.r,
          green: cat.color.g,
          blue: cat.color.b,
        );
      }
    }
    return AppColors.surface;
  }

  Future<void> onBookTap(BuildContext context, String book) async {
    final chapterCount = await viewModel.getChapterCountForBook(book);
    final bookColor = getBookColor(book);
    if (!context.mounted) return;
    final selected = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(book, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,
            ),
            itemCount: chapterCount,
            itemBuilder: (context, index) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: bookColor,
                ),
                onPressed: () {
                  Navigator.of(context).pop(index + 1);
                },
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('${index + 1}'),
                ),
              );
            },
          ),
        ),
      ),
    );
    if (selected != null) {
      await viewModel.selectBook(book);
      await viewModel.goToChapter(selected);
      pageController.dispose();
      initPageController(selected - 1);
    }
  }

  Widget buildCategorySection(BuildContext context, BookCategory category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 6),
          child: Text(
            category.name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: category.books.map((book) {
            return ActionChip(
              label: Text(book),
              labelStyle: const TextStyle(color: Colors.black87, fontSize: 13),
              backgroundColor: category.color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onPressed: () => onBookTap(context, book),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget buildPickerCategorySection(
    BuildContext context,
    BookCategory category,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 6),
          child: Text(
            category.name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: category.books.map((book) {
            final isSelected = book == viewModel.currentBook;
            return ActionChip(
              label: Text(book),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 13,
              ),
              backgroundColor: isSelected ? AppColors.accent : category.color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                viewModel.selectBook(book);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget buildBookList(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KJV Bible')),
      body: viewModel.books.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildSectionHeader('Old Testament'),
                  ...oldTestamentCategories.map(
                    (c) => buildCategorySection(context, c),
                  ),
                  buildSectionHeader('New Testament'),
                  ...newTestamentCategories.map(
                    (c) => buildCategorySection(context, c),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  void showBookPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        builder: (scrollContext, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildSectionHeader('Old Testament'),
              ...oldTestamentCategories.map(
                (c) => buildPickerCategorySection(sheetContext, c),
              ),
              buildSectionHeader('New Testament'),
              ...newTestamentCategories.map(
                (c) => buildPickerCategorySection(sheetContext, c),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void showChapterGrid(BuildContext context) {
    final bookColor = getBookColor(viewModel.currentBook);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(viewModel.currentBook),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: viewModel.chapterCount,
            itemBuilder: (context, index) {
              final isCurrentChapter = index + 1 == viewModel.currentChapter;
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: isCurrentChapter
                      ? AppColors.primary
                      : bookColor,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  pageController.jumpToPage(index);
                },
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('${index + 1}'),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildChapterView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => showBookPicker(context),
          child: Text('${viewModel.currentBook} ${viewModel.currentChapter}'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            initPageController(0);
            viewModel.selectBook('');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
          ),
          Center(
            child: GestureDetector(
              onTap: () => showChapterGrid(context),
              child: Text(
                '${viewModel.currentChapter}/${viewModel.chapterCount}',
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
          ),
        ],
      ),
      body: viewModel.verses.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : PageView.builder(
              controller: pageController,
              itemCount: viewModel.chapterCount,
              onPageChanged: (index) {
                viewModel.goToChapter(index + 1);
              },
              itemBuilder: (context, index) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: viewModel.verses.map((v) {
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
                                  color: AppColors.primary,
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
