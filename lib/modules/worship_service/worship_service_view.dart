import 'package:flutter/material.dart';
import '../../app_theme.dart';
import 'worship_service_viewmodel.dart';

class WorshipServiceView extends StatefulWidget {
  const WorshipServiceView({super.key});

  @override
  State<WorshipServiceView> createState() => WorshipServiceViewState();
}

class WorshipServiceViewState extends State<WorshipServiceView> {
  final viewModel = WorshipServiceViewModel();

  @override
  void initState() {
    super.initState();
    viewModel.addListener(() => setState(() {}));
    viewModel.loadSongs();
  }

  @override
  Widget build(BuildContext context) {
    if (viewModel.current != null) {
      return buildServiceDetail();
    }
    return buildServiceList();
  }

  Widget buildServiceList() {
    return Scaffold(
      appBar: AppBar(title: const Text('Worship Services')),
      floatingActionButton: FloatingActionButton(
        onPressed: showCreateDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: viewModel.services.isEmpty
          ? const Center(
              child: Text(
                'No worship services yet.\nTap + to create one.',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: viewModel.services.length,
              padding: const EdgeInsets.all(8.0),
              itemBuilder: (context, index) {
                final service = viewModel.services[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: ListTile(
                    title: Text(
                      service.name,
                      style: const TextStyle(color: AppColors.onSurface),
                    ),
                    subtitle: Text(
                      '${service.songs.length} songs • ${formatDate(service.date)}',
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: AppColors.textMuted,
                      ),
                      onPressed: () => viewModel.deleteService(service.name),
                    ),
                    onTap: () => viewModel.openService(service),
                  ),
                );
              },
            ),
    );
  }

  Widget buildServiceDetail() {
    return Scaffold(
      appBar: AppBar(
        title: Text(viewModel.current!.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: viewModel.goBack,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showSongPicker,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: viewModel.selectedSongs.isEmpty
          ? const Center(child: Text('Tap + to add songs'))
          : ListView.builder(
              itemCount: viewModel.selectedSongs.length,
              padding: const EdgeInsets.all(8.0),
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: Text(
                      '${index + 1}',
                      style: const TextStyle(color: AppColors.onSurface),
                    ),
                    title: Text(
                      viewModel.selectedTitles[index],
                      style: const TextStyle(color: AppColors.onSurface),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.remove_circle,
                        color: AppColors.textMuted,
                      ),
                      onPressed: () => viewModel.removeSong(index),
                    ),
                    onTap: () => viewModel.goToSong(index),
                  ),
                );
              },
            ),
    );
  }

  void showCreateDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New Worship Service'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: 'e.g. Sunday Service - June 15',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (textController.text.trim().isNotEmpty) {
                viewModel.createService(textController.text.trim());
                Navigator.of(dialogContext).pop();
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void showSongPicker() {
    String query = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setModalState) {
          final filtered = query.isEmpty
              ? List.generate(viewModel.allSongFiles.length, (i) => i)
              : List.generate(viewModel.allSongFiles.length, (i) => i)
                    .where(
                      (i) => viewModel.allSongFiles[i].toLowerCase().contains(
                        query,
                      ),
                    )
                    .toList();

          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            builder: (scrollContext, scrollController) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search songs...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) =>
                        setModalState(() => query = v.toLowerCase()),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final index = filtered[i];
                      return ListTile(
                        title: Text(
                          viewModel.allSongFiles[index].replaceAll('.txt', ''),
                        ),
                        onTap: () {
                          viewModel.addSong(viewModel.allSongFiles[index]);
                          Navigator.of(context).pop();
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

  String formatDate(DateTime date) => '${date.month}/${date.day}/${date.year}';
}
