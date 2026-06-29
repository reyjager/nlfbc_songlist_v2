import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';
import 'models/worship_service_model.dart';
import 'modules/home/home_view.dart';
import 'modules/tour/tour_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await WorshipServiceStorage.init();
  final prefs = await SharedPreferences.getInstance();
  final tourCompleted = prefs.getBool('tour_completed') ?? false;
  runApp(MyApp(showTour: !tourCompleted));
}

class MyApp extends StatelessWidget {
  final bool showTour;
  const MyApp({super.key, required this.showTour});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Song List',
      theme: appTheme,
      home: showTour ? const TourView() : const HomeView(),
    );
  }
}
