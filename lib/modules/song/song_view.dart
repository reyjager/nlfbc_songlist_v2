import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'song_viewmodel.dart';
import 'song_edit_view.dart';

class SongView extends StatefulWidget {
  final String title;
  final String fileName;

  const SongView({super.key, required this.title, required this.fileName});

  @override
  State<SongView> createState() => _SongViewState();
}

class _SongViewState extends State<SongView> {
  final _viewModel = SongViewModel();

  static final _sectionPattern = RegExp(
    r'^(\[?\d+\]?|[iIvVxX]+\.?|chorus|refrain|bridge|coda|intro|outro|verse\s*\d*|ending)\s*$',
    caseSensitive: false,
  );

  bool _isSectionHeader(String line) {
    final stripped = line.replaceAll(RegExp(r'\[.*?\]'), '').trim();
    return _sectionPattern.hasMatch(stripped);
  }

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(() => setState(() {}));
    _viewModel.loadSong(widget.fileName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.purpleAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Get.to(() => SongEditView(viewModel: _viewModel));
            },
          ),
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: _viewModel.transposeDown,
          ),
          Center(
            child: Text(
              '${_viewModel.transpose}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _viewModel.transposeUp,
          ),
          const VerticalDivider(),
          IconButton(
            icon: const Icon(Icons.text_decrease),
            onPressed: _viewModel.decreaseFontSize,
          ),
          IconButton(
            icon: const Icon(Icons.text_increase),
            onPressed: _viewModel.increaseFontSize,
          ),
        ],
      ),
      body: _viewModel.chordProText.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _viewModel.lines.map((line) {
                    if (line.trim().isEmpty) {
                      return const SizedBox(height: 24);
                    }

                    if (_isSectionHeader(line)) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 16.0, bottom: 4.0),
                        child: Text(
                          line.replaceAll(RegExp(r'\[.*?\]'), '').trim(),
                          style: TextStyle(
                            fontSize: _viewModel.fontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      );
                    }

                    var pairs = _viewModel.parseLine(line);

                    return Wrap(
                      crossAxisAlignment: WrapCrossAlignment.end,
                      children: pairs.map((pair) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              pair.chord,
                              style: TextStyle(
                                fontSize: _viewModel.chordFontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            Text(
                              pair.lyric,
                              style: TextStyle(
                                fontSize: _viewModel.fontSize,
                                color: Colors.black87,
                                height: 1.2,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    );
                  }).toList(),
                ),
              ),
            ),
    );
  }
}
