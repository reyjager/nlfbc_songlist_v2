import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../../app_theme.dart';
import 'song_viewmodel.dart';
import 'song_edit_view.dart';

class SongView extends StatelessWidget {
  final String title;
  final String fileName;

  SongView({super.key, required this.title, required this.fileName}) {
    viewModel.loadSong(fileName);
  }

  final viewModel = SongViewModel();

  static final sectionPattern = RegExp(
    r'^(\[?\d+\]?|[iIvVxX]+\.?|chorus|refrain|bridge|coda|intro|outro|verse\s*\d*|ending)\s*$',
    caseSensitive: false,
  );

  bool isSectionHeader(String line) {
    final stripped = line.replaceAll(RegExp(r'\[.*?\]'), '').trim();
    return sectionPattern.hasMatch(stripped);
  }

  Future<void> savePdf(BuildContext context) async {
    final file = File('/storage/emulated/0/Download/$title.pdf');

    if (!context.mounted) return;
    final shouldSave = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => PdfPreviewPage(
          title: title,
          fileName: fileName,
          viewModel: viewModel,
          alreadySaved: file.existsSync(),
          isSectionHeader: isSectionHeader,
        ),
      ),
    );

    if (shouldSave == true) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('PDF saved')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            actions: [
              IconButton(
                icon: const Icon(Icons.picture_as_pdf),
                onPressed: () => savePdf(context),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  await Get.to(() => SongEditView(viewModel: viewModel));
                },
              ),
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: viewModel.transposeDown,
              ),
              Center(
                child: Text(
                  '${viewModel.transpose}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: viewModel.transposeUp,
              ),
              const VerticalDivider(),
              IconButton(
                icon: const Icon(Icons.text_decrease),
                onPressed: viewModel.decreaseFontSize,
              ),
              IconButton(
                icon: const Icon(Icons.text_increase),
                onPressed: viewModel.increaseFontSize,
              ),
            ],
          ),
          body: viewModel.chordProText.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: viewModel.lines.map((line) {
                        if (line.trim().isEmpty) {
                          return const SizedBox(height: 24);
                        }

                        if (isSectionHeader(line)) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              top: 16.0,
                              bottom: 4.0,
                            ),
                            child: Text(
                              line.replaceAll(RegExp(r'\[.*?\]'), '').trim(),
                              style: TextStyle(
                                fontSize: viewModel.fontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          );
                        }

                        var pairs = viewModel.parseLine(line);

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
                                    fontSize: viewModel.chordFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                                Text(
                                  pair.lyric,
                                  style: TextStyle(
                                    fontSize: viewModel.fontSize,
                                    // color: Colors.black87,
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
      },
    );
  }
}

class PdfPreviewPage extends StatefulWidget {
  final String title;
  final String fileName;
  final SongViewModel viewModel;
  final bool alreadySaved;
  final bool Function(String) isSectionHeader;

  const PdfPreviewPage({
    super.key,
    required this.title,
    required this.fileName,
    required this.viewModel,
    required this.alreadySaved,
    required this.isSectionHeader,
  });

  @override
  State<PdfPreviewPage> createState() => PdfPreviewPageState();
}

class PdfPreviewPageState extends State<PdfPreviewPage> {
  double lyricSize = 13;
  int columns = 1;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    generatePreview();
  }

  Future<Uint8List> buildPdf() async {
    final pdf = pw.Document();
    final chordSize = lyricSize - 2;

    final content = <pw.Widget>[];

    content.add(
      pw.Text(
        widget.fileName.replaceAll('.txt', ''),
        style: pw.TextStyle(
          fontSize: lyricSize + 9,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
    content.add(pw.SizedBox(height: 12));

    for (int i = 0; i < widget.viewModel.lines.length; i++) {
      final line = widget.viewModel.lines[i];
      if (i == 0) continue;

      if (line.trim().isEmpty) {
        content.add(pw.SizedBox(height: 8));
        continue;
      }

      if (widget.isSectionHeader(line)) {
        content.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 8, bottom: 2),
            child: pw.Text(
              line.replaceAll(RegExp(r'\[.*?\]'), '').trim(),
              style: pw.TextStyle(
                fontSize: lyricSize,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        );
        continue;
      }

      final pairs = widget.viewModel.parseLine(line);
      final chordLine = pairs
          .map((p) => p.chord.padRight(p.lyric.length))
          .join();
      final lyricLine = pairs
          .map((p) => p.lyric.padRight(p.chord.length))
          .join();

      content.add(
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              chordLine,
              style: pw.TextStyle(
                fontSize: chordSize,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.red,
              ),
            ),
            pw.Text(lyricLine, style: pw.TextStyle(fontSize: lyricSize)),
          ],
        ),
      );
    }

    if (columns == 2) {
      final half = content.length ~/ 2;
      final left = content.sublist(0, half);
      final right = content.sublist(half);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (context) => pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: left,
                ),
              ),
              pw.SizedBox(width: 16),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: right,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      pdf.addPage(
        pw.MultiPage(
          pageTheme: const pw.PageTheme(
            pageFormat: PdfPageFormat.a4,
            margin: pw.EdgeInsets.all(24),
          ),
          build: (context) => content,
        ),
      );
    }

    return pdf.save();
  }

  Future<void> generatePreview() async {
    setState(() => loading = true);
    try {
      await buildPdf();
      if (!mounted) return;
      setState(() => loading = false);
    } catch (e) {
      if (!mounted) return;
      if (e.toString().contains('Widget won\'t fit')) {
        lyricSize -= 1;
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Text too large for page, reducing size'),
          ),
        );
      } else {
        setState(() => loading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> saveFile() async {
    final dir = Directory('/storage/emulated/0/Download');
    try {
      final filePath = '${dir.path}/${widget.title}.pdf';
      final file = File(filePath);
      final bytes = await buildPdf();
      await file.writeAsBytes(bytes);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved to Downloads: ${widget.title}.pdf'),
          duration: const Duration(seconds: 4),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      // Fallback: use share if permission fails
      if (!mounted) return;
      final tempDir = await getApplicationDocumentsDirectory();
      final filePath = '${tempDir.path}/${widget.title}.pdf';
      final file = File(filePath);
      final bytes = await buildPdf();
      await file.writeAsBytes(bytes);
      if (!mounted) return;
      await Share.shareXFiles([XFile(filePath)], subject: widget.title);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    }
  }

  List<Widget> buildPreviewContent() {
    final chordSize = lyricSize - 2;
    final lines = widget.viewModel.lines;
    final widgets = <Widget>[];

    widgets.add(
      Text(
        widget.fileName.replaceAll('.txt', ''),
        style: TextStyle(fontSize: lyricSize + 9, fontWeight: FontWeight.bold),
      ),
    );
    widgets.add(const SizedBox(height: 12));

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (i == 0) continue;

      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      if (widget.isSectionHeader(line)) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 2),
            child: Text(
              line.replaceAll(RegExp(r'\[.*?\]'), '').trim(),
              style: TextStyle(
                fontSize: lyricSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
        continue;
      }

      final pairs = widget.viewModel.parseLine(line);
      final chordLine = pairs
          .map((p) => p.chord.padRight(p.lyric.length))
          .join();
      final lyricLine = pairs
          .map((p) => p.lyric.padRight(p.chord.length))
          .join();

      widgets.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              chordLine,
              style: TextStyle(
                fontSize: chordSize,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            Text(lyricLine, style: TextStyle(fontSize: lyricSize)),
          ],
        ),
      );
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        actions: [
          TextButton.icon(
            onPressed: widget.alreadySaved ? null : saveFile,
            icon: Icon(
              Icons.save,
              color: widget.alreadySaved ? Colors.grey : Colors.white,
            ),
            label: Text(
              widget.alreadySaved ? 'Already Saved' : 'Save',
              style: TextStyle(
                color: widget.alreadySaved ? Colors.grey : Colors.white,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.text_decrease),
                onPressed: lyricSize > 8
                    ? () {
                        lyricSize -= 1;
                        generatePreview();
                      }
                    : null,
              ),
              Text(
                '${lyricSize.toInt()}',
                style: const TextStyle(fontSize: 16),
              ),
              IconButton(
                icon: const Icon(Icons.text_increase),
                onPressed: () {
                  lyricSize += 1;
                  generatePreview();
                },
              ),
              const Spacer(),
              ChoiceChip(
                label: const Text('1 Col'),
                selected: columns == 1,
                onSelected: (selected) {
                  if (selected) {
                    columns = 1;
                    generatePreview();
                  }
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('2 Col'),
                selected: columns == 2,
                onSelected: (selected) {
                  if (selected) {
                    columns = 2;
                    generatePreview();
                  }
                },
              ),
            ],
          ),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: buildPreviewContent(),
                ),
              ),
            ),
    );
  }
}
