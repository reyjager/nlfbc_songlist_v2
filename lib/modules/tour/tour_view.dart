import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home/home_view.dart';

class TourView extends StatefulWidget {
  const TourView({super.key});

  @override
  State<TourView> createState() => _TourViewState();
}

class _TourViewState extends State<TourView> {
  final _controller = PageController();
  int _currentPage = 0;

  static const _pages = [
    _TourPage(
      icon: Icons.library_music,
      title: 'Song List',
      description:
          'Browse through 166+ hymns and worship songs. Find your favorites quickly with search.',
      color: Colors.purple,
    ),
    _TourPage(
      icon: Icons.church,
      title: 'Worship Service Planner',
      description:
          'Plan your worship services by assigning songs to specific dates. Stay organized every Sunday.',
      color: Colors.deepPurple,
    ),
    _TourPage(
      icon: Icons.book,
      title: 'KJV Bible Reader',
      description:
          'Read the King James Version Bible offline. All 66 books at your fingertips.',
      color: Colors.indigo,
    ),
    _TourPage(
      icon: Icons.edit_note,
      title: 'Song Editor',
      description:
          'Edit song lyrics and chords to match your worship style and preferences.',
      color: Colors.teal,
    ),
    _TourPage(
      icon: Icons.music_note,
      title: 'Chord & Lyric Display',
      description:
          'View chords aligned above lyrics with transpose and font size controls for easy reading.',
      color: Colors.deepOrange,
    ),
  ];

  Future<void> _finishTour() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tour_completed', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) => _pages[i],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _finishTour,
                    child: const Text('Skip'),
                  ),
                  Row(
                    children: List.generate(
                      _pages.length,
                      (i) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == i ? 12 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? Colors.purpleAccent
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  _currentPage == _pages.length - 1
                      ? ElevatedButton(
                          onPressed: _finishTour,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purpleAccent,
                          ),
                          child: const Text('Get Started',
                              style: TextStyle(color: Colors.white)),
                        )
                      : ElevatedButton(
                          onPressed: () => _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purpleAccent,
                          ),
                          child: const Text('Next',
                              style: TextStyle(color: Colors.white)),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TourPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _TourPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 80, color: color),
          ),
          const SizedBox(height: 40),
          Text(
            title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
