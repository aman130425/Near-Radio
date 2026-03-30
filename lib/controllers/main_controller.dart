import 'package:get/get.dart';
import 'package:near_radio/core/services/play_store_update_service.dart';

/// Main controller for bottom navigation
class MainController extends GetxController {
  final RxInt currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Android: official Play in-app update (works on closed testing). Not [upgrader].
    PlayStoreUpdateService.checkAndPromptUpdate();
  }

  /// Change page index
  void changePage(int index) {
    currentIndex.value = index;
  }
}
