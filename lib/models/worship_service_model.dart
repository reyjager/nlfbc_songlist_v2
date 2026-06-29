import 'package:hive/hive.dart';

class WorshipServiceModel {
  final String name;
  final List<String> songs;
  final DateTime date;

  WorshipServiceModel({
    required this.name,
    required this.songs,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'songs': songs,
    'date': date.toIso8601String(),
  };

  factory WorshipServiceModel.fromMap(Map<dynamic, dynamic> map) {
    return WorshipServiceModel(
      name: map['name'] as String,
      songs: List<String>.from(map['songs'] as List),
      date: DateTime.parse(map['date'] as String),
    );
  }
}

class WorshipServiceStorage {
  static const boxName = 'worship_services';

  static Future<void> init() async => await Hive.openBox(boxName);

  static Box get box => Hive.box(boxName);

  static List<WorshipServiceModel> getAll() {
    return box.values
        .map((e) => WorshipServiceModel.fromMap(Map<dynamic, dynamic>.from(e)))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  static Future<void> save(WorshipServiceModel service) async {
    await box.put(service.name, service.toMap());
  }

  static Future<void> delete(String name) async {
    await box.delete(name);
  }
}
