import 'package:flutter/material.dart';
import 'song_viewmodel.dart';

class SongEditView extends StatefulWidget {
  final SongViewModel viewModel;

  const SongEditView({super.key, required this.viewModel});

  @override
  State<SongEditView> createState() => SongEditViewState();
}

class SongEditViewState extends State<SongEditView> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.viewModel.chordProText);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Song'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              await widget.viewModel.saveSong(controller.text);
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: TextField(
          controller: controller,
          maxLines: null,
          expands: true,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Edit lyrics and chords here...',
          ),
        ),
      ),
    );
  }
}
