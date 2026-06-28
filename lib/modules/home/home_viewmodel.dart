import 'package:get/get.dart';
import '../songlist/songlist_view.dart';
import '../worship_service/worship_service_view.dart';
import '../bible/bible_view.dart';

class HomeViewModel {
  void goToSongList() => Get.to(() => const SonglistView());
  void goToWorshipService() => Get.to(() => const WorshipServiceView());
  void goToBible() => Get.to(() => BibleView());
}
