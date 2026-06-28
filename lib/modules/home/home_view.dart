import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'home_viewmodel.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = HomeViewModel();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight(700)),
        ),

        backgroundColor: Colors.purpleAccent,
      ),
      body: ListView(
        // padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            color: Colors.purpleAccent,
            child: ListTile(
              leading: const Icon(Icons.library_music, color: Colors.white),
              title: const Text(
                'Song List',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight(700),
                ),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.white),
              onTap: viewModel.goToSongList,
            ),
          ),
          Card(
            color: Colors.purpleAccent,
            child: ListTile(
              leading: const Icon(Icons.church, color: Colors.white),
              title: const Text(
                'Worship Service',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight(700),
                ),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.white),
              onTap: viewModel.goToWorshipService,
            ),
          ),
          Card(
            color: Colors.purpleAccent,
            child: ListTile(
              leading: const Icon(Icons.book, color: Colors.white),
              title: const Text(
                'KJV Bible',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight(700),
                ),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.white),
              onTap: viewModel.goToBible,
            ),
          ),
        ],
      ),
    );
  }
}
