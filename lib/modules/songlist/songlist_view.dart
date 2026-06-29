import 'package:flutter/material.dart';
import '../../app_theme.dart';
import 'songlist_viewmodel.dart';

class SonglistView extends StatefulWidget {
  const SonglistView({super.key});

  @override
  State<SonglistView> createState() => SonglistViewState();
}

class SonglistViewState extends State<SonglistView> {
  final viewModel = SonglistViewModel();

  @override
  void initState() {
    super.initState();
    viewModel.addListener(() => setState(() {}));
    viewModel.loadSongs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Table of Content')),
      body: viewModel.songFiles.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search songs...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                    onChanged: viewModel.search,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: viewModel.songTitles.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text(
                            viewModel.songFiles[index].replaceAll('.txt', ''),
                            style: const TextStyle(color: AppColors.onSurface),
                          ),
                          trailing: const Icon(Icons.chevron_right, color: AppColors.onSurface),
                          onTap: () => viewModel.goToSong(index),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
