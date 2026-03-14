import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:near_radio/app/routes/app_pages.dart';
import 'package:near_radio/core/services/storage_service.dart';

/// Onboarding flow. Completing navigates to main and saves state so it won't show again.
class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  static const int totalPages = 3;

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (currentPage.value < totalPages - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      completeOnboarding();
    }
  }

  Future<void> completeOnboarding() async {
    await StorageService.setOnboardingCompleted();
    Get.offAllNamed(Routes.main);
  }
}
