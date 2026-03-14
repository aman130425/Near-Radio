import 'package:get/get.dart';

/// Main controller for bottom navigation
class MainController extends GetxController {
  final RxInt currentIndex = 0.obs;

  /// Change page index
  void changePage(int index) {
    currentIndex.value = index;
  }
}
