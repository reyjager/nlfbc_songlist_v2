import 'package:flutter/material.dart';
import 'worship_service_viewmodel.dart';

class WorshipServiceView extends StatefulWidget {
  const WorshipServiceView({super.key});

  @override
  State<WorshipServiceView> createState() => _WorshipServiceViewState();
}

class _WorshipServiceViewState extends State<WorshipServiceView> {
  final _viewModel = WorshipServiceViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(() => setState(() {}));
    _viewModel.loadSongs();
  }

  @override
  Widget build(BuildContext context) {
    if (_viewModel.current != null) {
      return _buildServiceDetail();
    }
    return _buildServiceList();
  }

  Widget _buildServiceList() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Worship Services'),
        backgroundColor: Colors.purpleAccent,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        child: const Icon(Icons.add),
      ),
      body: _viewModel.services.isEmpty
          ? const Center(child: Text('No worship services yet.\nTap + to create one.', textAlign: TextAlign.center))
          : ListView.builder(
              itemCount: _viewModel.services.length,
              padding: const EdgeInsets.all(8.0),
              itemBuilder: (context, index) {
                final service = _viewModel.services[index];
                return Card(
                  elevation: 3,
                  color: Colors.purpleAccent,
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text(service.name, style: const TextStyle(color: Colors.white)),
                    subtitle: Text('${service.songs.length} songs • ${_formatDate(service.date)}', style: const TextStyle(color: Colors.white70)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white70),
                      onPressed: () => _viewModel.deleteService(service.name),
                    ),
                    onTap: () => _viewModel.openService(service),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildServiceDetail() {
    return Scaffold(
      appBar: AppBar(
        title: Text(_viewModel.current!.name),
        backgroundColor: Colors.purpleAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _viewModel.goBack,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showSongPicker,
        child: const Icon(Icons.add),
      ),
      body: _viewModel.selectedSongs.isEmpty
          ? const Center(child: Text('Tap + to add songs'))
          : ListView.builder(
              itemCount: _viewModel.selectedSongs.length,
              padding: const EdgeInsets.all(8.0),
              itemBuilder: (context, index) {
                return Card(
                  elevation: 3,
                  color: Colors.purpleAccent,
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
                    title: Text(_viewModel.selectedTitles[index], style: const TextStyle(color: Colors.white)),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.white70),
                      onPressed: () => _viewModel.removeSong(index),
                    ),
                    onTap: () => _viewModel.goToSong(index),
                  ),
                );
              },
            ),
    );
  }

  void _showCreateDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Worship Service'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'e.g. Sunday Service - June 15'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _viewModel.createService(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showSongPicker() {
    String query = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          final filtered = query.isEmpty
              ? List.generate(_viewModel.allSongFiles.length, (i) => i)
              : List.generate(_viewModel.allSongFiles.length, (i) => i)
                  .where((i) => _viewModel.allSongFiles[i].toLowerCase().contains(query))
                  .toList();

          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            builder: (_, controller) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search songs...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => setModalState(() => query = v.toLowerCase()),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: controller,
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final index = filtered[i];
                      return ListTile(
                        title: Text(_viewModel.allSongFiles[index].replaceAll('.txt', '')),
                        onTap: () {
                          _viewModel.addSong(_viewModel.allSongFiles[index]);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.month}/${date.day}/${date.year}';
}
