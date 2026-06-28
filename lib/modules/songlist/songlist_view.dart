import 'package:flutter/material.dart';
import 'songlist_viewmodel.dart';

class SonglistView extends StatefulWidget {
  const SonglistView({super.key});

  @override
  State<SonglistView> createState() => _SonglistViewState();
}

class _SonglistViewState extends State<SonglistView> {
  final _viewModel = SonglistViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(() => setState(() {}));
    _viewModel.loadSongs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Table of Content'),
        backgroundColor: Colors.purpleAccent,
      ),
      body: _viewModel.songFiles.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search songs...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _viewModel.search,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _viewModel.songTitles.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 3,
                        color: Colors.purpleAccent,
                        child: ListTile(
                          title: Text(
                            _viewModel.songFiles[index].replaceAll('.txt', ''),
                            style: TextStyle(color: Colors.white),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                          ),
                          onTap: () => _viewModel.goToSong(index),
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
